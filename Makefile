TARGET       = FailCity
ARDUINO_LIBS =
AVRDUDE_ARD_BAUDRATE   = 57600
include config.mk
include Arduino.mk

debug: upload
	./debug.pl $(ARD_PORT)
