#!/bin/bash
set -e
source $2/$3
zephome=$1
envhome=$2
envfile=$3
#SPARK_SHARE=/reposhare/$BUILD_TYPE
SPARK_SHARE=/$BUILD_TYPE

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

echo "# SPARK_HOME is ${SPARK_HOME}"

# ----------------------------------------------------------------------
# Run spark (start & stop)
# ----------------------------------------------------------------------
# create PID dir. test case detect pid file so they can select active spark home dir for test
mkdir -p ${SPARK_HOME}/run
export SPARK_PID_DIR=${SPARK_HOME}/run

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

# starting
./start-master.sh

if [ "${SPARK_VER_RANGE}" == "<=1.3" ]||[ "${SPARK_VER_RANGE}" == "<=1.2" ]; then
	./start-slave.sh 1 `hostname`:$SPARK_MASTER_PORT
else
	./start-slave.sh spark://`hostname`:$SPARK_MASTER_PORT
fi

# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
