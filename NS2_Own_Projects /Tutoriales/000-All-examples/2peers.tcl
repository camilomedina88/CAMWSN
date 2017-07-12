# 2peers.tcl
# Created by Xenofontas Dimitropoulos
# Georgia Tech, Spring 2003

proc finish { }  {
	global tf ns
	if [info exists tf] {
		close $tf
	}
	$ns halt
}

set ns [new Simulator]

set n1 [$ns node]
set n2 [$ns node]

$ns duplex-link $n1 $n2 1Mb 1ms DropTail

# Create the AS nodes and BGP applications
set r [new BgpRegistry]
set fin 400

# Set the finish time of the simulation here 
set tf [ open out.tr w ]
$ns trace-all $tf

set BGP1 [new Application/Route/Bgp]
$BGP1 register  $r
$BGP1 finish-time  $fin
$BGP1 config-file ./bgpd1.conf
$BGP1 attach-node $n1
$BGP1 cpu-load-model uniform 0.0001 0.00001

set BGP2 [new Application/Route/Bgp]
$BGP2 register  $r
$BGP2 finish-time  $fin
$BGP2 config-file ./bgpd2.conf
$BGP2 attach-node $n2
$BGP2 cpu-load-model uniform 0.0001 0.00001

$ns at 399  "$BGP1 command \"show ip bgp\""
$ns at 399  "$BGP2 command \"show ip bgp\""

$ns at $fin  "finish"

puts "Starting the run"

$ns run


