# Test for 802.11 nodes.
# @author rouil
# @date 10/25/2005
# Test file for wimax
# Scenario: Communication between MN and Sink Node with MN attached to BS.
#           - Using grep ^r out.res | grep MAC | grep -c cbr you can see the number of
#           mac packets received at the destination (100 packets).
#           - Using grep ^s out.res | grep MAC | grep -c cbr you can see the number of
#           mac packets sent. By default the scheduler uses 64QAM_3_4 for
#           modulation. Using lower modulation can result in packet fragmentation
#           so the number of packets sent can increase (ex. 402 using QPSK_1_2)
#           - Using grep "1 0 cbr" out.res | grep -c ^r shows the number of packets
#           received at the destination.
#
# Topology scenario:
#
#
#	        |-----|
#	        | MN0 |                 ; 1.0.1
#	        |-----|
#
#
#		  (^)
#		   |
#	    |--------------|
#           | Base Station | 		; 1.0.0
#           |--------------|
#	    	   |
#	    	   |
#	     |-----------|
#            | Sink node | 		; 0.0.0
#            |-----------|
#

#check input parameters
if {$argc != 0} {
	puts ""
	puts "Wrong Number of Arguments! No arguments in this topology"
	puts ""
	exit (1)
}

# set global variables
set nb_mn 6				;# max number of mobile node
set nb_rs 3                             ;# max number of relay station
set nb_sn 6                             ;# max number of source node
set packet_size	1500			;# packet size in bytes at CBR applications
set output_dir .
set gap_size 1 ;#compute gap size between packets
puts "gap size=$gap_size"
set traffic_start 50
set traffic_stop  100
set simulation_stop 110

#define debug values
Mac/802_16 set debug_ 0
Mac/802_16 set print_stats_ 0
#Mac/802_16 set rtg_ 20
#Mac/802_16 set ttg_ 20
#Mac/802_16 set frame_duration_ 0.004
Mac/802_16 set client_timeout_ 110 ;#to avoid BS disconnecting the SS since the traffic starts a 100s
Phy/WirelessPhy/OFDM set g_ 0.25

#define coverage area for base station: 20m coverage
Phy/WirelessPhy set Pt_ 0.025
Phy/WirelessPhy set RXThresh_ 2.025e-12 ;#500m radius
Phy/WirelessPhy set CSThresh_ [expr 0.9*[Phy/WirelessPhy set RXThresh_]]

# Parameter for wireless nodes
set opt(chan)           Channel/WirelessChannel    ;# channel type
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)          Phy/WirelessPhy/OFDM       ;# network interface type
set opt(mac)            Mac/802_16/BS              ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)             LL                         ;# link layer type
set opt(ant)            Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)         50              	   ;# max packet in ifq
set opt(adhocRouting)   DSDV                       ;# routing protocol

set opt(x)		1100			   ;# X dimension of the topography
set opt(y)		1100			   ;# Y dimension of the topography

Mac/802_11 set basicRate_ 11Mb
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set bandwidth_ 11Mb

#defines function for flushing and closing files
proc finish {} {
        global ns tf output_dir nb_mn
        $ns flush-trace
        close $tf
        puts "Simulation done."
	exit 0
}

#create the simulator
set ns [new Simulator]
$ns use-newtrace

#open file for trace
set tf [open $output_dir/out.res w]
$ns trace-all $tf
puts "Output file configured"

#create the topography
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
#puts "Topology created"

# Create God
create-god [expr ($nb_mn + $nb_sn + $nb_rs + 1)]				;# nb_sn + nb_mn + nb_rs + 1 (base station)
#puts "God node created"

# set up for hierarchical routing (needed for routing over a basestation)
#puts "start hierarchical addressing"
$ns node-config -addressType hierarchical
AddrParams set domain_num_ 2          			;# domain number
lappend cluster_num 1 1            			;# cluster number for each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel $nb_sn [expr ($nb_mn+$nb_rs+1)] 		;# number of nodes for each cluster
AddrParams set nodes_num_ $eilastlevel
puts "Configuration of hierarchical addressing done"

for {set i 0} {$i < $nb_sn} {incr i} {
  set sinkNode_($i) [$ns node 0.0.[expr $i]]
  $sinkNode_($i) set X_ 50.0
  $sinkNode_($i) set Y_ 50.0
  $sinkNode_($i) set Z_ 0.0
}

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
                 -routerTrace ON \
                 -macTrace ON  \
                 -movementTrace OFF
#puts "Configuration of base station"

set bstation [$ns node 1.0.0]
$bstation random-motion 0
#puts "Base-Station node created"
#provide some co-ord (fixed) to base station node
$bstation set X_ 550.0
$bstation set Y_ 550.0
$bstation set Z_ 0.0
[$bstation set mac_(0)] set-channel 0

$ns node-config -macType Mac/802_16/RS \
                -wiredRouting OFF \
                -macTrace ON
for {set i 0} {$i < $nb_rs} {incr i} {
  # creation of RS's access channel
  set rstation [$ns node 1.0.[expr $i + 1]]
  $rstation set X_ 340.0
  $rstation set Y_ 550.0
  $rstation set Z_ 0.0
  [$rstation set mac_(0)] set-channel [expr $i + 1]   ;# RS uses this channel to communicate with MSs
  [$rstation set mac_(0)] set-relay-channel 0   ;# RS uses this channel to communicate with BS
}


for {set i 0} {$i < $nb_sn} {incr i} {
  # create the link between sink node and base station
  $ns duplex-link $sinkNode_($i) $bstation 100Mb 1ms DropTail
}


# creation of the mobile nodes
$ns node-config -macType Mac/802_16/SS \
                -wiredRouting OFF \
                -macTrace ON  				;# Mobile nodes cannot do routing.
for {set i 0} {$i < $nb_mn} {incr i} {
	set wl_node_($i) [$ns node 1.0.[expr $i + $nb_rs + 1]] 	;# create the node with given @.
	$wl_node_($i) random-motion 0			;# disable random motion
	$wl_node_($i) base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation

	#compute position of the node
        $wl_node_($i) set X_ 100.0
	$wl_node_($i) set Y_ 550.0
	$wl_node_($i) set Z_ 0.0
        #$ns at 0 "$wl_node_($i) setdest 1060.0 550.0 1.0"
        puts "wireless node $i created ..."			;# debug info

        [$wl_node_($i) set mac_(0)] set-channel [expr $i/2 + 1]
        [$wl_node_($i) set mac_(0)] set-diuc 7   ;# Change the node profile here (7=64QAM_3_4)

        #create source traffic
	#Create a TCP agent and attach it to node n0
	set tcp_($i) [new Agent/TCP/Reno]
	$ns attach-agent $sinkNode_($i) $tcp_($i)

	#create an sink into the sink node
	# Create the Null agent to sink traffic
	set sink_($i) [new Agent/TCPSink]
	$ns attach-agent $wl_node_($i) $sink_($i)

	# Attach the 2 agents
	$ns connect $tcp_($i) $sink_($i)

	# Create a CBR traffic source and attach it to udp0
	set ftp_($i) [new Application/FTP]
	$ftp_($i) attach-agent $tcp_($i)

}

# Traffic scenario: if all the nodes start talking at the same
# time, we may see packet loss due to bandwidth request collision

set diff 0.0
for {set i 0} {$i < $nb_mn} {incr i} {
    $ns at [expr $traffic_start+$i*$diff] "$ftp_($i) start"
    $ns at [expr $traffic_stop+$i*$diff] "$ftp_($i) stop"
}


$ns at $simulation_stop "finish"
#$ns at $simulation_stop "$ns halt"
# Run the simulation
puts "Running simulation for $nb_mn mobile nodes..."
$ns run

