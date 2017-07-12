#
# keep-peer.tcl
#

puts ""
puts "KEEP-PEER Validation Test: "
puts ""
puts " Two ASes, each with one router.  The routers are directly"
puts " connected, and are each running BGP."
puts ""
puts "    AS 0        AS 1 " 
puts "     n0 }------{ n1 "
puts ""


set nf [open keep-peer.nam w]
set ns [new Simulator]
$ns namtrace-all $nf

$ns node-config -BGP ON
set n0 [$ns node 0:10.0.0.1]
set n1 [$ns node 1:10.0.1.1]
$ns node-config -BGP OFF

$ns duplex-link $n0 $n1 1Mb 1ms DropTail

set bgp_agent0 [$n0 get-bgp-agent]
$bgp_agent0 bgp-id 10.0.0.1
## explicitly setting the parameters,
## although they're all default value
$bgp_agent0 neighbor 10.0.1.1 remote-as 1
$bgp_agent0 neighbor 10.0.1.1 hold-time 90
$bgp_agent0 neighbor 10.0.1.1 keep-alive-time 30
$bgp_agent0 neighbor 10.0.1.1 mrai 30

set bgp_agent1 [$n1 get-bgp-agent]
$bgp_agent1 bgp-id 10.0.1.1
## explicitly setting the parameters,
## although they're all default value
$bgp_agent1 neighbor 10.0.0.1 remote-as 0
$bgp_agent1 neighbor 10.0.0.1 hold-time 90
$bgp_agent1 neighbor 10.0.0.1 keep-alive-time 30
$bgp_agent1 neighbor 10.0.0.1 mrai 30

$ns at 300.0 "finish"

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	puts "Simulation finished. Executing nam..."
	exec nam keep-peer.nam
	exit 0
}

puts "Simulation starts..."
$ns run
	
	
