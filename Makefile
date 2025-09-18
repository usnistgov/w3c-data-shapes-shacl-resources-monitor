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

PYTHON3 ?= python3

data_shapes_srcdir := dependencies/data-shapes

shacl_resources_srcdir := dependencies/shacl-resources

all: \
  .venv-pre-commit/var/.pre-commit-built.log \
  .git_submodule_init.done.log

# This recipe does not create a file.  It instead guarantees timestamp
# order for later recipes in this file.
$(data_shapes_srcdir)/shacl12-vocabularies/shacl.ttl: \
  .git_submodule_init.done.log
	test -r $@
	touch -c $@

# This recipe does not create a file.  It instead guarantees timestamp
# order for later recipes in this file.
$(shacl_resources_srcdir)/shacl-owl/shacl-owl.ttl: \
  .git_submodule_init.done.log
	test -r $@
	touch -c $@

.PHONY: \
  check-owl-casting \
  check-supply-chain \
  check-supply-chain-submodules

.git_submodule_init.done.log: \
  .gitmodules
	git submodule update \
	  --init
	touch $@

# This virtual environment is meant to be built once and then persist,
# even through 'make clean'.
# If a recipe is written to remove this flag file, it should first run
# `pre-commit uninstall`.
.venv-pre-commit/var/.pre-commit-built.log:
	rm -rf .venv-pre-commit
	test -r .pre-commit-config.yaml \
	  || (echo "ERROR:Makefile:pre-commit is expected to install for this repository, but .pre-commit-config.yaml does not seem to exist." >&2 ; exit 1)
	$(PYTHON3) -m venv \
	  .venv-pre-commit
	source .venv-pre-commit/bin/activate \
	  && pip install \
	    --upgrade \
	    pip \
	    setuptools \
	    wheel
	source .venv-pre-commit/bin/activate \
	  && pip install \
	    pre-commit
	source .venv-pre-commit/bin/activate \
	  && pre-commit install
	mkdir -p \
	  .venv-pre-commit/var
	touch $@

.venv.done.log: \
  requirements.txt
	rm -rf venv
	$(PYTHON3) -m venv \
	  venv
	source venv/bin/activate \
	  && pip install \
	    --upgrade \
	    pip
	source venv/bin/activate \
	  && pip install \
	    --requirement requirements.txt
	touch $@

check: \
  check-owl-casting

# shacl-rdfs-and-owl.ttl is a build dependency to confirm cross-review
# has completed before running a diff.
check-owl-casting: \
  $(shacl_resources_srcdir)/shacl-owl/shacl-owl.ttl \
  shacl-rdfs-and-owl.ttl
	diff \
	  $(shacl_resources_srcdir)/shacl-owl/shacl-owl.ttl \
	  shacl-owl.ttl \
	  || (echo "ERROR:Makefile:The shacl-owl.ttl file in the shacl-resources submodule needs to be refreshed." >&2 ; exit 1)

check-supply-chain: \
  check-supply-chain-submodules

# This recipe checks that the pinned submodule states are the most
# current branch states in the upstream repositories, according to the
# .gitmodules file's `branch` lines.  Note the .gitmodules file will
# typically reference primary branches (`gh-pages` and `main`), but at
# times will reference other branches.
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
	  .*.done.log \
	  shacl-owl-classes.ttl \
	  shacl-owl-properties.ttl \
	  shacl-owl.ttl \
	  shacl-rdfs-and-owl.ttl
	@rm -rf \
	  venv

# This file is a syntax-normalizing tool brought in by this repository's
# pre-commit configuration.
rdf-toolkit.jar: \
  .venv-pre-commit/var/.pre-commit-built.log \
  shacl-owl-ontology.ttl
	# Run pre-commit once to trigger a resource download.
	source .venv-pre-commit/bin/activate \
	  && pre-commit run \
	    shacl-owl-ontology.ttl
	test -r $@
	touch -c $@

# This file houses statements asserting each rdfs:Class defined in the
# SHACL definition-files is an owl:Class.
shacl-owl-classes.ttl: \
  .venv.done.log \
  construct-class.sparql \
  $(data_shapes_srcdir)/shacl12-vocabularies/shacl.ttl
	source venv/bin/activate \
	  && case_sparql_construct \
	    _$@ \
	    construct-class.sparql \
	    $(data_shapes_srcdir)/shacl12-vocabularies/shacl.ttl
	mv _$@ $@

# This recipe intentionally left blank.  This file is a hard-coded
# "header", providing an owl:Ontology definition for shacl-owl.ttl.
shacl-owl-ontology.ttl:

# This file houses statements asserting each rdf:Property defined in the
# SHACL definition-files is an owl:AnnotationProperty.
shacl-owl-properties.ttl: \
  .venv.done.log \
  construct-property.sparql \
  $(data_shapes_srcdir)/shacl12-vocabularies/shacl.ttl
	source venv/bin/activate \
	  && case_sparql_construct \
	    _$@ \
	    construct-property.sparql \
	    $(data_shapes_srcdir)/shacl12-vocabularies/shacl.ttl
	mv _$@ $@

# This file is the combined resource meant to be provided via the
# w3c/shacl-resources repository.  Its build here is normalized to a
# certain syntax style for diff-comparison against the file currently in
# the w3c/shacl-resources repository.
shacl-owl.ttl: \
  rdf-toolkit.jar \
  shacl-owl-classes.ttl \
  shacl-owl-properties.ttl \
  shacl-owl-ontology.ttl
	source venv/bin/activate \
	  && rdfpipe \
	    --output-format turtle \
	    shacl-owl-ontology.ttl \
	    shacl-owl-classes.ttl \
	    shacl-owl-properties.ttl \
	    > ___$@
	@#Add a prefix for XML Schema to decide between "xs:" and "xsd:".
	( \
	  echo '@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .' \
	    && cat ___$@ \
	) > __$@
	rm ___$@
	@#Normalize RDF syntax of generated file.
	java -jar rdf-toolkit.jar \
	  --source __$@ \
	  --source-format turtle \
	  --target _$@ \
	  --target-format turtle
	rm __$@
	mv _$@ $@

# This file combines the SHACL and OWL-casting data into one graph to
# test that classes are both RDFS classes and OWL classes, and
# properties are both RDF properties and OWL annotation properties.
# This has been found useful in the SHACL 1.2 development period for
# catching when properties are proposed, implemented, but later removed.
shacl-rdfs-and-owl.ttl: \
  $(data_shapes_srcdir)/shacl12-vocabularies/shacl.ttl \
  shacl-owl.ttl \
  shapes/sh-shacl-owl.ttl
	source venv/bin/activate \
	  && rdfpipe \
	    $(data_shapes_srcdir)/shacl12-vocabularies/shacl.ttl \
	    shacl-owl.ttl \
	    > _$@
	source venv/bin/activate \
	  && pyshacl \
	    --shacl shapes/sh-shacl-owl.ttl \
	    _$@
	mv _$@ $@
