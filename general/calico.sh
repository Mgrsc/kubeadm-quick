#Install the Tigera Calico operator and custom resource definitions.
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.3/manifests/tigera-operator.yaml

#download yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.3/manifests/custom-resources.yaml
#Install Calico by creating the necessary custom resource. For more information on configuration options available in this manifest
result=$(kubectl cluster-info dump | grep -m 1 cluster-cidr | awk -F= '{print $2}' | sed 's/["|,]//g')
sed -i "s|cidr:.*|cidr: $result|g" custom-resources.yaml
kubectl create -f custom-resources.yaml
#Remove the taints on the control plane so that you can schedule pods on it.
read -p "remove taint？(y/n): " answer

if [ "$answer" = "y" ]; then
    kubectl taint nodes --all node-role.kubernetes.io/master-
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-
fi

exit 0