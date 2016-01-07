### Makefile by astroshim <hsshim@nflabs.com>
### This is a makefile for making zeppelin docker images or running zeppelin docker containers.

.PHONY: help build run


# ----------------------------------------------------------------------
# - Define Varialbes 
# ----------------------------------------------------------------------

LOCALREPO_BIN=$(BUILD_HOME)/build/localrepo/bin
LOCALREPO_DAT=$(BUILD_HOME)/build/localrepo/dat
REPOSHARE_ENV=$(REPOSHARE_PATH)/$(ZCI_ENV)

GET_RND_PORT=`$(BUILD_HOME)/build/buildstep.sh getport`
BACKEND_CONTAINER_NAME=$(name)

OS_VERSION=centos:centos6


# ----------------------------------------------------------------------
# - Host Port
# ----------------------------------------------------------------------

ZEPPELIN_PORT 							= 8080
ZEPPELIN_WEBSOCKET_PORT 				= 8081
ZEPPELIN_HOST_PORT_STANDALONE 			= $(GET_RND_PORT)
ZEPPELIN_HOST_WEBSOCKET_PORT_STANDALONE = $(GET_RND_PORT)


# ----------------------------------------------------------------------
# - Call Function
# ----------------------------------------------------------------------

docker_build = \
	echo ""; \
	source $(REPOSHARE_PATH)/$(ZCI_ENV); \
	$(LOCALREPO_BIN)/get_confirm_build_dat.sh $(REPOSHARE_ENV) $(LOCALREPO_DAT); \
	cp build.sh $1; \
	sed -i -e 's/DOCKER_VAR_OS/$(OS_VERSION)/g' $1/Dockerfile; \
	docker build --pull=false -t zeppelin-"$1:$(IMAGE_VERSION)" $1/;


# ----------------------------------------------------------------------
# - Build Options
# ----------------------------------------------------------------------

help:
	@echo
	@echo "  Several choices : "
	@echo
	@echo "   make build type=[type]    to build zeppelin docker image of defined type."
	@echo "   make run type=[type]      to run zeppelin docker container of defined type."
	@echo 
	@echo "  type : "
	@echo 
	@echo "   spark_standalone          use spark standalone backend."
	@echo "   spark_yarn                use yarn backend."
	@echo "   spark_mesos               use mesos backend."
	@echo 


build : 
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	$(call docker_build,$(type))
	
run : 
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	\
	echo "# Run spark standalone mode zeppelin! "; \
	echo "# Host Port : $(ZEPPELIN_HOST_PORT_STANDALONE) , $(ZEPPELIN_HOST_WEBSOCKET_PORT_STANDALONE)"; \
	\
	docker run --rm -i \
	-v $(REPOSHARE_PATH):/reposhare \
	-e BRANCH=$(BRANCH) \
	-e REPO=$(REPO) \
	-e ZCI_ENV=$(ZCI_ENV) \
	-e BUILD_TYPE=$(type) \
	-e CONT_NAME=$(BACKEND_CONTAINER_NAME) \
	-p $(ZEPPELIN_HOST_PORT_STANDALONE):$(ZEPPELIN_PORT) \
	-p $(ZEPPELIN_HOST_WEBSOCKET_PORT_STANDALONE):$(ZEPPELIN_WEBSOCKET_PORT) \
	--link spark_standalone_$(BACKEND_CONTAINER_NAME):spark_standalone \
	--link spark_mesos_$(BACKEND_CONTAINER_NAME):spark_mesos \
	--link spark_yarn_$(BACKEND_CONTAINER_NAME):spark_yarn \
	zeppelin-$(type):$(IMAGE_VERSION) /bin/bash;


# ----------------------------------------------------------------------
# - End of File
# ----------------------------------------------------------------------
