#!/usr/bin/env bash
################################################################################################
# prerequisite
# 选择任意一台机器，配置：
# 1. 集群内所有 ip->host 映射
# 2. 定义 CLUSTER 变量，包含所有集群节点
################################################################################################


set -eo pipefail

# 检查是否为root用户
if [ ! "$(whoami)" = "root" ]; then
  echo "Please run this script as root"
  exit;
fi

[ -z "$CLUSTER" ] && export CLUSTER="hadoop102 hadoop103 hadoop104"
export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade -y
apt install -y pdsh

echo "配置互相免密"
ssh-keygen -t rsa  -f ~/.ssh/id_rsa -N "" -q
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

echo "手动运行命令到其他节点"
echo "echo $(cat ~/.ssh/id_rsa.pub) >> /root/.ssh/authorized_keys"
read -p "Press any key to continue... " -n1 -s
sed -i /StrictHostKeyChecking/d /etc/ssh/ssh_config
sed -i -e '/^Host/a\ \ \ \ \ \ \ \ StrictHostKeyChecking no' /etc/ssh/ssh_config
for host in $CLUSTER; do
  rsync -avz /etc/hosts "$host":/etc/
  rsync -avz /etc/ssh/ssh_config "$host":/etc/ssh/
  rsync -avz /root/.ssh "$host":/root/
done

source <(curl -fsSL https://raw.githubusercontent.com/Grebeci/scripts/refs/heads/main/bigdata/init/functions.sh)
xcall " export DEBIAN_FRONTEND=noninteractive; apt update && apt upgrade -y"

xcall useradd -m -s /bin/bash bigdata
rsync -avz /root/.ssh /home/bigdata/
chown -R bigdata:bigdata /home/bigdata/.ssh
xsync /home/bigdata/.ssh

echo "bigdata ALL=(ALL:ALL) NOPASSWD:ALL" >/etc/sudoers.d/bigdata
xsync /etc/sudoers.d/bigdata