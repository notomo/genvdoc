DEPS_SKIP_GENVDOC=1

WORKFLOW_DIR ?= spec/.shared
include $(WORKFLOW_DIR)/neovim-plugin.mk

export REQUIREALL_IGNORE_MODULES:=genvdoc%.test%.example,example

spec/.shared/neovim-plugin.mk:
	git clone https://github.com/notomo/workflow.git --depth 1 spec/.shared
