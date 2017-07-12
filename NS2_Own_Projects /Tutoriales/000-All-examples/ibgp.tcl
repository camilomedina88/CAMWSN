# 
# ibgp.tcl
#
 
puts ""
puts "IBGP Validation Test: "
puts ""
puts " Three ASes connected in a line, the middle one containing two"
puts " BGP routers, the others just one each." 
puts "      AS 1          AS 0           AS 2"   
puts "      n2 }------{ n0 ... n1 }------{ n3"
puts "           eBGP      iBGP     eBGP"
puts ""

set nf [open ibgp.nam w]
set ns [new Simulator]
$ns namtrace-all $nf

$ns node-config -BGP ON
set n0 [$ns node 0:10.0.0.1]
set n1 [$ns node 0:10.0.1.1]
set n2 [$ns node 1:10.0.2.1]
set n3 [$ns node 2:10.0.3.1]
$ns node-config -BGP OFF

$ns duplex-link $n0 $n1 1Mb 1ms DropTail
$ns duplex-link $n0 $n2 1Mb 1ms DropTail
$ns duplex-link $n1 $n3 1Mb 1ms DropTail

set bgp_agent0 [$n0 get-bgp-agent]
$bgp_agent0 bgp-id 10.0.0.1
$bgp_agent0 neighbor 10.0.1.1 remote-as 0
$bgp_agent0 neighbor 10.0.2.1 remote-as 1

set bgp_agent1 [$n1 get-bgp-agent]
$bgp_agent1 bgp-id 10.0.1.1
$bgp_agent1 neighbor 10.0.0.1 remote-as 0
$bgp_agent1 neighbor 10.0.3.1 remote-as 2

set bgp_agent2 [$n2 get-bgp-agent]
$bgp_agent2 bgp-id 10.0.2.1
$bgp_agent2 neighbor 10.0.0.1 remote-as 0

set bgp_agent3 [$n3 get-bgp-agent]
$bgp_agent3 bgp-id 10.0.3.1
$bgp_agent3 neighbor 10.0.1.1 remote-as 0

$ns at 0.3 "puts \"\n time: 0.3 \n n2 (ip_addr 10.0.2.1) \
                     defines a network 10.0.2.0/24.\"" 
$ns at 0.3 "$bgp_agent2 network 10.0.2.0/24"

$ns at 0.3 "puts \"\n time: 0.3 \n n3 (ip_addr 10.0.3.1) \
                     defines a network 10.0.3.0/24.\"" 
$ns at 0.3 "$bgp_agent3 network 10.0.3.0/24"

$ns at 9.0 "puts \"\n time: 9 \
                     \n dump routing tables in all BGP agents: \n\""
$ns at 9.0 "$bgp_agent0 show-routes"
$ns at 9.0 "$bgp_agent1 show-routes"
$ns at 9.0 "$bgp_agent2 show-routes"
$ns at 9.0 "$bgp_agent3 show-routes"

$ns at 10.0 "finish"

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	puts "Simulation finished. Executing nam..."
	exec nam ibgp.nam	
	exit 0
}

puts "Simulation starts..."
$ns run
	
