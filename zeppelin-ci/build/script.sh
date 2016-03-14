#!/bin/bash
set -xe
source $2/$3
zephome=$1
envhome=$2
envfile=$3
target="/zeppelin-${SPARK_VER}"
btest="/zeppelin-${SPARK_VER}-test"
#SPARK_SHARE="/reposhare/$BUILD_TYPE"
SPARK_SHARE="/$BUILD_TYPE"
SPARK_DAT=spark-${SPARK_VER}-bin-hadoop${HADOOP_VER}
SPARK_BIN=$SPARK_DAT.tgz

# --------------------------------------------------
# confirm spark binary
# --------------------------------------------------
#if [ ! -d $SPARK_SHARE/$SPARK_DAT ]; then
	mkdir -p $SPARK_SHARE
	tar xfz /reposhare/$SPARK_BIN -C $SPARK_SHARE
#fi

# --------------------------------------------------
# set spark home
# --------------------------------------------------
if [[ $BUILD_TYPE == "spark_yarn" ]]; then
	\cp -f /tmp/spark_conf/*  ${SPARK_SHARE}/${SPARK_DAT}/conf/
fi
\cp -f /tmp/zeppelin-env.sh $target/conf/
echo "export SPARK_HOME=$SPARK_SHARE/$SPARK_DAT" >> $target/conf/zeppelin-env.sh

# --------------------------------------------------
# run scripts
# --------------------------------------------------
#cd $target
if [ -d $btest ]; then
	echo "# exist test source -> remove test sources : $btest"
	rm -rf $btest
fi

\cp -rf $target $btest
cd $btest
$envhome/script.sh

# --------------------------------------------------
# remove source
# --------------------------------------------------
echo "# remove sources"; cd /
rm -rf $target
rm -rf $btest

# --------------------------------------------------
# end of scripts
# --------------------------------------------------
