# Kubernetes Simple Deployment Shell Script for Debian/Ubuntu

kubeadm deploy kubernetes for debian/ubuntu

使用的cgroup为systemd cgroup

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

安装calico可参考[Quickstart for Calico on Kubernetes | Calico Documentation (tigera.io)](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)

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

kubeadm-config.yaml

```yaml
apiVersion: kubeadm.k8s.io/v1beta3  # 使用kubeadm的版本
bootstrapTokens:  # 用于初始化集群的令牌
- groups:
  - system:bootstrappers:kubeadm:default-node-token  # 令牌关联的组
  token: abcdef.0123456789abcdef  # 令牌的值
  ttl: 24h0m0s  # 令牌的有效期
  usages:  # 令牌的使用方式
  - signing
  - authentication
kind: InitConfiguration  # 初始化配置
localAPIEndpoint:  # 本地API端点配置
  advertiseAddress: 1.2.3.4  # 公开的地址
  bindPort: 6443  # 绑定的端口
nodeRegistration:  # 节点注册配置
  criSocket: unix:///var/run/containerd/containerd.sock  # 容器运行时接口的套接字
  imagePullPolicy: IfNotPresent  # 镜像拉取策略
  name: node  # 节点名称
  taints: null  # 节点污点
---
apiServer:  # API服务器配置
  timeoutForControlPlane: 4m0s  # 控制平面的超时时间
apiVersion: kubeadm.k8s.io/v1beta3  # 使用kubeadm的版本
certificatesDir: /etc/kubernetes/pki  # 证书的目录
clusterName: kubernetes  # 集群名称
controllerManager: {}  # 控制器管理器配置
dns: {}  # DNS配置
etcd:  # etcd配置
  local:  # 本地etcd配置
    dataDir: /var/lib/etcd  # 数据目录
imageRepository: registry.k8s.io  # 镜像仓库
kind: ClusterConfiguration  # 集群配置
kubernetesVersion: 1.28.0  # Kubernetes版本
networking:  # 网络配置
  dnsDomain: cluster.local  # DNS域
  serviceSubnet: 10.96.0.0/12  # 服务子网
scheduler: {}  # 调度器配置

```





