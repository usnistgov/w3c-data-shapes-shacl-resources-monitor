#!/usr/bin/make -f

# This software was developed at the National Institute of Standards
# and Technology by employees of the Federal Government in the course
# of their official duties. Pursuant to Title 17 Section 105 of the
# United States Code, this software is not subject to copyright
# protection within the United States. NIST assumes no responsibility
# whatsoever for its use by other parties, and makes no guarantees,
# expressed or implied, about its quality, reliability, or any other
# characteristic.
#
# We would appreciate acknowledgement if the software is used.

SHELL := /bin/bash

all: \
  .git_submodule_init.done.log

.PHONY: \
  check-supply-chain \
  check-supply-chain-submodules

.git_submodule_init.done.log: \
  .gitmodules
	git submodule update \
	  --init
	touch $@

check: \
  .git_submodule_init.done.log

check-supply-chain: \
  check-supply-chain-submodules

check-supply-chain-submodules: \
  .git_submodule_init.done.log
	git submodule update \
	  --remote
	git diff \
	  --exit-code \
	  --ignore-submodules=dirty \
	  dependencies

clean:
	@rm -f \
	  .*.done.log
