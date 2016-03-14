### Makefile by astroshim <hsshim@nflabs.com>
### This is a makefile for making backend docker images or running backend docker containers.

.PHONY: help build run


# ----------------------------------------------------------------------
# - Define Varialbes 
# ----------------------------------------------------------------------

OS_VERSION=centos:centos6
LOCALREPO_DAT=/opt/localrepo
LOCALREPO_BIN=$(BUILD_HOME)/build/localrepo/bin


# ----------------------------------------------------------------------
# - Host Port
# ----------------------------------------------------------------------

# zeppelin ports
ZEPPELIN_PORT = 8080
ZEPPELIN_WEBSOCKET_PORT = 8081

# spark ports
SPARK_MASTER_PORT = 7077
SPARK_MASTER_WEBUI_PORT = 7072
SPARK_WORKER_WEBUI_PORT = 8082

# mesos ports
MESOS_PORT = 5050
MESOS_HOST_PORT = 25050

# hadoop ports
HDFS_NN_HTTP_PORT = 50070
HDFS_NN_COMMAND_PORT = 9000
HDFS_DN_HTTP_PORT = 50075
HDFS_DN_DATA_PORT = 50010
HDFS_DN_COMMAND_PORT = 50020
YARN_JOB_TRACKER_PORT = 9001
YARN_NN_HTTP_PORT = 8042
YARN_RM_PORT = 8032
YARN_RM_HTTP_PORT = 8088
YARN_RM_RT_PORT = 8031
YARN_RM_SCHEDULER_PORT = 8030
YARN_RM_ADMIN_PORT = 8033


# ----------------------------------------------------------------------
# - Call Function
# ----------------------------------------------------------------------

docker_build = \
	@echo ""; \
	$(LOCALREPO_BIN)/get_confirm_build_dat.sh $(LOCALREPO_BIN) $(ZCI_ENV) $(LOCALREPO_DAT); \
	sed -i -e 's/DOCKER_VAR_OS/$(OS_VERSION)/g' $1/Dockerfile; \
	docker build --pull=false -t "$1:$(IMAGE_VERSION)" $1/


# ----------------------------------------------------------------------
# - Build Options
# ----------------------------------------------------------------------

help:
	@echo
	@echo "  Several choices : "
	@echo
	@echo "   make build type=[type]    to build zeppelin backend docker image of defined type."
	@echo "   make run type=[type]      to run zeppelin backend docker container of defined type."
	@echo 
	@echo "  type : "
	@echo 
	@echo "   spark_standalone          spark standalone cluster backend."
	@echo "   spark_yarn                spark yarn cluster backend."
	@echo "   spark_mesos               mesos cluster backend."
	@echo 

build :
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please.."; \
		exit 1; \
	fi
	$(call docker_build,$(type))

run : 
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please.."; \
		exit 1; \
	fi; \
	\
	$(LOCALREPO_BIN)/get_confirm_build_dat.sh $(LOCALREPO_BIN) $(ZCI_ENV) $(LOCALREPO_DAT);
	\
	if [ $(type) = "spark_standalone" ]; then \
		docker run -id \
		-v $(REPOSHARE_PATH):/reposhare \
		-e BUILD_TYPE=$(type) \
		-e ZCI_ENV=$(ZCI_ENV) \
		-e CONT_NAME=$(name) \
		--name $(name) \
		-h sparkmaster \
		-p $(ZEPPELIN_PORT) \
		-p $(SPARK_MASTER_PORT) \
		-p $(SPARK_MASTER_WEBUI_PORT) \
		-p $(SPARK_WORKER_WEBUI_PORT) \
		-p $(ZEPPELIN_WEBSOCKET_PORT) \
		$(type):$(IMAGE_VERSION) /bin/bash; \
		\
	elif [ $(type) = "spark_yarn" ]; then \
		docker run -id \
		-v $(REPOSHARE_PATH):/reposhare \
		-e BUILD_TYPE=$(type) \
		-e ZCI_ENV=$(ZCI_ENV) \
		-e CONT_NAME=$(name) \
		--name $(name) \
		-h sparkmaster \
		-p $(ZEPPELIN_PORT) \
		-p $(SPARK_MASTER_PORT) \
		-p $(SPARK_MASTER_WEBUI_PORT) \
		-p $(SPARK_WORKER_WEBUI_PORT) \
		-p $(ZEPPELIN_WEBSOCKET_PORT) \
		-p $(HDFS_NN_COMMAND_PORT) \
		-p $(YARN_JOB_TRACKER_PORT) \
		-p $(YARN_RM_HTTP_PORT) \
		-p $(YARN_NN_HTTP_PORT) \
		-p $(YARN_RM_SCHEDULER_PORT) \
		-p $(YARN_RM_RT_PORT) \
		-p $(YARN_RM_PORT) \
		-p $(YARN_RM_ADMIN_PORT) \
		-p $(HDFS_DN_DATA_PORT) \
		-p $(HDFS_DN_COMMAND_PORT) \
		-p $(HDFS_DN_HTTP_PORT) \
		-p $(HDFS_NN_HTTP_PORT) \
		$(type):$(IMAGE_VERSION) /bin/bash; \
		\
	elif [ $(type) = "spark_mesos" ]; then\
		docker run -id \
		-v $(REPOSHARE_PATH):/reposhare \
		-e BUILD_TYPE=$(type) \
		-e ZCI_ENV=$(ZCI_ENV) \
		-e CONT_NAME=$(name) \
		--name $(name) \
		-h sparkmaster \
		-p $(ZEPPELIN_PORT) \
		-p $(SPARK_MASTER_PORT) \
		-p $(SPARK_MASTER_WEBUI_PORT) \
		-p $(SPARK_WORKER_WEBUI_PORT) \
		-p $(ZEPPELIN_WEBSOCKET_PORT) \
		-p $(MESOS_PORT) \
		$(type):$(IMAGE_VERSION) /bin/bash; \
		\
	elif [ $(type) = "new_item" ]; then\
		\
		echo "Please set here backend new_item."; \
		\
	else\
		echo "not found to run backend."; \
	fi


# ----------------------------------------------------
# - New_item Adding Guide
# ----------------------------------------------------
#
# * Common :
#
#	docker run -id \
#	-v $(REPOSHARE_PATH):/reposhare \
#	-e BUILD_TYPE=$(type) \
#	-e ZCI_ENV=$(ZCI_ENV) \
#	-e CONT_NAME=$(name) \
#	--name $(name) \
#	-h sparkmaster \
#	-p $(GET_RND_PORT):$(ZEPPELIN_PORT) \
#	-p $(GET_RND_PORT):$(ZEPPELIN_WEBSOCKET_PORT) \
#   ...
#	$(type):$(IMAGE_VERSION) /bin/bash; \
#
# 
# * Do it yourself setting new_item : Ports
#
#	-p $(GET_RND_PORT):$(NEW_ITEM_PORT) \
#	-p $(GET_RND_PORT):$(...) \
#
# ----------------------------------------------------


# ----------------------------------------------------------------------
# - End of File
# ----------------------------------------------------------------------
