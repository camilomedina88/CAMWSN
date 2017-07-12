#a simple script to test the setup

#define parameters
set val(chan)           Channel/Channel_802_11     ;# channel type
set val(prop)           Propagation/Shadowing      ;# radio-propagation model
set val(netif)          Phy/WirelessPhy/Wireless_802_11_Phy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                    	   ;# link layer type
set val(ant)            Antenna/DirAntenna         ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             3                          ;# number of mobilenodes
set val(rp)             WLSTATIC                       ;# routing protocol
set val(ni)             1

# ======================================================================
# Main Program
# ======================================================================

# Initialize Global Variables
set ns_		[new Simulator]
$ns_ use-newtrace
set tracefd     [open simple.tr w]
#set par 	[open param.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]
$topo load_flatgrid 100000 100000

# configure node
        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel [new $val(chan)] \
			 -topoInstance $topo \
			 -agentTrace OFF \
			 -routerTrace OFF \
			 -macTrace ON \
			 -numif  $val(ni) \ 

create-god 3

proc create_node { x y z } {
	global ns_
	Mac/802_11 set dataRate_	11mb
	Mac/802_11 set basicRate_	1mb
        Mac/802_11 MAC_RTSThreshold 2500
	set newnode [$ns_ node]
	$newnode random-motion 0
	$newnode set X_ $x
	$newnode set Y_ $y
	$newnode set Z_ $z

	return $newnode
}

proc create_cbr_connection { from to startTime interval packetSize } {
	global ns_
	set udp0 [new Agent/UDP]
	set src [new Application/Traffic/CBR]
	$udp0 set packetSize_ $packetSize
	$src set packetSize_ $packetSize
	$src set interval_ $interval

	set sink [new Agent/Null]

	$ns_ attach-agent $from $udp0
	$src attach-agent $udp0
	$ns_ attach-agent $to $sink

	$ns_ connect $udp0 $sink
	$ns_ at $startTime "$src start"
	return $udp0
}

#node(0)
$ns_ node-config  -numif 1
set node_(0) [create_node 0 0 0]
[$node_(0) set netif_(0)] set channel_number_ 1
[$node_(0) set netif_(0)] set Pt_  0.2
[$node_(0) set mac_(0)] AirPropagationTime 0.000040
set a [new Antenna/DirAntenna]
$a setType 1
$a setAngle 0
[$node_(0) set netif_(0)] dir-antenna $a

#node(1)
$ns_ node-config  -numif 2
set node_(1) [create_node 10000 0 0]
[$node_(1) set netif_(0)] set channel_number_ 1
[$node_(1) set netif_(0)] set Pt_  0.2
[$node_(1) set mac_(0)] AirPropagationTime 0.000040
set a0 [new Antenna/DirAntenna]
$a0 setType 1
$a0 setAngle 180
[$node_(1) set netif_(0)] dir-antenna $a0

[$node_(1) set netif_(1)] set channel_number_ 1
[$node_(1) set netif_(1)] set Pt_  0.2
[$node_(1) set mac_(1)] AirPropagationTime 0.000040
set a1 [new Antenna/DirAntenna]
$a1 setType 1
$a1 setAngle 0
[$node_(1) set netif_(1)] dir-antenna $a1

#node(2)
$ns_ node-config  -numif 1
set node_(2) [create_node 21000 0 0]
[$node_(2) set netif_(0)] set channel_number_ 1
[$node_(2) set netif_(0)] set Pt_  0.2
[$node_(2) set mac_(0)] AirPropagationTime 0.000040
set a2 [new Antenna/DirAntenna]
$a2 setType 1
$a2 setAngle 180
[$node_(2) set netif_(0)] dir-antenna $a2


#These following set of commands manually makes a routing table for "wlstatic"
#the syntax is as follows:
#[$node_(0) set ragent_] addstaticroute <number of hops> <next hop> <destination node> <interface to use>
[$node_(0) set ragent_] addstaticroute 1 1 1 0
[$node_(0) set ragent_] addstaticroute 2 1 2 0
[$node_(1) set ragent_] addstaticroute 1 0 0 0
[$node_(1) set ragent_] addstaticroute 1 2 2 1
[$node_(2) set ragent_] addstaticroute 1 1 1 0
[$node_(2) set ragent_] addstaticroute 2 1 0 0

set cbr [create_cbr_connection $node_(0) $node_(2) 1.0 0.002 1500]
#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 2 "$node_($i) reset";
}
$ns_ at 2 "stop"
$ns_ at 2.1 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd 
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run

