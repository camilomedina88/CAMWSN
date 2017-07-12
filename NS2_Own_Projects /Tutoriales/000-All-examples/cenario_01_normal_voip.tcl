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
#	        | MNs |           ; 2.0.2 ~ 2.0.3
#	        |-----|
#
#		  (^)
#		   |
#	    |---------------|
#           | Relay Stations|     ; 2.0.1
#           |---------------|
#		  (^)
#		   |
#	    |---------------|
#           |  Base Station |     ; 2.0.0
#           |---------------|
#	    	   |
#	    	   |
#           |---------------|
#           |  Source Nodes |     ; 0.0.0 ~ 1.0.0
#           |---------------|
#

source functions.tcl

# Check input parameters
#if {$argc != 0} {
#	puts ""
#	puts "Wrong Number of Arguments! No arguments in this topology"
#	puts ""
#	exit (1)
#}

# Set global variables
set nb_mn [lindex $argv 1]		;# max number of mobile node
set nb_rs 1                             ;# max number of relay station
set nb_sn [lindex $argv 1]              ;# max number of source node
set packet_size	128			;# packet size in bytes at CBR applications
set output_dir .
set gap_size 1 ;#compute gap size between packets
set traffic_start 10
set traffic_stop  100
set simulation_stop 110

# Define debug values
Mac/802_16 set fbandwidth_           15e+6
Mac/802_16 set frame_duration_       0.0025
Mac/802_16 set algoritmo_ared_ 0 ;# define se utilizará algoritmo ARED para gerenciamento de filas (0 => NÃO, 1 => SIM)
Mac/802_16 set maximum_delay_ 9999 ;# delay ou latência máxima p/ aplicação => 999 s
Mac/802_16 set tolerated_jitter_ 9999 ;# jitter máximo tolerado => 999 s
Mac/802_16/BS set dlratio_ 0.5              ;# portion of the frame dedicated to downlink
Mac/802_16/SS set dlratio_ 0.5              ;# portion of the frame dedicated to downlink
Mac/802_16/RS set dlratio_ 0.5              ;# portion of the frame dedicated to downlink
Mac/802_16/BS set dl_acs_ratio_ 0.5
Mac/802_16/RS set dl_acs_ratio_ 0.5
Mac/802_16/SS set dl_acs_ratio_ 0.5
Mac/802_16/BS set ul_acs_ratio_ 0.5
Mac/802_16/RS set ul_acs_ratio_ 0.5
Mac/802_16/SS set ul_acs_ratio_ 0.5
Mac/802_16/BS set queue_size_ 100
Mac/802_16/BS set queue_length_ 100
#Mac/802_16/RS set queue_size_ 50
#Mac/802_16/RS set queue_length_ 50
Mac/802_16 set debug_ 0
Mac/802_16 set print_stats_ 0
Mac/802_16 set queue_measure_ 0
Mac/802_16 set min_th_ 1 ;# MR_min padrão 1
Mac/802_16 set max_th_ 2 ;# MR_max padrão 2
Mac/802_16 set record_queue_         0
Mac/802_16 set record_avg_queue_     0
Mac/802_16 set weighted_factor_      0.002 ;# novo
Mac/802_16 set client_timeout_ 110 ;#to avoid BS disconnecting the SS since the traffic starts a 100s
Mac/802_16 set ITU_PDP_         2 ;# novo
Phy/WirelessPhy/OFDM set g_ 0.25
WimaxScheduler/BS set use_drr_ 1
WimaxScheduler/RS set use_drr_ 1
WimaxScheduler/BS set update_pc_ 0 ;# Define se algoritmo utilizará contador de pausa
WimaxScheduler/RS set update_pc_ 0 ;# Define se algoritmo utilizará contador de pausa
WimaxScheduler/SS set update_pc_ 0 ;# Define se algoritmo utilizará contador de pausa
WimaxScheduler/BS set pc_ 2 ;# Define coeficiente de contador de pausa para congestionamento
WimaxScheduler/RS set pc_ 2 ;# Define coeficiente de contador de pausa para congestionamento
WimaxScheduler/SS set pc_ 2 ;# Define coeficiente de contador de pausa para congestionamento
WimaxScheduler/BS set adaptive_quantum_ 0 ;# Realiza cálculo de quantum adaptativo
WimaxScheduler/RS set adaptive_quantum_ 0
WimaxScheduler/SS set adaptive_quantum_ 0
WimaxScheduler/BS set quantum_ 500
WimaxScheduler/RS set quantum_ 500
WimaxScheduler/SS set quantum_ 500
WimaxScheduler/BS set quantum_original_ 500
WimaxScheduler/RS set quantum_original_ 500
WimaxScheduler/SS set quantum_original_ 500
RandomVariable/Pareto set avg_ 0.5
RandomVariable/Pareto set shape_ 1.5

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
set opt(ifqlen)         10000              	   ;# max packet in ifq
set opt(adhocRouting)   DSDV                       ;# routing protocol
set opt(x)		1100			   ;# X dimension of the topography
set opt(y)		1100			   ;# Y dimension of the topography

# Create the simulator
#set ns [new Simulator -multicast on]
set ns [new Simulator]
$ns use-newtrace

#$ns rtproto DV

# Open file for trace
set tf [open $output_dir/wimax_1RS_2SS_2SN_cenario_01_quantum_normal.tr w]
$ns trace-all $tf
#puts "Output file configured"

set arquivo_saida [lindex $argv 0] ;# define nome do arquivo de saida com vazão
# Open file for recording throughput
set throughput_rv_ [open $output_dir/$arquivo_saida w]

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

set cmd "lappend cluster_num 1"
for {set i 0} {$i < ($nb_sn)} {incr i} {
	set cmd [concat $cmd { 1}]
}
set cmd
#puts $cmd
eval $cmd

set cmd2 "lappend eilastlevel 1"
AddrParams set cluster_num_ $cluster_num
for {set i 0} {$i < [expr $nb_sn-1]} {incr i} {
	set cmd2 [concat $cmd2 { 1}]
}
set cmd2
set cmd2 [concat $cmd2 " [expr ($nb_mn+$nb_rs+1)]"]
#puts $cmd2
eval $cmd2

AddrParams set nodes_num_ $eilastlevel
puts "Configuration of hierarchical addressing done"

# Create the source nodes
for {set i 0} {$i < ($nb_sn)} {incr i} {
  #set sourceNode_($i) [$ns node 0.0.$i]
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
                -macTrace OFF  \
                -movementTrace OFF
#puts "Configuration of base station"

set bstation [$ns node $nb_sn.0.0]
$bstation random-motion 0
$bstation set X_ 550.0
$bstation set Y_ 550.0
$bstation set Z_ 0.0
[$bstation set mac_(0)] set-channel 0
#  set bs_sched [new WimaxScheduler/BS] ;# escalonador BS
#  [$bstation set mac_(0)] set-scheduler $bs_sched
#$bs_sched add-flow 2 0 1600 0

# Create the links between source nodes and base station
for {set i 0} {$i < $nb_sn} {incr i} {
  $ns duplex-link $sourceNode_($i) $bstation 100Mb 1ms DropTail
}

Mac/802_16/RS set queue_size_ 50
Mac/802_16/RS set queue_length_ 50

# Creation of RSs' access and relay channel
$ns node-config -macType Mac/802_16/RS \
                -wiredRouting OFF \
                -macTrace OFF
for {set i 0} {$i < $nb_rs} {incr i} {
  set rstation_($i) [$ns node $nb_sn.0.[expr $i + 1]]
  #set rstation_($i) [$ns node 0.0.[expr $i + 3 + $nb_sn]]
  $rstation_($i) set X_ 340.0
  $rstation_($i) set Y_ 550.0
  $rstation_($i) set Z_ 0.0
  [$rstation_($i) set mac_(0)] set-channel [expr $i + 1]   ;# RS uses this channel to communicate with MSs
  [$rstation_($i) set mac_(0)] set-relay-channel 0   ;# RS uses this channel to communicate with BS
#set-control-method  	// 0:  DL flow control (DLFC)
#	  		// 1:  Congestion-Aware (CA)
  [$rstation_($i) set mac_(0)] set-control-method 1
}

# Creation of the mobile nodes
$ns node-config -macType Mac/802_16/SS \
                -wiredRouting OFF \
                -macTrace OFF  				;# Mobile nodes cannot do routing.
for {set i 0} {$i < $nb_mn} {incr i} {
  set wl_node_($i) [$ns node $nb_sn.0.[expr $i + $nb_rs + 1]] 	;# create the node with given @.
  #set wl_node_($i) [$ns node 0.0.[expr $i + 3 + $nb_sn + $nb_rs]]
  $wl_node_($i) random-motion 0			;# disable random motion
  $wl_node_($i) base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation

  # Compute position of the node
  $wl_node_($i) set X_ 100.0
  $wl_node_($i) set Y_ 550.0
  $wl_node_($i) set Z_ 0.0
  #$ns at 0 "$wl_node_($i) setdest 1060.0 550.0 1.0"
  puts "wireless node $i created and its' channel is [expr $i/2+2]"			;# debug info
  #puts "wireless node $i created and its' channel is [expr 1/2+2]"			;# debug info

  #set ss_sched [new WimaxScheduler/SS] ;# escalonador SS
  #[$wl_node_($i) set mac_(0)] set-scheduler $ss_sched
  [$wl_node_($i) set mac_(0)] set-channel [expr $i/2 + 2]
  #[$wl_node_($i) set mac_(0)] set-channel [expr $i/10 + 1]
  [$wl_node_($i) set mac_(0)] set-diuc 7   ;# Change the node profile here (7=64QAM_3_4)

## add-flow TrafficPriority MinimumSustainedTrafficRate MAximumReservedTrafficRate ServiceFlowSchedulingType
##ServiceFlowSchedulingType: (0=>SERVICE_UGS), (1=>SERVICE_rtPS), (2=>SERVICE_ertPS), (3=>SERVICE_nrtPS), (4=>SERVICE_BE)
#$ss_sched add-flow 2 0 1600 $i

  # Create source traffic
  # Create a UDP agent and attach it to node n0
  set udp_($i) [new Agent/UDP]
  $ns attach-agent $sourceNode_($i) $udp_($i)
  $ns monitor-agent-trace $udp_($i)

  # Create an sink into the wireless node
  set sink_($i) [new Agent/LossMonitor]
  $ns attach-agent $wl_node_($i) $sink_($i)
  $ns monitor-agent-trace $sink_($i)

  # The 2 agents are connected
  $ns connect $udp_($i) $sink_($i)

  # Create a FTP traffic source and attach it to tcp_($i)
  set vbr_($i) [new Application/Traffic/CBR]
  $vbr_($i) set rate_ 64Kb
  $vbr_($i) set packetSize_ 240;
  $vbr_($i) attach-agent $udp_($i)
}

# Traffic scenario: if all the nodes start talking at the same
# time, we may see packet loss due to bandwidth request collision
set diff 0.1
for {set i 0} {$i < $nb_mn} {incr i} {
    $ns at [expr $traffic_start+$i*$diff] "$vbr_($i) start"
    $ns at [expr $traffic_stop+$i*$diff] "$vbr_($i) stop"
}

#$ns at 0.0 "record_throughput"

# Stop the simulation at the $simulation_stop
$ns at $simulation_stop "finish"

# Run the simulation
puts "Running simulation for $nb_mn mobile nodes..."
$ns run

