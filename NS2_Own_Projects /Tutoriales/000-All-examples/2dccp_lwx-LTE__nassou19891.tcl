#     http://www.linuxquestions.org/questions/programming-9/links-with-two-networks-in-ns2-4175523315/#4


# Define object Simulator
set ns [new Simulator ]

# Predefine tracing
set f [open dccp.tr w]
$ns trace-all $f
set nf [open dccp.nam w]
$ns namtrace-all $nf

#set up color flow
$ns color 1 Blue

#Declaration of intermediate nodes
set R1 [$ns node]
set R2 [$ns node]
$ns duplex-link $R1 $R2 5Mb 100ms DropTail
#$ns queue-limit $R1 $R2 25
#$ns queue-limit $R2 $R1 25
$ns duplex-link-op $R1 $R2 orient right
$ns duplex-link-op $R1 $R2 queuePos 0
$ns duplex-link-op $R2 $R1 queuePos 0

# ======================================================================
#  Default Parametres 
# ======================================================================
set opt(chan)        Channel/WirelessChannel    ;#Channel Type
set opt(prop)        Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)       Phy/WirelessPhy            ;# network interface type
set opt(mac)         Mac/LWX                    ;# MAC type
set opt(ifq)         Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)          LL                         ;# link layer type
set opt(ant)         Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)      50                         ;# max packet in ifq
set opt(nn)          2                          ;# number of mobilenodes
set opt(rp)          DSDV                       ;# routing protocol. DSDV, DSR, AODV.
set opt(x)           250                        ;# Topology size
set opt(y)           250                        ;# Topology size

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

# Create God
create-god $opt(nn)

# Create channel
set chan_ [new $opt(chan)]

# configure 802.16 nodes
$ns node-config -adhocRouting $opt(rp) \
		-llType $opt(ll) \
		-macType $opt(mac) \
		-ifqType $opt(ifq) \
		-ifqLen $opt(ifqlen) \
		-antType $opt(ant) \
		-propType $opt(prop) \
		-phyType $opt(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace OFF \
		-macTrace OFF \
		-movementTrace OFF \
		-channel $chan_

# ======================================================================
# Set Bandwidth Allocation Algorithm Type
# 0: test
# 1: Round Robin
# 2: Strict Priority
# ======================================================================

Mac/LWX env BWA_Algorithm_Type   2

#creation of BS
set node_id(0)     0
set BS       [$ns node]
$BS random-motion 0
$ns initial_node_pos $BS 20
$BS set X_ 15.0
$BS set Y_ 15.0
$BS set Z_ 0.0
$BS nodeid $node_id(0)
Mac/LWX env add_bs node_id $node_id(0)
puts "la station de base est créée"

#Link between BS et R1
$ns duplex-link $R1 $BS 100Mb 10ms DropTail

#Creation of 1 SS
set node_id(1)     101
set SS        [$ns node]
$SS random-motion 0
$ns initial_node_pos $SS 20
$SS set X_ 17.0
$SS set Y_ 17.0
$SS set Z_ 0.0
$SS nodeid $node_id(1)
Mac/LWX env add_ss node_id $node_id(1) bs_node_id $node_id(0)

#creation of LTE nodes

#define the nodes
set eNB [$ns node];#node id is 0
set aGW [$ns node];#node id is 1
set UE [$ns node];#node id is 2

#define the links to connect the nodes
$ns simplex-link $UE $eNB 500Mb 2ms LTEQueue/ULAirQueue 
$ns simplex-link $eNB $UE 1000Mb 2ms LTEQueue/DLAirQueue
$ns simplex-link $eNB $aGW 5000Mb 10ms LTEQueue/ULS1Queue 
$ns simplex-link $aGW $eNB 5000Mb 10ms LTEQueue/DLS1Queue

#Link between aGW et R2
$ns duplex-link $aGW $R2 10Gb 100ms DropTail

# Setup traffic flow between nodes
# TCP connections between SS and UE

#set dccp [new Agent/TCP]
set dccp [new Agent/DCCP/TCPlike]
#$tcp set class_ 2
set sink [new Agent/DCCP/TCPlike]
#set sink [new Agent/TCPSink]
$ns attach-agent $SS $dccp
$ns attach-agent $UE $sink
#Set FTP Trafic Flow
set ftp [new Application/FTP]
$ftp attach-agent $dccp
$ns connect $dccp $sink

# wimax for dccp data
# ss->bs
# init env var
set flow_info     [$dccp flow_info]
set src_nid       $node_id(1)
set from_nid      $node_id(1)
set to_nid        $node_id(0)

# add flow
# Mac/LWX env add_flow <type> $src_nid $from_nid $to_nid $flow_info
# type: bs_to_ss, ss_to_bs, rs_to_bs, rs_to_ss
Mac/LWX env add_flow ss_to_bs $src_nid $from_nid $to_nid $flow_info

# set flow attribute
# Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info <type> <value>
# type: rate(byte), QoS_Class (1~5), Rmin(bps), Rmax(bps), Lmax(ms), Jitter(ms)

# rate: modulation coding rate (symbol x subch)
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info rate       6
# 1: UGS, 2:ertps, 3:rtps, 4: nrtps, 5:BE
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info QoS_Class  2
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Rmin       1000000
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Rmax       1500000
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Lmax       60
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Jitter     45

$ns at 1.0 "$ftp start"
$ns at 600.0 "$ftp stop"

# finish tracing
$ns at 600 "finish"
proc finish {} {
	#global ns f log
	global ns f nf
	$ns flush-trace
	close $f
	close $nf
	puts "running nam..."
	exec nam dccp.nam &
	exit 0
}

# Finally, start the simulation.
$ns run
