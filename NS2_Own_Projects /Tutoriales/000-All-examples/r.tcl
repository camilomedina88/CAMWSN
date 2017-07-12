set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             3                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol

set ns [new Simulator]
set tracefd     [open simple.tr w]
$ns trace-all $tracefd

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 500 500

#
# Create God
#
create-god $val(nn)

        $ns node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType Mac/R-Rfid \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace OFF \
			 -macTrace ON \
			 -movementTrace OFF			
			 
set n(0) [$ns node]
$n(0) random-motion 0
        $ns node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType Mac/T-Rfid\
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace OFF \
			 -macTrace ON \
			 -movementTrace OFF			
		for {set i 1} {$i < 3} {incr i} {
		set n($i) [$ns node]	
		$n($i) random-motion 0		;# disable random motion
	}

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
$n(0) set X_ 5.0
$n(0) set Y_ 2.0
$n(0) set Z_ 0.0

$n(1) set X_ 39.0
$n(1) set Y_ 38.0
$n(1) set Z_ 0.0

$n(2) set X_ 29.0
$n(2) set Y_ 18.0
$n(2) set Z_ 0.0



set ra [new Agent/RfidRAgent]
set ta1 [new Agent/RfidTAgent]
set ta2 [new Agent/RfidTAgent]
$ra set packetSize_ 64

$n(0) attach $ra 3000
$n(1) attach $ta1 6000
$n(2) attach $ta2  6000

$ra set-mac [$n(0) set mac_(0)]
[$n(0) set mac_(0)] set-agent $ra

$ta1 set-mac [$n(1) set mac_(0)]
$ta2 set-mac [$n(2) set mac_(0)]

proc finish {} {
	global ns tracefd 
	$ns flush-trace
	close $tracefd
	$ns halt
}

$ns at 1.0 "$ra test"
$ns at 3.0 "$ra test"
$ns at 5.787 "puts [$ra now]"
$ns at 5.9 "$ra put_name"
$ns at 6.0 "finish"
$ns run
