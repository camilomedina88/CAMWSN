# Test for 802.16j nodes.
# @author Chung-Long Wu
# @date 04/30/2008
# Test file for wimax multi-hop relay networks
# Scenario: Communication between MNs and Source Nodes.  
#           MNs are attached to RSs, and RSs are attached to BS
#           - Using grep ^r out.res | grep MAC | grep -c tcp:  You can see the number of
#           mac packets received at the destination.
#           - Using grep ^s out.res | grep MAC | grep -c tcp:  You can see the number of
#           mac packets sent. By default the scheduler uses 64QAM_3_4 for
#           modulation. Using lower modulation can result in packet fragmentation
#           so the number of packets sent can increase (ex. 402 using QPSK_1_2)
#           - Using grep ^r out.res | grep MAC | grep tcp | grep -c 'Ni X':  You can see
#           the number of tcp packets received in the MAC layer.  X is the ID of Node X.
#
# Topology scenario:
#
#	        |-----|
#	        | MNs |           ; 5.0.3 ~ 5.0.7
#	        |-----|
#
#		  (^)
#		   |
#	    |---------------|
#           | Relay Stations|     ; 5.0.1 ~ 5.0.2
#           |---------------|
#		  (^)
#		   |
#	    |---------------|
#           |  Base Station |     ; 5.0.0
#           |---------------|
#	    	   |
#	    	   |
#           |---------------|
#           |  Source Nodes |     ; 0.0.0 ~ 4.0.0
#           |---------------|
#

# Check input parameters
if {$argc != 0} {
	puts ""
	puts "Wrong Number of Arguments! No arguments in this topology"
	puts ""
	exit (1)
}

# Set global variables
set nb_mn 4				;# max number of mobile node
set nb_rs 2                             ;# max number of relay station
set nb_sn 4                             ;# max number of source node
set packet_size	1500			;# packet size in bytes at CBR applications
set output_dir .
set gap_size 1 ;#compute gap size between packets
#puts "gap size=$gap_size"
set traffic_start 10
set traffic_stop  100
set simulation_stop 110

# Define debug values
Mac/802_16 set debug_ 0
Mac/802_16 set print_stats_ 0
Mac/802_16 set queue_measure_ 0
Mac/802_16 set client_timeout_ 110 ;#to avoid BS disconnecting the SS since the traffic starts a 100s
Mac/802_16 set ITU_PDP_         2
Phy/WirelessPhy/OFDM set g_ 0.25

# Define coverage area for base station: 20m coverage
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

# Defines function for flushing and closing files
proc finish {} {
  global ns tf output_dir nb_mn
  $ns flush-trace
  close $tf
  puts "Simulation done."
  exit 0
}

# Create the simulator
set ns [new Simulator]
$ns use-newtrace

# Open file for trace
set tf [open $output_dir/out.res w]
$ns trace-all $tf
puts "Output file configured"

# Create the topography
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
#puts "Topology created"

# Create God
create-god [expr ($nb_mn + $nb_sn + $nb_rs + 1)]				;# nb_sn + nb_mn + nb_rs + 1 (base station)
#puts "God node created"

# Set up for hierarchical routing (needed for routing over a basestation)
# puts "start hierarchical addressing"
$ns node-config -addressType hierarchical
AddrParams set domain_num_ [expr $nb_sn+1]          			;# domain number
lappend cluster_num 1 1 1 1 1            			;# cluster number for each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 1 1 [expr ($nb_mn+$nb_rs+1)] 		;# number of nodes for each cluster
AddrParams set nodes_num_ $eilastlevel
puts "Configuration of hierarchical addressing done"

# Create the source nodes
for {set i 0} {$i < ($nb_sn)} {incr i} {
  set sourceNode_($i) [$ns node $i.0.0]
  $sourceNode_($i) set X_ 50.0
  $sourceNode_($i) set Y_ 50.0
  $sourceNode_($i) set Z_ 0.0
}

# Create the Access Point (Base station)
$ns node-config -adhocRouting $opt(adhocRouting) \
                -llType $opt(ll) \
                -macType $opt(mac) \
                -ifqType $opt(ifq) \
                -ifqLen $opt(ifqlen) \
                -antType $opt(ant) \
                -propType $opt(prop) \
                -phyType $opt(netif) \
                -channel [new $opt(chan)] \
                -topoInstance $topo \
                -wiredRouting ON \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace ON  \
                -movementTrace OFF
#puts "Configuration of base station"

set bstation [$ns node $nb_sn.0.0]
$bstation random-motion 0
$bstation set X_ 550.0
$bstation set Y_ 550.0
$bstation set Z_ 0.0
[$bstation set mac_(0)] set-channel 0
#puts "Base-Station node created"

# Create the links between source nodes and base station
for {set i 0} {$i < $nb_sn} {incr i} {
  $ns duplex-link $sourceNode_($i) $bstation 100Mb 1ms DropTail
}

# Creation of RSs' access and relay channel
$ns node-config -macType Mac/802_16/RS \
                -wiredRouting OFF \
                -macTrace ON
for {set i 0} {$i < $nb_rs} {incr i} {
  set rstation_($i) [$ns node $nb_sn.0.[expr $i + 1]]
  $rstation_($i) set X_ 340.0
  $rstation_($i) set Y_ 550.0
  $rstation_($i) set Z_ 0.0
  [$rstation_($i) set mac_(0)] set-channel [expr $i + 1]   ;# RS uses this channel to communicate with MSs
  [$rstation_($i) set mac_(0)] set-relay-channel 0   ;# RS uses this channel to communicate with BS
}

# Creation of the mobile nodes
$ns node-config -macType Mac/802_16/SS \
                -wiredRouting OFF \
                -macTrace ON  				;# Mobile nodes cannot do routing.
for {set i 0} {$i < $nb_mn} {incr i} {
  set wl_node_($i) [$ns node $nb_sn.0.[expr $i + $nb_rs + 1]] 	;# create the node with given @.
  $wl_node_($i) random-motion 0			;# disable random motion
  $wl_node_($i) base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation

  # Compute position of the node
  $wl_node_($i) set X_ 100.0
  $wl_node_($i) set Y_ 550.0
  $wl_node_($i) set Z_ 0.0
  #$ns at 0 "$wl_node_($i) setdest 1060.0 550.0 1.0"
  puts "wireless node $i created and its' channel is [expr $i/2+1]"			;# debug info

  [$wl_node_($i) set mac_(0)] set-channel [expr $i/2 + 1]
  [$wl_node_($i) set mac_(0)] set-diuc 7   ;# Change the node profile here (7=64QAM_3_4)

  # Create source traffic
  # Create a TCP agent and attach it to node n0
  set tcp_($i) [new Agent/TCP/Reno]
  $ns attach-agent $sourceNode_($i) $tcp_($i)

  # Create an sink into the wireless node
  set sink_($i) [new Agent/TCPSink]
  $ns attach-agent $wl_node_($i) $sink_($i)

  # The 2 agents are connected
  $ns connect $tcp_($i) $sink_($i)

  # Create a FTP traffic source and attach it to tcp_($i)
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

# Stop the simulation at the $simulation_stop
$ns at $simulation_stop "finish"

# Run the simulation
puts "Running simulation for $nb_mn mobile nodes..."
$ns run

