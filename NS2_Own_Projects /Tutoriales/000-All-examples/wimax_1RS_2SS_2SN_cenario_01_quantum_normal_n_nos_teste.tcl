source functions.tcl

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
Mac/802_16 set fbandwidth_           5e+6
Mac/802_16 set frame_duration_       0.008
Mac/802_16/BS set dlratio_ 0.5              ;# portion of the frame dedicated to downlink
Mac/802_16/SS set dlratio_ 0.5              ;# portion of the frame dedicated to downlink
Mac/802_16/RS set dlratio_ 0.5              ;# portion of the frame dedicated to downlink
Mac/802_16/BS set queue_size_ 100
Mac/802_16/BS set queue_length_ 100
Mac/802_16 set debug_ 0
Mac/802_16 set print_stats_ 0
Mac/802_16 set queue_measure_ 0
Mac/802_16 set min_th_ 30 ;# MR_min padrão 1
Mac/802_16 set max_th_ 40 ;# MR_max padrão 2
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
set opt(ifqlen)         50              	   ;# max packet in ifq
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

#puts "God node created"

# Set up for hierarchical routing (needed for routing over a basestation)
# puts "start hierarchical addressing"
$ns node-config -addressType hierarchical
#$ns node-config -addressType expanded
#$ns node-config -addressType flat or expanded
AddrParams set domain_num_ 2
lappend cluster_num 1 1            			;# cluster number for each domain 
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel [expr $nb_sn] [expr 1+$nb_mn+$nb_rs]
AddrParams set nodes_num_ $eilastlevel

create-god 52

puts "Configuration of hierarchical addressing done"

# Create the source nodes
for {set i 0} {$i < $nb_sn} {incr i} {
  set sourceNode_($i) [$ns node 1.0.[expr $i+2]]
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

set bstation [$ns node 0.0.0]
$bstation random-motion 0
$bstation set X_ 550.0
$bstation set Y_ 550.0
$bstation set Z_ 0.0
[$bstation set mac_(0)] set-channel 0

# Create the links between source nodes and base station
for {set i 0} {$i < $nb_sn} {incr i} {
  $ns duplex-link $sourceNode_($i) $bstation 100Mb 1ms DropTail
}

Mac/802_16/RS set queue_size_ 50
Mac/802_16/RS set queue_length_ 50

# Creation of RSs' access and relay channel
$ns node-config -macType Mac/802_16/RS \
                -wiredRouting OFF \
                -macTrace ON
for {set i 0} {$i < $nb_rs} {incr i} {
  set rstation_($i) [$ns node 0.0.[expr $i + 1]]
  $rstation_($i) set X_ 340.0
  $rstation_($i) set Y_ 550.0
  $rstation_($i) set Z_ 0.0
  [$rstation_($i) set mac_(0)] set-channel [expr $i + 1]   ;# RS uses this channel to communicate with MSs
  [$rstation_($i) set mac_(0)] set-relay-channel 0   ;# RS uses this channel to communicate with BS
  #[$rstation_($i) set mac_(0)] add-ms-period-diuc 10.0 20.0 2 7    ;# start; end; MS address; DIUC
  #[$rstation_($i) set mac_(0)] add-ms-period-diuc 20.0 30.0 2 2
  #[$rstation_($i) set mac_(0)] add-ms-period-diuc 30.0 40.0 2 1
  #[$rstation_($i) set mac_(0)] add-ms-period-diuc 40.0 50.0 2 2
  #[$rstation_($i) set mac_(0)] add-ms-period-diuc 50.0 60.0 2 7
#set-control-method  	// 0:  DL flow control (DLFC)
#	  		// 1:  Congestion-Aware (CA)
  [$rstation_($i) set mac_(0)] set-control-method 1
  #$rstation_($i) insert-entry [new RtModule/Hier] [new Classifier/Hier]
}

# Creation of the mobile nodes
$ns node-config -macType Mac/802_16/SS \
                -wiredRouting OFF \
                -macTrace ON  				;# Mobile nodes cannot do routing.
for {set i 0} {$i < $nb_mn} {incr i} {
  set wl_node_($i) [$ns node 0.0.[expr $i + $nb_rs + 1]] 	;# create the node with given @.
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
  #$wl_node_($i) insert-entry [new RtModule/Hier] [new Classifier/Hier]

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
  set vbr_($i) [new Application/Traffic/VBR]
  $vbr_($i) set rate_ 1500Kb ;# corresponds to interval of 3.75ms
  $vbr_($i) set rate_dev_ 0.75;
  $vbr_($i) set rate_time_ 2.0;
  $vbr_($i) set burst_time_ 1.0;
  $vbr_($i) set n_o_changes_ 10;
  $vbr_($i) set time_dev_ 1.0;
  $vbr_($i) set constant_ false;
  $vbr_($i) set maxrate_ 1875Kb;
  $vbr_($i) set packetSize_ 128;
  $vbr_($i) set maxpkts_ 268435456; # 0x10000000 
  $vbr_($i) attach-agent $udp_($i)
}

# Traffic scenario: if all the nodes start talking at the same
# time, we may see packet loss due to bandwidth request collision
set diff 0.1
for {set i 0} {$i < $nb_mn} {incr i} {
    $ns at [expr $traffic_start+$i*$diff] "$vbr_($i) start"
    $ns at [expr $traffic_stop+$i*$diff] "$vbr_($i) stop"
}

$ns at 0.0 "record_throughput"

# Stop the simulation at the $simulation_stop
$ns at $simulation_stop "finish"

# Run the simulation
puts "Running simulation for $nb_mn mobile nodes..."
$ns run

