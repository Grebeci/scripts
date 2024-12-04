#!/usr/bin/env bash
set -eo pipefail

# 检查是否为root用户
if [ ! "$(whoami)" = "root" ]; then
  echo "Please run this script as root"
  exit;
fi

[ -z "$CLUSTER" ] && export CLUSTER="hadoop102 hadoop103 hadoop104"
export DEBIAN_FRONTEND=noninteractive
bash -c "$(curl -fsSL https://raw.githubusercontent.com/BigDataScholar/BigDataScholar.github.io/master/bigdata/init/functions.sh)"

apt update && apt upgrade -y
apt install -y pdsh

echo "配置互相免密"
ssh-keygen -t rsa  -f ~/.ssh/id_rsa -N "" -q
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

echo "手动运行命令到其他节点"
echo "echo $(cat ~/.ssh/id_rsa.pub) >> /root/.ssh/authorized_keys"
read -p "Press any key to continue... " -n1 -s
sed -i '/^Host/a\ \ \ \ \ \ \ \ StrictHostKeyChecking no' /etc/ssh/ssh_config
xsync /etc/ssh/ssh_config
xsync /etc/hosts
xcall "apt update && apt upgrade -y"

useradd -m -s /bin/bash bigdata
rsync -avz /root/.ssh /home/bigdata/
chown -R bigdata:bigdata /home/bigdata/.ssh
xsync /home/bigdata/.ssh

echo "bigdata ALL=(ALL:ALL) NOPASSWD:ALL" >/etc/sudoers.d/bigdata
xsync /etc/sudoers.d/bigdata