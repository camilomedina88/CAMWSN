# Tests the DelayMonitor TCL class's garbage collection. 
# DelayMonitor installs two objects, one at the entry point and one at the
# exit point across which point-to-point delay measurements are made.
# The DelayMonitorIn objects sits at the entry point and inserts 
# a reference to each packet that passes through the entry into a map.  
# Along with the reference to each packet, the map also stores the time 
# that each packet passed through the DelayMonitorIn object.
# As packets depart via the DelayMonitorOut object, the reference is 
# removed from the map, and the difference in time is used to obtain
# statistics.  Packets that are dropped inside the network between the entry
# and exit points never reach the DelayMonitorOut object and thus the 
# associated is not removed from the map.  To deal with this situation, 
# we periodically expire entries in the map-- we call it garbage collection.
# The expiration time is called the garbage_collection_interval_.
# The garbage_collection_interval is set large enough so that packets
# entering the network cannot reasonably experience network delays
# larger than the garbage collection interval. Of course the maximum
# delay that packets can experience is network dependent.  Thus the caller
# may have to adjust the garbage collection interval.
#
# We go through all the trouble of using a table to store entry times in 
# order to avoid using the timestamp field in the packets which may be used
# by intermediate statistics gathering components. 
#
# See $NS/rpi/delay-monitor.cc and $NS/tcl/rpi/delay-monitor.tcl
#
# Copyright(C)2002 David Harrison.
# Distributed according to the terms of the GNU Public License.
#
# author: David Harrison

source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/delay-monitor.tcl

set delay 12          ;# in ms
set bw 1              ;# in Mbps
set pktsize 1000

proc finish {} {
  global dmon bw pktsize delay n_tests_passed n_tests
  set mean [expr 8.0 * $pktsize / ($bw * 1.0e6) * 2 + $delay * .001 * 2]

  #run-nam

  if { $n_tests_passed == $n_tests } {
    # didn't exit on any of the above tests.    
    puts "\tPASSED"
  }
  exit 0
}

puts -nonewline "DelayMonitor Garbage Collection Test :"
set ns [new Simulator]

#use-nam

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n1 $n2 [set bw]M [set delay]ms DropTail
$ns duplex-link $n2 $n3 [set bw]M [set delay]ms DropTail

# orient the links.
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n1 $n2 queuePos 0.5 ;# 0.5 times pi radians from horizontal
$ns duplex-link-op $n2 $n3 queuePos 0.5 ;# 0.5 times pi radians from horizontal

# install error model that drops every nth packet.
#set em [new ErrorModule Fid]

# Option 1: Exponential interdrop times.
# This works.
set errmodel [new ErrorModel]
$errmodel set rate_ 1.0
$errmodel ranvar [new RandomVariable/Uniform]
$errmodel unit pkt

# Option2: Drop every nth packet.  Doesn't work.
#set errmodel [new ErrorModel/Periodic]
#$errmodel unit pkt
#$errmodel set offset_ 2        ;# drop every other packet.   
#$errmodel set default_drop_ 1  ;# drop all in burst.
#$errmodel set drop-target [new Agent/Null]

# insert the error model in link n2--n3.
set lnk [$ns link $n2 $n3]
#$lnk errormodule $em           ;# places the error-model before the queue 
#$lnk errormodule $errmodel
$lnk insert-linkloss $errmodel

#$em insert $errmodel
#$em bind $errmodel 0           ;# binds the error module to flow 0.

# create and install a delay monitor.
DelayMonitorIn set garbage_collection_interval_ 1s
set dmon [new DelayMonitor $n1 $n2 $n2 $n3]

# create a source that will send a few packets.
# packet is 8000 bits sent with rate 1kbps
# interdeparture time = (8000 / 1000)s = 8s per packet
create-cbr $n1 $n3 .001 $pktsize 0.0 0


proc before-garbage-collection {} {
  global dmon n_tests n_tests_passed
  set ns [Simulator instance]

  incr n_tests
  if { [$dmon get-time-map-size] == 1 } {
    incr n_tests_passed
  } else {
    puts "FAIL!! Time map should contain 1 entry."
  }

#  puts "At time [$ns now] the number of packets In dmon is 
#    [$dmon get-time-map-size]"
}

proc after-garbage-collection {} {
  global dmon n_tests n_tests_passed
  set ns [Simulator instance]

  incr n_tests
  if { [$dmon get-time-map-size] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAIL!! Garbage collection did not remove the expired packet."
  }

#  puts "At time [$ns now] the number of packets in dmon is 
#    [$dmon get-time-map-size]"
}

set n_tests 0
set n_tests_passed 0

# before 2 seconds, check to see how many packets are in the delay monitor.
$ns at 1.99 "before-garbage-collection"

# after 2 seconds, check to see how many packets are in the delay monitor.
# There should be zero because it should have been garbage collected at time 2.
$ns at 2.01 "after-garbage-collection"

# run for 2.5 seconds. 
# Only 1 packet will be sent.
$ns at 2.5 "finish"
$ns run

