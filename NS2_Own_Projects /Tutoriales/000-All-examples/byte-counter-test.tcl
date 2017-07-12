# Tests the ByteCounter TCL class. 
# See $NS/rpi/byte-counter.cc and $NS/tcl/rpi/byte-counter.tcl
#
# Copyright(c) 2002 David Harrison. 
# Distributed for your use according to the terms of the GNU Public License.
# author: David Harrison

source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/byte-counter.tcl

proc finish {} {
  global byte_counter
  if { [$byte_counter set barrivals_] != 13000 } {
    puts "\tFAILED \n\
      Byte counter received [$byte_counter set barrivals_] bytes when \
      it should have received 13000. See byte-counter-test.tcl."
  } else {
    puts "\tPASSED"
  }
  exit -1
}

puts -nonewline "ByteCounter Test:"
set ns [new Simulator]

set n1 [$ns node]
set n2 [$ns node]

$ns duplex-link $n1 $n2 1M 4ms DropTail

# create byte counter.
set byte_counter [new ByteCounter]

# insert byte counter into the link.
set link [$ns link $n1 $n2]
set queue [$link set queue_]
$byte_counter target [$queue target]
$queue target $byte_counter
$byte_counter reset

# create a source that will send a few packets.
# packet is 8000 bits sent with rate 100kbps
# interdeparture time = (8000 / 100)ms = 80ms per packet
create-cbr $n1 $n2 .1 1000 0.0


# run for 1 second. 
# number of packets in 1 second should be (1000ms / 80ms)= 12.5
# The thirteenth packet will pass through the byte counter and will
# finish transmission because the link's bitrate is much higher 
# than the senders bit rate.
$ns at 1 "finish"
$ns run
