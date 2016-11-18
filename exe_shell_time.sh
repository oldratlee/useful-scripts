#########################################################################
# File Name: exe_shell_time.sh
# Author: 遇见王斌
# mail: meetbill@163.com
# Created Time: 2016-11-18 09:57:17
#########################################################################
#!/bin/bash
StartDate=$(date);
StartDateSecond=$(date +%s);
echo "start"
#################################
#以下添加执行脚本

#################################

echo -e "\033[42;37m[Start time:     ]\033[0m  ${StartDate}";
echo -e "\033[42;37m[Completion time:]\033[0m  $(date) (Use: $[($(date +%s)-StartDateSecond)/60] minute)";

