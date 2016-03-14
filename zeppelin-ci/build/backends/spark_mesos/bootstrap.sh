#!/bin/bash
set -e
source /reposhare/$ZCI_ENV

# ----------------------------------------------------------------------
# Init
# ----------------------------------------------------------------------
BUILDSTEP_TIMEOUT=10800          #<- sec ( 3h )
BUILDSTEP_DIR=/reposhare/buildstep/$BUILD_TYPE
BUILDSTEP_ZEP=${CONT_NAME}_zeppelin.bs
BUILDSTEP_BAK=${CONT_NAME}_backend.bs
SPARK_SHARE=/reposhare/$BUILD_TYPE

/buildstep.sh init $BUILDSTEP_DIR $BUILDSTEP_TIMEOUT
/buildstep.sh log $BUILDSTEP_BAK "# Start, backend build ..."

if [ -f $BUILDSTEP_DIR/$BUILDSTEP_ZEP ]; then
    mv $BUILDSTEP_DIR/$BUILDSTEP_ZEP $BUILDSTEP_DIR/.$BUILDSTEP_ZEP.bak
fi


# ----------------------------------------------------------------------
# Setup spark & firefox
# ----------------------------------------------------------------------
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=7072
export SPARK_WORKER_WEBUI_PORT=8082
export SPARK_LOCAL_IP=`awk 'NR==1 {print $1}' /etc/hosts`

sed '1d' /etc/hosts > /tmp/hosts
cat /tmp/hosts > /etc/hosts
rm /tmp/hosts
echo "$SPARK_LOCAL_IP `hostname`" >> /etc/hosts

/buildstep.sh log $BUILDSTEP_BAK "- $BUILDSTEP_BAK : Setup Succeed"


##### starting mesos
mesos-master --ip=0.0.0.0 --work_dir=/var/lib/mesos & > /dev/null
mesos-slave --master=0.0.0.0:5050 --launcher=posix & > /dev/null

# ----------------------------------------------------------------------
# Run spark (start & stop)
# ----------------------------------------------------------------------
#IFS=' ' read -r -a SPARK_VERSIONS <<< "$SPARK_VERSION"
#for i in "${SPARK_VERSIONS[@]}"
while true
do
    ##### Build Step 1
    /buildstep.sh waitfor $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : started $BUILD_TYPE build"
	`cat $HOME/current_spark`

    ##### set spark env
    SPARK_VER=$i
	HADOOP_PRO=${HADOOP_VERSION%.*}
    SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_PRO

    export SPARK_HOME="$SPARK_SHARE/$SPARK_DAT"

	# create PID dir. test case detect pid file so they can select active spark home dir for test
	mkdir -p ${SPARK_HOME}/run
	export SPARK_PID_DIR=${SPARK_HOME}/run

    cd $SPARK_HOME/sbin

	cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
	echo "export MESOS_NATIVE_JAVA_LIBRARY=/usr/lib/libmesos.so" >> $SPARK_HOME/conf/spark-env.sh

	cp $SPARK_HOME/conf/spark-defaults.conf.template $SPARK_HOME/conf/spark-defaults.conf
	echo "spark.master mesos://`hostname`:5050" >> $SPARK_HOME/conf/spark-defaults.conf
	echo "spark.mesos.executor.home /usr/local/spark" >> $SPARK_HOME/conf/spark-defaults.conf

    ##### Build Step 1
    /buildstep.sh waitfor $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : started $BUILD_TYPE build spark $SPARK_VER"
    /buildstep.sh log $BUILDSTEP_BAK "- $BUILDSTEP_BAK : started $BUILD_TYPE backend spark $SPARK_VER"

    ##### starting
    ./start-master.sh

    set +e
    echo $SPARK_VER | grep "^1.[123].[0-9]" > /dev/null
    let ret=$?

    set -e
    if [ $ret -eq 0 ]; then   # spark 1.3 or prior
        ./start-slave.sh 1 `hostname`:$SPARK_MASTER_PORT
    else
        ./start-slave.sh spark://`hostname`:$SPARK_MASTER_PORT
    fi

    ##### Build Step 2
    /buildstep.sh log $BUILDSTEP_BAK "- $BUILDSTEP_BAK : wait for zeppelin - $BUILD_TYPE $SPARK_VER"
    /buildstep.sh waitfor $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : finished $BUILD_TYPE build spark $SPARK_VER"

    ##### stopping spark
    ./spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 1
    ./stop-master.sh

    ##### Build Step 3
    /buildstep.sh log $BUILDSTEP_BAK "- $BUILDSTEP_BAK : closed $BUILD_TYPE backend spark $SPARK_VER"
done


# ----------------------------------------------------------------------
# Tail
# ----------------------------------------------------------------------
CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
	service sshd stop
	/usr/sbin/sshd -D -d
else
	/bin/bash -c "$*"
fi


# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
