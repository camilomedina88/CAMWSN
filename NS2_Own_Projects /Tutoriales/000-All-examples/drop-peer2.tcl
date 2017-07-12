# 
# drop-peer2.tcl
#

puts ""
puts "DROP-PEER2 Validation Test:"
puts ""
puts " Three ASes connected in a line, each with one router."
puts "   AS 1       AS 0       AS 2"      	   			    
puts "   n1 }------{ n0 }------{ n2"
puts ""


set nf [open drop-peer2.nam w]
set ns [new Simulator]
$ns namtrace-all $nf

$ns node-config -BGP ON
set n0 [$ns node 0:10.0.0.1]
set n1 [$ns node 1:10.0.1.1]
set n2 [$ns node 2:10.0.2.1]
$ns node-config -BGP OFF

$ns duplex-link $n0 $n1 1Mb 1ms DropTail
$ns duplex-link $n0 $n2 1Mb 1ms DropTail

set bgp_agent0 [$n0 get-bgp-agent]
$bgp_agent0 bgp-id 10.0.0.1
$bgp_agent0 neighbor 10.0.1.1 remote-as 1
$bgp_agent0 neighbor 10.0.2.1 remote-as 2

set bgp_agent1 [$n1 get-bgp-agent]
$bgp_agent1 bgp-id 10.0.1.1
## explicitly setting the parameters,
$bgp_agent1 neighbor 10.0.0.1 remote-as 0
$bgp_agent1 neighbor 10.0.0.1 hold-time 90
$bgp_agent1 neighbor 10.0.0.1 keep-alive-time 200
$bgp_agent1 neighbor 10.0.0.1 mrai 30

set bgp_agent2 [$n2 get-bgp-agent]
$bgp_agent2 bgp-id 10.0.2.1
## explicitly setting the parameters,
## although they're all default values
$bgp_agent2 neighbor 10.0.0.1 remote-as 0
$bgp_agent2 neighbor 10.0.0.1 hold-time 90
$bgp_agent2 neighbor 10.0.0.1 keep-alive-time 30
$bgp_agent2 neighbor 10.0.0.1 mrai 30

$ns at 0.25 "puts \"\n time: 0.25 \n n0 (ip_addr 10.0.0.1) \
                     defines a network 10.0.0.0/24.\"" 
$ns at 0.25 "$bgp_agent0 network 10.0.3.0/24"

$ns at 0.25 "puts \"\n time: 0.25 \n n1 (ip_addr 10.0.1.1) \
                     defines a network 10.0.1.0/24.\"" 
$ns at 0.25 "$bgp_agent1 network 10.0.1.0/24"

$ns at 0.25 "puts \"\n time: 0.25 \n n2 (ip_addr 10.0.2.1) \
                     defines a network 10.0.2.0/24.\"" 
$ns at 0.25 "$bgp_agent2 network 10.0.2.0/24"

$ns at 31.0 "puts \"\n time: 31 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 31.0 "$bgp_agent0 show-routes"
$ns at 31.0 "$bgp_agent1 show-routes"
$ns at 31.0 "$bgp_agent2 show-routes"

## At 90.01, HoldTimer of bgp_agent0 expired, bgp_agent0 will 
## 1. drop peer with bgp_agnet1
## 2. withdrawl route that learned from bgp_agent1

$ns at 90.26 "puts \"\n time: 90.26 \
                     \n dump routing tables in all BGP agents: \n\""
$ns at 90.26 "$bgp_agent0 show-routes"
$ns at 90.26 "$bgp_agent1 show-routes"
$ns at 90.26 "$bgp_agent2 show-routes"

$ns at 100.0 "finish"

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	puts "Simulation finished. Executing nam..."
	exec nam drop-peer2.nam	
	exit 0
}

puts "Simulation starts..."
$ns run

	
