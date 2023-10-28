#!/bin/bash


# Install packages using apt-get
install_package() {
  apt-get install -y "$@"  > /dev/null
}

# Download a file from a URL and save it locally
download_file() {
  local url="$1"     # URL of file to download
  local dest="$2"    # Local destination of the file
  if [ ! -f "${dest}" ]; then  # If file does not exist locally, download it
    wget -q "${url}" -O "${dest}"
  fi
}

# Remove a local file
remove_file() {
  local file="$1"   # File to remove
  if [ -f "${file}" ]; then   # If file exists, remove it
    rm -rf "${file}"
    echo "${file} has been deleted!"
  fi
}

check_installed() {
  if [ -f "$1" ]; then
    echo -e "$2 has been installed successfully! \n"
  else
    echo -e "$2 not installed \n"
  fi
}

echo -e "ready!\n"

# Install required packages
install_package jq wget

# Disable swap
swapoff -a > /dev/null
sed -i '/ swap / s/^/#/' /etc/fstab > /dev/null

# Enable kernel modules required for Kubernetes
cat <<EOF | tee /etc/modules-load.d/k8s.conf  > /dev/null
overlay
br_netfilter
EOF
modprobe overlay  > /dev/null
modprobe br_netfilter  > /dev/null

# Enable IP forwarding and netfilter
cat <<EOF | tee /etc/sysctl.d/k8s.conf  > /dev/null
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system  > /dev/null

echo -e "Initialization is done ！！！！ Don't panic this is the first step \n"
echo -e ".\n"


# Download and install containerd
CONTAINERD_TAR=`ls | grep containerd-.*linux-amd64.tar.gz`
if [ "$CONTAINERD_TAR" != "" ]; then    # If containerd tar file exists locally, extract it
  tar xzvf "${CONTAINERD_TAR}" -C /usr/local  > /dev/null
  CONTAINERD_VERSION=$(echo "${CONTAINERD_TAR}" | sed -n 's/containerd-\(.*\)-linux-amd64.tar.gz/\1/p')
else                                       # Otherwise, download the latest release
  LATEST_CONTAINERD=$(curl --silent "https://api.github.com/repos/containerd/containerd/releases/latest" | jq -r .tag_name)
  CONTAINERD_URL="https://github.com/containerd/containerd/releases/download/${LATEST_CONTAINERD}/containerd-${LATEST_CONTAINERD#v}-linux-amd64.tar.gz"
  CONTAINERD_TAR="containerd-${LATEST_CONTAINERD#v}-linux-amd64.tar.gz"
  download_file "${CONTAINERD_URL}" "${CONTAINERD_TAR}"
  tar xzvf "${CONTAINERD_TAR}" -C /usr/local  > /dev/null
  CONTAINERD_VERSION="${LATEST_CONTAINERD#v}"
fi

echo -e ".. \n"
# Install the containerd service file and start containerd
CONTAINERD_SERVICE_DEST="/etc/systemd/system/containerd.service"
if [ -f containerd.service ]; then  
  cp containerd.service "${CONTAINERD_SERVICE_DEST}"
  systemctl daemon-reload
  systemctl enable --now containerd
else                                          # Otherwise, download the service file and start containerd
  CONTAINERD_SERVICE_URL="https://raw.githubusercontent.com/containerd/containerd/main/containerd.service"
  download_file "${CONTAINERD_SERVICE_URL}" "${CONTAINERD_SERVICE_DEST}"
  systemctl daemon-reload
  systemctl enable --now containerd
fi
echo -e "...\n"


# Download and install runc
RUNC_DEST="runc.amd64"
if [ -f "$RUNC_DEST" ]; then
  install -m 755 "$RUNC_DEST" /usr/local/sbin/runc 
else
  LATESTRUNC=$(curl -s https://api.github.com/repos/opencontainers/runc/releases/latest | jq -r .tag_name)
  URLRUNC="https://github.com/opencontainers/runc/releases/download/${LATESTRUNC}/runc.amd64"
  download_file "${URLRUNC}" "${RUNC_DEST}"
  install -m 755 "$RUNC_DEST" /usr/local/sbin/runc
fi
echo -e "....\n"


# Install CNI plugins
CNI_TAR=$(ls cni-plugins-linux-amd64-*.tgz 2>/dev/null)  > /dev/null
if [ -n "$CNI_TAR" ]; then
  LATESTCNI=$(echo "$CNI_TAR" | sed 's/cni-plugins-linux-amd64-\(.*\).tgz/\1/')
  mkdir -p /opt/cni/bin
  tar xzf "cni-plugins-linux-amd64-${LATESTCNI}.tgz" -C /opt/cni/bin   > /dev/null 
else
  LATESTCNI=$(curl -s https://api.github.com/repos/containernetworking/plugins/releases/latest | jq -r .tag_name)    
  URLCNI="https://github.com/containernetworking/plugins/releases/download/${LATESTCNI}/cni-plugins-linux-amd64-${LATESTCNI}.tgz"
  CNI_TAR="cni-plugins-linux-amd64-${LATESTCNI}.tgz"
  download_file "${URLCNI}" "${CNI_TAR}"
  mkdir -p /opt/cni/bin 
  tar xzf "$CNI_TAR" -C /opt/cni/bin    > /dev/null
fi
echo -e ".....\n"
echo ""
check_installed "/usr/local/bin/containerd" "containerd ${CONTAINERD_VERSION} install access"
sleep 1
check_installed "/etc/systemd/system/containerd.service" "containerd service access"
sleep 1
check_installed "/usr/local/sbin/runc" "runc ${LATESTRUNC}"
sleep 1
check_installed "/opt/cni/bin/dhcp" "cni-plugins ${LATESTCNI}"

echo -e "ok！！next！\n"
# Update containerd configuration
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's%registry.k8s.io/pause:3.8%registry.aliyuncs.com/google_containers/pause:3.9%g' /etc/containerd/config.toml
sed -i 's%SystemdCgroup = false%SystemdCgroup = true%g' /etc/containerd/config.toml
systemctl daemon-reload
systemctl restart containerd
sleep 1
echo -e "......\n"

# Create a config for crictl
tee /etc/crictl.yaml > /dev/null <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF
sleep 1
echo -e ".......\n"

# Ask if downloaded files should be removed and take action
echo "Download completed! Do you want to remove downloaded files? (y/n)"
read answer
if [ "$answer" == "y" ] || [ "$answer" == "Y" ]; then
  remove_file "${CONTAINERD_TAR}"
  remove_file "${RUNC_DEST}"
  remove_file "${CNI_TAR}"
  remove_file "containerd.service"
else
  echo -e "Downloaded files are not removed!\n"
fi



echo "containerd ${LATEST_CONTAINERD} installation completed"