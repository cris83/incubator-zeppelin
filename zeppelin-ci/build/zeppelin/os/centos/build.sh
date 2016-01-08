#!/bin/bash
set -e
echo "# ZCI-ENV FILE : $ZCI_ENV"
source /reposhare/$ZCI_ENV
SPARK_SHARE=/reposhare

# ----------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------
function spark_yarn_conf		#<- only spark_yarn
{
	home=$1
	item=$2

	if [[ $item == "spark_yarn" ]]; then
		echo "- Copy spark conf ."
		\cp -f /tmp/spark_conf/*  $home/conf/
	fi
}

function first_build_only_spark
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	ITEM=$4
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	rm -rf /zeppelin/interpreter/spark
	mvn package -Pbuild-distr -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -Pscalding -B

	\cp -f /tmp/${ITEM}_zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=$SPARK_SHARE/$ITEM/$SPARK_DAT" >> conf/zeppelin-env.sh
	spark_yarn_conf "$SPARK_SHARE/$ITEM/$SPARK_DAT" $ITEM

	#sleep 3
	mvn verify -Drat.skip=true -Pusing-packaged-distr -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -Pscalding -B
}

function first_build
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	ITEM=$4
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	# install
	mvn package -DskipTests -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -Pscalding -B

	# spark dep
	mvn package -Pbuild-distr -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -Pscalding -B

	\cp -f /tmp/${ITEM}_zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=$SPARK_SHARE/$ITEM/$SPARK_DAT" >> conf/zeppelin-env.sh
	spark_yarn_conf "$SPARK_SHARE/$ITEM/$SPARK_DAT" $ITEM

	#sleep 3
	mvn verify -Drat.skip=true -Pusing-packaged-distr -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -Pscalding -B
}

function skiptests_etc_build
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	ITEM=$4
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	rm -rf /zeppelin/interpreter/spark
	mvn package -DskipTests -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -B -pl 'zeppelin-interpreter,spark-dependencies,spark'

	\cp -f /tmp/${ITEM}_zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=$SPARK_SHARE/$ITEM/$SPARK_DAT" >> conf/zeppelin-env.sh
	spark_yarn_conf "$SPARK_SHARE/$ITEM/$SPARK_DAT" $ITEM

	mvn package -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -B -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-server' -Dtest=org.apache.zeppelin.rest.*Test -DfailIfNoTests=false
}

# only 1.2 and 1.1
function etc_build
{
	SPARK_VER=$1
	SPARK_PRO=$2
	HADOOP_VER=$3
	ITEM=$4
	SPARK_DAT=spark-$SPARK_VER-bin-hadoop$HADOOP_VER

	rm -rf /zeppelin/interpreter/spark
	mvn package -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -Ppyspark -B -pl 'zeppelin-interpreter,spark-dependencies,spark'

	\cp -f /tmp/${ITEM}_zeppelin-env.sh /zeppelin/conf/
	echo "export SPARK_HOME=$SPARK_SHARE/$ITEM/$SPARK_DAT" >> conf/zeppelin-env.sh
	spark_yarn_conf "$SPARK_SHARE/$ITEM/$SPARK_DAT" $ITEM

	mvn package -Pspark-$SPARK_PRO -Phadoop-$HADOOP_VER -B -pl 'zeppelin-interpreter,zeppelin-zengine,zeppelin-server' -Dtest=org.apache.zeppelin.rest.*Test -DfailIfNoTests=false
}


# ----------------------------------------------------------------------
# Init
# ----------------------------------------------------------------------
# firefox 
ln -s /reposhare/firefox/firefox /usr/bin/firefox


# ----------------------------------------------------------------------
# Open XVFB
# ----------------------------------------------------------------------
dbus-uuidgen > /var/lib/dbus/machine-id
Xvfb $DISPLAY -ac -screen 0 1280x1024x24 &


# ----------------------------------------------------------------------
# Cloning zeppelin
# ----------------------------------------------------------------------
git clone -b $BRANCH $REPO /zeppelin
cd /zeppelin


# ----------------------------------------------------------------------
# Build Script
# ----------------------------------------------------------------------
arg_num=0
IFS=' '

read -r -a items <<< "$BUILD_ITEMS"
for ITEM in ${items[@]}
do
	echo "- Set ${ITEM} Buildstep"
	BUILDSTEP_TIMEOUT=300
	BUILDSTEP_DIR=/reposhare/buildstep/$ITEM
	BUILDSTEP_ZEP="${ITEM}_${CONT_NAME}_zeppelin.bs"
	BUILDSTEP_BAK="${ITEM}_${CONT_NAME}_backend.bs"

	/buildstep.sh init $BUILDSTEP_DIR $BUILDSTEP_TIMEOUT
	/buildstep.sh log $BUILDSTEP_ZEP "# Starting, Zeppelin Build ..."

	read -r -a SPARK_VERSIONS <<< "$SPARK_VERSION"
	for i in "${SPARK_VERSIONS[@]}"
	do
		SPARK_VER=$i
		SPARK_PROFILE=${SPARK_VER%.*}
		HADOOP_PROFILE=${HADOOP_VERSION%.*}

		##### Build Step 1
		/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : started $ITEM build spark $SPARK_VER"

		##### Build Step 2 ( build spark 1.x )
		if [[ $ITEM == "spark_standalone" ]]; then

			if [[ $arg_num == 0 ]]; then
				first_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE $ITEM
			else
				if [[ $SPARK_PROFILE == "1.2" || $SPARK_PROFILE == "1.1" ]]; then
					etc_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE $ITEM
				else
					skiptests_etc_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE $ITEM
				fi
			fi

		else

			if [[ $arg_num == 0 ]]; then
				first_build_only_spark $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE $ITEM
			else
				if [[ $SPARK_PROFILE == "1.2" || $SPARK_PROFILE == "1.1" ]]; then
					etc_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE $ITEM
				else
					skiptests_etc_build $SPARK_VER $SPARK_PROFILE $HADOOP_PROFILE $ITEM
				fi
			fi

		fi

		arg_num=1

		##### Build Step 3
		/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : finished $ITEM build spark $SPARK_VER"
		/buildstep.sh log $BUILDSTEP_ZEP "- $BUILDSTEP_ZEP : wait for backend - spark $SPARK_VER"
		/buildstep.sh waitfor $BUILDSTEP_BAK "- $BUILDSTEP_BAK : closed $ITEM backend spark $SPARK_VER"
	done

	echo "- ${ITEM} build done."
	arg_num=0

done
echo "Done!"


# ----------------------------------------------------------------------
# End of Script
# ----------------------------------------------------------------------
