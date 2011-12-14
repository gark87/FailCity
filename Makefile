#####################################################################
# Copyright (C) 2011 gark87 <gark87@mail.ru>(FailCity project)
#
# This Makefile takes a lot from Arduino command line tools Makefile
# by
# Copyright (C) 2010 Martin Oldfield <m@mjo.tc>, based on work that is
# Copyright Nicholas Zambetti, David A. Mellis & Hernando Barragan
#
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
######################################################################
# Why did not use 'Arduino command line tools'(ACLT) itself?
# 1) I want to distribute FailCity with all libraries 
#    in this repository, but ACLT does not build sources 
#    in subdirectories
# 2) I had a lot of troubles with building Ethernet* libraries ad-hoc
#    with ACLT 
######################################################################

include config.mk

TARGET = FailCity
AVRDUDE_ARD_BAUDRATE = 57600
SRC_DIRS = FailCity Ethernet EthernetDHCP EthernetDNS
# Everything gets built in here
OBJDIR = build-cli
DEBUG_SCRIPT = ./debug.pl

######################################################################
# Local sources
######################################################################

LOCAL_C_SRCS    = $(shell find $(SRC_DIRS) -name "*.c")
LOCAL_CPP_SRCS  = $(shell find $(SRC_DIRS) -name "*.cpp")
LOCAL_CC_SRCS   = $(shell find $(SRC_DIRS) -name "*.cc")
LOCAL_PDE_SRCS  = $(shell find $(SRC_DIRS) -name "*.pde")
LOCAL_AS_SRCS   = $(shell find $(SRC_DIRS) -name "*.S")
LOCAL_OBJ_FILES = $(patsubst %,%.o, $(LOCAL_C_SRCS) $(LOCAL_CPP_SRCS) \
		$(LOCAL_CC_SRCS) $(LOCAL_PDE_SRCS) \
		$(LOCAL_AS_SRCS))
SRC_INCLUDES    = $(patsubst %,-I%, $(shell find $(SRC_DIRS) -type d))
LOCAL_OBJS      = $(patsubst %,$(OBJDIR)/%,$(LOCAL_OBJ_FILES))

######################################################################
# Some paths
######################################################################

ifneq (ARDUINO_DIR,)

ifndef AVR_TOOLS_PATH
AVR_TOOLS_PATH    = /usr/bin
endif

ifndef ARDUINO_ETC_PATH
ARDUINO_ETC_PATH  = /etc
endif

ifndef AVRDUDE_CONF
AVRDUDE_CONF     = $(ARDUINO_ETC_PATH)/avrdude.conf
endif

ARDUINO_LIB_PATH  = $(ARDUINO_DIR)/hardware/libraries
ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/arduino/cores/arduino

endif

######################################################################
# core sources
######################################################################

ifeq ($(strip $(NO_CORE)),)
ifdef ARDUINO_CORE_PATH
CORE_C_SRCS     = $(wildcard $(ARDUINO_CORE_PATH)/*.c)
CORE_CPP_SRCS   = $(wildcard $(ARDUINO_CORE_PATH)/*.cpp)
CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.o) $(CORE_CPP_SRCS:.cpp=.o)
CORE_OBJS       = $(patsubst $(ARDUINO_CORE_PATH)/%,  \
			$(OBJDIR)/%,$(CORE_OBJ_FILES))
endif
endif

# all the objects!
OBJS            = $(LOCAL_OBJS) $(CORE_OBJS)

######################################################################
# Avrdude
######################################################################

ifndef AVRDUDE
AVRDUDE          = $(AVR_TOOLS_PATH)/avrdude
endif

AVRDUDE_COM_OPTS = -q -V -p $(MCU)
ifdef AVRDUDE_CONF
AVRDUDE_COM_OPTS += -C $(AVRDUDE_CONF)
endif

ifndef AVRDUDE_ARD_PROGRAMMER
AVRDUDE_ARD_PROGRAMMER = stk500v1
endif

ifndef AVRDUDE_ARD_BAUDRATE
AVRDUDE_ARD_BAUDRATE   = 19200
endif

AVRDUDE_ARD_OPTS = -c $(AVRDUDE_ARD_PROGRAMMER) -b $(AVRDUDE_ARD_BAUDRATE) -P $(ARD_PORT) $(AVRDUDE_ARD_EXTRAOPTS)

ifndef ISP_LOCK_FUSE_PRE
ISP_LOCK_FUSE_PRE  = 0x3f
endif

ifndef ISP_LOCK_FUSE_POST
ISP_LOCK_FUSE_POST = 0xcf
endif

ifndef ISP_HIGH_FUSE
ISP_HIGH_FUSE      = 0xdf
endif

ifndef ISP_LOW_FUSE
ISP_LOW_FUSE       = 0xff
endif

ifndef ISP_EXT_FUSE
ISP_EXT_FUSE       = 0x01
endif

ifndef ISP_PROG
ISP_PROG	   = -c stk500v2
endif

AVRDUDE_ISP_OPTS = -P $(ISP_PORT) $(ISP_PROG)

######################################################################
# Explicit targets start here
######################################################################
TARGET_ELF = $(OBJDIR)/$(TARGET).elf
TARGET_HEX = $(OBJDIR)/$(TARGET).hex

all: 		$(OBJDIR) $(TARGET_ELF)

$(OBJDIR):
		mkdir $(OBJDIR)

$(TARGET_ELF): $(OBJS) $(OBJDIR)
		$(CC) $(LDFLAGS) -o $@ $(OBJS) $(SYS_OBJS)

upload:		reset raw_upload

raw_upload:	$(TARGET_HEX)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ARD_OPTS) \
			-U flash:w:$(TARGET_HEX):i

# BSD stty likes -F, but GNU stty likes -f/--file.  Redirecting
# stdin/out appears to work but generates a spurious error on MacOS at
# least. Perhaps it would be better to just do it in perl ?
reset:		
		for STTYF in 'stty --file' 'stty -f' 'stty <' ; \
		  do $$STTYF /dev/tty >/dev/null 2>&1 && break ; \
		done ; \
		$$STTYF $(ARD_PORT)  hupcl ; \
		(sleep 0.1 2>/dev/null || sleep 1) ; \
		$$STTYF $(ARD_PORT) -hupcl 

ispload:	$(TARGET_HEX)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -e \
			-U lock:w:$(ISP_LOCK_FUSE_PRE):m \
			-U hfuse:w:$(ISP_HIGH_FUSE):m \
			-U lfuse:w:$(ISP_LOW_FUSE):m \
			-U efuse:w:$(ISP_EXT_FUSE):m
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -D \
			-U flash:w:$(TARGET_HEX):i
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) \
			-U lock:w:$(ISP_LOCK_FUSE_POST):m

clean:
	$(REMOVE) $(OBJS) $(TARGETS) $(DEP_FILE) $(DEPS)


.PHONY:	all clean depends upload raw_upload reset

debug: upload $(DEBUG_SCRIPT)
	$(DEBUG_SCRIPT) $(ARD_PORT)


# Names of executables
CC      = $(AVR_TOOLS_PATH)/avr-gcc
CXX     = $(AVR_TOOLS_PATH)/avr-g++
OBJCOPY = $(AVR_TOOLS_PATH)/avr-objcopy
OBJDUMP = $(AVR_TOOLS_PATH)/avr-objdump
AR      = $(AVR_TOOLS_PATH)/avr-ar
SIZE    = $(AVR_TOOLS_PATH)/avr-size
NM      = $(AVR_TOOLS_PATH)/avr-nm
REMOVE  = rm -f
MV      = mv -f
CAT     = cat
ECHO    = echo

CPPFLAGS      = -mmcu=$(MCU) -DF_CPU=$(F_CPU) \
			-I. -I$(ARDUINO_CORE_PATH) \
			$(SRC_INCLUDES) -g -Os -w -Wall \
			-ffunction-sections -fdata-sections
CFLAGS        = -std=gnu99
CXXFLAGS      = -fno-exceptions
ASFLAGS       = -mmcu=$(MCU) -I. -x assembler-with-cpp
LDFLAGS       = -mmcu=$(MCU) -lm -Wl,--gc-sections -Os

# Rules for making a CPP file from the main sketch (.cpe)
PDEHEADER     = \\\#include \"WProgram.h\"
# Expand and pick the first port
ARD_PORT      = $(firstword $(wildcard $(ARDUINO_PORT)))

# normal local sources
# .o rules are for objects, .d for dependency tracking
# there seems to be an awful lot of duplication here!!!
 
$(filter %.c.o, $(LOCAL_OBJS)) : $(OBJDIR)/%.c.o : %.c $(OBJDIR)
	mkdir -p `dirname $@`
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(filter %.cpp.o, $(LOCAL_OBJS)) : $(OBJDIR)/%.cpp.o : %.cpp $(OBJDIR)
	mkdir -p `dirname $@`
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# core files
$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.c
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# various object conversions
$(OBJDIR)/%.hex: $(OBJDIR)/%.elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

$(OBJDIR)/%.eep: $(OBJDIR)/%.elf
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
		--change-section-lma .eeprom=0 -O ihex $< $@

$(OBJDIR)/%.lss: $(OBJDIR)/%.elf
	$(OBJDUMP) -h -S $< > $@

$(OBJDIR)/%.sym: $(OBJDIR)/%.elf
	$(NM) -n $< > $@
