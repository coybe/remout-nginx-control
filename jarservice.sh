#!/bin/bash
#####################################################Environment Setting#######################################################

#1.启动所有jar程序：sh jarservice.sh start all

#2.停止所有jar程序：sh jarservice.sh stop all

#3.重启所有jar程序：sh jarservice.sh restart all

#4.单独启动、停止、重启某个jar程序：把最后面的all替换为某个jar程序的代码即可

#环境变量配置
export JAVA_HOME=/usr/local/java/jdk1.8.0_261
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH


#程序代码数组
APPS=(base device alarm hidden inspect statistics message task system api)

#程序名称数组

NAMES=(基本服务 设备服务 警报服务 隐患服务 巡检服务 统计服务 信息服务 定时任务 系统服务 接口服务)

#jar包数组

JARS=(skynet-base-1.5.jar skynet-device-1.5.jar skynet-alarm-1.5.jar skynet-hidden-1.5.jar skynet-inspect-1.5.jar skynet-statistics-1.5.jar skynet-message-1.5.jar skynet-task-1.5.jar skynet-system-1.5.jar skynet-api-1.5.jar)

#jar包路径数组

#PATHS=(/home/software/deploy/ /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy)
PROJECTDIR="/mnt/skynet/deploy"
JARPATH="/mnt/skynet/deploy/jarupload"

start(){
local APPNAME=
local NAME=
local CLASSNAME=
#local PROJECTDIR=
local command="sh jarservice.sh start"
local cmd2="$1"
local cmd2ok=0
local cnt=0
local okcnt=0
#local C_PID="0"
#for i in `seq 0 22`
echo "---------------------------开始启动服务..."
for(( i=0;i<${#APPS[@]};i++))
do
APPNAME=${APPS[$i]}
NAME=${NAMES[$i]}
CLASSNAME=${JARS[$i]}
#PROJECTDIR=${PATHS[$i]}
if [ "$cmd2" == "all" ] || [ "$cmd2" == "$APPNAME" ]; then
cmd2ok=1
C_PID="0"
cnt=0
#ps -ef | grep "$CLASSNAME" | awk '{print $2}' | while read pid
PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
#do
#C_PID=$(ps --no-heading $pid | wc -l)
#if [ "$C_PID" == "1" ]; then
if [ -n "$PID" ]
then
echo "$APPNAME---$NAME:己经运行,PID=$PID"
#okcnt=$(($okcnt+1))
else
	#报表服务 接口服务依赖前面的服务

	if [ "$APPNAME" == "task" ] ;
	then
	echo "$APPNAME---$NAME:等待启动中..."
	sleep 60s
	fi
cd $PROJECTDIR
cd $APPNAME
#rm -f $PROJECTDIR/nohup.out
command="nohup java -jar $CLASSNAME"
exec $command >> $PROJECTDIR/$APPNAME.log 2>&1 &
#exec $command >> ./log/nohup`date +%Y-%m-%d`.out 2>&1 &
#exec $command >/dev/null 2>&1 &
#ps -ef | grep "$CLASSNAME" | awk '{print $2}' | while read pid
#do
# C_PID=$(ps --no-heading $pid | wc -l)
#done
PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
cnt=0
#while (("$C_PID" == "0"))
while [ -z "$PID" ]
do
if (($cnt==35))
then
echo "$APPNAME---$NAME:$cnt秒内未启动，请检查！"
break
fi
cnt=$(($cnt+1))
sleep 1s
#ps -ef | grep "$CLASSNAME" | awk '{print $2}' | while read pid
#do
# C_PID=$(ps --no-heading $pid | wc -l)
#done
PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
done
	if [ "$APPNAME" == "api" ] ;
	then
	echo "$APPNAME---$NAME:启动中..."
	sleep 30s
	fi
okcnt=$(($okcnt+1))
echo "$APPNAME---$NAME:己经成功启动,PID=$PID"

fi
#done
fi
done
if (($cmd2ok==0))
then
echo "command2: all|system|base|device|alarm|hidden|inspect|statistics|message|task|api"
else
echo "---------------------------本次启动:$okcnt个服务"
fi
/mnt/skynet/deploy/remoute_start_nginx.sh
}

stop(){
#rm -f /mnt/skynet/deploy/*.log
/mnt/skynet/deploy/remoute_kill_nginx.sh
local APPNAME=
local CLASSNAME=
#local PROJECTDIR=
local command="sh jarservice.sh stop"
local cmd2="$1"
local cmd2ok=0
#local C_PID="0"
local okcnt=0
echo "---------------------------开始停止服务..."
for(( i=0;i<${#APPS[@]};i++))
do
APPNAME=${APPS[$i]}
NAME=${NAMES[$i]}
CLASSNAME=${JARS[$i]}
#PROJECTDIR=${PATHS[$i]}
if [ "$cmd2" == "all" ] || [ "$cmd2" == "$APPNAME" ]; then
cmd2ok=1
rm -f /mnt/skynet/deploy/$APPNAME.log
#ps -ef | grep "$CLASSNAME" | awk '{print $2}' | while read PID
PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
#do
#C_PID=$(ps --no-heading $PID | wc -l)
#if [ "$C_PID" == "1" ]; then
if [ -n "$PID" ]
then
echo "$NAME:PID=$PID准备结束"
kill $PID
#C_PID=$(ps --no-heading $PID | wc -l)
#while (("$C_PID" == "1"))
PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
while [ -n "$PID" ]
do
sleep 1s
#C_PID=$(ps --no-heading $PID | wc -l)
PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
done
echo "$NAME:成功结束"


okcnt=$(($okcnt+1))
else
echo "$NAME:未运行"
fi
#停止后，先移除文件，再从jarupload更新文件,请保持jarupload文件为最新
if [ ! -f "$PROJECTDIR/$APPNAME/$CLASSNAME" ]; then
	echo "--------------$NAME:旧的文件不存在"
	echo "$JARPATH"
else
	rm -rf $PROJECTDIR/$APPNAME/$CLASSNAME
	echo "--------------$NAME:旧文件移除成功"
fi


if [ ! -f "$JARPATH/$CLASSNAME" ]; then
	echo "--------------$NAME:文件不存在，请确认$CLASSNAME有被上传到$JARPATH"
	exit
else

\cp -rf $JARPATH/$CLASSNAME $PROJECTDIR/$APPNAME/$CLASSNAME
sleep 1

if [ ! -f "$PROJECTDIR/$APPNAME/$CLASSNAME" ]; then
	echo "--------------$NAME:文件更新失败"
	exit
else
	chmod 777 $PROJECTDIR/$APPNAME/$CLASSNAME
	echo "--------------$NAME:文件更新成功"
fi

fi

#done
fi
done
if (($cmd2ok==0))
then
echo "command2: all|system|base|device|alarm|hidden|inspect|statistics|message|task|api"
else
echo "---------------------------本次共停止:$okcnt个服务"
fi
rm -f  ./*.log
}

case "$1" in
start)
start "$2"
exit 1
;;
stop)
stop "$2"
;;
restart)
stop "$2"
start "$2"
;;
*)
echo "command1: start|stop|restart"
exit 1
;;
esac
