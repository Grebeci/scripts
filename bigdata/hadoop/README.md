aliyun-install-hadoop3.sh
阿里云一键搭集群

- 前期准备
  - 阿里云三台机器
  - 配置ip到hostname映射
  - 新建一个用户配置，配置该用户的超级管理员权限
  - 配置所有节点相互免密登录, root用户和一般用户都需要
  - 其他依赖：
    ```bash
    sudo yum install -y epel-release
    sudo yum install -y psmisc nc net-tools rsync vim lrzsz ntp libzstd openssl-static libaio pv pdsh python3-devel
    sudo pip3 install request****  
    ```
- 额外准备
  - 阿里云对象存储 OSS，安装包