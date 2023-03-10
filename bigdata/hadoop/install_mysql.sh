#/bin/bash
set -eu
set -o pipefail

MySQL_REPO="https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm"
[[ $(rpm -qa | grep libaio | wc -l) -ne 0 ]] || (echo "缺少libaio依赖" && exit 1)
[[ $(rpm -qa | grep net-tools | wc -l) -ne 0 ]] || (echo "缺少 net-tools依赖" && exit 1)

function init() {
# stop mysql
service mysql stop 2>/dev/null
service mysqld stop 2>/dev/null
# uninstall mysql 
rpm -qa | grep -i -E mysql\|mariadb | xargs -n1 rpm -e --nodeps
# delete mysql files
rm -rf /var/lib/mysql
rm -rf /usr/lib64/mysql
rm -rf /etc/my.cnf
rm -rf /usr/my.cnf
rm -rf /var/log/mysqld.log
}

function install_mysql8() {
init
# install&start
rpm -Uvh $MySQL_REPO
yum install -y mysql-server
systemctl start mysqld

# init
PASSWORD=$(cat /var/log/mysqld.log | grep password  | awk -F " " '{print $NF}')
mysql -uroot -p"$PASSWORD"   --connect-expired-password --execute="
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Root@cqmyg123';
set global validate_password.policy=LOW;
set global validate_password.length=1;
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
flush privileges;
"
}

# 安装的是mysql 55 无需改密码
function install_mysql5() {
init
# install&start
rpm -Uvh $MySQL_REPO
sed -i '/MySQL 8\.0 Community Server/,/enabled=1/{s/enabled=1/enabled=0/}' mysql-community.repo
sed -i '/MySQL 5\.5 Community Server/,/enabled=0/{s/enabled=0/enabled=1/}' mysql-community.repo
yum install -y mysql-server
systemctl start mysqld
}



if [ "$1" == "mysql5" ];then
    install_mysql5
elif [ "$1" == "mysql8" ];then
    install_mysql8
fi
