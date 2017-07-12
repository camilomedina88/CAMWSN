# Test script to evaluate datarate in 802.16 networks.
# @author rouil
# Scenario: Communication between MN and Sink Node with MN attached to BS.

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
if {$argc != 3} {
	puts ""
	puts "Wrong Number of Arguments! 3 arguments for this script"
	puts "Usage: ns datarate.tcl modulation cyclic_prefix "
        puts "modulation: OFDM_BPSK_1_2, OFDM_QPSK_1_2, OFDM_QPSK_3_4"
        puts "            OFDM_16QAM_1_2, OFDM_16QAM_3_4, OFDM_64QAM_2_3, OFDM_64QAM_3_4"
        puts "cyclic_prefix: 0.25, 0.125, 0.0625, 0.03125"
        puts "rtPS scheduler: NIST_RR, RR, mSIR, WRR, TRS_RR, TRS_mSIR"
	exit 
}

# set global variables
set output_dir .
set traffic_start 20
set traffic_stop  70
set simulation_stop 70

# Configure Wimax
Mac/802_16 set debug_ 0
Mac/802_16 set frame_duration_ 0.020

#define coverage area for base station: 20m coverage 
Phy/WirelessPhy/OFDM set g_ [lindex $argv 1]
Phy/WirelessPhy set Pt_ 0.025
Phy/WirelessPhy set RXThresh_ 2.025e-12 ;# 500m radius
Phy/WirelessPhy set CSThresh_ [expr 0.9*[Phy/WirelessPhy set RXThresh_]]

# Parameter for wireless nodes
set opt(chan)           Channel/WirelessChannel    ;# channel type
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)          Phy/WirelessPhy/OFDM       ;# network interface type
set opt(mac)            Mac/802_16                 ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)             LL                         ;# link layer type
set opt(ant)            Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)         50              	   ;# max packet in ifq
set opt(adhocRouting)   DSDV                       ;# routing protocol

set opt(x)		1100			   ;# X dimension of the topography
set opt(y)		1100			   ;# Y dimension of the topography

#defines function for flushing and closing files
proc finish {} {
        global ns tf output_dir nb_mn
        $ns flush-trace
        close $tf
	exit 0
}

#create the simulator
set ns [new Simulator]
$ns use-newtrace

#create the topography
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
#puts "Topology created"

#open file for trace
set tf [open $output_dir/8MN_out.res w]
$ns trace-all $tf
#puts "Output file configured"

# set up for hierarchical routing (needed for routing over a basestation)
$ns node-config -addressType hierarchical
AddrParams set domain_num_ 2          			;# domain number
lappend cluster_num 1 1            			;# cluster number for each domain 
AddrParams set cluster_num_ $cluster_num
#Aymen#lappend eilastlevel 1 2 		;# number of nodes for each cluster (1 for sink and one for mobile node + base station
lappend eilastlevel 1 29

AddrParams set nodes_num_ $eilastlevel
puts "Configuration of hierarchical addressing done"

# Create God
create-god 30

#creates the sink node in first address space.
set sinkNode [$ns node 0.0.0]
puts "sink node created"

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
                 -agentTrace OFF \
                 -routerTrace OFF \
                 -macTrace ON  \
                 -movementTrace OFF






#puts "Configuration of base station"

set bstation [$ns node 1.0.0]  
$bstation random-motion 0
#provide some co-ord (fixed) to base station node
$bstation set X_ 550.0
$bstation set Y_ 550.0
$bstation set Z_ 0.0
set clas [new SDUClassifier/Dest]
[$bstation set mac_(0)] add-classifier $clas


#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
set bs_sched [new WimaxScheduler/BS]
$bs_sched set-default-modulation [lindex $argv 0]     ;#OFDM_BPSK_1_2
[$bstation set mac_(0)] set-scheduler $bs_sched
[$bstation set mac_(0)] set-channel 0
puts "Base-Station node created"



# create the link between sink node and base station
$ns duplex-link $sinkNode $bstation 100Mb 1ms DropTail
######################












########################################################

set nb_UGS 0



#### interval_ ########
set interval_ugs(1) 0.15

set interval_ugs(2) 0.15
set interval_ugs(3) 0.15
set interval_ugs(4) 0.15
set interval_ugs(5) 0.15
set interval_ugs(6) 0.04
set interval_ugs(7) 0.05
set interval_ugs(8) 0.1
set interval_ugs(9) 0.1
#######################


#### SNR #########
set SNR_ugs(1) 9.5

set SNR_ugs(2) 12.5
set SNR_ugs(3) 16.5
set SNR_ugs(4) 20.5
set SNR_ugs(5) 22.5
set SNR_ugs(6) 12.5
set SNR_ugs(7) 12.5
set SNR_ugs(8) 12.5
set SNR_ugs(9) 12.5
##################


$ns node-config -wiredRouting OFF \
                -macTrace ON  				;# Mobile nodes cannot do routing.

for {set j 1} {$j < [expr $nb_UGS + 1]} {incr j} {
set wl_node_ugs($j) [$ns node 1.0.[expr $j]] 	;# create the node with given @.	

$wl_node_ugs($j) random-motion 0			;# disable random motion
$wl_node_ugs($j) base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation
#compute position of the node
$wl_node_ugs($j) set X_ [expr 450 + 5 * $j]
$wl_node_ugs($j) set Y_ [expr 450]
$wl_node_ugs($j) set Z_ 0.0

#puts "wireless node $j created"

set clas [new SDUClassifier/Dest]
[$wl_node_ugs($j) set mac_(0)] add-classifier $clas
#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
set ss_sched [new WimaxScheduler/SS]
[$wl_node_ugs($j) set mac_(0)] set-scheduler $ss_sched
[$wl_node_ugs($j) set mac_(0)] set-channel 0


#Create a UDP agent and attach it to wl_node$j
set udp_ugs($j) [new Agent/UDP]
$udp_ugs($j) set packetSize_ 1000
$ns attach-agent $wl_node_ugs($j) $udp_ugs($j)


# Create a CBR traffic source and attach it to udp4
set cbr_ugs($j) [new Application/Traffic/CBR]
$cbr_ugs($j) set packetSize_ 1000
$cbr_ugs($j) set interval_ $interval_ugs($j)
$cbr_ugs($j) attach-agent $udp_ugs($j)

# Create the Null agent to sink traffic
set null_ugs($j) [new Agent/Null] 
$ns attach-agent $sinkNode $null_ugs($j)

# Attach the 2 agents
$ns connect $udp_ugs($j) $null_ugs($j)
$udp_ugs($j) set fid_ $j


## add-flow TrafficPriority MaximumSustainedTrafficRate MinimumReservedTrafficRate ServiceFlowSchedulingType
##ServiceFlowSchedulingType: 0=>SERVICE_UGS, 1=>SERVICE_rtPS, 2=>SERVICE_nrtPS, 3=>SERVICE_BE
$ss_sched add-flow 5 [expr 30 + [$cbr_ugs($j) set packetSize_] * [Mac/802_16 set frame_duration_] / [$cbr_ugs($j) set interval_]] 0 0

##set-PeerNode-SNR PeerNode SNR
$ns at 1.3 "$bs_sched set-PeerNode-SNR [expr $j] $SNR_ugs($j)"

##set-PeerNode-UGSPeriodicity PeerNode Periodicity
$ns at 1.3 "$bs_sched set-PeerNode-UGSPeriodicity [expr $j] 1"

#Schedule start/stop of traffic
$ns at $traffic_start "$cbr_ugs($j) start"
$ns at $traffic_stop "$cbr_ugs($j) stop"

}
####################









################################################
## rtPS connections
set first_rtPS 101
set nb_rtPS 0



$bs_sched set-SymbolNumberForUnicastRequest 3

#bs_sched set-rtPSscheduling scheduling
# "RR", "mSIR", "mmSIR", "WRR", "TRS_RR", "TRS_mSIR", ...
#set rtPS_scheduler_ "RR"

set rtPS_scheduler_ [lindex $argv 2]

$bs_sched set-rtPSscheduling $rtPS_scheduler_


proc send_next_packet_VBR {udp_ size_ interval_} {
  global ns traffic_stop
#  $udp_ send [expr round([$size_ value])]
$udp_ send 1000

if {[$ns now] < [expr $traffic_stop - $interval_]} {
  $ns at [expr [$ns now] + $interval_] "send_next_packet_VBR $udp_ $size_ $interval_"
}

}


# seed the default RNG
global defaultRNG
$defaultRNG seed 9999




#### interval_ ########
set interval_rtPS(1) 0.1
set interval_rtPS(2) 0.1
set interval_rtPS(3) 0.1

set interval_rtPS(4) 0.01
set interval_rtPS(5) 0.01
set interval_rtPS(6) 0.01
set interval_rtPS(7) 0.01
set interval_rtPS(8) 0.01
set interval_rtPS(9) 0.01
#######################


#### SNR #########
set SNR_rtPS(1) 7.0
set SNR_rtPS(2) 7.5
set SNR_rtPS(3) 9.0

set SNR_rtPS(4) 12.0
set SNR_rtPS(5) 17.0
set SNR_rtPS(6) 17.5
set SNR_rtPS(7) 20.0
set SNR_rtPS(8) 24.0
set SNR_rtPS(9) 25.5
##################




#### WRR #########
if {$rtPS_scheduler_ == "WRR"} {
set WRR_rtPS(1) 1
set WRR_rtPS(2) 1
set WRR_rtPS(3) 1
set WRR_rtPS(4) 2
set WRR_rtPS(5) 2
set WRR_rtPS(6) 3
set WRR_rtPS(7) 3

set WRR_rtPS(8) 4
set WRR_rtPS(9) 4
}
##################


##################
#set-TRSparameters-SNR-Tr-Tp-L SNRth Tr Tp L
$bs_sched set-TRSparameters-SNR-Tr-Tp-L 8.5 2 3 4
##################


$ns node-config -wiredRouting OFF \
                -macTrace ON  				;# Mobile nodes cannot do routing.

for {set j $first_rtPS} {$j < [expr $first_rtPS + $nb_rtPS]} {incr j} {
set wl_node_rtPS($j) [$ns node 1.0.[expr $nb_UGS + $j + 1 - $first_rtPS]] 	;# create the node with given @.	

$wl_node_rtPS($j) random-motion 0			;# disable random motion
$wl_node_rtPS($j) base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation
#compute position of the node
$wl_node_rtPS($j) set X_ [expr 550 + 5 * [expr $j + 1 - $first_rtPS]]
$wl_node_rtPS($j) set Y_ [expr 650]
$wl_node_rtPS($j) set Z_ 0.0

#puts "wireless node $j created"

set clas [new SDUClassifier/Dest]
[$wl_node_rtPS($j) set mac_(0)] add-classifier $clas
#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
set ss_sched [new WimaxScheduler/SS]
[$wl_node_rtPS($j) set mac_(0)] set-scheduler $ss_sched
[$wl_node_rtPS($j) set mac_(0)] set-channel 0


#Create a UDP agent and attach it to wl_node$j
set udp_rtPS($j) [new Agent/UDP]
$ns attach-agent $wl_node_rtPS($j) $udp_rtPS($j)

# Create the Null agent to sink traffic
set null_rtPS($j) [new Agent/Null] 
$ns attach-agent $sinkNode $null_rtPS($j)

# Attach the 2 agents
$ns connect $udp_rtPS($j) $null_rtPS($j)
$udp_rtPS($j) set fid_ $j

set interval_rtPS($j) $interval_rtPS([expr $j + 1 - $first_rtPS])


## exponential distribution
#set sizeRNG_rtPS($j) [new RNG]

#set size_rtPS($j) [new RandomVariable/Exponential]
#$size_rtPS($j) set avg_ 1000
#$size_rtPS($j) use-rng $sizeRNG_rtPS($j)


# uniform distribution
set sizeRNG_rtPS($j) [new RNG]

set size_rtPS($j) [new RandomVariable/Uniform]
$size_rtPS($j) set min_ 500
$size_rtPS($j) set max_ 1500
$size_rtPS($j) use-rng $sizeRNG_rtPS($j)


## add-flow TrafficPriority MaximumSustainedTrafficRate MinimumReservedTrafficRate ServiceFlowSchedulingType
##ServiceFlowSchedulingType: 0=>SERVICE_UGS, 1=>SERVICE_rtPS, 2=>SERVICE_nrtPS, 3=>SERVICE_BE
$ss_sched add-flow 5 0 0 1

##set-PeerNode-SNR PeerNode SNR
$ns at 1.3 "$bs_sched set-PeerNode-SNR [expr $nb_UGS + $j + 1 - $first_rtPS] $SNR_rtPS([expr $j + 1 - $first_rtPS])"

##set-PeerNode-UnicastRequestPeriodicity PeerNode Periodicity
$ns at 1.3 "$bs_sched set-PeerNode-UnicastRequestPeriodicity [expr $nb_UGS + $j + 1 - $first_rtPS] 2"


if {$rtPS_scheduler_ == "WRR"} {
  # set-PeerNode-WRRschedulingForrtPS PeerNode Weight
  $ns at 1.3 "$bs_sched set-PeerNode-WRRschedulingForrtPS [expr $nb_UGS + $j + 1 - $first_rtPS] $WRR_rtPS([expr $j + 1 - $first_rtPS])"
}



$ns at [expr 15.0 + [expr $j + 1 - $first_rtPS] * 0] "send_next_packet_VBR $udp_rtPS($j) $size_rtPS($j) $interval_rtPS($j)"

#puts "n[expr $nb_UGS + $j + 1 - $first_rtPS] starts at [expr 15.0 + [expr $j + 1 - $first_rtPS] * 0]"

}







####################################################################
set first_BE 301

$ns node-config -wiredRouting OFF \
                -macTrace ON  				;# Mobile nodes cannot do routing.

set wl_node_BE($first_BE) [$ns node 1.0.[expr $nb_UGS + $nb_rtPS + 1]] 	;# create the node with given @.	
$wl_node_BE($first_BE) random-motion 0			;# disable random motion
$wl_node_BE($first_BE) base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation
#compute position of the node
$wl_node_BE($first_BE) set X_ 559.0
$wl_node_BE($first_BE) set Y_ 617.0
$wl_node_BE($first_BE) set Z_ 0.0

puts "wireless node _BE $first_BE created"

set clas [new SDUClassifier/Dest]
[$wl_node_BE($first_BE) set mac_(0)] add-classifier $clas
#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
set ss_sched [new WimaxScheduler/SS]
[$wl_node_BE($first_BE) set mac_(0)] set-scheduler $ss_sched
[$wl_node_BE($first_BE) set mac_(0)] set-channel 0

# css
##set-PeerNode-SNR PeerNode SNR
$ns at 1.3 "$bs_sched set-PeerNode-SNR [expr $nb_UGS + $nb_rtPS + 1] 12.31"

##set-BwRequestSendingPeriod BwRequestSendingPeriod_
$ss_sched set-BwRequestSendingPeriod 10

## add-flow TrafficPriority MaximumSustainedTrafficRate MinimumReservedTrafficRate ServiceFlowSchedulingType
##ServiceFlowSchedulingType: 0 => SERVICE_UGS, 1=>SERVICE_rtPS, 2=> SERVICE_ertPS, 3=>SERVICE_nrtPS, 4=>SERVICE_BE
$ss_sched add-flow 1 0 0 4

#set data_to_send_BE($first_BE) 30000

#$ns at $traffic_start "$ss_sched set-BandwidthBEconnections $data_to_send_BE($first_BE)"

#$ns at $traffic_start "uplink_ftp_tcp_data $wl_node_BE($first_BE) $first_BE $data_to_send_BE($first_BE)"

$ns at 13.0 "uplink_ftp_tcp $wl_node_BE($first_BE) $first_BE"
#################################################################################












####################################################################
$ns node-config -wiredRouting OFF \
                -macTrace ON  				;# Mobile nodes cannot do routing.

set wl_node_BE([expr $first_BE + 1]) [$ns node 1.0.[expr $nb_UGS + $nb_rtPS + 2]] 	;# create the node with given @.	
$wl_node_BE([expr $first_BE + 1]) random-motion 0			;# disable random motion
$wl_node_BE([expr $first_BE + 1]) base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation
#compute position of the node
$wl_node_BE([expr $first_BE + 1]) set X_ 465.0
$wl_node_BE([expr $first_BE + 1]) set Y_ 523.0
$wl_node_BE([expr $first_BE + 1]) set Z_ 0.0

puts "wireless node [expr $first_BE + 1] created"

set clas [new SDUClassifier/Dest]
[$wl_node_BE([expr $first_BE + 1]) set mac_(0)] add-classifier $clas
#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
set ss_sched [new WimaxScheduler/SS]
[$wl_node_BE([expr $first_BE + 1]) set mac_(0)] set-scheduler $ss_sched
[$wl_node_BE([expr $first_BE + 1]) set mac_(0)] set-channel 0

# css
##set-PeerNode-SNR PeerNode SNR
$ns at 1.3 "$bs_sched set-PeerNode-SNR [expr $nb_UGS + $nb_rtPS + 2] 12.32"

##set-BwRequestSendingPeriod BwRequestSendingPeriod_
$ss_sched set-BwRequestSendingPeriod 10

## add-flow TrafficPriority MaximumSustainedTrafficRate MinimumReservedTrafficRate ServiceFlowSchedulingType
##ServiceFlowSchedulingType: 0 => SERVICE_UGS, 1=>SERVICE_rtPS, 2=> SERVICE_ertPS, 3=>SERVICE_nrtPS, 4=>SERVICE_BE
$ss_sched add-flow 1 0 0 4

#set data_to_send_BE([expr $first_BE + 1]) 30000
#$ns at $traffic_start "uplink_ftp_tcp_data $wl_node_BE([expr $first_BE + 1]) [expr $first_BE + 1] $data_to_send_BE([expr $first_BE + 1])"

$ns at 13.0 "uplink_ftp_tcp $wl_node_BE([expr $first_BE + 1]) [expr $first_BE + 1]"
#################################################################################






proc uplink_ftp_tcp_data {wl_node fid data_to_send} {
global ns sinkNode
#Setup a TCP connection
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $wl_node $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $sinkNode $sink
$ns connect $tcp $sink
$tcp set fid_ $fid
$tcp set packetSize_ 1000

#setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
$ftp set packetSize_ 1000

$ftp send $data_to_send
}



proc uplink_ftp_tcp {wl_node fid} {
global ns sinkNode
#Setup a TCP connection
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $wl_node $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $sinkNode $sink
$ns connect $tcp $sink
$tcp set fid_ $fid
$tcp set packetSize_ 1000

#setup a FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
$ftp set packetSize_ 1000

$ftp start
}



################procedure : Record ####################
set f0 [open 1_out.tr w]

proc record {} {
global f0 cbr
set ns [Simulator instance]
set time 0.05
set now [$ns now]
set packetSize [$cbr set packetSize_]
set rate [$cbr set rate_]
set seqno [$cbr set seqno_]
puts $f0 "$now paketSize $packetSize rate $rate seqno $seqno"
$ns at [expr $now + $time] "record"
}

##$ns at $traffic_start "record"
########################################################




$ns at $simulation_stop "finish"
puts "Starts simulation"
$ns run
puts "Simulation done."







####################################################################
#$ns node-config -wiredRouting OFF \
#                -macTrace ON  				;# Mobile nodes cannot do routing.

#set wl_node2 [$ns node 1.0.2] 	;# create the node with given @.	
#$wl_node2 random-motion 0			;# disable random motion
#$wl_node2 base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation
##compute position of the node
#$wl_node2 set X_ 510.0
#$wl_node2 set Y_ 510.0
#$wl_node2 set Z_ 0.0

#puts "wireless node 2 created"

#set clas [new SDUClassifier/Dest]
#[$wl_node2 set mac_(0)] add-classifier $clas
##set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
#set ss_sched [new WimaxScheduler/SS]
#[$wl_node2 set mac_(0)] set-scheduler $ss_sched
#[$wl_node2 set mac_(0)] set-channel 0

#####downlink traffic
##create source traffic
##Create a UDP agent and attach it to node n0
###set udp2 [new Agent/UDP]
###$udp2 set packetSize_ 1000
###$ns attach-agent $sinkNode $udp2

## Create a CBR traffic source and attach it to udp0
###set cbr2 [new Application/Traffic/CBR]
###$cbr2 set packetSize_ 1000
###$cbr2 set interval_ 0.002
###$cbr2 attach-agent $udp2

##create an sink into the sink node

## Create the Null agent to sink traffic
###set null2 [new Agent/Null] 
###$ns attach-agent $wl_node2 $null2

## Attach the 2 agents
###$ns connect $udp2 $null2
###$udp2 set fid_ 2
####


####uplink traffic
##create source traffic
##Create a UDP agent and attach it to wl_node2 
#set udp2 [new Agent/UDP]
#$udp2 set packetSize_ 1000
#$ns attach-agent $wl_node2 $udp2

## Create a CBR traffic source and attach it to udp0
#set cbr2 [new Application/Traffic/CBR]
#$cbr2 set packetSize_ 1000
#$cbr2 set interval_ 0.2
#$cbr2 attach-agent $udp2

##create an sink into the sink node

## Create the Null agent to sink traffic
#set null2 [new Agent/Null] 
#$ns attach-agent $sinkNode $null2

## Attach the 2 agents
#$ns connect $udp2 $null2
#$udp2 set fid_ 2


###set-PeerNode-SNR PeerNode SNR
#$ns at 1.3 "$bs_sched set-PeerNode-SNR 2 7.2"

###set-PeerNode-UGSPeriodicity PeerNode Periodicity
#$ns at 1.3 "$bs_sched set-PeerNode-UGSPeriodicity 2 1"

### add-flow TrafficPriority MaximumSustainedTrafficRate MinimumReservedTrafficRate ServiceFlowSchedulingType
###ServiceFlowSchedulingType: 0 => SERVICE_UGS, 1 => SERVICE_rtPS, 2 => SERVICE_nrtPS, 3 => SERVICE_BE
#$ss_sched add-flow 5 [expr 60 + [$cbr2 set packetSize_] * [Mac/802_16 set frame_duration_] / [$cbr2 set interval_]] 0 0

##Schedule start/stop of traffic
#$ns at $traffic_start "$cbr2 start"
#$ns at $traffic_stop "$cbr2 stop"
###################################################################






## echo random values
#for {set j 0} {$j < 5} {incr j} {
#puts "[expr round([$size12 value])]"
#}


## uniform distribution
#set sizeRNG12 [new RNG]

#set size12_ [new RandomVariable/Uniform]
#$size12_ set min_ 500
#$size12_ set max_ 1500
#$size12_ use-rng $sizeRNG12

#for {set j 0} {$j < 5} {incr j} {
#puts "[expr round([$size12_ value])]"
#}





####################################################################
#$ns node-config -wiredRouting OFF \
#                -macTrace ON  				;# Mobile nodes cannot do routing.

#set wl_node14 [$ns node 1.0.6] 	;# create the node with given @.	
#$wl_node14 random-motion 0			;# disable random motion
#$wl_node14 base-station [AddrParams addr2id [$bstation node-addr]] ;#attach mn to basestation
##compute position of the node
#$wl_node14 set X_ 414.0
#$wl_node14 set Y_ 514.0
#$wl_node14 set Z_ 0.0

#puts "wireless node 14 created"

#set clas [new SDUClassifier/Dest]
#[$wl_node14 set mac_(0)] add-classifier $clas
##set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
#set ss_sched [new WimaxScheduler/SS]
#[$wl_node14 set mac_(0)] set-scheduler $ss_sched
#[$wl_node14 set mac_(0)] set-channel 0


##Create a UDP agent and attach it to wl_node14
#set udp14 [new Agent/UDP]
#$ns attach-agent $wl_node14 $udp14

## Create the Null agent to sink traffic
#set null14 [new Agent/Null] 
#$ns attach-agent $sinkNode $null14

## Attach the 2 agents
#$ns connect $udp14 $null14
#$udp14 set fid_ 14

#set interval14 0.7


#set sizeRNG14 [new RNG]

#set size14 [new RandomVariable/Exponential]
#$size14 set avg_ 1000
#$size14 use-rng $sizeRNG14


### add-flow TrafficPriority MaximumSustainedTrafficRate MinimumReservedTrafficRate ServiceFlowSchedulingType
###ServiceFlowSchedulingType: 0=>SERVICE_UGS, 1=>SERVICE_rtPS, 2=>SERVICE_nrtPS, 3=>SERVICE_BE
#$ss_sched add-flow 5 0 0 1

###set-PeerNode-SNR PeerNode SNR
#$ns at 1.3 "$bs_sched set-PeerNode-SNR 6 7.1"

###set-PeerNode-UnicastRequestPeriodicity PeerNode Periodicity
#$ns at 1.3 "$bs_sched set-PeerNode-UnicastRequestPeriodicity 6 5"


##$ns at 4 "send_next_packet_VBR $udp14 $size14 $interval14"

#################################################################################









############################FTP over UDP###############
##proc uplink_ftp_udp {wl_node fid traffic_start} {

##global sinkNode ns traffic_start
#Setup a TCP connection
##set udp [new Agent/UDP]
##$ns attach-agent $wl_node $udp
##set null [new Agent/Null]
##$ns attach-agent $sinkNode $null
##$ns connect $udp $null
##$udp set fid_ fid
##$udp set packetSize_ 1000

#setup a FTP over TCP connection
##set ftp [new Application/FTP]
##$ftp attach-agent $udp
##$ftp set type_ FTP
##$ftp set packetSize_ 1000
##$ns at $traffic_start "$ftp send 5000"
##}
#######################################################
