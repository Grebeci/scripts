#!/usr/bin/env bash
#
#################################################################
# Description: 该脚本用于获取Hive中所有表的建表语句
# # beeline -u jdbc:hive2://hadoop102:10000 -n bigdata
# Usage: ./export.sh db_name
# Note: 这只是 Demo, 实际使用注意，
#       1， 多个查表SQL可能对Hive-Meta造成压力, 注意使用
#       2， 配置 Beeline 连接信息
#       3， 生成 查询SQL文件：create_tb.sql
#################################################################

# 参数校验
if [ $# -ne 1 ]; then
  echo "Usage: ./export.sh db_name"
  exit 1
fi

db_name=$1

alias beeline='beeline -u jdbc:hive2://hadoop102:10000 -n bigdata'

# 1. 获取该库下所有的表名
beeline --outputformat=csv2 --showHeader=false -e "show tables in ${db_name};" > tables.txt

sql_template="show create table ${db_name}.%s"

# 2. 生成建表语句
mapfile -t tables < tables.txt

printf -v sql_statements "$sql_template; select \";\" ;\n" "${tables[@]}"

echo -e "${sql_statements}" > create_tb.sql

# 3. 执行查询
beeline --silent=true --outputformat=csv2 --showHeader=false -f create_tb.sql > create_tb.txt
