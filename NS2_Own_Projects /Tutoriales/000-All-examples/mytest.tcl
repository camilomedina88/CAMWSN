# We can create queues of desired length by manipulating the recevier
# advertised window.  This allows us to test queue length statistics
# gathering
#
# author: David Harrison

source $env(NS)/tcl/rpi/rpi-queue-monitor.tcl
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/graph.tcl

set K 4
set INT 0.1
set bw 1M
set delay 8ms
set pktsize 1000
                                                                                
Queue set limit_ 10000  ;# essentially infinite
Agent/TCP set packetSize_ $pktsize

proc finish {} {
  global INT K ls0 ls1 ls2 ;#qlen_graph
  global n_tests n_tests_passed

  #$qlen_graph display

  incr n_tests
  set ten_percent [$ls0 get-percentile-packet-queue-length 10]
  if { $ten_percent == 9 } { 
    incr n_tests_passed
  } else {
    puts "\nFAILED ls0 10th percentile queue length should be 9, but it is \
      $ten_percent."
  }

  incr n_tests
  set ten_percent [$ls1 get-percentile-packet-queue-length 10]
  if { $ten_percent == 9 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls1 10th percentile queue length should be 9, but it is \
      $ten_percent."
  }

  incr n_tests
  set ten_percent [$ls2 get-percentile-packet-queue-length 10] 
  if { $ten_percent == 9 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls2 10th percentile queue length should be 9, but it is \
      $ten_percent."
  }

  incr n_tests
  set twenty_five_percent [$ls0 get-percentile-packet-queue-length 25] 
  if { $twenty_five_percent == 14 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls0 25th percentile queue length should be 14, but it is \
      $twenty_five_percent."
  }

  incr n_tests
  set twenty_five_percent [$ls1 get-percentile-packet-queue-length 25]
  if { $twenty_five_percent == 14 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls1 25th percentile queue length should be 14, but it is \
      $twenty_five_percent."
  }

  incr n_tests
  set twenty_five_percent [$ls2 get-percentile-packet-queue-length 25]
  if { $twenty_five_percent == 14 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls2 25th percentile queue length should be 14, but it is \
      $twenty_five_percent."
  }

  incr n_tests
  set median [$ls0 get-percentile-packet-queue-length 50]
  if { $median == 19 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls0 median queue length should be 19, but it is \
      $median."
  }

  incr n_tests
  set median [$ls1 get-percentile-packet-queue-length 50]
  if { $median == 19 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls1 median queue length should be 19, but it is \
      $median."
  }

  incr n_tests
  set median [$ls2 get-percentile-packet-queue-length 50]
  if { $median == 19 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls2 median queue length should be 19, but it is \
      $median."
  }

  incr n_tests
  set seventy_five_percent [$ls0 get-percentile-packet-queue-length 75]
  if { $seventy_five_percent == 24 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls0 seventy fifth percentile queue length should be 24, \
      but it is $seventy_five_percent."
  }

  incr n_tests
  set seventy_five_percent [$ls1 get-percentile-packet-queue-length 75]
  if { $seventy_five_percent == 24 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls1 seventy fifth percentile queue length should be 24, \
      but it is $seventy_five_percent."
  }

  incr n_tests
  set seventy_five_percent [$ls2 get-percentile-packet-queue-length 75]
  if { $seventy_five_percent == 24 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls2 seventy fifth percentile queue length should be 24, \
      but it is $seventy_five_percent."
  }

  incr n_tests
  set ninety_percent [$ls0 get-percentile-packet-queue-length 90]
  if { $ninety_percent == 29 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls0 ninetieth percentile queue length should be 29, \
      but it is $ninety_percent."
  }

  incr n_tests
  set ninety_percent [$ls1 get-percentile-packet-queue-length 90]
  if { $ninety_percent == 29 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls1 ninetieth percentile queue length should be 29, \
      but it is $ninety_percent."
  }

  incr n_tests
  set ninety_percent [$ls2 get-percentile-packet-queue-length 90]
  if { $ninety_percent == 29 } {
    incr n_tests_passed
  } else {
    puts "\nFAILED ls2 ninetieth percentile queue length should be 29, \
      but it is $ninety_percent."
  }

  if { $n_tests == $n_tests_passed } {
    puts "\tPASSED all $n_tests tests."
  } else {
    puts "\tFAILURE. Passed only $n_tests_passed out of $n_tests tests."
  }

  exit 0
}


set ns [new Simulator]
set n_tests 0
set n_tests_passed 0

puts -nonewline "RPIQueueMonitor Tests:" 

set qmon [new QueueMonitor/ED/RPI]
incr n_tests
set tenth_percentile \
  [$qmon percentile-in-bytes 10 "rpi-queue-monitor-test.txt"] 
if { $tenth_percentile != 2000 } {
  puts "\nFAILED The 10th percentile in bytes should be 2000 bytes, \
    but it is $tenth_percentile."
} else {
  incr n_tests_passed
}

incr n_tests
set tenth_percentile \
  [$qmon percentile-in-packets 10 "rpi-queue-monitor-test.txt"]
if { $tenth_percentile != 2 } {
  puts "\nFAILED The 10th percentile in packets should be 2 packets, \
    but it is $tenth_percentile."
} else {
  incr n_tests_passed
}

incr n_tests
set median [$qmon percentile-in-bytes 50 "rpi-queue-monitor-test.txt"]
if { $median != 8000 } {
  puts "\nFAILED The median in bytes should be 8000, \
    but it is $median."
} else {
  incr n_tests_passed
}

incr n_tests
set median [$qmon percentile-in-packets 50 "rpi-queue-monitor-test.txt"]
if { $median != 8 } {
  puts "\nFAILED The median in packets should be 8, \
    but it is $median."
} else {
  incr n_tests_passed
}

# Now test percentiles with weighted samples.
incr n_tests
set tenth_percentile \
  [$qmon percentile-in-bytes 10 "rpi-queue-monitor-test2.txt"] 
if { $tenth_percentile != 1000 } {
  puts "\nFAILED The 10th percentile in bytes should be 1000 bytes, \
    but percentile-in-bytes 10 on \"rpi-queue-monitor-test2.txt\" \
    returned $tenth_percentile."
} else {
  incr n_tests_passed
}

incr n_tests
set median [$qmon percentile-in-packets 50 "rpi-queue-monitor-test2.txt"]
if { $median != 6 } {
  puts "\nFAILED The median in packets should be 6, \
    but it is $median."
} else {
  incr n_tests_passed
}

incr n_tests
set top [$qmon percentile-in-packets 100 "rpi-queue-monitor-test2.txt"]
if { $top != 16 } {
  puts "\nFAILED The top in packets should be 16, \
    but percentie-in-packets 100 on \"rpi-queue-monitor-test2.txt\" \
    returned $top."
} else {
  incr n_tests_passed
}

# Instead of asking the queue monitor directly, we now test the interface
# via link-stats.tcl  (Should these tests be in link-stats-test.tcl?)
set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 $bw $delay DropTail
                                                                                
set tcp [$ns create-connection TCP/Reno $n0 TCPSink $n1 0]
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.01 "$ftp start"

set lstats [new LinkStats $n0 $n1]
$lstats trace
$lstats set trace_file_name_ "rpi-queue-monitor-test.txt"

incr n_tests
set tenth_percentile [$lstats get-percentile-byte-queue-length 10]
if { $tenth_percentile != 2000 } {
  puts "\nFAILED The 10th percentile in bytes should be 2000 bytes, \
    but get-percentile-byte-queue-length is $tenth_percentile."
} else {
  incr n_tests_passed
}

incr n_tests
set median [$lstats get-percentile-byte-queue-length 50]
if { $median != 8000 } {
  puts "\nFAILED The median queue length in bytes should be 8000 bytes, \
    but get-percentile-byte-queue-length is $median."
} else {
  incr n_tests_passed
}

# bound the tcp window.
set bps [bw2bps $bw]
set dsec [t2sec $delay]
set bw_delay [expr $bps * $dsec / (8.0 * $pktsize)]
$tcp set window_ [expr $bw_delay + 10]

#set qlen_graph [new Graph/QLenVersusTime $n0 $n1]

$ns at 2 "$tcp set window_ [expr $bw_delay + 15]"
$ns at 4 "$tcp set window_ [expr $bw_delay + 20]"
$ns at 6 "$tcp set window_ [expr $bw_delay + 25]"
$ns at 8 "$tcp set window_ [expr $bw_delay + 30]"

set ls0 [new LinkStats $n0 $n1]
set ls1 [new LinkStats $n0 $n1]
set ls2 [new LinkStats $n0 $n1]
$ls0 trace
$ls1 trace-every-kth 4
$ls2 trace-every-interval 0.1

$ns at 10 "finish"
$ns run
