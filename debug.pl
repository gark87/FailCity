#!/usr/bin/env perl

use strict;
use warnings;
# Set up the serial port
use Device::SerialPort;

my $device = shift @ARGV;
my $port = Device::SerialPort->new($device);

# 115200, 81N on the USB ftdi driver
$port->baudrate(115200);
$port->databits(8);
$port->parity("none");
$port->stopbits(1);

while (1) {
  # Poll to see if any data is coming in
  my $char = $port->lookfor();

  # If we get data, then print it
  # Send a number to the arduino
  print "LOG:$char\n" if $char;
  sleep(1);
} 
