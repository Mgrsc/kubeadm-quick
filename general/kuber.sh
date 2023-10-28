#!/bin/bash
set -eo pipefail
 apt-get update && apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
# Disable swap
 swapoff -a
 sed -i '/swap/ s%/swap%#/swap%g' /etc/fstab

# Load required kernel modules
cat <<EOF |  tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
 modprobe overlay
 modprobe br_netfilter

# Configure kernel parameters
cat <<EOF |  tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
 sysctl --system



mkdir -p /etc/apt/keyrings/
curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg |  gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" |  tee /etc/apt/sources.list.d/kubernetes.list
latest_k8s_response=$(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases/latest)
latest_k8s_version=$(echo "$latest_k8s_response" | jq -r '.tag_name')
echo "The latest Kubernetes version is: $latest_k8s_version"
echo -e "Which version do you want to install? Please specify:"
read k8s_version
apt-get update 
apt-get install -y kubelet=${k8s_version}* kubeadm=${k8s_version}* kubectl=${k8s_version}*

apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet

# sed -i 's/ExecStart=\/usr\/bin\/kubelet/Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=\/etc\/kubernetes\/bootstrap-kubelet.conf --kubeconfig=\/etc\/kubernetes\/kubelet.conf --cgroup-driver=cgroupfs"/' /lib/systemd/system/kubelet.service

#systemctl daemon-reload && systemctl restart kubelet



kubeadm config print init-defaults  > kubeadm-config.yaml

echo "okey!!! please edit kubeadm-config.yaml and run kubeadm init --config kubeadm-config.yaml"