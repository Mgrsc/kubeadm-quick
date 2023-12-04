#!/bin/bash

# 删除当前节点的污点
kubectl taint nodes $master_node $taint_key- 2>/dev/null

# 使用 GitHub API 获取最新版本号
latest_version=$(curl -s "https://api.github.com/repos/kubeedge/kubeedge/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')

if [ -z "$latest_version" ]; then
    echo "获取 kubeedge 最新版本失败！"
    exit 1
fi

# 构建下载链接
download_url="https://github.com/kubeedge/kubeedge/releases/download/$latest_version/keadm-$latest_version-linux-amd64.tar.gz"

# 下载最新版本的 kubeedge
if ! wget "$download_url"; then
    echo "下载 kubeedge 失败！"
    exit 1
fi

# 解压下载的文件
tar -xf keadm-$latest_version-linux-amd64.tar.gz

# 删除压缩包
rm -f keadm-$latest_version-linux-amd64.tar.gz

# 移动 keadm 到 /usr/bin/
mv keadm-$latest_version-linux-amd64/keadm/keadm /usr/bin/

# 删除解压的目录
rm -rf keadm-$latest_version-linux-amd64

# 完成安装
echo "kubeedge 安装完成！"

read -p "确认要安装云侧吗？（按回车继续，输入q退出）" confirmation

if [ "$confirmation" == "q" ]; then
    echo "已取消安装"
    exit 0
fi

read -p "请输入IP地址（例如192.168.30.20）：" ip_address

read -p "请输入版本号（例如v1.15.1）：" version

echo "您输入的IP地址为：$ip_address"
echo "您输入的版本号为：$version"

command="keadm init --kube-config /root/.kube/config --advertise-address=$ip_address --kubeedge-version=$version"
eval $command

if [ $? -eq 0 ]; then
    echo "kubeedge 云侧安装成功！"
else
    echo "kubeedge 云侧安装失败！"
    exit 1
fi

