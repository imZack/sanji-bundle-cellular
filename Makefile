NAME    = $(shell cat bundle.json | sed -n 's/"name"//p' | tr -d '", :')
VERSION = $(shell cat bundle.json | sed -n 's/"version"//p' | tr -d '", :')

PROJECT = sanji-bundle-$(NAME)

DISTDIR = $(PROJECT)-$(VERSION)
ARCHIVE = $(CURDIR)/$(DISTDIR).tar.gz

SANJI_VER   ?= 1.0
INSTALL_DIR = $(DESTDIR)/usr/lib/sanji-$(SANJI_VER)/$(NAME)
STAGING_DIR = $(CURDIR)/staging
PROJECT_STAGING_DIR = $(STAGING_DIR)/$(DISTDIR)

TARGET_FILES = \
	LICENSE \
	bundle.json \
	requirements.txt \
	index.py \
	cellular_utility/__init__.py \
	cellular_utility/cell_mgmt.py \
	cellular_utility/event.py \
	cellular_utility/management.py \
	cellular_utility/vnstat.py \
	data/cellular.json.factory

DIST_FILES= \
	$(TARGET_FILES) \
	README.md \
	Makefile \
	tests/__init__.py \
	tests/requirements.txt \
	tests/test_index.py \
	cellular_utility/tests/__init__.py \
	cellular_utility/tests/test_cell_mgmt.py

INSTALL_FILES=$(addprefix $(INSTALL_DIR)/,$(TARGET_FILES))
STAGING_FILES=$(addprefix $(PROJECT_STAGING_DIR)/,$(DIST_FILES))


all:

clean:
	rm -rf $(DISTDIR)*.tar.gz $(STAGING_DIR)
	@rm -rf .coverage
	@find ./ -name *.pyc | xargs rm -rf

distclean: clean

pylint:
	flake8 -v --exclude=.git,__init__.py,.env .
test:
	nosetests --with-coverage --cover-erase --cover-package=index,cellular_utility -v

dist: $(ARCHIVE)

$(ARCHIVE): distclean $(STAGING_FILES)
	@mkdir -p $(STAGING_DIR)
	cd $(STAGING_DIR) && \
		tar zcf $@ $(DISTDIR)

$(PROJECT_STAGING_DIR)/%: %
	@mkdir -p $(dir $@)
	@cp -a $< $@

install: $(INSTALL_FILES)

$(INSTALL_DIR)/%: %
	@mkdir -p $(dir $@)
	@cp -a $< $@

uninstall:
	-rm $(addprefix $(INSTALL_DIR)/,$(TARGET_FILES))

.PHONY: clean dist pylint test
