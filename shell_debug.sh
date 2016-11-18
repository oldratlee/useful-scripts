#########################################################################
# File Name: debug.sh
# Author: 遇见王斌
# mail: meetbill@163.com
# Created Time: 2016-01-18 11:33:54
#########################################################################
#!/bin/bash
#	_debug_=10    #测试是否正确使用
#	_info_=20     #输出程序信息
#	_notice_=30   #输出重要步骤信息
#	_warn_=40     
#	_error_=50
#	_crit_=60


# debug等级以上的日志
g_LOG_GRADE=/tmp/SHELLWHEEL_grade.log
# debug信息记录日志
g_LOG_DEBUG=/tmp/SHELLWHEEL_debug.log

#-----------------------------------------------------
#debug的提示等级
#_LOG_LEVEL="_info_"
_LOG_LEVEL="10"
#-----------------------------------------------------
#{{{ERRTRAP
function ERRTRAP()
{
	echo "[LINE:$1] Error: Command or function exited with status $?"
}
#}}}
#{{{Logit
function Logit()
{
	_debug_=10
	_info_=20
	_notice_=30
	_warn_=40
	_error_=50
	_crit_=60

	_F_LOG_LEVEL=$1

	##enter the log name or number ,convert it to log level number or name
	function get_loglevel()
	{
		_TMP_LOG_LEVEL=$1
		case ${_TMP_LOG_LEVEL} in
    	    _debug_ | 10 )
                _TMP_LOG_LEVEL_NUM=10
                _TMP_LOG_LEVEL_NAME=_debug_;;
    	    _info_ | 20 )
                _TMP_LOG_LEVEL_NUM=20
                _TMP_LOG_LEVEL_NAME=_info_;;
        	_notice_ | 30 )
                _TMP_LOG_LEVEL_NUM=30
                _TMP_LOG_LEVEL_NAME=_notice_;;
       		_warn_ | 40)
                _TMP_LOG_LEVEL_NUM=40
                _TMP_LOG_LEVEL_NAME=_warn_;;
        	_error_ | 50 )
                _TMP_LOG_LEVEL_NUM=50
                _TMP_LOG_LEVEL_NAME=_error_;;
        	_crit_ | 60 )
                _TMP_LOG_LEVEL_NUM=60
                _TMP_LOG_LEVEL_NAME=_crit_;;
        	*)
                _TMP_LOG_LEVEL_NUM=255
                _TMP_LOG_LEVEL_NAME=wronglevel
                echo "arguments error"
                exit 255;;
		esac

		echo ${_TMP_LOG_LEVEL_NUM} ${_TMP_LOG_LEVEL_NAME}
	}

	#convert
	_F_LOG_LEVEL_NUM=`get_loglevel ${_F_LOG_LEVEL} | awk '{print $1}'`
	_F_LOG_LEVEL_NAME=`get_loglevel ${_F_LOG_LEVEL} | awk '{print $2}'`
	_LOG_LEVEL_NUM=`get_loglevel ${_LOG_LEVEL} | awk '{print $1}'`
	_LOG_LEVEL_NAME=`get_loglevel ${_LOG_LEVEL} | awk '{print $2}'`
	#decide whether to dispaly it or not
	#if the global _LOG_LEVEL config level is less then user configed level
	#then display it

	if [ "${_LOG_LEVEL_NUM}" -le "${_F_LOG_LEVEL_NUM}" ]
	then
		if [ "${_F_LOG_LEVEL_NUM}" = "30" ]
		then
			echo "[notice]=====================================================" 2>&1 | tee -a ${g_LOG_GRADE}
		fi
		#define the output prefix format here.
        local DATE_CUR
		DATE_CUR=`date +%F" "%H:%M`
		if [  "${_F_LOG_LEVEL_NUM}" = "10" ]
		then
			echo -n "${DATE_CUR} LOG_LEVEL[${_F_LOG_LEVEL_NAME}]:" 2>&1 >> ${g_LOG_DEBUG}
        	echo "$2" 2>&1 >> ${g_LOG_DEBUG}
			#we can execute $2 as a function directly.
		else
			echo -n "${DATE_CUR} LOG_LEVEL[${_F_LOG_LEVEL_NAME}]:" 2>&1 | tee -a ${g_LOG_GRADE}
        	echo "$2" 2>&1 | tee -a ${g_LOG_GRADE}
			#we can execute $2 as a function directly.
			#        $2
		fi
	fi
}

#}}}
#{{{Help
function Help(){
	#use $FUNCNAME to show the function name in the output,so we can know that who 
	#output the message
	Logit _crit_ "function[${FUNCNAME}]: help msg"
}
#}}}
#{{{Test
function Test(){
	Logit 10 "line:[${LINENO}]:Function [${FUNCNAME}]10"
	Logit 20 "line:[${LINENO}]:Function [${FUNCNAME}]20"
	Logit 30 "line:[${LINENO}]:Function [${FUNCNAME}]30"
	Logit 40 "line:[${LINENO}]:Function [${FUNCNAME}]40"
	Logit 50 "line:[${LINENO}]:Function [${FUNCNAME}]50"
	Logit 60 "line:[${LINENO}]:Function [${FUNCNAME}]60"
}
#}}}

Test
