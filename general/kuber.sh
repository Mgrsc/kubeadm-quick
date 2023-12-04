#!/bin/bash
set -eo pipefail
# apt-transport-https 可能是一个虚拟包（dummy package）；如果是的话，你可以跳过安装这个包
apt-get install -y apt-transport-https ca-certificates curl gpg
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

latest_k8s_version=$(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases/latest | jq -r '.tag_name')
echo "The github latest Kubernetes version is: $latest_k8s_version"
echo -e "Which version do you want to install? Please specify:"
read -r k8s_version
k8s_version_short=$(echo "$k8s_version" | cut -d. -f1-2)
sudo mkdir -p /etc/apt/keyrings/
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v${k8s_version_short}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${k8s_version_short}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=${k8s_version}* kubeadm=${k8s_version}* kubectl=${k8s_version}*


apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet


kubeadm config print init-defaults  > kubeadm-config.yaml

echo "okey!!! please edit kubeadm-config.yaml and run kubeadm init --config kubeadm-config.yaml"
