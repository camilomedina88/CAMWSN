

# This file contains tests for the link statistics gathering functions
# found in $NS/tcl/rpi/link-stats.tcl.
#
# @author David Harrison
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/graph.tcl   ;# DEBUG

set n_tests 0
set n_tests_passed 0
Queue set limit_ 1000  ;# large enough to avoid loss.
set BW 100             ;# in Mbps
set DELAY 10           ;# in ms.
set TOL 0.00000001
set TARGET_QLEN 15 ;# target queue length during TCP steady state as determined
                   ;# by receiver advertised window - bw*rtt.

# This function tests the behavior of the link statistics procedures
# when they are called have zero time has elapsed since the LinkStats
# object was instantiated.
proc zero-time-tests {} {
  global n_tests n_tests_passed lstats

  incr n_tests
  if [catch {$lstats get-utilization}] {
    incr n_tests_passed
  } else {
    puts "FAILED TEST.
      LinkStats get-utilization should throw an error
      when called after zero simulation time has elapsed since LinkStats
      was instantiated."
  }

  incr n_tests
  if [catch {$lstats get-packet-utilization 1000}] {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      LinkStats get-utilization should throw an error
      when called after zero simulation time has elapsed since LinkStats
      was instantiated."
  }

  incr n_tests
  if [catch {$lstats get-throughput}] {
    incr n_tests_passed
  } else {
     puts "FAILED TEST. 
      LinkStats get-throughput should throw an error
      when called after zero simulation time has elapsed since LinkStats
      was instantiated."
  }

  incr n_tests
  if [catch {$lstats get-power}] {
    incr n_tests_passed
  } else {
    puts "FAILED TEST.
      LinkStats get-power should throw an error when called
      after zero simulation time has elapsed since LinkStats
      was instantiated."   
  }
 
  incr n_tests
  if { [$lstats get-packet-arrivals] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      LinkStats get-packet-arrivals should return 0
      when called after zero simulation time has elapsed since LinkStats
      was instantiated."
  }

  incr n_tests
  if { [$lstats get-byte-arrivals] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      LinkStats get-byte-arrivals should return 0
      when called after zero simulation time has elapsed since LinkStats
      was instantiated."
  }

  incr n_tests
  if { [$lstats get-packet-drops] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      LinkStats get-byte-drops should return 0
      when called after zero simulation time has elapsed since LinkStats
      was instantiated. It returns \"[$lstats get-packet-drops]\""
  }

  incr n_tests
  if { [$lstats get-packet-departures] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      LinkStats get-packet-departures should return 0 when called
      after zero simulation time has elapsed since LinkStats
      was instantiated. It returns \"[$lstats get-packet-departures]\""
  }

  incr n_tests
  if { [$lstats get-byte-departures] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      LinkStats get-byte-departures should return 0 
      when called after zero simulation time has elapsed since
      LinkStats was instantiated. It returns \"[$lstats get-byte-departures]\""
  }

  incr n_tests
  if { [string compare [$lstats get-mean-queue-delay] NaN] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-mean-queue-delay should return NaN when called 
      after zero simulation time has elapsed since LinkStats
      was instantiated. It returns \"[$lstats get-mean-queue-delay]\""
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [string compare [$lstats get-queue-delay-variance] NaN] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-queue-delay-variance should return NaN when
      called after zero simulation time has elapsed since LinkStats
      was instantiated. It returns \"[$lstats get-queue-delay-variance]\""
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [string compare [$lstats get-queue-delay-stddev] NaN] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-queue-delay-stddev should return NaN
      when called after zero simulation time has elapsed since LinkStats 
      was instantiated. It returns \"[$lstats get-queue-delay-stddev]\""
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-mean-packet-queue-length] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-mean-packet-queue-length should return
      0 when called after zero simulation time has elapsed since LinkStats
      was instantiated. It returns \"[$lstats get-mean-packet-queue-length]\""
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-mean-byte-queue-length] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-mean-byte-queue-length should return 0
      when called after zero simulation time has elapsed since LinkStats
      was instantiated. It returns \"[$lstats get-mean-byte-queue-length]\""
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-max-packet-queue-length] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-max-packet-queue-length should return 0
      when called after zero simulation time has elapsed since LinkStats
      was instantiated. It returns \"[$lstats get-max-packet-queue-length]\""
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-max-byte-queue-length] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-max-byte-queue-length should return 0 when called 
      when called after zero simulation time has elapsed since LinkStats
      was instantiated. It returns \"[$lstats get-max-byte-queue-length]\""
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-min-packet-queue-length] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-min-packet-queue-length should return 0
      when called after zero simulation time has elapsed since LinkStats
      was instantiated.  It returns \"[$lstats get-min-packet-queue-length]\""
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-min-byte-queue-length] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-min-byte-queue-length should return 0 when called 
      after zero simulation time has elapsed since LinkStats
      was instantiated.  It returns \"[$lstats get-min-byte-queue-length]\""
  } else {
    incr n_tests_passed
  }

}


# This function tests the behavior of the link statistics procedures
# when time has elapsed but no packets have been received.
proc zero-packet-tests {} {
  global n_tests n_tests_passed lstats

  incr n_tests
  if { [$lstats get-utilization] != 0 } {
    puts "FAILED TEST. 
      LinkStats get-utilization should return 0 when no packets 
      have traversed the link. It returns \"[$lstats get-utilization]\""
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-throughput] } {
    puts "FAILED TEST. LinkStats get-throughput should return 0 when no
      packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [string compare [$lstats get-power] "NaN"] != 0 } {
    puts "FAILED TEST. LinkStats get-power should return NaN when no
      packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-packet-arrivals] != 0 } {
    puts "FAILED TEST. LinkStats get-packet-arrivals should return 0 when
      no packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-byte-arrivals] != 0 } {
    puts "FAILED TEST. LinkStats get-byte-arrivals should return 0 when no
      packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-packet-drops] != 0 } {
    puts "FAILED TEST. LinkStats get-packet-drops should return 0 when no
     packets have traversed the link."
  } else {
    incr n_tests_passed
  }
  

  incr n_tests
  if { [$lstats get-byte-drops] != 0 } {
    puts "FAILED TEST. LinkStats get-byte-drops should return 0 when no
      packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-packet-departures] != 0 } {
    puts "FAILED TEST. LinkStats get-packet-departures should return 0 when no
      packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-byte-departures] != 0 } {
    puts "FAILED TEST. LinkStats get-byte-departures should return 0 when no
      packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [string compare [$lstats get-mean-queue-delay] NaN] != 0 } {
    puts "FAILED TEST. LinkStats get-mean-queue-delay should return NaN
      when no packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [string compare [$lstats get-queue-delay-variance] NaN] != 0 } {
    puts "FAILED TEST. LinkStats get-queue-delay-variance should return NaN
      when no packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [string compare [$lstats get-queue-delay-stddev] NaN] != 0 } {
    puts "FAILED TEST. LinkStats get-queue-delay-stddev should return NaN
      when no packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-mean-packet-queue-length] != 0 } {
    puts "FAILED TEST. LinkStats get-mean-packet-queue-length should return
      0 when no packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-mean-byte-queue-length] != 0 } {
    puts "FAILED TEST. LinkStats get-mean-byte-queue-length should return
      0 when no packets have traversed the link." 
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-max-packet-queue-length] != 0 } {
    puts "FAILED TEST. LinkStats get-max-packet-queue-length should return
      0 when no packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-max-byte-queue-length] != 0 } {
    puts "FAILED TEST. LinkStats get-max-byte-queue-length should return
      0 when no packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-min-packet-queue-length] != 0 } {
    puts "FAILED TEST. LinkStats get-min-packet-queue-length should return
      0 when no packets have traversed the link."
  } else {
    incr n_tests_passed
  }

  incr n_tests
  if { [$lstats get-min-byte-queue-length] != 0 } {
    puts "FAILED TEST. LinkStats get-min-byte-queue-length should return
      0 when no packets have traversed the link."
  } else {
    incr n_tests_passed
  }
}

# Tests the value of utilization and throughput after 1 second
# in which only one packet traversed the link.
proc one-packet-in-one-second { } {
  global n_tests n_tests_passed lstats BW TOL

  set dt 1.0     ;# in seconds
  set bw [expr $BW * 1.0e6]   ;# bps
  set pksz [expr 1000 * 8]
  set rate [expr $pksz / $dt]  

  incr n_tests
  set util [expr $rate / $bw]
  if { $util < [expr [$lstats get-utilization] + $TOL] && \
       $util > [expr [$lstats get-utilization] - $TOL] } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-utilization should return $util over
      a 1 second interval in which a single 1000 byte packet was transmitted
      through a $BW Mbps link.  Instead it returns 
      [$lstats get-utilization]"
  }


  incr n_tests
  if { $util < [expr [$lstats get-packet-utilization 1000] + $TOL] && \
       $util > [expr [$lstats get-packet-utilization 1000] - $TOL] } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-packet-utilization should return $util
          over a second in which a single 1000 byte packet was transmitted
          through a $BW Mbps link. Instead it returns
          [$lstats get-packet-utilization 1040]."
  }

  incr n_tests
  if { $rate < [expr [$lstats get-throughput] + $TOL] && \
	   $rate > [expr [$lstats get-throughput] - $TOL] } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-throughput should return $rate averaged
          over a second in which a single 1000 byte packet was transmitted."
  }

  incr n_tests
  if { [string compare [$lstats get-power] "NaN"] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-power should return NAN in for an 
          interval over which only one packet was transmitted, because 
          the packet should have received zero queueing delay. Instead,
          it returns [$lstats get-power]."
  }

  incr n_tests
  if { [$lstats get-packet-arrivals] == 1 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-packet-arrivals should return 1 in an
          interval in which only 1 packet was sent. Instead it returns 
          [$lstats get-packet-arrivals]."
  }

  incr n_tests
  if { [$lstats get-byte-arrivals] == 1000 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-byte-arrivals should return 1000 after
          an interval in which only a single 1000 byte packet was sent.
          Instead it returns [$lstats get-byte-arrivals]"
  }

  incr n_tests
  if { [$lstats get-packet-drops] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-packet-drops shoudl return 0 after an
      interval in which only a single packet was sent, because this single
      packet should not be dropped. However, it returns 
      [$lstats get-packet-drops]"
  }

  incr n_tests
  if { [$lstats get-byte-drops] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-byte-drops should return 0 after an
      interval in which only a single packet was sent.  However, it
      returns [$lstats get-byte-drops]"
  }

  incr n_tests
  if { [$lstats get-packet-departures] == 1 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-packet-departures should return 1
      after an interval in which only a single packet was sent.  However, it
      returns [$lstats get-packet-departures]"
  }

  incr n_tests
  if { [$lstats get-byte-departures] == 1000 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-byte-departures should return 1000
      after an interval in which only a single packet was sent.  However, it
      returns [$lstats get-byte-departures]"
  }

  incr n_tests
  if { [$lstats get-mean-queue-delay] < $TOL } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-mean-queue-delay should return 0
      after an interval in which only a single packet was sent.  However, it
      returns [$lstats get-mean-queue-delay]"
  }

  incr n_tests
    if { [$lstats get-queue-delay-variance] < $TOL } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-queue-delay-variance should return 0
      after an interval in which only a single packet was sent. However, it
      returns [$lstats get-queue-delay-variance]."
  }

  incr n_tests
  if { [$lstats get-queue-delay-stddev] < $TOL } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-queue-delay-stddev should return 0
      after an interval in which only a single packet was sent. However, it
      returns [$lstats get-queue-delay-stddev]."
  }

  incr n_tests
  if { [$lstats get-mean-packet-queue-length] <= 1 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      LinkStats get-mean-packet-queue-length should be
      no greater than 1 in an interval in which only 1 packet was sent.
      However, it returns [$lstats get-mean-packet-queue-length]"
  }

  incr n_tests
  if { [$lstats get-mean-byte-queue-length] <= 1000 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      LinkStats get-mean-byte-queue-length should be
      no greater than 1000 in an interval in which only a single 1000 byte
      packet was sent. However, it returns 
      [$lstats get-mean-packet-queue-length]"
  }

  incr n_tests
  if { [$lstats get-max-packet-queue-length] <= 1 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      LinkStats get-max-packet-queue-length should be no
      greater than 1 in an interval in which only 1 packet was sent.
      However, it returns [$lstats get-max-packet-queue-length]"
  }

  incr n_tests
  if { [$lstats get-max-byte-queue-length] <= 1000 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-max-byte-queue-length should be no
      greater than 1000 in an interval in which only a single 1000 byte
      packet was sent.  However, it returns 
      [$lstats get-max-packet-queue-length]"
  }

  incr n_tests
  if { [$lstats get-min-packet-queue-length] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-min-packet-queue-length should be 0
      in an interval in which only a single 1000 byte
      packet was sent.  However, it returns 
      [$lstats get-min-packet-queue-length]"
  }

  incr n_tests
  if { [$lstats get-min-byte-queue-length] == 0 } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. LinkStats get-min-byte-queue-length should be 0
      in an interval in which only a single 1000 byte
      packet was sent.  However, it returns 
      [$lstats get-min-byte-queue-length]"
  }
}


# We test statistics gathered during steady state for a TCP
# connection with window size bounded by its receiver advertised window.
# The buffer size is large enough to avoid loss and there is only one
# connection, thus the queue should stabilize around a target queue length
# equal to the receiver advertised window minus the bandwidth-RTT 
# product.
#
proc advertised-window-limited-tcp-tests {} {
  global TARGET_QLEN TOL BW lstats n_tests n_tests_passed
  #global old_target_qlen

  # average queue length should be close to TARGET_QLEN
  # We accept two valid answers to handle the ns-2.1b5 which sets
  # the packet length equal to TCP's packetSize_ data member while
  # ns-2.1b9a and ns-2.26 set the packet length to packetSize_ + 
  # tcpip_base_hdr_size_
  incr n_tests
  if { [$lstats get-mean-packet-queue-length] < $TARGET_QLEN + 1 && \
	    [$lstats get-mean-packet-queue-length] > $TARGET_QLEN - 1  } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      get-mean-packet-queue-length should return around
      $TARGET_QLEN in advertised-window-limited-tcp-tests, because
      a TCP connection is bouded by its recevier advertised window to 
      the bandwidth-RTT product + $TARGET_QLEN. However 
      it returns \"[$lstats get-mean-packet-queue-length]\""
  }
   
  # queue delay should be close to TARGET_QLEN / bitrate.
  incr n_tests
  set bps [expr $BW * 1.0e6]
  set sz [expr [Agent/TCP set packetSize_] + \
    [Agent/TCP set tcpip_base_hdr_size_]]
  set bits_sz [expr $sz * 8.0]
  set pkt_delay [expr $bits_sz / $bps]
  set target_qdelay [expr $TARGET_QLEN * $pkt_delay]

  # recompute delay for ns-2.1b5
  #set old_sz [Agent/TCP set packetSize_]
  #set bits_sz [expr $old_sz * 8.0]
  #set old_pkt_delay [expr $bits_sz / $bps]
  #set old_target_qdelay [expr $old_target_qlen * $old_pkt_delay]

  if { [$lstats get-mean-queue-delay] < $target_qdelay + $pkt_delay \
       && \
       [$lstats get-mean-queue-delay] > $target_qdelay - $pkt_delay } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      get-mean-queue-delay should return around
      $target_qdelay in  advertised-window-limited-tcp-tests, because
      a TCP connection is bouded by its recevier advertised window to 
      the bandwidth-RTT product + $TARGET_QLEN.  However,
      it returns \"[$lstats get-mean-queue-delay]\""
  }

  # In the steady-state, max queue length should be greater than the 
  # TARGET_QLEN but not be much more than the TARGET_QLEN.
  incr n_tests
  if { [$lstats get-max-packet-queue-length] < $TARGET_QLEN + 5 && \
       [$lstats get-max-packet-queue-length] >= $TARGET_QLEN } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      In the steady-state, get-max-packet-queue-length 
      should return a value greater than or equal to the target queue length 
      $TARGET_QLEN, but not much greater than $TARGET_QLEN.  Instead
      it returns [$lstats get-max-packet-queue-length]."
  }

  # queue delay variance and stddev should be near zero.
  incr n_tests
  if { [$lstats get-queue-delay-variance] < $TOL } {
    incr n_tests_passed
  } else {
    puts "FAILED TEST. 
      In the stead-state, get-queue-delay-variance
      should be near-zero because the queue should stabilize around
      the target queue length $TARGET_QLEN.  Instead get-queue-delay-variance
      returns [$lstats get-queue-delay-variance]."
  }
}

proc finish { } {
  global lstats n_tests n_tests_passed qlen_graph util_graph cwnd_graph

  #run-nam

  #$qlen_graph display
  #$util_graph display
  #$cwnd_graph display

  if { $n_tests == $n_tests_passed } {
    puts "PASSED all $n_tests tests."
  } else {
    puts "FAILURE. Passed only $n_tests_passed out of $n_tests tests."
  }
  exit -1
}


puts -nonewline "link-stats Tests:\t"
set ns [new Simulator]
#use-nam
set n0 [$ns node]
set n1 [$ns node]
$ns duplex-link $n0 $n1 [set BW]M [set DELAY]ms DropTail
set lstats [new LinkStats $n0 $n1]

set udp [$ns create-connection UDP $n0 UDP $n1 0]

zero-time-tests
$ns at 0.1 "zero-packet-tests"
#$ns at 1 "$lstats reset; $udp send 1000 hello"
$ns at 1 "$lstats reset; $udp sendmsg 1000 hello"
$ns at 2 "one-packet-in-one-second"

set tcp [$ns create-connection TCP/Reno $n0 TCPSink $n1 0]
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# packet size is MTU + TCP header size + IP header size where
# packetSize_ = MTU and tcpip_base_hdr_size_ includes both TCP and IP headers.
# ns-2.1b5 creates packets of size packetSize_ while ns-2.1b9a and
# ns-2.26 create packets of size packetSize_ + tcpcp_base_hdr_size_
if { $env(NSVER) == "2.1b5" } {
  set sz [$tcp set packetSize_]
} else {
  set sz [expr [$tcp set packetSize_] + [$tcp set tcpip_base_hdr_size_]]
}
set bits_sz [expr $sz * 8.0]
set rtt [expr $DELAY / 1000.0 * 2]
set bw_rtt_product [expr $BW * 1.0e6 / $bits_sz * $rtt]
$tcp set window_ [expr $bw_rtt_product + $TARGET_QLEN + 1]

# compute target queue length for ns-2.1b5
#set old_sz [$tcp set packetSize_]
#set old_bits_sz [expr $old_sz * 8.0]
#set rtt [expr $DELAY / 1000.0 * 2]
#set bw_rtt_product [expr $BW * 1.0e6 / $old_bits_sz * $rtt]
#set old_target_qlen [expr [$tcp set window_] - $bw_rtt_product -1]

$ns at 3 "$ftp start"
#set qlen_graph [new Graph/QLenVersusTime $n0 $n1]
#set util_graph [new Graph/UtilizationVersusTime $n0 $n1 0.1]
#set cwnd_graph [new Graph/CWndVersusTime $tcp]

# We allow enough time to pass so that the queue stabilizes around 
# TARGET_QLEN packets.
$ns at 4 "$lstats reset"

$ns at 5 "advertised-window-limited-tcp-tests"
$ns at 5.5 finish
$ns run
