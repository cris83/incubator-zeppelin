### Makefile by astroshim <hsshim@nflabs.com>
### This is a makefile for making zeppelin docker images or running zeppelin docker containers.

.PHONY: help build run


# ----------------------------------------------------------------------
# - Define Varialbes 
# ----------------------------------------------------------------------

OS_VERSION=centos:centos6
LOCALREPO_DAT=/opt/localrepo
LOCALREPO_BIN=$(BUILD_HOME)/build/localrepo/bin
REPOSHARE_ENV=$(REPOSHARE_PATH)/$(ZCI_ENV)
BACKEND_CONTAINER_NAME=$(name)

GET_RND_PORT=`$(BUILD_HOME)/build/buildstep.sh getport`
GET_OPT_LINK=`$(BUILD_HOME)/build/buildstep.sh getlink $(REPOSHARE_ENV) $(name)`


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
	docker build --pull=false -t "$1:$(IMAGE_VERSION)" $1/;


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
	if [ -z $(type) ]; then \
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
	-e CONT_NAME=$(BACKEND_CONTAINER_NAME) \
	-p $(ZEPPELIN_HOST_PORT_STANDALONE):$(ZEPPELIN_PORT) \
	-p $(ZEPPELIN_HOST_WEBSOCKET_PORT_STANDALONE):$(ZEPPELIN_WEBSOCKET_PORT) \
	$(GET_OPT_LINK) \
	$(type):$(IMAGE_VERSION) /bin/bash;


# ----------------------------------------------------------------------
# - End of File
# ----------------------------------------------------------------------
