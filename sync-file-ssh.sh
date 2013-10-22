#!/bin/bash
# 方便快速同步hadoop或者hbase文件

if [ -z $1 ]; then
  echo '请指定要同步文件/目录路径，例如:'
  echo './sync-file.sh srcPath destPath'
  echo './sync-file.sh srcPath #同步目的路径与原路径一直。'
  exit 1
fi

if [[ $1 == "/"* ]]; then
  srcpath=$1
else
  srcpath=`pwd`/$1
fi        
         
if [ -z $2 ]; then
  destpath=`dirname $1`
else    
  destpath=$2 
fi           

username=`logname`
    
echo "同步命令：scp -r $srcpath $username@$node:$destpath"
for node in `cat $HADOOP_HOME/etc/hadoop/slaves`
do
  echo "========同步数据: $node========="
  scp -r $srcpath $username@$node:$destpath
done
