### Makefile by astroshim <hsshim@nflabs.com>
### This is a makefile for making zeppelin docker images or running zeppelin docker containers.

.PHONY: help build run


# ----------------------------------------------------------------------
# - Define Varialbes 
# ----------------------------------------------------------------------

OS_VERSION=centos:centos6
LOCALREPO_DAT=/opt/localrepo
LOCALREPO_BIN=$(BUILD_HOME)/build/localrepo/bin
ZCI_ENV_FILE=$(ZCI_ENV)/.zci.env

BACKEND_CONTAINER_NAME=$(name)
NICKNAME="sparkmaster"


# ----------------------------------------------------------------------
# - Host Port
# ----------------------------------------------------------------------

ZEPPELIN_PORT = 8080
ZEPPELIN_WEBSOCKET_PORT = 8081


# ----------------------------------------------------------------------
# - Call Function
# ----------------------------------------------------------------------

docker_build = \
	echo ""; \
	cp build.sh $1; \
	$(LOCALREPO_BIN)/get_confirm_build_dat.sh $(LOCALREPO_BIN) $(ZCI_ENV) $(LOCALREPO_DAT); \
	sed -i -e 's/DOCKER_VAR_OS/$(OS_VERSION)/g' $1/Dockerfile; \
	docker build --pull=false -t zeppelin-"$1:$(IMAGE_VERSION)" $1


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
		echo "Type \"make help\" to run. please.."; \
		exit 1; \
	fi; \
	$(call docker_build,$(type))
	
run : 
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please.."; \
		exit 1; \
	fi; \
	\
	case $(type) in \
	    spark_standalone | \
	    spark_yarn 		 | \
	    spark_mesos 	 | \
	    new_item ) \
		\
			echo "# Run $(type) mode zeppelin! "; \
			docker run -id \
			-v $(REPOSHARE_PATH):/reposhare \
			-e ZCI_ENV=$(ZCI_ENV) \
			-e BUILD_TYPE=$(type) \
			-e CONT_NAME=$(BACKEND_CONTAINER_NAME) \
			--name zeppelin-$(BACKEND_CONTAINER_NAME) \
			-p $(ZEPPELIN_PORT) \
			-p $(ZEPPELIN_WEBSOCKET_PORT) \
			--link $(BACKEND_CONTAINER_NAME):$(NICKNAME) \
			zeppelin-$(type):$(IMAGE_VERSION) /bin/bash; \
		;; \
		\
		*) \
			echo "not found to run backend."; \
			exit 1; \
		;; \
	esac


# ----------------------------------------------------------------------
# - End of File
# ----------------------------------------------------------------------
