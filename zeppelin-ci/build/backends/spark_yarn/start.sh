#!/bin/bash
set -e
source $2/$3
zephome=$1
envhome=$2
envfile=$3
#SPARK_SHARE=/reposhare/$BUILD_TYPE
SPARK_SHARE=/$BUILD_TYPE
HADOOP_VERSION="${HADOOP_VER}.0"
HADOOP_PROFILE="${HADOOP_VER}"


# ----------------------------------------------------------------------
# - Setup hadoop ( deafults )
# ----------------------------------------------------------------------
function setup_hadoop
{
	echo "# setting hadoop"
	CONTAINER_HADOOP="/hadoop"

	mkdir -p $CONTAINER_HADOOP
	tar xfz /reposhare/hadoop/hadoop-${HADOOP_VERSION}.tar.gz -C $CONTAINER_HADOOP

	if [ -L /usr/local/hadoop ]; then
		rm -f /usr/local/hadoop
	fi
	ln -s ${CONTAINER_HADOOP}/hadoop-${HADOOP_VERSION} /usr/local/hadoop
	: ${HADOOP_PREFIX:=/usr/local/hadoop}

	sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/java/default\nexport HADOOP_PREFIX=/usr/local/hadoop\nexport HADOOP_HOME=/usr/local/hadoop\n:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
	sed -i '/^export HADOOP_CONF_DIR/ s:.*:export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

	mkdir -p $HADOOP_PREFIX/input
	\cp -f $HADOOP_PREFIX/etc/hadoop/*.xml $HADOOP_PREFIX/input

	# add config
	\cp -f /tmp/core-site.xml $HADOOP_PREFIX/etc/hadoop/core-site.xml
	\cp -f /tmp/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
	\cp -f /tmp/mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
	\cp -f /tmp/yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml

	# format of hdfs
	mkdir -p /data/
	chmod 777 /data/
	$HADOOP_PREFIX/bin/hdfs namenode -format

	chmod +x /usr/local/hadoop/etc/hadoop/*-env.sh

	$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

	# installing libraries if any 
	cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

	service sshd start

	echo ${HADOOP_VERSION} > /current_hadoop
}

# ----------------------------------------------------------------------
# - Setup spark for yarn
# ----------------------------------------------------------------------
# setup spark
SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_PROFILE
SPARK_BIN=spark-$SPARK_VER-bin-hadoop$HADOOP_PROFILE.tgz
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

# setup_yarn
if [ ! -f /current_hadoop ]; then
	setup_hadoop
fi

if [ `cat /current_hadoop` = ${HADOOP_VERSION} ]; then
	echo ""
else
	echo "# current hadoop version : ${HADOOP_VERSION}"
	setup_hadoop
fi


# ----------------------------------------------------------------------
# - Run backend
# ----------------------------------------------------------------------
# create PID dir. test case detect pid file so they can select active spark home dir for test
mkdir -p ${SPARK_HOME}/run
export SPARK_PID_DIR=${SPARK_HOME}/run

# starting hadoop
echo "# starting hadoop"
echo spark.yarn.jar hdfs:///spark/spark-assembly-$SPARK_VER-hadoop$HADOOP_VERSION.jar > $SPARK_HOME/conf/spark-defaults.conf
cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

echo "# starting dfs"
$HADOOP_PREFIX/sbin/start-dfs.sh
echo "# starting yarn"
$HADOOP_PREFIX/sbin/start-yarn.sh
$HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-$SPARK_VER-bin-hadoop$HADOOP_PROFILE/lib /spark

# starting spark
#cd $SPARK_HOME/sbin
#./start-master.sh -i $SPARK_LOCAL_IP

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
#./start-master.sh
./start-master.sh -i $SPARK_LOCAL_IP

if [ "${SPARK_VER_RANGE}" == "<=1.3" ]||[ "${SPARK_VER_RANGE}" == "<=1.2" ]; then
	./start-slave.sh 1 `hostname`:$SPARK_MASTER_PORT
else
	./start-slave.sh spark://`hostname`:$SPARK_MASTER_PORT
fi

# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
