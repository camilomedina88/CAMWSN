#a simple script to test the setup

#define parameters
set val(chan)           Channel/Channel_802_11     ;# channel type
set val(prop)           Propagation/Shadowing      ;# radio-propagation model
set val(netif)          Phy/WirelessPhy/Wireless_802_11_Phy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                    	   ;# link layer type
set val(ant)            Antenna/DirAntenna         ;# antenna model
set val(ifqlen)         100                         ;# max packet in ifq
set val(nn)             2                          ;# number of mobilenodes
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
			 -agentTrace ON \
			 -routerTrace OFF \
			 -macTrace OFF \
			 -numif  $val(ni) \ 

create-god 2 

proc create_node { x y z } {
	global ns_ maxprg
	Mac/802_11 set dataRate_	11mb
	Mac/802_11 set basicRate_	1mb
        Mac/802_11 set RTSThreshold_    2500
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


proc create_tcp_connection { from to startTime } {
        global ns_ 
        set tcp [new Agent/TCP]
        set sink [new Agent/TCPSink]
        $ns_ attach-agent $from $tcp
        $ns_ attach-agent $to $sink
        $ns_ connect $tcp $sink
        set ftp [new Application/FTP]
        $ftp set packetSize_ 1500
        $ftp attach-agent $tcp
        $ns_ at  $startTime "$ftp start"
}

#node(0)
$ns_ node-config  -numif 1
set node_(0) [create_node 0 0 0]
[$node_(0) set netif_(0)] set channel_number_ 1
[$node_(0) set netif_(0)] set Pt_  0.5
[$node_(0) set mac_(0)] AirPropagationTime 0.000040
[$node_(0) set mac_(0)] AirPropagationConst 1
set a [new Antenna/DirAntenna]
$a setType 1
$a setAngle 0
[$node_(0) set netif_(0)] dir-antenna $a

#node(1)
$ns_ node-config  -numif 1
set node_(1) [create_node 10000 0 0]
[$node_(1) set netif_(0)] set channel_number_ 1
[$node_(1) set netif_(0)] set Pt_  0.5
[$node_(1) set mac_(0)] AirPropagationTime 0.000040
[$node_(1) set mac_(0)] AirPropagationConst 1
set a [new Antenna/DirAntenna]
$a setType 1
$a setAngle 180
[$node_(1) set netif_(0)] dir-antenna $a



#These following set of commands manually makes a routing table for "wlstatic"
#the syntax is as follows:
#[$node_(0) set ragent_] addstaticroute <number of hops> <next hop> <destination node> <interface to use>
[$node_(0) set ragent_] addstaticroute 1 1 1 0
[$node_(1) set ragent_] addstaticroute 1 0 0 0

#set mac_addr [[$node_(0) set mac_(0)] id]
#puts "mac address is $mac_addr"
#[$node_(1) set ll_(0)] add-arp-entry 0 $mac_addr

set cbr [create_cbr_connection $node_(1) $node_(0) 1.0 0.002 1500]
#set tcp [create_tcp_connection $node_(1) $node_(0) 0.0]
#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 5 "$node_($i) reset";
}
$ns_ at 5 "stop"
$ns_ at 5.1 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd 
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run

