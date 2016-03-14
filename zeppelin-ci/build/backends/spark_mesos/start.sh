#!/bin/bash
set -e
source $2/$3
zephome=$1
envhome=$2
envfile=$3
#SPARK_SHARE=/reposhare/$BUILD_TYPE
SPARK_SHARE=/$BUILD_TYPE

# ----------------------------------------------------------------------
# starting mesos
# ----------------------------------------------------------------------
function run_mesos
{
	mesos-master --ip=0.0.0.0 --work_dir=/var/lib/mesos > /dev/null 2>&1 &
	mesos-slave --master=0.0.0.0:5050 --launcher=posix > /dev/null 2>&1 &
	echo "# mesos started"
	echo "1" > /tmp/current_mesos
}

# ----------------------------------------------------------------------
# Setup spark & firefox
# ----------------------------------------------------------------------
SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER
SPARK_BIN=spark-$SPARK_VER-bin-hadoop$HADOOP_VER.tgz
mkdir -p $SPARK_SHARE
tar xzf /reposhare/$SPARK_BIN -C $SPARK_SHARE

export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=7072
export SPARK_WORKER_WEBUI_PORT=8082
export SPARK_LOCAL_IP=`awk 'NR==1 {print $1}' /etc/hosts`
export SPARK_HOME="$SPARK_SHARE/$SPARK_DAT"

## reset hosts
if [ ! -f /tmp/hosts ]; then
    sed '1d' /etc/hosts > /tmp/hosts
    cat /tmp/hosts > /etc/hosts
    rm /tmp/hosts
    echo "$SPARK_LOCAL_IP `hostname`" >> /etc/hosts
fi

if [ ! -f /tmp/current_mesos ]; then
	run_mesos
fi

# ----------------------------------------------------------------------
# Run spark (start & stop)
# ----------------------------------------------------------------------
# create PID dir. test case detect pid file so they can select active spark home dir for test
mkdir -p ${SPARK_HOME}/run
export SPARK_PID_DIR=${SPARK_HOME}/run

cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
echo "export MESOS_NATIVE_JAVA_LIBRARY=/usr/lib/libmesos.so" >> $SPARK_HOME/conf/spark-env.sh

cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
echo "spark.master mesos://`hostname`:5050" >> $SPARK_HOME/conf/spark-defaults.conf
echo "spark.mesos.executor.home /usr/local/spark" >> $SPARK_HOME/conf/spark-defaults.conf

set +e
echo ${SPARK_VER} | grep "^1.[123].[0-9]" > /dev/null
if [ $? -eq 0 ]; then
	echo "${SPARK_VER}" | grep "^1.[12].[0-9]" > /dev/null
	if [ $? -eq 0 ]; then
		SPARK_VER_RANGE="<=1.2"
	else
		SPARK_VER_RANGE="<=1.3"
	fi
else
	SPARK_VER_RANGE=">1.3"
fi

set -e
cd $SPARK_HOME/sbin

##### starting
./start-master.sh

if [ "${SPARK_VER_RANGE}" == "<=1.3" ]||[ "${SPARK_VER_RANGE}" == "<=1.2" ]; then
	./start-slave.sh 1 `hostname`:$SPARK_MASTER_PORT
else
	./start-slave.sh spark://`hostname`:$SPARK_MASTER_PORT
fi

# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
