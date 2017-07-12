# Test for MutiFaceNodes using Triggers.
# Scenario: Create a multi-interface node using different technologies
#           There is a TCP connection between the router0 and MultiFaceNode.
#           We first use the UMTS interface, then we switch the traffic 
#           to the 802.11 interface when it becomes available. 
#           When the node leaves the coverage area of 802.11, it creates a link going down 
#           event to redirect to UMTS.
#
# Topology scenario:
#
#                                   bstation802(3.0.0)->)
#                                   /
#                                  /      
# router0(1.0.0)---router1(2.0.0)-----------bstation80216(4.0.0)          +------------------------------------+ 
#                                  \        		                  + iface1:802.11(3.0.1)|              |
#                                   \                                     +---------------------+ MutiFaceNode |
#                                   rnc(0.0.0)                            + iface0:UMTS(0.0.2)  |  (5.0.0)     |
#                                      |                                  +---------------------+              |
#                                 bstationUMTS(0.0.1)->)        	  + iface2:80216(4.0.0) |              |	
#									  +------------------------------------+
# NN Multiface node.




#check input parameters
global ns

set nn [lindex $argv 0]

# set global variables
set output_dir .

#define coverage area for base station: 50m coverage 
Phy/WirelessPhy set Pt_ 0.0134
Phy/WirelessPhy set freq_ 2412e+6
Phy/WirelessPhy set RXThresh_ 5.25089e-10

#define frequency of RA at base station
Agent/ND set maxRtrAdvInterval_ 6
Agent/ND set minRtrAdvInterval_ 2
Agent/ND set router_lifetime_   1800
Agent/ND set minDelayBetweenRA_ 0.03
Agent/ND set maxRADelay_        0

#Wireless routing algorithm update frequency (in seconds)
Agent/DSDV set perup_ 8

# Define global simulation parameters
Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover2 set case_ 2
Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover2 set confidence_th_ 90

#Define DEBUG parameters
set quiet 0
Agent/ND set debug_ 0 
Agent/MIH set debug_ 1
Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover2 set debug_ 1
Mac/802_11 set debug_ 1
Mac/802_16 set debug_ 1


#Rate at which the nodes start moving
set moveStart 2
set moveStop 100
set speed 10
#origin of the MN
set X_src 70.0
set Y_src 120.0
set X_dst 120.0
set Y_dst 120.0

#defines function for flushing and closing files
proc finish {} {
    global ns f
    $ns flush-trace
    close $f
    puts " Simulation ended."
    exit 0
}

#create the simulator
set ns [new Simulator]
$ns use-newtrace

#open file for trace
set f [open data.tr w]
$ns trace-all $f

# set up for hierarchical routing (needed for routing over a basestation)
$ns node-config -addressType hierarchical
AddrParams set domain_num_  6                      ;# domain number
AddrParams set cluster_num_ {1 1 1 1 1 1}            ;# cluster number for each domain 

set tmp1 [expr $nn+2]
set tmp2 [expr $nn+1]

lappend tmp $tmp1                                  ;# UMTS MNs+RNC+BS
lappend tmp 1                                      ;# router 0
lappend tmp 1                                      ;# router 1
lappend tmp $tmp2                                  ;# 802.11 MNs+BS
lappend tmp $tmp2				   ;# 802.16 MNs+BS
lappend tmp $nn                                    ;# MULTIFACE nodes 
AddrParams set nodes_num_ $tmp

#create the topography
set opt(x)		2000			   ;# X dimension of the topography
set opt(y)		2000			   ;# Y dimension of the topography
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
#puts "Topology created"

$ns set hsdschEnabled_ 1addr
$ns set hsdsch_rlc_set_ 0
$ns set hsdsch_rlc_nif_ 0

# configure RNC node
$ns node-config -UmtsNodeType rnc 
set rnc [$ns create-Umtsnode 0.0.0] ;# node id is 0.
    puts "rnc: tcl=$rnc; id=[$rnc id]; addr=[$rnc node-addr]"


# configure UMTS base station
$ns node-config -UmtsNodeType bs \
		-downlinkBW 384kbs \
		-downlinkTTI 10ms \
		-uplinkBW 384kbs \
		-uplinkTTI 10ms \
     		-hs_downlinkTTI 2ms \
      		-hs_downlinkBW 384kbs 

set bsUMTS [$ns create-Umtsnode 0.0.1] ;# node id is 1
puts "bsUMTS(NodeB): tcl=$bsUMTS; id=[$bsUMTS id]; addr=[$bsUMTS node-addr]"

$ns setup-Iub $bsUMTS $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000

set j 1

for {set i 0} {$i<$nn} {incr i} {

$ns node-config -UmtsNodeType ue \
		-baseStation $bsUMTS \
		-radioNetworkController $rnc \

set j [expr $j+1]

set iface0_($j) [$ns create-Umtsnode 0.0.$j] ; #Node Id begins with 2. 

puts "*** tcl=$iface0_($j) ; id=[$iface0_($j) id]; addr=[$iface0_($j) node-addr]"	

}

set dummy_node [$ns create-Umtsnode 0.0.[expr 2+$nn]]
puts "*** dummy: tcl=$dummy_node; id=[$dummy_node id]; addr=[$dummy_node node-addr]"

set router0 [$ns node 1.0.0]
set router1 [$ns node 2.0.0]

puts "router0: tcl=$router0; id=[$router0 id]; addr=[$router0 node-addr]"
puts "router1: tcl=$router1; id=[$router1 id]; addr=[$router1 node-addr]"

# connect links 
$ns duplex-link $rnc $router1 622Mbit 0.4ms DropTail 1000
$ns duplex-link $router1 $router0 100MBit 30ms DropTail 1000
$rnc add-gateway $router1

for {set i 1} {$i<=$nn} {incr i} {

$ns node-config  -multiIf ON                            

set multiFaceNode_($i) [$ns node 5.0.$i] 
$ns node-config  -multiIf OFF                    

puts "multiFaceNode(s) tcl=$multiFaceNode_($i); id=[$multiFaceNode_($i) id]; addr=[$multiFaceNode_($i) node-addr] "
}

create-god [expr 7+4*$nn]


# parameter for wireless nodes
set opt(chan)           Channel/WirelessChannel    ;# channel type for 802.11
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model 802.11
set opt(netif)          Phy/WirelessPhy            ;# network interface type 802.11
set opt(mac)            Mac/802_11                 ;# MAC type 802.11
set opt(ifq)            Queue/DropTail/PriQueue    ;# interface queue type 802.11
set opt(ll)             LL                         ;# link layer type 802.11
set opt(ant)            Antenna/OmniAntenna        ;# antenna model 802.11
set opt(ifqlen)         50              	   ;# max packet in ifq 802.11
set opt(adhocRouting)   DSDV                       ;# routing protocol 802.11
set opt(umtsRouting)    ""                         ;# routing for UMTS (to reset node config)

#Define MAC 802_11 parameters
Mac/802_11 set bss_timeout_ 5
Mac/802_11 set pr_limit_ 1.2 ;#for link going down

# configure rate for 802.11
Mac/802_11 set basicRate_ 11Mb
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set bandwidth_ 11Mb




# configure Access Points 80211
$ns node-config  -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -channel [new $opt(chan)] \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop)    \
                 -phyType $opt(netif) \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF  \
                 -movementTrace OFF

# configure Base station 802.11
set bstation802 [$ns node 3.0.0]
$bstation802 set X_ 100.0
$bstation802 set Y_ 100.0
$bstation802 set Z_ 0.0

# we need to set the BSS for the base station
set bstationMac [$bstation802 getMac 0]
set AP_ADDR_0 [$bstationMac id]

$bstationMac bss_id $AP_ADDR_0
$bstationMac enable-beacon
[$bstation802 set mac_(0)] set-channel 2

# add link to backbone
$ns duplex-link $bstation802 $router1 100MBit 15ms DropTail 1000

# creation of the wireless interface 802.11

for {set i 1} {$i<=$nn} {incr i} {

$ns node-config -wiredRouting OFF \
		-agentTrace ON \
		-movementTrace ON \
                -macTrace ON 		

set iface1_($i) [$ns node 3.0.$i]     ;# node id is 8. 
$iface1_($i) random-motion 1	;#0 disable random motion 1 else
$iface1_($i) base-station [AddrParams addr2id [$bstation802 node-addr]] ;#attach mn to basestation
[$iface1_($i) set mac_(0)] set-channel 2


}

# WIMAX CONFIGURATION

#read arguments
set seed                             0
Mac/802_16 set scan_iteration_       2
Mac/802_16 set lgd_factor_           1.1

Mac/802_16 set scan_duration_         50
Mac/802_16 set interleaving_interval_ 40

Mac/802_16 set dcd_interval_         5 ;#max 10s
Mac/802_16 set ucd_interval_         5 ;#max 10s
set default_modulation               OFDM_16QAM_3_4 ;#OFDM_BPSK_1_2
set contention_size                  5 ;#for initial ranging and bw  
Mac/802_16 set t21_timeout_          0.02 ;#max 10s, to replace the timer for looking at preamble 
Mac/802_16 set client_timeout_       50 

# add Wimax nodes
set opt(netif)          Phy/WirelessPhy/OFDM      ;# network interface type 802.16
set opt(mac)            Mac/802_16                 ;# MAC type 802.16

# radius = 1000
Phy/WirelessPhy set freq_ 3.5e+9  ;# hz
Phy/WirelessPhy set Pt_ 15
Phy/WirelessPhy set RXThresh_ 7.59375e-11 ;#1000m radius
Phy/WirelessPhy set CSThresh_ [expr 0.8*[Phy/WirelessPhy set RXThresh_]]

set chan [new $opt(chan)]

# configure Access Points
$ns node-config  -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -channel $chan \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop)    \
                 -phyType $opt(netif) \
                 -topoInstance $topo \
                 -wiredRouting ON \
                 -agentTrace ON \
                 -routerTrace OFF \
                 -macTrace OFF  \
                 -movementTrace OFF

# configure Base station 802.16
set bstation802_16 [$ns node 4.0.0] ;
$bstation802_16 set X_ 1000
$bstation802_16 set Y_ 1000
$bstation802_16 set Z_ 0.0
puts "bstation802_16: tcl=$bstation802_16; id=[$bstation802_16 id]; addr=[$bstation802_16 node-addr]"

set clas [new SDUClassifier/Dest]
[$bstation802_16 set mac_(0)] add-classifier $clas
#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
set bs_sched [new WimaxScheduler/BS]
$bs_sched set-default-modulation $default_modulation
[$bstation802_16 set mac_(0)] set-scheduler $bs_sched
[$bstation802_16 set mac_(0)] set-channel 1

# creation of the wireless interface 802.16
for {set i 1} {$i<=$nn} {incr i} {
$ns node-config -wiredRouting OFF \
		-agentTrace ON \
		-movementTrace ON \
                -macTrace ON 				
set iface2_($i) [$ns node 4.0.$i] 	                                   ;# node id is 6.
$iface2_($i) random-motion 1                           ;# disable random motion
$iface2_($i) base-station [AddrParams addr2id [$bstation802_16 node-addr]] ;#attach mn to basestation

puts "*** tcl=$iface2_($i) ; id=[$iface2_($i) id]; addr=[$iface2_($i) node-addr]"

set clas [new SDUClassifier/Dest]
[$iface2_($i) set mac_(0)] add-classifier $clas
#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
set ss_sched [new WimaxScheduler/SS]
[$iface2_($i) set mac_(0)] set-scheduler $ss_sched
[$iface2_($i) set mac_(0)] set-channel 1

}


# add link to backbone
$ns duplex-link $bstation802_16 $router1 100MBit 15ms DropTail 1000

#ADD INTERFACE TO MULTIFACE
for {set i 1} {$i<=$nn} {incr i} {

set j [expr $i+1]
$multiFaceNode_($i) add-interface-node $iface0_($j)
$multiFaceNode_($i) add-interface-node $iface1_($i)
$multiFaceNode_($i) add-interface-node $iface2_($i)


$iface1_($i) set X_ $X_src
$iface1_($i) set Y_ $Y_src
$iface1_($i) set Z_ 0.0

$iface2_($i) set X_ $X_src
$iface2_($i) set Y_ $Y_src
$iface2_($i) set Z_ 0.0

set dstx 200
set dsty 120 

$ns at [expr $moveStart] "$iface1_($i) setdest $dstx $dsty $speed"
$ns at [expr $moveStart] "$iface2_($i) setdest $dstx $dsty $speed"
}

# INSTALL ND MODULES

# RNC UMTS
set nd_rncUMTS [$rnc install-nd]
$nd_rncUMTS set-router TRUE
$nd_rncUMTS router-lifetime 5
$nd_rncUMTS enable-broadcast FALSE
$nd_rncUMTS add-ra-target 0.0.2 ;#in UMTS there is no notion of broadcast. 

# MN UMTS
for {set i 1} {$i<=$nn} {incr i} {
set j [expr $i+1]
set nd_ue_($i) [$iface0_($j) install-nd]
}

set nd_bs [$bstation802 install-nd]
$nd_bs set-router TRUE
$nd_bs router-lifetime 18
$ns at 1 "$nd_bs start-ra"

# MN WIFI
for {set i 1} {$i<=$nn} {incr i} {
set nd_mn_($i) [$iface1_($i) install-nd]
}

# BS WIMAX
set nd_bs2 [$bstation802_16 install-nd]
$nd_bs2 set-router TRUE
$nd_bs2 router-lifetime 20 ;#just enough to expire while we are connected to wlan.
$ns at 1 "$nd_bs2 start-ra"

# MN WIMAX
for {set i 1} {$i<=$nn} {incr i} {
set nd_mn2_($i) [$iface2_($i) install-nd]
}

# INSTALL HANDOVER MODULE
# add the handover module for the Interface Management


for {set i 1} {$i<=$nn} {incr i} {

set handover_($i) [new Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover2]
puts "handover($i) on node : $handover_($i)"

$multiFaceNode_($i) install-ifmanager $handover_($i)
# install interface manager into multi-interface node and CN
$nd_mn_($i) set-ifmanager $handover_($i) 
$nd_ue_($i) set-ifmanager $handover_($i) 
$nd_mn2_($i) set-ifmanager $handover_($i)
set mih_($i) [$multiFaceNode_($i) install-mih]
$handover_($i) connect-mih $mih_($i) ;#create connection between MIH and iface management

set j [expr $i+1]

$handover_($i) nd_mac $nd_ue_($i) [$iface0_($j) set mac_(0)] 
$handover_($i) nd_mac $nd_mn_($i) [$iface1_($i) set mac_(0)]
$handover_($i) nd_mac $nd_mn2_($i) [$iface2_($i) set mac_(0)] ;#to know how to send RS

}
################################################################################
# TCP application between router0 and Multi interface node
# Create a UDP agent and attach it to node n0

for {set i 1} {$i<=$nn} {incr i} {
set udp_($i) [new Agent/UDP]
$udp_($i) set packetSize_ 1500

if {$quiet == 0} {
    puts "udp($i) on node : $udp_($i)"
}

# Create a CBR traffic source and attach it to udp0
set cbr_($i) [new Application/Traffic/CBR]
puts "cbr($i) on node : $cbr_($i)"
$cbr_($i) set packetSize_ 1024
$cbr_($i) set interval_ 0.001
$cbr_($i) attach-agent $udp_($i)

#create an sink into the sink node

# Create the Null agent to sink traffic

set null_($i) [new Agent/Null] 
puts "null_($i) on node : $null_($i)"
   
#Router0 is receiver    
#$ns attach-agent $router0 $null_

#Router0 is transmitter    
$ns attach-agent $router0 $udp_($i)
} 
   
#Multiface node is receiver
for {set i 1} {$i<=$nn} {incr i} {
set j [expr $i+1]
$multiFaceNode_($i) attach-agent $null_($i) $iface0_($j)
$handover_($i) add-flow $null_($i) $udp_($i) $iface0_($j) 1 ;#2000.
#$handover_($i) add-flow $null_($i) $udp_($i) $iface0_($j) 2 ;#2000.
#$handover_($i) add-flow $null_($i) $udp_($i) $iface0_($j) 3 ;#2000.	
}


# REGISTRATION
$router0 install-default-ifmanager

# 80211
set ifmgmt_bs [$bstation802 install-default-ifmanager]
set mih_bs [$bstation802 install-mih]
$ifmgmt_bs connect-mih $mih_bs

set tmp [$bstation802 set mac_(0)] ;#in 802.11 one interface is created
$tmp mih $mih_bs
$mih_bs add-mac $tmp


# 80216
set mih_bs2 [$bstation802_16 install-mih]
set tmp_bs2 [$bstation802_16 set mac_(0)]
$tmp_bs2 mih $mih_bs2
$mih_bs2 add-mac $tmp_bs2

# do registration in UMTS. This will create the MACs in UE and base stations
$ns node-config -llType UMTS/RLC/AM \
    -downlinkBW 384kbs \
    -uplinkBW 384kbs \
    -downlinkTTI 20ms \
    -uplinkTTI 20ms \
    -hs_downlinkTTI 2ms \
    -hs_downlinkBW 384kbs

for {set i 1} {$i<=$nn} {incr i} {

set j [expr $i+1]
# for the first HS-DCH, we must create. If any other, then use attach-dch
set dch0_($i) [$ns create-dch $iface0_($j) $null_($i)]; # multiface node receiver
$ns attach-dch $iface0_($j) $handover_($i) $dch0_($i)
$ns attach-dch $iface0_($j) $nd_ue_($i) $dch0_($i)

# Now we can register the MIH module with all the MACs
set tmp2 [$iface0_($j) set mac_(2)] ;#in UMTS and using DCH the MAC to use is 2 (0 and 1 are for RACH and FACH)
$tmp2 mih $mih_($i)
$mih_($i) add-mac $tmp2

set tmp1 [$iface1_($i) set mac_(0)] ;#in 802.11 one interface is created
$tmp1 mih $mih_($i)
$mih_($i) add-mac $tmp1




$bsUMTS trace-outlink $f 2
$iface0_($j) trace-inlink $f 2
$iface0_($j) trace-outlink $f 3




}




#############################################################


puts " Simulation is running ... please wait ..."




$ns run
