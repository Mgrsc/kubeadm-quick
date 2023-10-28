# Kubernetes Simple Deployment Shell Script 

kubeadm deploy kubernetes

## 用法

1. 首先在`/etc/hosts`中进行配置。
2. 执行`sudo bash init.sh`。
3. 执行`sudo bash debianinit.sh`。
4. 执行`bash kuber.sh`。
5. 然后，根据您的特定要求编辑`kubeadm-config.yaml`。
6. 运行`kubeadm init --config kubeadm-config.yaml`

```bash
注意：
1.在进行配置之前一定要修改节点名称，否则加入节点后kubectl get node无法显示
2.以上四个步骤都应在所有节点上执行。 
3.然后，根据您的具体要求配置控制平面和节点。
4.使用flannel网络插件一定要设置--pod-network-cidr=10.244.0.0/16 设置为flannel分配的子网的范围
5.kubadm设置阿里镜像仓库--image-repository registry.aliyuncs.com/google_containers
6.生成加入节点的示例文件 kubeadm config print join-defaults > kubeadm-config.yaml
7.重新生成加入命令 kubeadm token create --ttl 0 --print-join-command
8.重置集群kubeadm reset && rm -rf /root/.kube && rm -rf /etc/cni/net.d
9.使用docker安装 --cri-socket=unix:///var/run/cri-dockerd.sock
```

以下是 `kubeadm init` 命令的全部参数列表，以表格格式呈现：

| 参数                            | 描述                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| `--config`                      | 使用指定的配置文件进行初始化                                 |
| `--ignore-preflight-errors`     | 忽略预检错误                                                 |
| `--dry-run`                     | 执行初始化步骤的仿真运行，但不进行任何实际更改               |
| `--skip-token-print`            | 不要打印生成的加入令牌                                       |
| `--skip-certificate-key-print`  | 不要打印生成的证书密钥                                       |
| `--experimental-upload-certs`   | 上传证书到集群备份存储库                                     |
| `--certificate-key`             | 使用指定的证书密钥进行初始化                                 |
| `--apiserver-advertise-address` | Kubernetes API Server 监听的 IP 地址                         |
| `--apiserver-bind-port`         | Kubernetes API Server 绑定的端口                             |
| `--apiserver-cert-extra-sans`   | 为 Kubernetes API Server 证书添加额外的 Subject Alternative Names（SANs） |
| `--apiserver-cert-hostname`     | Kubernetes API Server 证书的主机名                           |
| `--upload-certs`                | 上传生成的证书和密钥到备份存储库                             |
| `--node-name`                   | 节点的名称                                                   |
| `--pod-network-cidr`            | 在初始化集群时使用的 Pod 网络 CIDR                           |
| `--service-cidr`                | 在初始化集群时使用的服务 CIDR                                |
| `--service-dns-domain`          | 为服务创建的 DNS 域名                                        |
| `--image-repository`            | 使用指定的镜像仓库                                           |
| `--kubernetes-version`          | 使用指定的 Kubernetes 版本进行初始化                         |
| `--feature-gates`               | 启用指定的特性门户列表                                       |
| `--skip-token-print`            | 不要打印生成的加入令牌                                       |
| `--v` / `-v`                    | 设置日志级别                                                 |
| `--dry-run`                     | 执行初始化步骤的仿真运行，但不进行任何实际更改               |
