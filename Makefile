#
# Copyright © 2019 Keith Packard <keithp@keithp.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#

SNEK_NO_BUILD_TARGETS = 1
SNEK_ROOT = .

include snek-install.defs

SNEK_OTHEROS?=0
ifeq ($(SNEK_OTHEROS),1)
SNEK_OTHEROS_DIR=$(SNEK_HOSTS)/linux $(SNEK_HOSTS)/windows $(SNEK_HOSTS)/macosx $(SNEK_HOSTS)/zip
endif

SUBDIRS = snekde doc examples $(SNEK_OTHEROS_DIR)

SNEKS = $(SNEK_PORTS)/posix/snek $(FIRMWARE)

all: $(SNEKS)
	+for dir in $(SUBDIRS); do (cd $$dir && make PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)) || exit 1; done

$(SNEKS): FORCE
	+cd `dirname $@` && make PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)

FORCE:

check: all
	+cd test && make $@
	+black --check --exclude 'fail-syntax-.*\.py' .

SHAREFILES = \
	snek.defs \
	$(SNEK_SRC) \
	$(SNEK_EXT_SRC) \
	$(SNEK_RAW_INC) \
	$(SNEK_EXT_INC) \
	$(SNEK_BUILTINS) \
	$(SNEK_EXT_BUILTINS) \
	$(SNEK_ROOT)/snek-gram.ll \
	$(SNEK_ROOT)/snek-builtin.py

IMAGEFILES = \
	snek.svg

DOCFILES = \
	$(IMAGEFILES)

PKGFILES = \
	snek.pc

install: $(SHAREFILES) $(PKGFILES) $(DOCFILES)
	install -d $(DESTDIR)$(SHAREDIR)
	for i in $(SHAREFILES); do install --mode=644 "$$i" $(DESTDIR)$(SHAREDIR) || exit 1; done
	install -d $(DESTDIR)$(PKGCONFIG)
	for i in $(PKGFILES); do install --mode=644 "$$i" $(DESTDIR)$(PKGCONFIG) || exit 1; done
	install -d $(DESTDIR)$(DOCDIR)
	for i in $(DOCFILES); do install --mode=644 "$$i" $(DESTDIR)$(DOCDIR) || exit 1; done
	+for dir in $(SUBDIRS); do (cd $$dir && make PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) $@) || exit 1; done
	+for snek in $(SNEKS); do (cd `dirname $$snek` && make PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) $@) || exit 1; done

upload: $(SNEKS)
	+cd doc && make upload
	+for otheros in $(SNEK_OTHEROS_DIR); do (cd "$$otheros" && make upload); done

otheros: $(SNEKS)
	+cd doc && make
	+for otheros in $(SNEK_OTHEROS_DIR); do (cd "$$otheros" && make); done

snek.pc: snek.pc.in
	$(SNEK_SED) $^ > $@

snek-mu.py:
	find . -name '*.builtin' -print0 | xargs -0 python3 ./snek-builtin.py --mu -o $@

docker:
	docker build -t phsilva/snek .

clean:
	rm -f snek.pc
	+for dir in $(SUBDIRS); do (cd $$dir && make PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) $@); done
	+for snek in $(SNEKS); do (cd `dirname $$snek` && make PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) $@); done
