for {set i 0} {$i < $numNodes } {incr i} {
  set node_($i) [$ns_ node $i]
  $node_($i) random-motion 0		;# disable random motion
  $god_ new_node $node_($i)
  set mac_($i) [$node_($i) set mac_(0)]
  $mac_($i) values-file $valuefile
}

source $topoFile

# Sink application
set null_(0) [new Agent/Null]
$ns_ attach-agent $node_($sinknode) $null_(0)

# Source addition
for {set i 0} {$i < $numsources} {incr i} {
  set udp_($i) [new Agent/UDP]
  set srcid [expr $sinknode - $numsources + $i]
  $ns_ attach-agent $node_($srcid) $udp_($i)
  $ns_ connect $udp_($i) $null_(0)
  # changed here by acw for exponential traffic

  #         set cbr_($i) [new Application/Traffic/Exponential]
  #         $cbr_($i) attach-agent $udp_($i)
  #         $cbr_($i) set packetSize_ 46
  #         $cbr_($i) set burst_time_ 50ms
  #         $cbr_($i) set idle_time_ 50ms
  #         $cbr_($i) set rate_ 1000

  set cbr_($i) [new Application/Traffic/CBR]
  $cbr_($i) set packetSize_ [Mac/802_11 set payloadSize_]
  $cbr_($i) set interval_ 1
  $cbr_($i) set random_ 0
  $cbr_($i) attach-agent $udp_($i)

  $ns_ at [expr 1.00 + [expr $i * .05]] "$cbr_($i) start"
  $ns_ at $preStopTime "$cbr_($i) stop"
  $ns_ at [expr [Mac/802_11 set startStatTime_] - 50] "$cbr_($i) set interval_ $interval"
}

for {set i 0} {$i < $numNodes } {incr i} {
  $ns_ at $stopTime "$node_($i) reset";
  $ns_ at $stopTime "$mac_($i) print-stat"
}

$ns_ at $stopTime "$ns_ halt"
