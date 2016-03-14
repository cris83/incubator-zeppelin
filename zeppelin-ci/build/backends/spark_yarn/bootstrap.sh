#!/bin/bash
set -e

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

# ----------------------------------------------------------------------
# Setup hadoop ( deafults )
# ----------------------------------------------------------------------
#mkdir -p /tmp/hadoop
#tar xfz /reposhare/hadoop-2.3.0.tar.gz -C /tmp/hadoop
#RUN ln -s /tmp/hadoop/hadoop* /usr/local/hadoop

mkdir -p /reposhare/hadoop
tar xfz /reposhare/hadoop/hadoop-2.3.0.tar.gz
RUN ln -s /tmp/hadoop/hadoop* /usr/local/hadoop

: ${HADOOP_PREFIX:=/usr/local/hadoop}
$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

# installing libraries if any 
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
