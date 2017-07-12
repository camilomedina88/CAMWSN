#     http://www.linuxquestions.org/questions/linux-newbie-8/simulation-of-handoff-b-w-umts-and-802-11-a-4175524038/ 
#set debug attributes
Agent/ND set debug_ 1
Agent/MIH set debug_ 1
Agent/MIHUser/IFMNGMT/MIPV6/Handover/Simple set debug_ 1

# set global variables
set output_dir .

#create the simulator
set ns [new Simulator]
#$ns use-newtrace

#open file for trace
set f [open out1.tr w]
$ns trace-all $f

# set up for hierarchical routing (needed for routing over a basestation)
$ns node-config -addressType hierarchical
AddrParams set domain_num_ 6 ;# domain number
AddrParams set cluster_num_ {1 1 1 1 1 1} ;# cluster number for each domain
AddrParams set nodes_num_ {3 1 1 1 2 2} ;# number of nodes for each cluster

# configure UMTS.
# Note: The UMTS configuration MUST be done first otherwise it does not work
# furthermore, the node creation in UMTS MUST be as follow
# rnc, base station, and UE (User Equipment)
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
puts "bsUMTS: tcl=$bsUMTS; id=[$bsUMTS id]; addr=[$bsUMTS node-addr]"

# connect RNC and base station
$ns setup-Iub $bsUMTS $rnc 622Mbit 622Mbit 15ms 15ms DummyDropTail 2000

$ns node-config -UmtsNodeType ue \
-baseStation $bsUMTS \
-radioNetworkController $rnc

set iface0 [$ns create-Umtsnode 0.0.2] ;# node id is 2
puts "iface0(UMTS): tcl=$iface0; id=[$iface0 id]; addr=[$iface0 node-addr]"

# Node address for router0 and router1 are 3 and 4, respectively.
set cn [$ns node 1.0.0]
puts "cn: tcl=$cn; id=[$cn id]; addr=[$cn node-addr]"
set router1 [$ns node 2.0.0]
puts "router1: tcl=$router1; id=[$router1 id]; addr=[$router1 node-addr]"


# connect links
$ns duplex-link $rnc $router1 622Mbit 0.4ms DropTail 1000
$ns duplex-link $router1 $cn 100MBit 5ms DropTail 1000
$rnc add-gateway $router1

# creation of the MutiFaceNodes. It MUST be done before the 802.11
$ns node-config -multiIf ON ;#to create MultiFaceNode
set multiFaceNode [$ns node 5.0.0] ;# node id is 5
$ns node-config -multiIf OFF ;#reset attribute
puts "multiFaceNode: tcl=$multiFaceNode; id=[$multiFaceNode id]; addr=[$multiFaceNode node-addr]"

# parameter for wireless nodes
set opt(chan) Channel/WirelessChannel ;# channel type for 802.11
set opt(prop) Propagation/TwoRayGround ;# radio-propagation model 802.11
set opt(netif) Phy/WirelessPhy ;# network interface type 802.11
set opt(mac) Mac/802_11 ;# MAC type 802.11
set opt(ifq) Queue/DropTail/PriQueue ;# interface queue type 802.11
set opt(ll) LL ;# link layer type 802.11
set opt(ant) Antenna/OmniAntenna ;# antenna model 802.11
set opt(ifqlen) 50 ;# max packet in ifq 802.11
set opt(adhocRouting) DSDV ;# routing protocol 802.11
set opt(umtsRouting) "" ;# routing for UMTS (to reset node config)

set opt(x) 800 ;# X dimension of the topography
set opt(y) 800 ;# Y dimension of the topography

# configure rate for 802.11
Mac/802_11 set basicRate_ 11Mb
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set bandwidth_ 11Mb

#create the topography
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
#puts "Topology created"

# create God
create-god 10 ;# give the number of nodes


# configure Access Points
$ns node-config -adhocRouting $opt(adhocRouting) \
-llType $opt(ll) \
-macType $opt(mac) \
-channel [new $opt(chan)] \
-ifqType $opt(ifq) \
-ifqLen $opt(ifqlen) \
-antType $opt(ant) \
-propType $opt(prop) \
-phyType $opt(netif) \
-topoInstance $topo \
-wiredRouting ON \
-agentTrace ON \
-routerTrace OFF \
-macTrace ON \
-movementTrace OFF


proc finish {} {
global ns f
$ns flush-trace
close $f
#exec nam mih.nam &
puts " Simulation ended."
exit 0
}

# configure Base station 802.11
set bstation1 [$ns node 3.0.0] ;
$bstation1 set X_ [expr 500.0]
$bstation1 set Y_ 300.0
$bstation1 set Z_ 0.0
puts "bstation802.11: tcl=$bstation1; id=[$bstation1 id]; addr=[$bstation1 node-addr]"
# we need to set the BSS for the base station
set bstationMac [$bstation1 getMac 0]
set AP_ADDR_0 [$bstationMac id]
puts "bss_id for bstation 1=$AP_ADDR_0"
$bstationMac bss_id $AP_ADDR_0
$bstationMac enable-beacon
$bstationMac set-channel 1

# creation of the wireless interface 802.11
$ns node-config -wiredRouting OFF \
-macTrace ON
#      set iface1 [$ns node 3.0.1] ;# node id is 7.
set iface1 [$ns node 7.0.0]

$iface1 random-motion 0 ;# disable random motion
$iface1 base-station [AddrParams addr2id [$bstation1 node-addr]] ;#attach mn to basestation
$iface1 set X_ 50.0
$iface1 set Y_ 200.0
$iface1 set Z_ 0.0
[$iface1 set mac_(0)] set-channel 1
# define node movement. We start from outside the coverage, cross it and leave.
$ns at 10 "$iface1 setdest 590.0 200.0 30.0"
puts "iface1: tcl=$iface1; id=[$iface1 id]; addr=[$iface1 node-addr]"


# configure Base station 802.11
set bstation2 [$ns node 4.0.0] ;
$bstation2 set X_ [expr 300.0]
$bstation2 set Y_ 300.0
$bstation2 set Z_ 0.0
puts "bstation802: tcl=$bstation2; id=[$bstation2 id]; addr=[$bstation2 node-addr]"
#we need to set the BSS for the base station
set bstationMac [$bstation2 getMac 0]
set AP_ADDR_0 [$bstationMac id]
puts "bss_id for bstation 2=$AP_ADDR_0"
$bstationMac bss_id $AP_ADDR_0
$bstationMac enable-beacon
$bstationMac set-channel 2
$iface1 base-station [AddrParams addr2id [$bstation2 node-addr]] ;#attach mn to basestation


# add link to backbone
$ns duplex-link $bstation1 $router1 100MBit 15ms DropTail 1000
$ns duplex-link $bstation2 $router1 100MBit 15ms DropTail 1000

# add interfaces to MultiFaceNode
$multiFaceNode add-interface-node $iface1
#$multiFaceNode add-interface-node $iface2
$multiFaceNode add-interface-node $iface0


# install ND modules

# take care of UMTS
# Note: The ND module is on the rnc node NOT in the base station
set nd_rncUMTS [$rnc install-nd]
$nd_rncUMTS set-router TRUE
$nd_rncUMTS router-lifetime 5
$nd_rncUMTS enable-broadcast FALSE
$nd_rncUMTS add-ra-target 0.0.2 ;#in UMTS there is no notion of broadcast.
#We fake it by sending unicast to a list of nodes
set nd_ue [$iface0 install-nd]

# now WLAN
set nd_bs1 [$bstation1 install-nd]
$nd_bs1 set-router TRUE
$nd_bs1 router-lifetime 7

set nd_bs2 [$bstation2 install-nd]
$nd_bs2 set-router TRUE
$nd_bs2 router-lifetime 7

set nd_mn1 [$iface1 install-nd]
#set nd_mn2 [$iface1 install-nd]

set nd_router [$router1 install-nd]
$nd_router set-router TRUE
$nd_router router-lifetime 5


# install interface manager into multi-interface node and CN
set handover [new Agent/MIHUser/IFMNGMT/MIPV6/Handover/Simple]
$multiFaceNode install-ifmanager $handover
$nd_mn1 set-ifmanager $handover
$handover nd_mac $nd_mn1 [$iface1 set mac_(0)] ;#to know how to send RS
#$nd_mn2 set-ifmanager $handover
#$handover nd_mac $nd_mn2 [$iface2 set mac_(0)] ;#to know how to send RS


set ifmgmt_cn [$cn install-default-ifmanager]

# install MIH in multi-interface node
set mih [$multiFaceNode install-mih]

$handover connect-mih $mih ;#create connection between MIH and iface management

# install MIH on AP
set mih_bs1 [$bstation1 install-mih]
set tmp_bs1 [$bstation1 set mac_(0)]
$tmp_bs1 mih $mih_bs1
$mih_bs1 add-mac $tmp_bs1

set mih_bs2 [$bstation2 install-mih]
set tmp_bs2 [$bstation2 set mac_(0)]
$tmp_bs2 mih $mih_bs2
$mih_bs2 add-mac $tmp_bs2

# create a TCP agent and attach it to multi-interface node
set tcp_(0) [new Agent/TCP/FullTcp]
# $ns attach-agent $iface0 $tcp_(0) ;# old command to attach to node
$multiFaceNode attach-agent $tcp_(0) $iface0 ;# new command: the interface is used for sending
set app_(0) [new Agent/Null] ;#we can use this or the next line

# create a TPC agent and attach it to router0
set tcp_(1) [new Agent/TCP/FullTcp]
$ns attach-agent $cn $tcp_(1)
set app_(1) [new Application/TcpApp $tcp_(1)] ;#activate this line if done created abot
puts "App1 id=$app_(1)"

#Create a CBR traffic source and attach it to tcp_(1)
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 1000
$cbr_(0) set interval_ 0.5
$cbr_(0) attach-agent $tcp_(1)
$handover add-flow $tcp_(0) $tcp_(1) $iface0 1
$tcp_(0) listen
puts "tcp stream made from [$cn node-addr] and [$iface0 node-addr]"

# do registration in UMTS. This will create the MACs in UE and base stations
$ns node-config -llType UMTS/RLC/AM \
-downlinkBW 384kbs \
-uplinkBW 384kbs \
-downlinkTTI 20ms \
-uplinkTTI 20ms \
-hs_downlinkTTI 2ms \
-hs_downlinkBW 384kbs

# for the first HS-DCH, we must create. If any other, then use attach-dch
set dch0 [$ns create-dch $iface0 $tcp_(0)]
$ns attach-dch $iface0 $handover $dch0
$ns attach-dch $iface0 $nd_ue $dch0
puts "dch channel"

# Now we can register the MIH module with all the MACs
set tmp2 [$iface0 set mac_(2)] ;#in UMTS and using DCH the MAC to use is 2 (0 and 1 are for RACH and FACH)
$tmp2 mih $mih
$mih add-mac $tmp2 ;#inform the MIH about the local MAC
set tmp2 [$iface1 set mac_(0)] ;#in 802.11 one interface is created
$tmp2 mih $mih
$mih add-mac $tmp2 ;#inform the MIH about the local MAC



Application/TcpApp instproc recv {data} {
global ns
$ns trace-annotate "$self received data \"$data\""
puts "$self received data \"$data\" at [$ns now]"
}


$ns at 10 "$cbr_(0) start" ;#we should make sure we have UMTS link up before starting to send.

# set original status of interface. By default they are up..so to have a link up,
# we need to put them down first.
$ns at 0 "[eval $iface0 set mac_(2)] disconnect-link" ;#UMTS UE


# set the starting time for Router Advertisements
$ns at 3 "$nd_bs1 start-ra"
#$ns at 3 "$nd_bs2 start-ra"
#$ns at 3 "$nd_bs3 start-ra"
$ns at 1 "$nd_rncUMTS start-ra"
$ns at 1 "$nd_router start-ra"

$ns at 9 "[eval $iface0 set mac_(2)] connect-link" ;#umts link

$ns at 45 "finish"

puts " Simulation is running ... please wait ..."
$ns run
