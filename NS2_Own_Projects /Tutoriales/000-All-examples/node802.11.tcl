# Test datarate for 802.11 nodes with different modulations.
# @author rouil
# @date 02/26/2007

#
# Topology scenario:
#
#
#	        |-----|               |-----|
#	        | MN0 |               | MN1 |
#	        |-----|               |-----|
#
#
#
#		  (^)                   (^)
#		   |                     |
#	    |--------------|      |--------------|  
#           |     AP 0     | 	  |     AP 1     |     
#           |--------------|      |--------------|
#	    	   |             /
#	    	   |            /
#	     |-----------|     /
#            | Sink node |____/ 		; node 0
#            |-----------|
#
# To see the number of packets dropped during simulation, execute "grep -c ^d out.res"


#check input parameters
if {$argc != 0} {
	puts ""
	puts "Wrong Number of Arguments! No argument in this script"
	puts ""
	puts ""
	puts ""
	exit
}

# set global variables
set nb_mn 4 				;# number of mobile node
set packet_size	1000			;# packet size in bytes at CBR applications 
set output_dir .
set gap_size 0.001
set traffic_start 2
set traffic_stop  5
set simulation_stop 5

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
#Mac/802_11 set bandwidth_ 1Mb
Mac/802_11 set RTSThreshold_  30000
Mac/802_11 set debug_ 1


#defines function for flushing and closing files
proc finish {} {
        global ns tf output_dir nb_mn
        $ns flush-trace
	close $tf
       	exit 
}

#create the simulator
set ns [new Simulator]
$ns use-newtrace

#create the topography
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
#puts "Topology created"

#open file for trace
set tf [open $output_dir/out.res w]
$ns trace-all $tf
#puts "Output file configured"

# set up for hierarchical routing (needed for routing over a basestation)
#puts "start hierarchical addressing"
$ns node-config -addressType hierarchical
AddrParams set domain_num_ 3          			;# domain number
lappend cluster_num 1 1 1           			;# cluster number for each domain 
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 2 2 ;# number of nodes for each cluster 
AddrParams set nodes_num_ $eilastlevel
puts "Configuration of hierarchical addressing done"

# Create God
create-god 4				;# nb_mn + 2 (base station and sink node)
#puts "God node created"

#creates the sink node in first addressing space.
set sinkNode [$ns node 0.0.0]
#provide some co-ord (fixed) to sink node
$sinkNode set X_ 50.0
$sinkNode set Y_ 10.0
$sinkNode set Z_ 0.0
#puts "sink node created"

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
#puts "Configuration of base station"

set bstation [$ns node 1.0.0]  
$bstation random-motion 0
#provide some co-ord (fixed) to base station node
$bstation set X_ 50.0
$bstation set Y_ 50.0
$bstation set Z_ 0.0
set bstationMac [$bstation getMac 0]
set AP_ADDR_0 [$bstationMac id]
$bstationMac bss_id $AP_ADDR_0
$bstationMac set-channel 1
$bstationMac enable-beacon
[$bstation set netif_(0)] setTechno 802.11
puts "Base-Station node AP0 created"

# creation of the mobile nodes
$ns node-config -wiredRouting OFF \
                -macTrace ON  				;# Mobile nodes cannot do routing.
for {set i 0} {$i < $nb_mn} {incr i} {
    if { $i == 0 } { 
	Mac/802_11 set dataRate_ 1Mb
    } else {
	Mac/802_11 set dataRate_ 11Mb
    }


	set wl_node_($i) [$ns node 1.0.[expr $i + 2]] 	;# create the node with given @.	
	$wl_node_($i) random-motion 0			;# disable random motion
#	puts "wireless node $i created ..."			;# debug info
	$wl_node_($i) base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation
	$wl_node_($i) set X_ [expr 40.0+$i]
	$wl_node_($i) set Y_ 50.0
	$wl_node_($i) set Z_ 0.0
        [$wl_node_($i) set mac_(0)] set-channel 1
        [$wl_node_($i) set netif_(0)] setTechno 802.11

        set j [expr 2*$i]
        #create source traffic
	#Create a UDP agent and attach it to node n0
	set udp_($j) [new Agent/UDP]
	$udp_($j) set packetSize_ 1500
	$ns attach-agent $wl_node_($i) $udp_($j)

	# Create a CBR traffic source and attach it to udp0
	set cbr_($j) [new Application/Traffic/CBR]
	$cbr_($j) set packetSize_ $packet_size
	$cbr_($j) set interval_ $gap_size
	$cbr_($j) attach-agent $udp_($j)

	#create an sink into the sink node

	# Create the Null agent to sink traffic
	set null_($j) [new Agent/Null] 
	$ns attach-agent $sinkNode $null_($j)
	
	# Attach the 2 agents
	$ns connect $udp_($j) $null_($j)

        set j [expr 2*$i+1]
        puts "J=$j"
        #create source traffic
        #Create a UDP agent and attach it to node n0
        set udp_($j) [new Agent/UDP]
        $udp_($j) set packetSize_ 1500
        $ns attach-agent $sinkNode $udp_($j)

        # Create a CBR traffic source and attach it to udp0
        set cbr_($j) [new Application/Traffic/CBR]
        $cbr_($j) set packetSize_ $packet_size
        $cbr_($j) set interval_ $gap_size
        $cbr_($j) attach-agent $udp_($j)

        #create an sink into the sink node

        # Create the Null agent to sink traffic
        set null_($j) [new Agent/Null]
        $ns attach-agent $wl_node_($i) $null_($j)

        # Attach the 2 agents
        $ns connect $udp_($j) $null_($j)
}

# create the link between sink node and base station
$ns duplex-link $sinkNode $bstation 100Mb 1ms DropTail

# Traffic scenario: here the all start talking at the same time
for {set i 0} {$i < 2*$nb_mn} {incr i} {
    $ns at [expr $traffic_start + 0.003 * $i] "$cbr_($i) start"
    $ns at $traffic_stop "$cbr_($i) stop"
}


$ns at $simulation_stop "finish"
#$ns at $simulation_stop "$ns halt"
# Run the simulation
puts "Running simulation for $nb_mn mobile nodes..."
$ns run
puts "Simulation done."
