#!/bin/bash
set -e
source $2/$3
zephome=$1
envhome=$2
envfile=$3
#SPARK_SHARE=/reposhare/$BUILD_TYPE
SPARK_SHARE=/$BUILD_TYPE

# ----------------------------------------------------------------------
# Stopping Backend
# ----------------------------------------------------------------------
SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER
export SPARK_HOME="$SPARK_SHARE/$SPARK_DAT"

# create PID dir. test case detect pid file so they can select active spark home dir for test
export SPARK_PID_DIR=${SPARK_HOME}/run

# stopping
cd $SPARK_HOME/sbin
./spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 1
./stop-master.sh

# stopping hadoop
echo "# stopping hadoop"
: ${HADOOP_PREFIX:=/usr/local/hadoop}
$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

cd $HADOOP_PREFIX
$HADOOP_PREFIX/sbin/stop-dfs.sh
$HADOOP_PREFIX/sbin/stop-yarn.sh

# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
