#!/bin/bash
set -e

HOME=$1
ENV_HOME=$2
REPO_HOME=$3
JOB_PATH=${ENV_HOME}/properties
REPOSHARE_PATH=/tmp/build/reposhare


function get_spark
{
	SPARK_VER=$1
	SPARK_BIN=spark-$SPARK_VER-bin-hadoop$HADOOP_VER.tgz

	# download
	if [ ! -f $REPO_HOME/$SPARK_BIN ]; then
		set +e
		echo " - Doesn't exist spark : $REPO_HOME/$SPARK_BIN"
		echo ""
		wget -P $REPO_HOME http://mirror.tcpdiag.net/apache/spark/spark-$SPARK_VER/$SPARK_BIN

		set -e
		if [ ! -f $REPO_HOME/$SPARK_BIN ]; then
			echo " - Retry Downloading..."
			#wget -P $REPO_HOME http://apache.mirror.cdnetworks.com/spark/spark-$SPARK_VER/$SPARK_BIN
			wget -P $REPO_HOME http://archive.apache.org/dist/spark/spark-${SPARK_VER}/$SPARK_BIN
		fi
	fi
}


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

#		echo "# build order : $order_env"
		read -r -a SPARK_VERS <<< "$SPARK_VER"
		for version in "${SPARK_VERS[@]}"
		do
			SPARK_VER=$version
			SPARK_BIN=spark-$SPARK_VER-bin-hadoop$HADOOP_VER.tgz

			get_spark $version
			#if [ ! -f $REPO_HOME/$SPARK_BIN ]; then
			#	$HOME/downloadSpark.sh $SPARK_VER $HADOOP_VER
			#fi

			# setup
			#echo " - Setup : $SPARK_VER";
			if [ ! -f $REPOSHARE_PATH/$SPARK_BIN ]; then
				cp -f $REPO_HOME/$SPARK_BIN $REPOSHARE_PATH/
			fi
		done
	done
done

