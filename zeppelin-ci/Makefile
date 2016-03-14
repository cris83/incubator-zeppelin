### Makefile by astroshim <hsshim@nflabs.com>
### This is a makefile for making docker images or running docker containers.

.PHONY: help env build run clean


# -----------------------------------------------------------------------------
# - Define Varialbes
# -----------------------------------------------------------------------------

BUILD_HOME=$(shell pwd)

BUILD_DIR=/tmp/build/$(name)
REPOSHARE_DIR=/tmp/build/reposhare
ZEPPELIN_BUILD_DIR=$(BUILD_DIR)/zeppelin
INTERPRETER_BUILD_DIR=$(BUILD_DIR)/backends

LOCALREPO_DAT=/opt/localrepo
LOCALREPO_BIN=$(BUILD_HOME)/build/localrepo/bin

#ZCI_ENV=$(BUILD_HOME)/zeppelin/zeppelin-ci/build/conf
ZCI_ENV=$(BUILD_HOME)/build/conf
ZCI_ENV_FILE=$(BUILD_HOME)/build/conf/.zci.env

ZEPP_HOME=$(REPOSHARE_DIR)/users/$(name)
USER_ZCI_ENV=$(ZEPP_HOME)/zeppelin/zeppelin-ci/build/conf


# -----------------------------------------------------------------------------
# - Call Funtions
# -----------------------------------------------------------------------------

setup_back = \
	mkdir -p $(INTERPRETER_BUILD_DIR); \
	rm -rf $(INTERPRETER_BUILD_DIR)/$(item); \
	\
	if [ -f build/backends/Makefile ] && [ -d build/backends/$(item) ]; then \
		cp -f build/backends/Makefile $(INTERPRETER_BUILD_DIR); \
		cp -rf build/backends/$(item) $(INTERPRETER_BUILD_DIR); \
	else \
		echo ""; echo "* Backends - No such file or directory : $(item)"; \
        $(BUILD_HOME)/build/buildstep.sh putres $(REPOSHARE_DIR) $(name) 1; \
	fi

setup_zepp = \
	mkdir -p $(ZEPPELIN_BUILD_DIR)/os/centos; \
	rm -rf $(ZEPPELIN_BUILD_DIR)/os/centos/$(item); \
	\
	if [ -f build/zeppelin/os/centos/Makefile ] && \
	   [ -f build/zeppelin/os/centos/build.sh ] && \
	   [ -d build/zeppelin/os/centos/$(item)  ]; then \
		cp -f build/zeppelin/os/centos/Makefile $(ZEPPELIN_BUILD_DIR)/os/centos; \
		cp -f build/zeppelin/os/centos/build.sh $(ZEPPELIN_BUILD_DIR)/os/centos; \
		cp -rf build/zeppelin/os/centos/$(item) $(ZEPPELIN_BUILD_DIR)/os/centos; \
	else \
		echo ""; echo "* Zeppelin - No such file or directory : $(item)"; \
        $(BUILD_HOME)/build/buildstep.sh putres $(REPOSHARE_DIR) $(name) 1; \
	fi

run_job =  \
	source $(ZCI_ENV_FILE); \
	for dir in $$(find $(1) -type d); do \
	  ( \
		cd $$dir ; \
		if [ -f Makefile ]; then \
			for t in $$dir/*; do \
			  (if [ -d $$t ]; then \
				if [[ `basename $$t` == $(3) ]]; then \
					cp -f $(BUILD_HOME)/build/buildstep.sh $$t; \
					echo ""; echo -n -e "@ Target Path : $$t\n - "; \
					make $2 -f Makefile \
						type=`basename $$t` \
						name=$(name) \
						BUILD_HOME=$(BUILD_HOME) \
						BUILD_PATH=$$t \
						ZCI_ENV=$(ZCI_ENV) \
						REPOSHARE_PATH=$(REPOSHARE_DIR); \
					$(BUILD_HOME)/build/buildstep.sh putres $(REPOSHARE_DIR) $(name) $$?; \
					echo ""; \
			  	fi; \
			  fi; \
			); done \
		fi; \
	); done	


# -----------------------------------------------------------------------------
# - Build options
# -----------------------------------------------------------------------------

help:
	@echo
	@echo "  Several choices : "
	@echo
	@echo "   make build     to build all docker image."
	@echo "   make run       to run all docker container."
	@echo 
	@echo "   example) "
	@echo "    ]# make build type=backend item=spark_standalone "
	@echo "    ]# make build type=zeppelin item=spark_standalone "
	@echo 
	@echo "  type : "
	@echo 
	@echo "   backend        jobs for backends."
	@echo "   zeppelin       jobs for zeppelin."
	@echo 
	@echo "   sub item : "
	@echo "   examples) "
	@echo "    *              all items in the build system will be ran."
	@echo "    spark_*        all spark cluster will be builded or ran."
	@echo
	@echo "    ]# make run type=backend item=spark_standalone name=[Container Name]"
	@echo "    ]# make run type=zeppelin item=spark_standalone name=[Backend Container Name]"
	@echo "       REPO=[your repository url] BRANCH=[your branch]"
	@echo 

env :
	@build/ciyaml

build : env
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	if [ -z $(item) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	echo "* Build Type     : $(type)"; echo ""; \
	\
	$(LOCALREPO_BIN)/get_build_dat.sh $(LOCALREPO_BIN) $(ZCI_ENV) $(LOCALREPO_DAT); \
	if [ "$(type)" = "backend" ]; then \
		$(call setup_back); \
		$(call run_job,$(INTERPRETER_BUILD_DIR),$@,$(item)) \
	elif [ "$(type)" = "zeppelin" ]; then \
		$(call setup_zepp); \
		$(call run_job,$(ZEPPELIN_BUILD_DIR),$@,$(item)) \
	else \
		echo "no type you want!"; \
		exit 1; \
	fi;

run :
	@if [ -z $(type) ]; then \
		echo "Type \"make help\" to run. please..";\
		exit 1; \
	fi; \
	\
	if [ "$(type)" = "backend" ]; then \
		$(call setup_back); \
		$(call run_job,$(INTERPRETER_BUILD_DIR),$@,$(item)) \
	elif [ "$(type)" = "zeppelin" ]; then \
		$(call setup_zepp); \
		$(call run_job,$(ZEPPELIN_BUILD_DIR),$@,$(item)) \
	else \
		echo "no type you want!"; \
		exit 1; \
	fi;

clean :
	@rm -rf $(REPOSHARE_DIR)


# -----------------------------------------------------------------------------
# - End of File
# -----------------------------------------------------------------------------
