#
# new2.tcl
#

puts ""
puts "SELECT Validation Test: "
puts ""
puts " A \"triangle\" consisting of three ASes.  Each AS has one"
puts " BGP-speaking router.  Each router is connected directly to"
puts " the routers in each neighboring AS."
puts ""
puts "    AS----AS "
puts "     \\    /  "
puts "      \\  /   "
puts "       AS    "
puts ""


set nf [open new.nam w]
set ns [new Simulator]
$ns namtrace-all $nf

$ns node-config -BGP ON
set n0 [$ns node 0:10.0.0.1]
set n1 [$ns node 1:10.0.1.1]
set n2 [$ns node 2:10.0.2.1]
set n3 [$ns node 3:10.0.3.1]
set n4 [$ns node 4:10.0.4.1]
set n5 [$ns node 5:10.0.5.1]
set n6 [$ns node 6:10.0.6.1]
set n7 [$ns node 7:10.0.7.1]
set n8 [$ns node 8:10.0.8.1]
set n9 [$ns node 9:10.0.9.1]
set n10 [$ns node 10:10.0.10.1]
set n11 [$ns node 11:10.0.11.1]
set n12 [$ns node 12:10.0.12.1]
set n13 [$ns node 13:10.0.13.1]
$ns node-config -BGP OFF

$ns duplex-link $n1 $n3 1Mb 1ms DropTail
$ns duplex-link $n3 $n5 1Mb 1ms DropTail
$ns duplex-link $n5 $n7 1Mb 1ms DropTail
$ns duplex-link $n7 $n9 1Mb 1ms DropTail
$ns duplex-link $n9 $n12 1Mb 1ms DropTail

set bgp_agent1 [$n1 get-bgp-agent]
$bgp_agent1 bgp-id 10.0.1.1
$bgp_agent1 neighbor 10.0.3.1 remote-as 3

set bgp_agent3 [$n3 get-bgp-agent]
$bgp_agent3 bgp-id 10.0.3.1
$bgp_agent3 neighbor 10.0.0.1 remote-as 0
$bgp_agent3 neighbor 10.0.1.1 remote-as 1
$bgp_agent3 neighbor 10.0.2.1 remote-as 2
$bgp_agent3 neighbor 10.0.4.1 remote-as 4
$bgp_agent3 neighbor 10.0.5.1 remote-as 5
$bgp_agent3 neighbor 10.0.6.1 remote-as 6

set bgp_agent5 [$n5 get-bgp-agent]
$bgp_agent5 bgp-id 10.0.5.1
$bgp_agent5 neighbor 10.0.3.1 remote-as 3
$bgp_agent5 neighbor 10.0.4.1 remote-as 4
$bgp_agent5 neighbor 10.0.6.1 remote-as 6
$bgp_agent5 neighbor 10.0.7.1 remote-as 7

set bgp_agent7 [$n7 get-bgp-agent]
$bgp_agent7 bgp-id 10.0.7.1
$bgp_agent7 neighbor 10.0.5.1 remote-as 5
$bgp_agent7 neighbor 10.0.8.1 remote-as 8
$bgp_agent7 neighbor 10.0.9.1 remote-as 9
$bgp_agent7 neighbor 10.0.10.1 remote-as 10

set bgp_agent9 [$n9 get-bgp-agent]
$bgp_agent9 bgp-id 10.0.9.1
$bgp_agent9 neighbor 10.0.7.1 remote-as 7
$bgp_agent9 neighbor 10.0.8.1 remote-as 8
$bgp_agent9 neighbor 10.0.10.1 remote-as 10
$bgp_agent9 neighbor 10.0.11.1 remote-as 11
$bgp_agent9 neighbor 10.0.12.1 remote-as 12
$bgp_agent9 neighbor 10.0.13.1 remote-as 13

set bgp_agent12 [$n12 get-bgp-agent]
$bgp_agent12 bgp-id 10.0.12.1
$bgp_agent12 neighbor 10.0.9.1 remote-as 9

$ns at 0.35 "puts \"\n time: 0.35 \n n1 (ip_addr 10.0.1.1) \
                       defines a network 10.0.1.0/24.\""
$ns at 0.35 "$bgp_agent1 network 10.0.1.0/24"

$ns at 0.55 "puts \"\n time: 0.55 \n n3 (ip_addr 10.0.3.1) \
                       defines a network 10.0.3.0/24.\""
$ns at 0.55 "$bgp_agent3 network 10.0.3.0/24"

$ns at 0.75 "puts \"\n time: 0.75 \n n5 (ip_addr 10.0.2.1) \
                       defines a network 10.0.5.0/24.\""
$ns at 0.75 "$bgp_agent5 network 10.0.5.0/24"

$ns at 0.95 "puts \"\n time: 0.95 \n n7 (ip_addr 10.0.7.1) \
                       defines a network 10.0.7.0/24.\""
$ns at 0.95 "$bgp_agent7 network 10.0.7.0/24"

$ns at 1.15 "puts \"\n time: 1.15 \n n9 (ip_addr 10.0.9.1) \
                       defines a network 10.0.9.0/24.\""
$ns at 1.15 "$bgp_agent9 network 10.0.9.0/24"

$ns at 1.45 "puts \"\n time: 1.45 \n n12 (ip_addr 10.0.12.1) \
                       defines a network 10.0.12.0/24.\""
$ns at 1.45 "$bgp_agent12 network 10.0.12.0/24"

$ns at 39.0 "puts \"\n time: 39 \
                    \n dump routing tables in all BGP agents: \n\""
$ns at 39.0 "$bgp_agent1 show-routes"
$ns at 39.0 "$bgp_agent3 show-routes"
$ns at 39.0 "$bgp_agent5 show-routes"
$ns at 39.0 "$bgp_agent7 show-routes"
$ns at 39.0 "$bgp_agent9 show-routes"
$ns at 39.0 "$bgp_agent12 show-routes"

$ns at 40.0 "finish"

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	puts "Simulation finished. Executing nam..."
	exec nam new2.nam
	exit 0
}

puts "Simulation starts..."
$ns run
