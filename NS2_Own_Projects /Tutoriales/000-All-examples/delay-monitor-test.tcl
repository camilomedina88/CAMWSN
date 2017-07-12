# Tests the DelayMonitor TCL class. 
# See $NS/rpi/delay-monitor.cc and $NS/tcl/rpi/delay-monitor.tcl
#
# Copyright(C)2002 David Harrison.
# Distributed according to the terms of the GNU Public License.
#
# author: David Harrison

source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/delay-monitor.tcl

set delay 4          ;# in ms
set bw 1             ;# in Mbps
set pktsize 1000

proc finish {} {
  global dmon bw pktsize delay
  set mean [expr 8.0 * $pktsize / ($bw * 1.0e6) * 2 + $delay * .001 * 2]

  set n_tests 0
  set n_tests_passed 0

  # test number of samples.
  incr n_tests
  if { [$dmon get-n-samples] != 12 } {
    puts "\tFAILED \n\
      DelayMonitor obtained [$dmon get-n-samples] when expected 12."
  } else {
    incr n_tests_passed
  }

  # test mean
  incr n_tests
  if { [$dmon get-mean-delay] > 1.01 * $mean || 
       [$dmon get-mean-delay] < 0.99 * $mean } {
    puts "\tFAILED \n\
      DelayMonitor computed mean delay [$dmon get-mean-delay] seconds when \
      expecting [set mean] seconds. See delay-monitor-test.tcl."
  } else {
    incr n_tests_passed
  } 
    
  # test variance.
  incr n_tests
  if { [$dmon get-delay-variance] > 0.01 } {
    puts "\tFAILED\n\ 
      DelayMonitor computed a delay variance of [$dmon get-delay-variance]
      when expected near zero delay variance."
  } else {
    incr n_tests_passed
  }

  # test standard deviation.
  incr n_tests
  if { [$dmon get-standard-deviation] } {
    puts "\tFAILED\n\
      DelayMonitor computed a standard deviation of 
      [$dmon get-standard-deviation] when standard deviation should be 
      near zero." 
  } else {
    incr n_tests_passed
  }

  # test min-delay
  incr n_tests
  if { [$dmon get-min-delay] > 1.01 * $mean || \
       [$dmon get-min-delay] < 0.99 * $mean } {
    puts "\tFAILED\n\
      DelayMonitor computed a min delay of [$dmon get-min-delay] when
      should be approximately $mean"
    exit -1
  } else {
    incr n_tests_passed
  }

  # test max delay
  incr n_tests
  if { [$dmon get-max-delay] > 1.01 * $mean ||
       [$dmon get-max-delay] < 0.99 * $mean } {
    puts "\tFAILED\n\
      DelayMonitor computed a max delay of [$dmon get-max-delay] when
      should be approximately $mean"
    exit -1
  } else {
    incr n_tests_passed
  }  

  # didn't exit on any of the above tests.    
  if { $n_tests == $n_tests_passed } {
    puts "\tPASSED all $n_tests tests."
  } else {
    puts "\tFAILURE.  Passed only $n_tests_passed out of $n_tests delay-monitor-test.tcl tests."
  } 

  exit 0
}

puts -nonewline "DelayMonitor Test:"
set ns [new Simulator]

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n1 $n2 [set bw]M [set delay]ms DropTail
$ns duplex-link $n2 $n3 [set bw]M [set delay]ms DropTail

# create and install a delay monitor.
set dmon [new DelayMonitor $n1 $n2 $n2 $n3]

# create a source that will send a few packets.
# packet is 8000 bits sent with rate 100kbps
# interdeparture time = (8000 / 100)ms = 80ms per packet
create-cbr $n1 $n3 .1 $pktsize 0.0


# run for 1 second. 
# number of packets in 1 second should be (1000ms / 80ms)= 12.5
# The thirteenth packet will pass through the byte counter and will
# finish transmission because the link's bitrate is much higher 
# than the senders bit rate.
$ns at 1 "finish"
$ns run

