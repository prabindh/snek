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

SNEK_ROOT = ../..
SNEK_ATMEGA = $(SNEK_ROOT)/chips/atmega

include $(SNEK_ATMEGA)/snek-atmega.defs

SNEK_LOCAL_VPATH = $(SNEK_ATMEGA)

SNEK_LOCAL_SRC = \
	snek-pow.c \
	snek-duemilanove.c \
	$(SNEK_ATMEGA_SRC)

SNEK_LOCAL_INC = \
	$(SNEK_ATMEGA_INC)

SNEK_LOCAL_BUILTINS = \
	$(SNEK_ATMEGA_BUILTINS) \
	snek-duemilanove.builtin

include $(SNEK_ROOT)/snek-install.defs

SNEK_CFLAGS = $(SNEK_MOST_WARNINGS) $(SNEK_BASE_CFLAGS)

BASE=snek-duemilanove-$(SNEK_VERSION)
ELF=$(BASE).elf
HEX=$(BASE).hex
MAP=$(BASE).map
CC=avr-gcc

OPT=-Os -frename-registers -funsigned-char -fno-jump-tables -mcall-prologues

CFLAGS=$(OPT) -DF_CPU=16000000UL -mmcu=atmega328p -I. -I$(SNEK_LOCAL_VPATH) -g $(SNEK_CFLAGS) -Waddr-space-convert
LDFLAGS=-Wl,-uvfprintf -lprintf_flt -lm \
	-Wl,--defsym -Wl,__TEXT_REGION_LENGTH__=0x8000 \
	-Wl,--defsym -Wl,__DATA_REGION_LENGTH__=0x7a0 \
	-Wl,--defsym -Wl,__EEPROM_REGION_LENGTH__=0x400 \
	-Wl,-Map=$(MAP)

ISP = usbtiny
#ISP = avrisp2

#
# lfuse: 0xff
#	CKDIV8:		1	no divide by 8
#	CKOUT:		1	no clock output
#	SUT1:		1	crystal osc, slow startup
#	SUT0:		1	crystal osc, slow startup
#	CKSEL3:		1	low swing osc, 8-16MHz
#	CKSEL2:		1	low swing osc, 8-16MHz
#	CKSEL1:		1	low swing osc, 8-16MHz
#	CKSEL0:		1	crystal osc
# hfuse:
#	RSTDISBL:	1	reset enabled
#	DWEN:		1	debug wire disabled
#	SPIEN:		0	SPI program enabled
#	WDTON:		1	watch dog disabled
#	EESAVE:		0	EEPROM saved across chip erase
#	BOOTSZ1:	1	256 words
#	BOOTSZ0:	1	256 words
#	BOOTRST:	1	boot to address 0
# efuse:
#	BODLEVEL2	1	brown out 2.5-2.9V
#	BODLEVEL1	0	brown out 2.5-2.9V
#	BODLEVEL0	1	brown out 2.5-2.9V

all: $(HEX) snek-duemilanove-install

$(HEX): $(ELF)
	avr-objcopy -O ihex -R .eeprom $^ $@

$(ELF): $(SNEK_OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@gawk '/__data_load_end/{printf("ROM used: %d bytes\n", strtonum($$1)); }' $(MAP)

snek-duemilanove-install: snek-duemilanove-install.in
	$(SNEK_SED) $^ > $@
	chmod +x $@

set-fuse:
	avrdude -F -V -c $(ISP) -p ATMEGA328P -U lfuse:w:0xff:m
	avrdude -F -V -c $(ISP) -p ATMEGA328P -U hfuse:w:0xd7:m
	avrdude -F -V -c $(ISP) -p ATMEGA328P -U efuse:w:0xfd:m

load: $(HEX) snek-duemilanove-install
	./snek-duemilanove-install -isp $(ISP) -hex $(HEX) load

install: snek-duemilanove-install $(HEX) snek-duemilanove-install.1
	install -d $(DESTDIR)$(BINDIR)
	install snek-duemilanove-install $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(SHAREDIR)
	install -m 0644 $(HEX) $(DESTDIR)$(SHAREDIR)
	install -d $(DESTDIR)$(MANDIR)/man1
	install -m 0644 snek-duemilanove-install.1 $(DESTDIR)$(MANDIR)/man1

clean::
	rm -f *.elf *.hex *.map snek-duemilanove-install
