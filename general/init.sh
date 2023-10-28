#!/bin/bash

# 更新软件源并升级所有包
apt update -y && apt upgrade -y

# 安装常用工具和软件包
apt install wget curl sudo python3 python3-pip -y

# 禁用IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf && sysctl -p

# 修改vim默认配置
find /usr/share/vim -name "defaults.vim" -exec sed -i 's/mouse=a/mouse=""/g' {} \;

# 去掉/root/.bashrc中的#号
sed -i -r '/^#[[:space:]]*(alias|export|umask|eval)/ s/^#//' /root/.bashrc

bash
