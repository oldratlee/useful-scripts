#!/bin/bash

if [ $# -ne 3 ]; then
  echo '请输入用户名、密码、执行命令，例如：'
  echo './proc.sh username password "ls -la"'
  exit 1
fi

username=$1
password=$2
cmd=$3

for node in `cat $HADOOP_HOME/etc/hadoop/slaves`
do
  echo "==================================$node start======================================"
  expect -c "
    set timeout 2
    spawn ssh $username@$node
    expect {
      \"*password:\" { send \"$password\r\" }
    }
    expect \"#*\"  
    send \"$cmd\r\"  
    send \"exit\r\"
  expect eof"
  echo "==================================$node end========================================"
done
