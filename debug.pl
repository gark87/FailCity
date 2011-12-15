#!/usr/bin/env perl

use strict;
use warnings;
use IO::Handle;
# Set up the serial port
use Device::SerialPort;
# set SIGQUIT handler
use sigtrap qw(die QUIT);

my $device = shift @ARGV;
my $port = Device::SerialPort->new($device);

# 115200, 81N on the USB ftdi driver
$port->baudrate(115200);
$port->databits(8);
$port->parity("none");
$port->stopbits(1);

STDOUT->autoflush(1);
# print how to quit =)
print "\nUse <Ctrl> + <\\>(QUIT signal) to quit.\n\n";
sleep(2);

while (1) {
  # Poll to see if any data is coming in
  my $char = $port->lookfor();

  # If we get data, then print it
  # Send a number to the arduino
  print "LOG:$char\n" if $char;
} 
