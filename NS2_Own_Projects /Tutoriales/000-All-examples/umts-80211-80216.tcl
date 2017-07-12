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
#									  +---------------------|	       |
#									  + iface:LTE(0.0.3)	|	       |	
#                  							  +---------------------+--------------+	
# 1 Multiface node.

#check input parameters
global ns

if { $argc > 0 } { 
 
  set seed     [lindex $argv 0]   ;# random seed
  set interval	[lindex $argv 1]
  set utility 	[lindex $argv 2]


# 802.11	
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set cost80211_   [lindex $argv 3]
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set energy80211_ [lindex $argv 4]

#802.16
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set cost80216_   [lindex $argv 5] 
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set energy80216_ [lindex $argv 6]
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set PER80216_ [lindex $argv 7]
# UMTS.3G
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set costUMTS_   [lindex $argv 8] 
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set energyUMTS_ [lindex $argv 9]
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set PERUMTS_ [lindex $argv 10] 
# LTE
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set costLTE_   [lindex $argv 11]
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set energyLTE_ [lindex $argv 12]
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set PERLTE_ [lindex $argv 13]
#pref 
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref1 [lindex $argv 14] 
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref2 [lindex $argv 15] 
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref3 [lindex $argv 16] 
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref4 [lindex $argv 17] 
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref5 [lindex $argv 18] 

  	
  # set utility function	
  Mac/802_11 set MIH_UTILITY_ $utility
  Mac/802_16 set MIH_UTILITY_ $utility	
  Mac/Umts set MIH_UTILITY_ $utility

  set rate_ [expr 1024/$interval]
  	
  puts "£££rate in bytes $rate_"

  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set rate80211_ $rate_	
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set rate80216_ $rate_
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set rateUMTS_  $rate_	
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set rateLTE_  $rate_	
 
  Mac/802_11 set rate_ $rate_   ;#data rate	
  Mac/802_16 set rate_ $rate_   ;#data rate	
  Mac/Umts set rate_ $rate_    ;#data rate
  Mac/Umts set rateLTE_ $rate_    ;#data rate
  
  Mac/802_11 set cost_   [lindex $argv 3]
  Mac/802_11 set energy_ [lindex $argv 4]
		

  Mac/802_16 set cost_   [lindex $argv 5]
  Mac/802_16 set energy_ [lindex $argv 6]
  Mac/802_16 set PER_    [lindex $argv 7]

  Mac/Umts set cost_ [lindex $argv 8]
  Mac/Umts set energy_ [lindex $argv 9]
  Mac/Umts set PER_ [lindex $argv 10]

  Mac/Umts set costLTE_ [lindex $argv 11]
  Mac/Umts set energyLTE_ [lindex $argv 12]
  Mac/Umts set PERLTE_ [lindex $argv 13]	 

  Mac/802_11 set pref1 [lindex $argv 14]
  Mac/802_11 set pref2 [lindex $argv 15]
  Mac/802_11 set pref3 [lindex $argv 16]
  Mac/802_11 set pref4 [lindex $argv 17]
  Mac/802_11 set pref5 [lindex $argv 18]	

  Mac/802_16 set pref1 [lindex $argv 14]
  Mac/802_16 set pref2 [lindex $argv 15]
  Mac/802_16 set pref3 [lindex $argv 16]
  Mac/802_16 set pref4 [lindex $argv 17]
  Mac/802_16 set pref5 [lindex $argv 18]
	
  Mac/Umts set pref1 [lindex $argv 14]
  Mac/Umts set pref2 [lindex $argv 15]
  Mac/Umts set pref3 [lindex $argv 16]
  Mac/Umts set pref4 [lindex $argv 17]
  Mac/Umts set pref5 [lindex $argv 18]

  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref1 [lindex $argv 14]
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref2 [lindex $argv 15]
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref3 [lindex $argv 16]
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref4 [lindex $argv 17]
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set pref5 [lindex $argv 18]

  	
  #Speed of the mobile nodes (m/sec)
  set moveSpeed [lindex $argv 19]	 	

  # Number of users
  Mac/802_11 set NN 1
  Mac/802_16 set NN 1
  Mac/Umts   set NN 1 
  Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set NN 1
	
# don't need to bind UMTS var...	
  		 		
} else {

puts "error parameters : script.tcl SEED nn "
}

set LTEON 0


# set global variables
set output_dir .


# seed the default RNG
global defaultRNG
if {$argc == 2} {
    set seed [lindex $argv 1]
    if { $seed == "random"} {
	$defaultRNG seed 0
    } else {
	$defaultRNG seed 1000
    }
}

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
Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set case_ 3
Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set confidence_th_ 80

#Define DEBUG parameters
set quiet 0
Agent/ND set debug_ 1 
Agent/MIH set debug_ 1
Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1 set debug_ 1
Mac/802_11 set debug_ 1
Mac/802_16 set debug_ 1

#Rate at which the nodes start moving
set moveStart 2
set moveStop  100

#origin of the MN
set X_src [lindex $argv 20]
#set X_src 105.0
set Y_src 115.0

#set X_dst 2600.0 ;#direction to wimax
#set X_dst 300 ;#direction to wifi
set X_dst [lindex $argv 21]
set Y_dst 115.0

#set timeLTE [expr floor(50+rand() * 100)]; random scenario
if { $moveSpeed !=0 } {
set timeLTE [expr $X_src / $moveSpeed];
} else {
set timeLTE 0
}



#defines function for flushing and closing files
proc finish {} {
    global ns f quiet
    $ns flush-trace
    close $f
    if {$quiet == 0} {
    puts " Simulation ended."
    }
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
# 1st cluster: UMTS: 2 network entities + nb of mobile nodes
# 2nd cluster: CN
# 3rd cluster: core network
# 4th cluster: WLAN: 1BS + nb of mobile nodes
# 5th cluster: super nodes
lappend tmp 4                                      ;# UMTS 2MNs+RNC+BS
lappend tmp 1                                      ;# router 0
lappend tmp 1                                      ;# router 1
lappend tmp 2                                      ;# 802.11 MNs+BS
lappend tmp 2					   ;# 802.16 MNs+BS
lappend tmp 1                                      ;# MULTIFACE nodes 
AddrParams set nodes_num_ $tmp

#create the topography
set opt(x)		5000			   ;# X dimension of the topography
set opt(y)		5000			   ;# Y dimension of the topography
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
#puts "Topology created"

##################################################################################
# Configure UMTS               							 #
##################################################################################
# Note: The UMTS configuration MUST be done first otherwise it does not work
#       furthermore, the node creation in UMTS MUST be as follow
#       rnc, base station, and UE (User Equipment)
$ns set hsdschEnabled_ 1addr
$ns set hsdsch_rlc_set_ 0
$ns set hsdsch_rlc_nif_ 0

# configure RNC node
$ns node-config -UmtsNodeType rnc 
set rnc [$ns create-Umtsnode 0.0.0] ;# node id is 0.
if {$quiet == 0} {
    puts "rnc: tcl=$rnc; id=[$rnc id]; addr=[$rnc node-addr]"
}

# configure UMTS base station
$ns node-config -UmtsNodeType bs \
		-downlinkBW 384kbs \
		-downlinkTTI 10ms \
		-uplinkBW 384kbs \
		-uplinkTTI 10ms \
     		-hs_downlinkTTI 2ms \
      		-hs_downlinkBW 384kbs 

set bsUMTS [$ns create-Umtsnode 0.0.1] ;# node id is 1
if {$quiet == 0} {
    puts "bsUMTS (NodeB): tcl=$bsUMTS; id=[$bsUMTS id]; addr=[$bsUMTS node-addr]"
}

# connect RNC and base station
$ns setup-Iub $bsUMTS $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000

$ns node-config -UmtsNodeType ue \
		-baseStation $bsUMTS \
		-radioNetworkController $rnc

set iface0 [$ns create-Umtsnode 0.0.2] ; #Node Id begins with 2. 


if {$LTEON == 1} {

#puts "time LTE: $timeLTE
set iface [$ns create-Umtsnode 0.0.3] ; # node for LTE
}



# Node address for router0 and router1
set router0 [$ns node 1.0.0]
set router1 [$ns node 2.0.0]
if {$quiet == 0} {
    puts "router0: tcl=$router0; id=[$router0 id]; addr=[$router0 node-addr]"
    puts "router1: tcl=$router1; id=[$router1 id]; addr=[$router1 node-addr]"
}

# connect links 
$ns duplex-link $rnc $router1 622Mbit 0.4ms DropTail 1000
$ns duplex-link $router1 $router0 100MBit 30ms DropTail 1000
$rnc add-gateway $router1

# creation of the MutiFaceNodes. It MUST be done before the 802.11
$ns node-config  -multiIf ON                            

set multiFaceNode [$ns node 5.0.1] 

$ns node-config  -multiIf OFF                    
if {$quiet == 0} {
    puts "multiFaceNode(s) has/have been created"
}


# create God
create-god 14				                ;# give the number of nodes 


##################################################################################
# Now we add 802.11 nodes							 #
##################################################################################

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

Mac/802_11 set RXThreshold_ 5.25089e-10 ; #for 50m cv

# configure rate for 802.11
Mac/802_11 set basicRate_ 11Mb
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set bandwidth_ 11Mb


# configure bandwidth LTE 
Mac/Umts set bandwidthLTE_ 120Mb



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
                 -macTrace ON  \
                 -movementTrace OFF

# configure Base station 802.11
set bstation802 [$ns node 3.0.0]
$bstation802 set X_ 100.0
$bstation802 set Y_ 100.0
$bstation802 set Z_ 0.0

if {$quiet == 0} {
    puts "bstation802: tcl=$bstation802; id=[$bstation802 id]; addr=[$bstation802 node-addr]"
}
# we need to set the BSS for the base station
set bstationMac [$bstation802 getMac 0]
set AP_ADDR_0 [$bstationMac id]
if {$quiet == 0} {
    puts "bss_id for bstation 1=$AP_ADDR_0"
}
$bstationMac bss_id $AP_ADDR_0
$bstationMac enable-beacon

# add link to backbone
$ns duplex-link $bstation802 $router1 100MBit 15ms DropTail 1000

# creation of the wireless interface 802.11
$ns node-config -wiredRouting OFF \
		-movementTrace ON \
                -macTrace ON 		

set iface1 [$ns node 3.0.1]     ;# node id is 8. 
$iface1 random-motion 1	;# disable random motion
$iface1 base-station [AddrParams addr2id [$bstation802 node-addr]] ;#attach mn to basestation


###############################################################################
# Node position
$iface1 set X_ $X_src
$iface1 set Y_ $Y_src
$iface1 set Z_ 0.0
###############################################################################
if {$quiet == 0} {
    puts "Iface 1 = $iface1"
}



###############################################################################
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
                 -routerTrace ON \
                 -macTrace ON  \
                 -movementTrace OFF

# configure Base station 802.16
set bstation802_16 [$ns node 4.0.0] ;
$bstation802_16 set X_ 150
$bstation802_16 set Y_ 100
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
$ns node-config -wiredRouting OFF \
		-movementTrace ON \
                -macTrace ON 				
set iface2 [$ns node 4.0.1] 	                                   ;# node id is 6.	
$iface2 random-motion 1                           ;# disable random motion
$iface2 base-station [AddrParams addr2id [$bstation802_16 node-addr]] ;#attach mn to basestation


###############################################################################
# Node position
$iface2 set X_ $X_src
$iface2 set Y_ $Y_src
$iface2 set Z_ 0.0
###############################################################################

set clas [new SDUClassifier/Dest]
[$iface2 set mac_(0)] add-classifier $clas
#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
set ss_sched [new WimaxScheduler/SS]
[$iface2 set mac_(0)] set-scheduler $ss_sched
[$iface2 set mac_(0)] set-channel 1


###############################################################################
#calculate the speed of the node
$ns at $moveStart "$iface1 setdest $X_dst $Y_dst $moveSpeed"
$ns at $moveStart "$iface2 setdest $X_dst $Y_dst $moveSpeed"
###############################################################################

# add link to backbone
$ns duplex-link $bstation802_16 $router1 100MBit 15ms DropTail 1000

###############################################################################
#ADD INTERFACE TO MULTIFACE
if {$LTEON == 1} { 
$multiFaceNode add-interface-node $iface ;# LTE
}
$multiFaceNode add-interface-node $iface0
$multiFaceNode add-interface-node $iface1
$multiFaceNode add-interface-node $iface2
###############################################################################
# Periodique handoff test... 
#$ns at 100 "[eval $iface1 set mac_(0)] set-handoff80211 1" 
#$ns at 8 "[eval $iface1 set mac_(0)] set-handoff80211 1" 
#$ns at 12 "[eval $iface1 set mac_(0)] set-handoff80211 1" 
#$ns at 15 "[eval $iface1 set mac_(0)] set-handoff80211 1" 

###############################################################################
# INSTALL ND MODULES
# take care of UMTS Note: The ND module is on the rnc node NOT in the base station

# RNC UMTS
set nd_rncUMTS [$rnc install-nd]
$nd_rncUMTS set-router TRUE
$nd_rncUMTS router-lifetime 5
$nd_rncUMTS enable-broadcast FALSE
$nd_rncUMTS add-ra-target 0.0.2 ;#in UMTS there is no notion of broadcast. 

if {$LTEON == 1} {
# MN LTE
set nd_lte [$iface install-nd]
}
# MN UMTS
set nd_ue [$iface0 install-nd]

# BS WIFI
set nd_bs [$bstation802 install-nd]
$nd_bs set-router TRUE
$nd_bs router-lifetime 18
$ns at 1 "$nd_bs start-ra"

# MN WIFI
set nd_mn [$iface1 install-nd]

# BS WIMAX
set nd_bs2 [$bstation802_16 install-nd]
$nd_bs2 set-router TRUE
$nd_bs2 router-lifetime 20 ;#just enough to expire while we are connected to wlan.
$ns at 1 "$nd_bs2 start-ra"

# MN WIMAX
set nd_mn2 [$iface2 install-nd]

################################################################################
# INSTALL HANDOVER MODULE
# add the handover module for the Interface Management
set handover [new Agent/MIHUser/IFMNGMT/MIPV6/Handover/Handover1]
$multiFaceNode install-ifmanager $handover

# install interface manager into multi-interface node and CN
$nd_mn set-ifmanager $handover 
$nd_ue set-ifmanager $handover 
$nd_mn2 set-ifmanager $handover

set mih [$multiFaceNode install-mih]
$handover connect-mih $mih ;#create connection between MIH and iface management


if {$LTEON == 1} { 
$handover nd_mac $nd_lte [$iface set mac_(0)]
}
$handover nd_mac $nd_ue [$iface0 set mac_(0)] 
$handover nd_mac $nd_mn [$iface1 set mac_(0)]
$handover nd_mac $nd_mn2 [$iface2 set mac_(0)] ;#to know how to send RS



################################################################################

################################################################################
# TCP application between router0 and Multi interface node
# Create a UDP agent and attach it to node n0
set udp_ [new Agent/UDP]
$udp_ set packetSize_ 1500

if {$quiet == 0} {
    puts "udp on node : $udp_"
}

# Create a CBR traffic source and attach it to udp0
set cbr_ [new Application/Traffic/CBR]
$cbr_ set packetSize_ 1024
$cbr_ set interval_ $interval
$cbr_ attach-agent $udp_

#create an sink into the sink node

# Create the Null agent to sink traffic
set null_ [new Agent/Null] 
    
#Router0 is receiver    
#$ns attach-agent $router0 $null_

#Router0 is transmitter    
$ns attach-agent $router0 $udp_

   
#Multiface node is receiver
$multiFaceNode attach-agent $null_ $iface0
$handover add-flow $null_ $udp_ $iface0 1 ;#2000.
################################################################################
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
set mih_bs [$bstation802_16 install-mih]
set tmp_bs [$bstation802_16 set mac_(0)]
$tmp_bs mih $mih_bs
$mih_bs add-mac $tmp_bs


# do registration in UMTS. This will create the MACs in UE and base stations
$ns node-config -llType UMTS/RLC/AM \
    -downlinkBW 384kbs \
    -uplinkBW 384kbs \
    -downlinkTTI 20ms \
    -uplinkTTI 20ms \
    -hs_downlinkTTI 2ms \
    -hs_downlinkBW 384kbs

if {$LTEON == 1} {
# for the first HS-DCH, we must create. If any other, then use attach-dch
set dch [$ns create-dch $iface $null_]; # multiface node receiver
$ns attach-dch $iface $handover $dch
$ns attach-dch $iface $nd_lte $dch
}

# for the first HS-DCH, we must create. If any other, then use attach-dch
set dch0 [$ns create-dch $iface0 $null_]; # multiface node receiver
$ns attach-dch $iface0 $handover $dch0
$ns attach-dch $iface0 $nd_ue $dch0

if {$LTEON == 1} {
# Now we can register the MIH module with all the MACs
set tmpLTE [$iface set mac_(2)] ;#in UMTS and using DCH the MAC to use is 2 (0 and 1 are for RACH and FACH)
$tmpLTE mih $mih
$mih add-mac $tmpLTE
}

# Now we can register the MIH module with all the MACs
set tmp2 [$iface0 set mac_(2)] ;#in UMTS and using DCH the MAC to use is 2 (0 and 1 are for RACH and FACH)
$tmp2 mih $mih
$mih add-mac $tmp2

set tmp2 [$iface1 set mac_(0)] ;#in 802.11 one interface is created
$tmp2 mih $mih
$mih add-mac $tmp2

set tmp2 [$iface2 set mac_(0)] ;#in 802.16 one interface is created
$tmp2 mih $mih
$mih add-mac $tmp2             ;#inform the MIH about the local MAC


#Start the application 1sec before the MN is entering the WLAN cell
$ns at [expr $moveStart - 1] "$cbr_ start"
#Stop the application according to another poisson distribution (note that we don't leave the 802.11 cell)
$ns at [expr $moveStop  + 1] "$cbr_ stop"

# set original status of interface. By default they are up..so to have a link up, 
# we need to put them down first.
$ns at 0 "[eval $iface0 set mac_(2)] disconnect-link" ;#UMTS UE
$ns at 0.001 "[eval $iface0 set mac_(2)] connect-link"     ;#umts link 

if {$LTEON == 1} {

$ns at $timeLTE "[eval $iface set mac_(2)] disconnect-link-LTE" ;#LTE UE

$ns at $timeLTE "[eval $iface set mac_(2)] connect-link-LTE"     ;#LTE link
}




#$ns at $moveStart "puts \"At $moveStart Mobile Node starts moving\""
#$ns at [expr $moveStart+10] "puts \"++At [expr $moveStart+10] Mobile Node enters wlan\""
#$ns at [expr $moveStart+110] "puts \"++At [expr $moveStart+110] Mobile Node leaves wlan\""
#$ns at $moveStop "puts \"Mobile Node stops moving\""



$ns at [expr $moveStop + 1] "puts \"Simulation ends at [expr $moveStop+1]\"" 
$ns at [expr $moveStop + 1] "finish" 

if {$quiet == 0} {
puts " Simulation is running ... please wait ..."
}

$ns run
