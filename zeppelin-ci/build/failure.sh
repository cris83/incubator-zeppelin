#!/bin/bash
set -e
source $2/$3
zephome=$1
envhome=$2
envfile=$3
src="/zeppelin-${SPARK_VER}"
src_test="zeppelin-${SPARK_VER}-test"

# run scripts
#echo ""; cd $zephome
#cp -rf /zeppelin-$SPARK_VER  $src-test/zeppelin-$SPARK_VER-test
#cp -rf $src ${src}-${SPARK_VER}-test

home=`cd $zephome;cd ..;pwd`

if [ -d "$home/$src_test" ]; then
	cd $home/$src_test
else
	cd $src
fi

echo -n "Current DIR : "; pwd
$envhome/failure.sh

exit 0
