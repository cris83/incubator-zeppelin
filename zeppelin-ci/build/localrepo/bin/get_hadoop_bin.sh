#!/bin/bash
set -e

HOME=$1
ENV_HOME=$2
REPO_HOME=$3
JOB_PATH=${ENV_HOME}/properties
REPOSHARE_PATH=/tmp/build/reposhare
REPOSHARE_HADOOP=$REPOSHARE_PATH/hadoop 

function get_hadoop
{
	HADOOP_VERSION="$1.0"
	if [[ $item == "spark_yarn" ]]; then
		HADOOP_BIN=hadoop-$HADOOP_VERSION.tar.gz
		if [ ! -f $REPO_HOME/$HADOOP_BIN ]; then
			echo " - Doesn't exist -> Downloading hadoop : $REPO_HOME/$HADOOP_BIN"
			echo ""
			wget -P $REPO_HOME https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/$HADOOP_BIN
			#cp -f $REPO_HOME/$HADOOP_BIN $BUILD_PATH/hadoop.tar.gz
		#else
		#	echo " - Already exist : $HADOOP_BIN"
		fi

		if [ ! -f $REPOSHARE_HADOOP/$HADOOP_BIN ]; then
			cp -f $REPO_HOME/$HADOOP_BIN $REPOSHARE_HADOOP
		fi
	fi
}


mkdir -p $REPOSHARE_HADOOP

ls -a ${JOB_PATH}/.job*.env | while read envfile
do
	source ${envfile}

	JOB_ORDERS=""
	case $orders in
		"none"|"NONE")	exit 0					;;
		"all"|"ALL")	JOB_ORDERS=$order_all	;;
		*)				JOB_ORDERS=$orders		;;
	esac

	IFS=' '
	read -r -a ORDER <<< "$JOB_ORDERS"
	for order_env in "${ORDER[@]}"
	do
		source "${ENV_HOME}/${order_env}/.${order_env}.env"
		get_hadoop $HADOOP_VER
	done
done
