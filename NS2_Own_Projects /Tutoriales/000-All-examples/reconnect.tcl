#
# reconnect.tcl
#

puts ""
puts "RECONNECT Validation Test:"
puts ""
puts " Three ASes connected in a line, each with one router."
puts "       AS 0       AS 1       AS 2"
puts "       n0 }------{ n1 }------{ n2"
puts ""


set nf [open reconnect.nam w]
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

set bgp_agent1 [$n1 get-bgp-agent]
$bgp_agent1 bgp-id 10.0.1.1
$bgp_agent1 neighbor 10.0.0.1 remote-as 0
$bgp_agent1 neighbor 10.0.0.1 keep-alive-time 200  
$bgp_agent0 neighbor 10.0.2.1 remote-as 2

set bgp_agent2 [[$n2 get-module BGP] get-bgp-agent]
$bgp_agent2 bgp-id 10.0.2.1
$bgp_agent2 neighbor 10.0.0.1 remote-as 0

$ns at 0.25 "puts \"\n time: 0.25 \n n0 (ip_addr 10.0.0.1) \
                       defines a network 10.0.0.0/24.\""
$ns at 0.25 "$bgp_agent0 network 10.0.0.0/24"

$ns at 0.35 "puts \"\n time: 0.35 \n n1 (ip_addr 10.0.1.1) \
                       defines a network 10.0.1.0/24.\"" 
$ns at 0.35 "$bgp_agent1 network 10.0.1.0/24"

$ns at 0.45 "puts \"\n time: 0.45 \n n2 (ip_addr 10.0.2.1) \
                       defines a network 10.0.2.0/24.\""
$ns at 0.45 "$bgp_agent2 network 10.0.2.0/24"

## Network converges at 27.25*. 
$ns at 31.0 "puts \"\n time: 31 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 31.0 "$bgp_agent0 show-routes"
$ns at 31.0 "$bgp_agent1 show-routes"
$ns at 31.0 "$bgp_agent2 show-routes"

## At 90.01, HoldTimer of bgp_agent0 expired, bgp_agent0 will 
## 1. drop peer with bgp_agnet1
## 2. withdrawl route that learned from bgp_agent1

## Connection closing finished at 90.36*.
$ns at 90.37 "puts \"\n time: 90.37 \
                     \n dump routing tables in all BGP agents: \n\""
$ns at 90.37 "$bgp_agent0 show-routes"
$ns at 90.37 "$bgp_agent1 show-routes"
$ns at 90.37 "$bgp_agent2 show-routes"

## Network converges at 121.0* again after reconnection.
$ns at 121.0 "puts \"\n time: 121 \
                     \n dump routing tables in all BGP agents: \n\""

$ns at 121.0 "$bgp_agent0 show-routes"
$ns at 121.0 "$bgp_agent1 show-routes"
$ns at 121.0 "$bgp_agent2 show-routes"

$ns at 130.0 "finish"

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	puts "Simulation finished. Executing nam..."
	exec nam reconnect.nam
	exit 0
}

puts "Simulation starts..."
$ns run

#* These times are recorded with "jitter_factor_seed" set to 12345.
#  (Please see file bgp/global.h)
	
