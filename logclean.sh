current_date=`date -d "-1 day" "+%Y%m%d"`  
#echo $current_date

rm_date=`date -d "-8 day" "+%Y%m%d"`  
#echo $rm_date
#程序代码数组
APPS=(base device alarm hidden inspect statistics message task system api)

#程序名称数组

NAMES=(基本服务 设备服务 警报服务 隐患服务 巡检服务 统计服务 消息服务 报表服务 系统服务 接口服务)

PROJECTDIR="/mnt/skynet/deploy/log"
NPROJECTDIR=$PROJECTDIR/old_log/${current_date}
RMPROJECTDIR=$PROJECTDIR/old_log/${rm_date}

# 如果日期目录不存在，创建目录
if [ ! -d "$NPROJECTDIR/" ];then
  	mkdir $NPROJECTDIR
fi

for(( i=0;i<${#APPS[@]};i++))
do
	APPNAME=${APPS[$i]}
	# 如果文件不存在，直接复制日志，如果已有当天日志，则合并日志
	if [ ! -f "$NPROJECTDIR/$APPNAME.log" ];then
		cp -rf $PROJECTDIR/$APPNAME.log   $NPROJECTDIR/$APPNAME.log
	else
		cat $PROJECTDIR/$APPNAME.log >> $NPROJECTDIR/$APPNAME.log
	fi
	# 清空日志输出文件	  
	cat /dev/null > $PROJECTDIR/$APPNAME.log 
done
#清除7天前日志
if [ ! -d "$RMPROJECTDIR/" ];then
  	rm -Rf $RMPROJECTDIR
fi


