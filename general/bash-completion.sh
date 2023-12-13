apt install -y  bash-completion
source /usr/share/bash-completion/bash_completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
#常用alias
echo "alias k=kubectl" >> ~/.bashrc
echo "alias kg='kubectl get'" >> ~/.bashrc
echo "alias kgp='kubectl get pods'" >> ~/.bashrc
echo "alias kgs='kubectl get svc'" >> ~/.bashrc
echo "alias kgn='kubectl get nodes'" >> ~/.bashrc
echo "alias kdp='kubectl describe pods'" >> ~/.bashrc
echo "alias kds='kubectl describe svc'" >> ~/.bashrc
echo "alias kdn='kubectl describe nodes'" >> ~/.bashrc
echo "alias krm='kubectl delete'" >> ~/.bashrc
echo "alias kaf='kubectl apply -f'" >> ~/.bashrc
echo "alias kcf='kubectl create -f'" >> ~/.bashrc
echo "alias kdf='kubectl delete -f'" >> ~/.bashrc
echo "alias kex='kubectl exec -it'" >> ~/.bashrc
echo "alias klo='kubectl logs'" >> ~/.bashrc
#请重新进入shell
echo "please re-enter shell"
