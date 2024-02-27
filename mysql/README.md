# MySQL 8 install script

### 环境

**Operating System:**  CentOS 7

### 先决条件

1. 安装 git 

    ```bash
    yum install -y  git
    ```

2. 安装 `libaio` 和 `net-tools` 这两个依赖
    
    ```bash
    yum install -y libaio net-tools
    ```

3. clone & install 
    
    ```bash
    git clone  git clone https://github.com/Grebeci/scripts.git

    cd scripts/mysql
    bash -x install_mysql8.sh
    ```

    