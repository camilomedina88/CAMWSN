#
# This script was written for the sole purpose of showing the fhmip ns-2 extnesion. 
#
# July 2003 - Robert Hsieh
#
#
# Simulation Instructions:
#
#
# To simulate Mobile IP:
#	classic handoff mechanism (miss 2 advertisement msg).
#	Procedures: mip-reg.cc => block out MAP_MODE, FAST_HANDOVER, MAP_FAST_HANDOVER
#	            simula.tcl => block out 'priority' associated with all nodes,
#                                 block out 'attach-mapagent'
#
# To simulate Mobile IP with priority handoff:
#	Using priority handoff. Mobile node switch to nodes with higher priority (shown inside adv msg). Prioirty handoff
#         is included in the J. Widmer's ns-extnesion package.
#	Procedures: mip-reg.cc => block out MAP_MODE, FAST_HANDOVER, MAP_FAST_HANDOVER
#	            simula.tcl => make sure priority is set for nodes
#                                 block out 'attach-mapagent'
#                                  
# To simualte Hierarchical Mobile IP:
#	Using priority handoff.
#	Procedures: mip-reg.cc => unblock MAP_MODE
#	            simula.tcl => make sure priority is set for nodes
#                                 unblock 'attach-mapagent'
#
# To simulate (Flat Mobile IP with Fast-handover):
#	Using priority handoff.
#	Procedures: mip-reg.cc => unblock FAST_HANDOVER (block both MAP_MODE and FAST_MAP_HANDOVER)
#	            simula.tcl => make sure priority is set for nodes
#                                 block out 'attach-mapagent'
#
# To simulate (Hierarchical Mobile IP with Fast-handover):
#	Using priority handoff. 
#	Procedures: mip-reg.cc => unblock MAD_MODE, FAST_HANDOVER, FAST_MAP_HANDOVER
#	            simula.tcl => make sure priority is set
#                                 unblock 'attach-mapagent'
#
#


# upgraded to NS2.31 by Pedro Vale Estrela (IST/TULisbon), March 2007  (FHMIP+NOAH)

set ns_ [new Simulator]
$ns_ node-config -addressType hierarchical

AddrParams set domain_num_ 5 
 lappend cluster_num 2 1 1 2 2
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel 1 1 2 1 1 1 1 1
AddrParams set nodes_num_ $eilastlevel


# to show ack number, header flags, header length
# Note: only useful though if using tcpfull
#Trace set show_tcphdr_ 1



set tracefd [open traffic.tr w]
$ns_ use-newtrace
$ns_ trace-all $tracefd


set namtracefd [open traffic.nam w]
$ns_ namtrace-all $namtracefd


set topo [new Topography]
$topo load_flatgrid 1000 1000
set god_ [create-god 1]


##############
# NODE SETUP #
##############

# Wired nodes => CH, MAP, N1, N2, N3
#

#CH - 0
set CN [$ns_ node 0.0.0]

#MAP - 1
set MAP [$ns_ node 2.0.0]

#N1 - 2
set N1 [$ns_ node 0.1.0]

#N2 - 3
set N2 [$ns_ node 3.0.0]

#N3 - 4
set N3 [$ns_ node 4.0.0]

# NOAH nodes (wireless+wired) => HA, PAR, NAR
# MN is a special node (i.e. a NOAH node with wiredrouting turned off)

set chan_ [new Channel/WirelessChannel]
$ns_ node-config -mobileIP ON \
                  -adhocRouting NOAH \
                  -llType LL \
                  -macType Mac/802_11 \
                  -ifqType Queue/DropTail/PriQueue \
                  -ifqLen 50 \
                  -antType Antenna/OmniAntenna \
                  -propType Propagation/TwoRayGround \
                  -phyType Phy/WirelessPhy \
                  -channel $chan_ \
	 	  -topoInstance $topo \
                  -wiredRouting ON \
		  -agentTrace ON \
                  -routerTrace OFF \
                  -macTrace ON


#HA - 5
set HA [$ns_ node 1.0.0]
[$HA set regagent_] priority 3

#MN - 6
$ns_ node-config -wiredRouting OFF
set MN [$ns_ node 1.0.1]
[$MN set regagent_] set home_agent_ [AddrParams addr2id [$HA node-addr]]
$ns_ node-config -wiredRouting ON

#PAR - 7
set PAR [$ns_ node 3.1.0 2.0.0]
[$PAR set regagent_] priority 3

#NAR - 8
set NAR [$ns_ node 4.1.0 2.0.0]
[$NAR set regagent_] priority 4



#####################
# PLACEMENT of NODE #
#####################

$CN set X_ 80.0
$CN set Y_ 5.0

$N1 set X_ 120.0
$N1 set Y_ 10.0

$HA set X_ 160.0
$HA set Y_ 5.0

$MN set X_ 160.0
$MN set Y_ 5.1

$MAP set X_ 120.0
$MAP set Y_ 15.0

$N2 set X_ 85.0
$N2 set Y_ 60.0

$N3 set X_ 155.0
$N3 set Y_ 60.0

$PAR set X_ 85.0
$PAR set Y_ 135.0

$NAR set X_ 155.0
$NAR set Y_ 135.0


##############
# LINK SETUP #
##############

# droptail = (FIFO), RED = Random Early Detection
$ns_ duplex-link $CN $N1 100Mb 2ms RED         ;# Since consitiute a domain, so we simplify it by just use 100M and keep the delay of 2ms constant
$ns_ duplex-link $HA $N1 100Mb 2ms RED         ;# same as above
$ns_ duplex-link $MAP $N1 100Mb 50ms RED       ;# We increase the dealy to 50ms to show the advantange of MAP
$ns_ duplex-link $N2 $MAP 10Mb 2ms RED         ;# All nodes below MAP belongs to a single domain, therefore we keep the delay at constant 2ms and vary the
$ns_ duplex-link $N3 $MAP 10Mb 2ms RED         ;#  bandwidth in a decreasing order, i.e. from 100M to 10M to 1M.
$ns_ duplex-link $PAR $N2 1000Kb 2ms DropTail
$ns_ duplex-link $NAR $N3 1000Kb 2ms DropTail




#####################
# APPLICATION SETUP #
#####################

# RCH Attaching the MAP agent.
$ns_ attach-mapagent $MAP       ;# Need to enable MAP_MODE in mip-reg.cc

set tcp_(1) [$ns_ create-connection TCP $CN TCPSink $MN 1]
$tcp_(1) set window_ 32
$tcp_(1) set packetSize_ 512

# RCH  Setting connection monitor - to compensate the non existance of frequency jumping in 802.11.
$ns_ connection-monitor 1 $MN 


#trace all congestion window (cwnd) value for this TCP connection
set cwndtrace [open all.cwnd w]
$tcp_(1) trace cwnd_
$tcp_(1) attach $cwndtrace

set ftp_(1) [new Application/FTP]
$ftp_(1) attach-agent $tcp_(1)
$ns_ at 5.0 "$ftp_(1) start"
$ns_ at 80.0 "$ftp_(1) stop"



############
# SCENARIO #
############

#$ns_ at 6.0 "$MN set X_ 85.0"	
#$ns_ at 6.0 "$MN set Y_ 135.1"	

$ns_ at 6.0 "$MN setdest 85.0 135.1 100"			;# pmsrve: move MN to PAR at a really high speed

#
# http://www.tkn.tu-berlin.de/publications/papers/Handover_Blackout_Duration_of_L3_Mobility_Management_Schemes1.pdf
#
# We had to change the script to do this with the setdest command instead of just changing the 
# position of the node since ns-2.28 was not #updating the topological lists properly if the
# node was moved this way.
#
#
# $mobilenode setdest X Y s 
#
# This command is used to setup a destination for the mobilenode. 
# The mobile node starts moving towards destination given by <X> and <Y> at a speed of <s> m/s. 
#


$ns_ at 10.0 "$MN setdest 155.0 135.1 1"


for {set t 10} {$t < 80} {incr t 10} {
    $ns_ at $t "puts stderr \"completed through $t/80 secs...\""
}

$ns_ at 0.0 "puts stderr \"Simulation started...\""


set opt(stop) 80


$ns_ at [expr $opt(stop) + 0.0001] "puts stderr \"Simulation finished\""
$ns_ at [expr $opt(stop) + 0.0002] "close $tracefd"
$ns_ at [expr $opt(stop) + 0.0002] "close $namtracefd"
$ns_ at [expr $opt(stop) + 0.0003] "$ns_ halt"

$ns_ run
