#
# forwarding.tcl
#

puts ""
puts "FORWARDING Validation Test: "
puts ""
puts " This network consists of 32 autonomous systems, each represented"
puts " by a single BGP router with an IGP router attached."  
puts " In the center is a backbone network consisting of five autonomous"
puts " systems.  Three of those ASes have other ASes connected."
puts ""


set f [open forwarding.out w]
set nf [open forwarding.nam w]

set ns [new Simulator]

$ns trace-all $f
$ns namtrace-all $nf

$ns node-config -BGP ON
for {set j 0} {$j < 32 } {incr j} {
	set n($j) [$ns node $j:10.0.$j.1]
}
$ns node-config -BGP OFF

for {set j 32} {$j < 64 } {incr j} {
	set n($j) [$ns node [expr $j - 32]:10.0.$j.1]
}

for {set j 0} {$j < 32 } {incr j} {
	$ns duplex-link $n($j) $n([expr 32 + $j]) 1Mb 1ms DropTail
}

## BACKBONE
$ns duplex-link $n(0) $n(1) 1Mb 1ms DropTail
$ns duplex-link $n(0) $n(4) 1Mb 1ms DropTail
$ns duplex-link $n(1) $n(2) 1Mb 1ms DropTail
$ns duplex-link $n(2) $n(4) 1Mb 1ms DropTail
$ns duplex-link $n(2) $n(3) 1Mb 1ms DropTail
$ns duplex-link $n(3) $n(4) 1Mb 1ms DropTail

## NET 1
$ns duplex-link $n(1) $n(5) 1Mb 1ms DropTail

$ns duplex-link $n(5) $n(6) 1Mb 1ms DropTail
$ns duplex-link $n(5) $n(7) 1Mb 1ms DropTail
$ns duplex-link $n(5) $n(8) 1Mb 1ms DropTail
$ns duplex-link $n(6) $n(9) 1Mb 1ms DropTail
$ns duplex-link $n(6) $n(10) 1Mb 1ms DropTail
$ns duplex-link $n(6) $n(11) 1Mb 1ms DropTail
$ns duplex-link $n(8) $n(12) 1Mb 1ms DropTail
$ns duplex-link $n(8) $n(13) 1Mb 1ms DropTail
$ns duplex-link $n(8) $n(14) 1Mb 1ms DropTail
$ns duplex-link $n(14) $n(15) 1Mb 1ms DropTail
$ns duplex-link $n(14) $n(16) 1Mb 1ms DropTail
$ns duplex-link $n(14) $n(17) 1Mb 1ms DropTail

## NET 2
$ns duplex-link $n(3) $n(18) 1Mb 1ms DropTail
$ns duplex-link $n(3) $n(19) 1Mb 1ms DropTail

$ns duplex-link $n(19) $n(20) 1Mb 1ms DropTail
$ns duplex-link $n(19) $n(21) 1Mb 1ms DropTail
$ns duplex-link $n(19) $n(22) 1Mb 1ms DropTail


## NET 3
$ns duplex-link $n(4) $n(23) 1Mb 1ms DropTail
$ns duplex-link $n(4) $n(24) 1Mb 1ms DropTail

$ns duplex-link $n(23) $n(25) 1Mb 1ms DropTail
$ns duplex-link $n(23) $n(26) 1Mb 1ms DropTail
$ns duplex-link $n(24) $n(27) 1Mb 1ms DropTail
$ns duplex-link $n(24) $n(28) 1Mb 1ms DropTail
$ns duplex-link $n(24) $n(29) 1Mb 1ms DropTail
$ns duplex-link $n(27) $n(30) 1Mb 1ms DropTail
$ns duplex-link $n(27) $n(31) 1Mb 1ms DropTail

## INTER-NET 
$ns duplex-link $n(15) $n(18) 1Mb 1ms DropTail
$ns duplex-link $n(9) $n(29) 1Mb 1ms DropTail

for {set i 0} {$i < 32 } {incr i} {
	set bgp_agent($i) [$n($i) get-bgp-agent]
	$bgp_agent($i) set-auto-config
}

## BACKBONE
$ns at 1.0 "$bgp_agent(0) network 0.0.3.192/28"
$ns at 1.0 "$bgp_agent(1) network 0.0.3.176/28"
$ns at 1.0 "$bgp_agent(2) network 0.0.3.160/28"
$ns at 1.0 "$bgp_agent(3) network 0.0.3.144/28"
$ns at 1.0 "$bgp_agent(4) network 0.0.3.128/28"
## NET 1
$ns at 1.0 "$bgp_agent(5) network 0.0.0.192/28"
$ns at 1.0 "$bgp_agent(6) network 0.0.0.176/28"
$ns at 1.0 "$bgp_agent(7) network 0.0.0.160/28"
$ns at 1.0 "$bgp_agent(8) network 0.0.0.144/28"
$ns at 1.0 "$bgp_agent(9) network 0.0.0.128/28"
$ns at 1.0 "$bgp_agent(10) network 0.0.0.112/28"
$ns at 1.0 "$bgp_agent(11) network 0.0.0.96/28 "
$ns at 1.0 "$bgp_agent(12) network 0.0.0.80/28 "
$ns at 1.0 "$bgp_agent(13) network 0.0.0.64/28 "
$ns at 1.0 "$bgp_agent(14) network 0.0.0.48/28 "
$ns at 1.0 "$bgp_agent(15) network 0.0.0.32/28 "
$ns at 1.0 "$bgp_agent(16) network 0.0.0.16/28 "
$ns at 1.0 "$bgp_agent(17) network 0.0.0.0/28  "
## NET 2
$ns at 1.0 "$bgp_agent(18) network 0.0.3.64/28 "
$ns at 1.0 "$bgp_agent(19) network 0.0.3.48/28 "
$ns at 1.0 "$bgp_agent(20) network 0.0.3.32/28 "
$ns at 1.0 "$bgp_agent(21) network 0.0.3.16/28 "
$ns at 1.0 "$bgp_agent(22) network 0.0.3.0/28  "
## NET 3
$ns at 1.0 "$bgp_agent(23) network 0.0.2.128/28"
$ns at 1.0 "$bgp_agent(24) network 0.0.2.112/28"
$ns at 1.0 "$bgp_agent(25) network 0.0.2.96/28 "
$ns at 1.0 "$bgp_agent(26) network 0.0.2.80/28 "
$ns at 1.0 "$bgp_agent(27) network 0.0.2.64/28 "
$ns at 1.0 "$bgp_agent(28) network 0.0.2.48/28 "
$ns at 1.0 "$bgp_agent(29) network 0.0.2.32/28 "
$ns at 1.0 "$bgp_agent(30) network 0.0.2.16/28 "
$ns at 1.0 "$bgp_agent(31) network 0.0.2.0/28 "


$ns at 999.0 "puts \"\n time: 999 \
                     \n dump routing tables in all BGP agents: \n\""

for {set i 0} {$i < 32 } {incr i} {
	$ns at 999.0 "$bgp_agent($i) show-routes"
}

$ns at 1000.0 "finish"

proc finish {} {
	global ns f nf
	$ns flush-trace
	close $f
	close $nf
	puts "Simulation finished. Executing nam..."
	exec nam forwarding
	exit 0
}

puts "Simulation starts..."
$ns run
	
