#!/bin/bash
###############################
###java hadoop install ########
###############################

# 先在一台上安装，之后同步到所有节点
# 1. 环境准备, env file
# 2. 安装 java
#     解压，配置环境变量，同步到所有本节点
# 3. 安装hadoop
#     解压，配置环境变量，配置四个配置文件，同步到所有节点，格式化 NameNode，启动hdfs，yarn

xcall "killall -9 java" 2>/dev/null

ENV_FILE=/etc/profile.d/my_env.sh
MYUSER=xin
JDK_MIRROR="http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz"
HADOOP_MIROR="https://archive.apache.org/dist/hadoop/common/hadoop-3.1.3/hadoop-3.1.3.tar.gz"
ARCHIVE_DIR="/home/$MYUSER/archive/"
INSTALL_DIR="/home/$MYUSER/lib"
CLUSTER="hadoop100 hadoop101 hadoop102"

# 解压安装包
function install_package() {
    ls "$ARCHIVE_DIR" | grep "$1"| xargs -I{} tar -zxf "$ARCHIVE_DIR"/{} -C "$INSTALL_DIR"
}

# hadoop 配置项快捷添加
function add_site() {
if [ ! -e $1 ]; then
touch $1
cat > $1 << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
</configuration>
EOF
fi
  sed -i "/<name>$2<\/name>/d" $1
  sed -i "/<\/configuration>/i<property><name>$2<\/name><value>$3<\/value><\/property>" $1
}


# env-file
[ -f $ENV_FILE ] || touch $ENV_FILE
sed -i "/CLUSTER/d" $ENV_FILE
cat >> $ENV_FILE << EOF
#CLUSTER
export CLUSTER="$CLUSTER"
EOF

# download files
[ -d $ARCHIVE_DIR ] || mkdir -p "$ARCHIVE_DIR"
[ -d $INSTALL_DIR ]  || mkdir -p "$INSTALL_DIR"
for url in $JDK_MIRROR $HADOOP_MIROR;
do
    wget -P "$ARCHIVE_DIR" --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "$url"
done

# install java
[ -z "$JAVA_HOME" ] && JAVA_HOME="$INSTALL_DIR"/jdk1.8.0_131
xsync $JAVA_HOME
sed -i "/JAVA_HOME/d" $ENV_FILE
cat >>  $ENV_FILE << EOF
#JAVA_HOME
export JAVA_HOME=$JAVA_HOME
export PATH=\$PATH:\$JAVA_HOME/bin
EOF


# install hadoop
#解压
HADOOP_HOME="$INSTALL_DIR"/hadoop
xcall "rm -rf $HADOOP_HOME"
install_package hadoop
mv "$INSTALL_DIR/hadoop-3.1.3" "$HADOOP_HOME"

# 配置环境变量
sed -i "/HADOOP_HOME/d" $ENV_FILE
cat >>  $ENV_FILE << EOF
#HADOOP_HOME
export HADOOP_HOME=$HADOOP_HOME
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
EOF

# hadoop的四个配置文件
NN=hadoop100
RM=hadoop101
SNN=hadoop102


add_site $HADOOP_HOME/etc/hadoop/core-site.xml "fs.defaultFS" "hdfs://$NN:8020"
add_site $HADOOP_HOME/etc/hadoop/core-site.xml "hadoop.tmp.dir" "$HADOOP_HOME/data"
# 下面三个不是必要，但是装hive要
add_site $HADOOP_HOME/etc/hadoop/core-site.xml "hadoop.proxyuser.$MYUSER.hosts" "*"
add_site $HADOOP_HOME/etc/hadoop/core-site.xml "hadoop.proxyuser.$MYUSER.groups" "*"
add_site $HADOOP_HOME/etc/hadoop/core-site.xml "hadoop.http.staticuser.user" "$MYUSER"

add_site $HADOOP_HOME/etc/hadoop/hdfs-site.xml "dfs.namenode.http-address" "$NN:9870"
add_site $HADOOP_HOME/etc/hadoop/hdfs-site.xml "dfs.namenode.secondary.http-address" "$SNN:9868"
#add_site $HADOOP_HOME/etc/hadoop/hdfs-site.xml "dfs.hosts.exclude" "$HADOOP_HOME/etc/hadoop/blacklist"
add_site $HADOOP_HOME/etc/hadoop/hdfs-site.xml "dfs.hosts" "$HADOOP_HOME/etc/hadoop/workers"

add_site $HADOOP_HOME/etc/hadoop/mapred-site.xml "mapreduce.framework.name" "yarn"
add_site $HADOOP_HOME/etc/hadoop/mapred-site.xml "mapreduce.jobhistory.address" "$SNN:10020"
add_site $HADOOP_HOME/etc/hadoop/mapred-site.xml "mapreduce.jobhistory.webapp.address" "$SNN:19888"

add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.nodemanager.aux-services" "mapreduce_shuffle"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.resourcemanager.hostname" "$RM"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.nodemanager.env-whitelist" "JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.scheduler.minimum-allocation-mb" "512"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.scheduler.maximum-allocation-mb" "8192"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.nodemanager.resource.memory-mb" "8192"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.nodemanager.pmem-check-enabled" "false"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.nodemanager.vmem-check-enabled" "false"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.log-aggregation-enable" "true"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.log.server.url" "http://\${yarn.timeline-service.webapp.address}/applicationhistory/logs"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.log-aggregation.retain-seconds" "604800"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.timeline-service.enabled" "true"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.timeline-service.hostname" "\${yarn.resourcemanager.hostname}"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.timeline-service.http-cross-origin.enabled" "true"
add_site $HADOOP_HOME/etc/hadoop/yarn-site.xml "yarn.resourcemanager.system-metrics-publisher.enabled" "true"

cat > $HADOOP_HOME/etc/hadoop/workers << EOF
$NN
$RM
$SNN
EOF


# 同步到所有节点
xsync $ENV_FILE
xsync $HADOOP_HOME
# 初始化NameNode
su - $MYUSER -c "hdfs namenode -format 1>/dev/null 2>&1 &"
xcall 'chown -R xin:xin /home/xin/lib'


