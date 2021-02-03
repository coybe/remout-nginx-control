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

#JARS=(skynet-base-1.5.jar skynet-device-1.5.jar skynet-alarm-1.5.jar skynet-hidden-1.5.jar skynet-inspect-1.5.jar skynet-statistics-1.5.jar skynet-message-1.5.jar skynet-task-1.5.jar skynet-system-1.5.jar skynet-api-1.5.jar)

#jar包路径数组

#PATHS=(/home/software/deploy/ /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy /home/software/deploy)
PEOJECTVERSION="1.5"
PEOJECTNAME="skynet"
PROJECTDIR="/mnt/skynet/deploy"
JARPATH="/mnt/skynet/deploy/jarupload"

JARBAKPATH="/mnt/skynet/deploy/jarbak"
BOOTFAIL="/mnt/skynet/deploy/bootfail"
DATATIME=`date +%m_%d_%H_%M`
failedflag=0
current_date=`date -d "-1 day" "+%Y%m%d"`  
NPROJECTDIR="/mnt/skynet/deploy/log/old_log/${current_date}"

start(){
	local APPNAME=
	local NAME=
	local CLASSNAME= #local PROJECTDIR=
	local command="sh jarservice.sh start"
	local cmd2="$1"
	local cmd2ok=0
	local cnt=0
	local okcnt=0

	echo "****************************开始启动服务****************************"

	for(( i=0;i<${#APPS[@]};i++))
	do
		APPNAME=${APPS[$i]}
		NAME=${NAMES[$i]}     #CLASSNAME=${JARS[$i]}
		CLASSNAME="$PEOJECTNAME-$APPNAME-$PEOJECTVERSION.jar"      #PROJECTDIR=${PATHS[$i]}
		if [ "$cmd2" == "all" ] || [ "$cmd2" == "$APPNAME" ]; then
			cmd2ok=1
			C_PID="0"
			cnt=0

			PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`

			if [ -n "$PID" ]
			then
				echo "$APPNAME---$NAME:己经运行,PID=$PID"
			else
				cd $PROJECTDIR
				cd $APPNAME
				command="nohup java -jar $CLASSNAME &"
				exec $command >> $PROJECTDIR/log/$APPNAME.log 2>&1 &	 #exec $command >/dev/null 2>&1 &
				echo "$APPNAME---$NAME:开始启动"
				sleep 2s
				startflag=`grep "启动成功" $PROJECTDIR/log/$APPNAME.log`
				cnt=0
				while [ "${startflag:0-6:4}" != "启动成功" ]
				do
					if (($cnt==175))
					then
						let usetime=$(($cnt/5))
						echo "*******************************************************************************************************************************"	
						tput setaf 1; echo "**************************************$APPNAME---$NAME:$usetime秒内未启动，请检查！**************************************************"
						tput setaf 7; echo "*******************************************************************************************************************************"
						failedflag=1
						if [ "$cmd2" != "all" ]; then
							cp -rf $PROJECTDIR/log/$APPNAME.log $BOOTFAIL/$APPNAME
							cp -rf $JARPATH/$CLASSNAME $BOOTFAIL/$CLASSNAME
							cp -rf $JARBAKPATH/$CLASSNAME $JARPATH/$CLASSNAME 
							cp -rf $JARBAKPATH/$CLASSNAME $PROJECTDIR/$APPNAME/CLASSNAME
							

							exec $command >> $PROJECTDIR/log/$APPNAME.log 2>&1 &
						fi
						break
					fi
					cnt=$(($cnt+1))
					sleep 0.2s
					startflag=`grep "启动成功" $PROJECTDIR/log/$APPNAME.log`
					if [ "${startflag:0-6:4}" != "启动成功" ]
					then
						if [[ $cnt -eq 1 ]]
						then
						echo -e "$APPNAME---$NAME:启动中...\c"
						else
							echo -e ".\c"
						fi
					else
						#PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
						#tput setab [1-7] # Set the background colour using ANSI escape
						#tput setaf [1-7] # Set the foreground colour using ANSI escape
						#Num  Colour    #define         R G B
 
						#0    black     COLOR_BLACK     0,0,0
						#1    red       COLOR_RED       1,0,0
						#2    green     COLOR_GREEN     0,1,0
						#3    yellow    COLOR_YELLOW    1,1,0
						#4    blue      COLOR_BLUE      0,0,1
						#5    magenta   COLOR_MAGENTA   1,0,1
						#6    cyan      COLOR_CYAN      0,1,1
						#7    white     COLOR_WHITE     1,1,1
						echo -e "[\c"
						tput setaf 2; echo -e "成功\c"
						tput setaf 7; echo "]"
						okcnt=$(($okcnt+1))	
					fi
				done
			fi
		fi
		if [[ $failedflag -eq 1 ]]
		then
			break
		fi
	done
	if (($cmd2ok==0))
	then
		echo "command2: all|system|base|device|alarm|hidden|inspect|statistics|message|task|api"
	else
		echo "****************************本次启动:$okcnt个服务****************************"
		if [[ "$cmd2" == "all" ]] && [[ $okcnt -lt ${#APPS[@]} ]]; then
			cp -rf $PROJECTDIR/log/*.log $BOOTFAIL/
			cp -rf $JARPATH/*.jar $BOOTFAIL/
			cp -rf $JARBAKPATH/*.jar $JARPATH/
			
			echo -e "-------文件回滚中...\c"
			while ((i=0;i<50))
			do
				echo -e ".\c"
				sleep 0.2s
				let i+=1
			done
			echo " "
		else
			if [[ $failedflag -ne 1 ]]
			then
				echo  " "
				tput setab 2; echo "***********************************************************************************************"
				tput setab 2; echo "*                                                                                             *"
				tput setab 2; echo "*                          恭喜你！版本更新成功！                                             *"
				tput setab 2; echo "*                                                                                             *"
				tput setab 2; echo "***********************************************************************************************"
				tput setab 0; echo -e " \c"
				echo -e " "
				date +%Y_%m_%d_%H_%M >> $JARBAKPATH/*.tt
			fi
		fi

	fi
/mnt/skynet/deploy/remoute_start_nginx.sh
}

stop(){
#rm -f /mnt/skynet/deploy/*.log
/mnt/skynet/deploy/remoute_kill_nginx.sh

	date +%Y_%m_%d_%H_%M >> $BOOTFAIL/*.tt
	local APPNAME=
	local CLASSNAME=
	local command="sh jarservice.sh stop"
	local cmd2="$1"
	local cmd2ok=0
	local okcnt=0

	if [ ! -d "$NPROJECTDIR/" ];then
		mkdir $NPROJECTDIR
	fi
	echo "****************************开始停止服务****************************"
	for(( i=0;i<${#APPS[@]};i++))
	do
		APPNAME=${APPS[$i]}
		NAME=${NAMES[$i]}
		CLASSNAME="$PEOJECTNAME-$APPNAME-$PEOJECTVERSION.jar"

		if [ "$cmd2" == "all" ] || [ "$cmd2" == "$APPNAME" ]
		then
			cmd2ok=1
			if [ ! -f "$NPROJECTDIR/$APPNAME.log" ];then
				cp -rf /mnt/skynet/deploy/log/$APPNAME.log   $NPROJECTDIR/$APPNAME.log
			else
				cat /mnt/skynet/deploy/log/$APPNAME.log >> $NPROJECTDIR/$APPNAME.log
			fi


			rm -f /mnt/skynet/deploy/log/$APPNAME.log

			PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
			if [ -n "$PID" ]
			then
				echo "$NAME:PID=$PID准备结束"
				kill $PID
				PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
				while [ -n "$PID" ]
				do
					sleep 1s
					PID=`ps -ef |grep $(echo $CLASSNAME |awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}'`
				done
				echo "$NAME:成功结束"
				okcnt=$(($okcnt+1))
			else
				echo "$NAME:未运行"
			fi

			if [ ! -f "$PROJECTDIR/$APPNAME/$CLASSNAME" ]
			then
				echo "--------------$NAME:旧的文件不存在"
				echo "$JARPATH"
			else

				if (($failedflag==0))
				then
					rm -rf $JARBAKPATH/$CLASSNAME	
					mv -f $PROJECTDIR/$APPNAME/$CLASSNAME $JARBAKPATH/$CLASSNAME
					echo "--------------$NAME:旧文件备份成功"
				fi
			fi


			if [ ! -f "$JARPATH/$CLASSNAME" ]
			then
				echo "--------------$NAME:文件不存在，请确认$CLASSNAME有被上传到$JARPATH"
				exit
			else
				cp -rf $JARPATH/$CLASSNAME $PROJECTDIR/$APPNAME/$CLASSNAME
				sleep 1

				if [ ! -f "$PROJECTDIR/$APPNAME/$CLASSNAME" ]
				then
					echo "--------------$NAME:文件更新失败"
					exit
				else
					chmod 777 $PROJECTDIR/$APPNAME/$CLASSNAME
					echo "--------------$NAME:文件更新成功"
				fi
			fi
		fi
	done
	if (($cmd2ok==0))
	then
		echo "command2: all|system|base|device|alarm|hidden|inspect|statistics|message|task|api"
	else
		echo "****************************本次共停止:$okcnt个服务****************************"
	fi
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
if [[ $failedflag -eq 1 ]];
then
	stop "$2"
	failedflag=0
	echo "****************************旧版本服务开始启动****************************"
	start "$2"
	tput setab 3; echo "***********************************************************************************************"
	tput setab 3; echo "*                                                                                             *"
	tput setab 3; echo "*                       已启动更新前版本，请查看日志文件，检查此次更新文件！                  *"
	tput setab 3; echo "*                                                                                             *"
	tput setab 3; echo "***********************************************************************************************"
	tput setab 0; echo " "
fi	
;;
*)
echo "command1: start|stop|restart"
exit 1
;;
esac
