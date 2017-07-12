#variable settings
set opt(debug)          0
set opt(bwtracetime)    0.01
set opt(dfLinkDelay)    1ms	;#default link delay
set opt(cnLinkDelay)    10ms	;#cn-lma link delay
set opt(agentType)      Agent/UDP
set opt(sinkType)       Agent/LossMonitor
set opt(trafficType)    Application/Traffic/CBR

#if traffic is CBR
set opt(cbrInterval)    0.001
set opt(cbrPacketSize)  1000

# Parameter for wireless nodes
set opt(chan)           Channel/WirelessChannel    ;# channel type
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)          Phy/WirelessPhy            ;# network interface type
set opt(mac)            Mac/802_11                 ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)             LL                         ;# link layer type
set opt(ant)            Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)         50              	   ;# max packet in ifq
set opt(adhocRouting)   DSDV                       ;# routing protocol

set opt(x)		670			   ;# X dimension of the topography
set opt(y)		670			   ;# Y dimension of the topography

Mac/802_11 set basicRate_ 1Mb
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set RTSThreshold_  30000
Mac/802_11 set debug_ 0

#debug messages
Agent/PMIPv6 set debug_ $opt(debug)
Agent/PMIPv6/MAG set debug_ $opt(debug)
Agent/PMIPv6/LMA set debug_ $opt(debug)

#defines function for flushing and closing files
proc finish {} {
        global ns tf bf
        $ns flush-trace
				close $tf
				close $bf
				
       	exit 
}

proc record {} {
	global ns bf sink opt
	
	set time $opt(bwtracetime)
	
	set bw [$sink set bytes_]
	
	set now [$ns now]
	puts $bf "$now [expr $bw/$time*8/100000]"
	
	$sink set bytes_ 0
	$ns at [expr $now+$time] "record"
}

#create the simulator
set ns [new Simulator]

#give random seed
#ns-random 0

#create the topography
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

#open file for trace
set tf [open trace.out w]
$ns trace-all $tf

#open file for throughput trace
set bf [open throughput.out w]

# set up for hierarchical routing (needed for routing over a basestation)
$ns node-config -addressType hierarchical
AddrParams set domain_num_ 5          			;# domain number
AddrParams set cluster_num_ {1 1 1 1 1}
AddrParams set nodes_num_ {1 2 1 1 1}

# Create God
create-god 6

#creates the in first addressing space.
set router [$ns node 0.0.0]
$router set X_ 350.0
$router set Y_ 300.0
$router set Z_ 0.0

set lma [$ns node 1.0.0]
$lma set X_ 350.0
$lma set Y_ 100.0
$lma set Z_ 0.0

#attach Agent/PMIPv6/LMA to the LMA
set lma_pm [$lma install-lma]

set cn [$ns node 2.0.0]
$cn set X_ 500.0
$cn set Y_ 300.0
$cn set Z_ 0.0

#BE CAREFUL!. PMIPv6 agent must be installed before connecting link(duplex-link)
$ns duplex-link $cn $lma 100Mb $opt(cnLinkDelay) DropTail
$ns duplex-link $lma $router 100Mb $opt(dfLinkDelay) DropTail

#define coverage area for base station: 20m coverage
Phy/WirelessPhy set Pt_ 0.025
Phy/WirelessPhy set RXThresh_ 2.025e-12
Phy/WirelessPhy set CSThresh_ [expr 0.9*[Phy/WirelessPhy set RXThresh_]]

#creates the Access Point (Base station)
$ns node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop)    \
                 -phyType $opt(netif) \
                 -channel [new $opt(chan)] \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace ON  \
                 -movementTrace OFF

#create MAG1
set mag1 [$ns node 3.0.0]
$mag1 random-motion 0
$mag1 set X_ 100.0
$mag1 set Y_ 200.0
$mag1 set Z_ 0.0

#NIST settings
set mag1_mac [$mag1 getMac 0]
set mag1_addr [$mag1_mac id]
$mag1_mac bss_id $mag1_addr
$mag1_mac set-channel 1
$mag1_mac enable-beacon
[$mag1 set netif_(0)] setTechno 802.11

#install PMIPv6/MAG agent to the MAG1
set mag1_pm [$mag1 install-mag]
set lmaa [$lma node-addr]
$mag1_pm set-lmaa [AddrParams addr2id $lmaa]

#setup 802.11 MAC to support MN ATTACH Event
$mag1_mac set use_pmip6_ext_ 1
$mag1_mac pmip6-agent $mag1_pm

#Create MAG2
set mag2 [$ns node 4.0.0]
$mag2 random-motion 0
$mag2 set X_ 600.0
$mag2 set Y_ 200.0
$mag2 set Z_ 0.0

#NIST settings
set mag2_mac [$mag2 getMac 0]
set mag2_addr [$mag2_mac id]
$mag2_mac bss_id $mag2_addr
$mag2_mac set-channel 6
$mag2_mac enable-beacon
[$mag2 set netif_(0)] setTechno 802.11

#install PMIPv6/MAG agent to the MAG1
set mag2_pm [$mag2 install-mag]
$mag2_pm set-lmaa [AddrParams addr2id $lmaa]

#setup 802.11 MAC to support MN ATTACH Event
$mag2_mac set use_pmip6_ext_ 1
$mag2_mac pmip6-agent $mag2_pm

#ALSO, installing PMIPv6/MAG must come first before duplex-link
$ns duplex-link $mag1 $router 100Mb $opt(dfLinkDelay) DropTail
$ns duplex-link $mag2 $router 100Mb $opt(dfLinkDelay) DropTail

# creation of the mobile nodes
$ns node-config -wiredRouting OFF \
                -macTrace ON  				;# Mobile nodes cannot do routing.

Mac/802_11 set dataRate_ 11Mb

#Create mobile node
set mn [$ns node 1.0.1]
$mn random-motion 0
$mn base-station [AddrParams addr2id [$mag1 node-addr]]
$mn set X_ 100.0
$mn set Y_ 500.0
$mn set Z_ 0.0

#NIST settings
set mn_mac [$mn set mac_(0)]
[$mn set mac_(0)] set-channel 1
[$mn set netif_(0)] setTechno 802.11

#add MN-ID to the prefix_pool of LMA
#with ns-2, node's address cannot be changed.
#so, we use full MN's address as if it were MN's prefix
$lma_pm register-mn-addr [$mn_mac id] [AddrParams addr2id [$mn node-addr]]


#Traffic setup
set agent [new $opt(agentType)]
$agent set class_ 2
$ns attach-agent $cn $agent

set traffic [new $opt(trafficType)]
$traffic attach-agent $agent

if { $opt(trafficType) == "Application/Traffic/CBR" } {
	$traffic set packetSize_ $opt(cbrPacketSize)
	$traffic set interval_ $opt(cbrInterval)
}

set sink [new $opt(sinkType)]
$ns attach-agent $mn $sink

$ns connect $agent $sink

$ns at 0.0 "record"

$ns at 0.5 "$traffic start"
$ns at 19.5 "$traffic stop"

$ns at 1.0 "$mn setdest 600.00 500.00 50.00"
$ns at 20 "finish"

$ns run
