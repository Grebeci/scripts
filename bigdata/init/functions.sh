#!/usr/bin/env bash

function xcall() {
  [ -z "$CLUSTER" ] && CLUSTER="doris101 doris102 doris103"
  pdsh -R ssh -w "$CLUSTER" "$*" | sort -k1 | awk -F ": " '{if (host!=$1) {host=$1;print ">>>>>>>>>>>>  "host"  <<<<<<<<<<<<"};$1=null;print $0  }'
}
export -f xcall

function xsync() {
    #1. 判断参数个数
    if [ $# -lt 1 ]; then
      echo Not Enough Arguement!
      exit;
    fi
    #2. 遍历所有文件
    for file in $@
    do
      #4. 判断文件是否存在
      if [ -e $file ]
      then
        #5. 获取父目录
        pdir=$(cd -P $(dirname $file); pwd)
        #6. 获取当前文件的名称
        fname=$(basename $file)
        xcall "mkdir -p $pdir"
        xcall "rsync -aq $(hostname):$pdir/$fname $pdir"
      else
        echo $file does not exists!
      fi
    done
}
export -f xsync