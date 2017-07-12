#    ravija shah <ravijaflowers@gmail.com>



global ns
remove-all-packet-headers
add-packet-header MPEG4 MAC_HS RLC LL Mac RTP TCP IP Common Flags
set opt(umtsRouting)    ""                         ;# routing for UMTS (to reset node config)
#defines function for flushing and closing files
proc finish {} {
    global ns f
    $ns flush-trace
    close $f
    puts " Simulation ended."
    exit 0
}

# set global variables
#set output_dir .

#create the simulator
set ns [new Simulator]
$ns use-newtrace

#open file for trace
set f [open out.tr w]
$ns trace-all $f

# set up for hierarchical routing (needed for routing over a basestation)
$ns node-config -addressType hierarchical
AddrParams set domain_num_  6                       ;# domain number
AddrParams set cluster_num_ {1 1 1 1 1 1}           ;# cluster number for each domain 
AddrParams set nodes_num_   {6 1 13 5 5 1}           ;# number of nodes for each cluster             

# configure UMTS. 
# Note: The UMTS configuration MUST be done first otherwise it does not work
#       furthermore, the node creation in UMTS MUST be as follow
#       rnc, base station, and UE (User Equipment)
$ns set hsdschEnabled_ 1addr
$ns set hsdsch_rlc_set_ 0
$ns set hsdsch_rlc_nif_ 0

# configure RNC node
$ns node-config -UmtsNodeType rnc $opt(umtsRouting)
set rnc [$ns node 0.0.0] ;# node id is 0.
$rnc set type_ $opt(umtsRouting)
puts "rnc: tcl=$rnc; id=[$rnc id]; addr=[$rnc node-addr]"

# configure UMTS base station
$ns node-config -UmtsNodeType bs $opt(umtsRouting)\
		-downlinkBW 384kbs \
		-downlinkTTI 10ms \
		-uplinkBW 384kbs \
		-uplinkTTI 10ms \
     		-hs_downlinkTTI 2ms \
      		-hs_downlinkBW 384kbs 

set bsUMTS [$ns node 0.0.1] ;# node id is 1
$bsUMTS set type_ $opt(umtsRouting)
puts "bsUMTS: tcl=$bsUMTS; id=[$bsUMTS id]; addr=[$bsUMTS node-addr]"

# connect RNC and base station
#$ns duplex-link $bsUMTS $rnc 622Mb 15ms RED

$ns node-config -UmtsNodeType ue $opt(umtsRouting)\
		-baseStation $bsUMTS \
		-radioNetworkController $rnc

set iface0 [$ns node 0.0.2] ;# node id is 2
$iface0 set type_ $opt(umtsRouting)
puts "iface0(UMTS): tcl=$iface0; id=[$iface0 id]; addr=[$iface0 node-addr]" 
set iface1 [$ns node 0.0.3] ;# node id is 2
$iface1 set type_ $opt(umtsRouting)
puts "iface1(UMTS): tcl=$iface1; id=[$iface1 id]; addr=[$iface1 node-addr]" 
set iface2 [$ns node 0.0.4] ;# node id is 2
$iface2 set type_ $opt(umtsRouting)
puts "iface2(UMTS): tcl=$iface2; id=[$iface2 id]; addr=[$iface2 node-addr]" 
set iface3 [$ns node 0.0.5] ;# node id is 2
$iface3 set type_ $opt(umtsRouting)
puts "iface3(UMTS): tcl=$iface3; id=[$iface3 id]; addr=[$iface3 node-addr]" 

# Node address for router0 and router1 are 4 and 5, respectively.
set router0 [$ns node 1.0.0]
puts "router0: tcl=$router0; id=[$router0 id]; addr=[$router0 node-addr]"
set router1 [$ns node 2.0.0]
puts "router1: tcl=$router1; id=[$router1 id]; addr=[$router1 node-addr]"
set router2 [$ns node 2.0.1]
puts "router2: tcl=$router2; id=[$router2 id]; addr=[$router2 node-addr]"
set router3 [$ns node 2.0.2]
puts "router3: tcl=$router3; id=[$router3 id]; addr=[$router3 node-addr]"
set router4 [$ns node 2.0.3]
puts "router4: tcl=$router4; id=[$router4 id]; addr=[$router4 node-addr]"
set router5 [$ns node 2.0.4]
puts "router5: tcl=$router5; id=[$router5 id]; addr=[$router5 node-addr]"
set router6 [$ns node 2.0.5]
puts "router6: tcl=$router6; id=[$router6 id]; addr=[$router6 node-addr]"
set router7 [$ns node 2.0.6]
puts "router7: tcl=$router7; id=[$router7 id]; addr=[$router7 node-addr]"
set router8 [$ns node 2.0.7]
puts "router8: tcl=$router8; id=[$router8 id]; addr=[$router8 node-addr]"
set router9 [$ns node 2.0.8]
puts "router9: tcl=$router9; id=[$router9 id]; addr=[$router9 node-addr]"
set router10 [$ns node 2.0.9]
puts "router10: tcl=$router10; id=[$router10 id]; addr=[$router10 node-addr]"
set router11 [$ns node 2.0.10]
puts "router11: tcl=$router11; id=[$router11 id]; addr=[$router11 node-addr]"
set router12 [$ns node 2.0.11]
puts "router12: tcl=$router12; id=[$router12 id]; addr=[$router12 node-addr]"
# creating lan to iface2
#lappend nodelist $router1
set router13 [$ns node 2.0.12]
#lappend nodelist $router2
puts "router13: tcl=$router13; id=[$router13 id]; addr=[$router13 node-addr]"


# connect links 
$ns duplex-link $rnc $router1 622Mb 0.4ms DropTail 
$ns duplex-link $router1 $router0 100Mb 5ms DropTail 
$ns duplex-link $router1 $router2 100Mb 5ms DropTail 
$ns duplex-link $router1 $router3 100Mb 5ms DropTail
$ns duplex-link $router1 $router4 100Mb 5ms DropTail
$ns duplex-link $router1 $router5 100Mb 5ms DropTail
$ns duplex-link $router1 $router6 100Mb 5ms DropTail
$ns duplex-link $router1 $router7 100Mb 5ms DropTail
$ns duplex-link $router1 $router8 100Mb 5ms DropTail
$ns duplex-link $router1 $router9 100Mb 5ms DropTail
$ns duplex-link $router1 $router10 100Mb 5ms DropTail
$ns duplex-link $router1 $router11 100Mb 5ms DropTail
$ns duplex-link $router1 $router12 100Mb 5ms DropTail
$ns duplex-link $router1 $router13 100MB 5ms DropTail
#$rnc add-gateway $router1


# creation of the MutiFaceNodes. It MUST be done before the 802.11
$ns node-config  -multiIf ON                            ;#to create MultiFaceNode 
set multiFaceNode [$ns node 5.0.0]                      ;# node id is 6
$ns node-config  -multiIf OFF                           ;#reset attribute
puts "multiFaceNode: tcl=$multiFaceNode; id=[$multiFaceNode id]; addr=[$multiFaceNode node-addr]"

#
# Now we add 802.11 nodes
#

# parameter for wireless nodes
set opt(chan)           Channel/WirelessChannel    ;# channel type for 802.11
set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model 802.11
set opt(netif)          Phy/WirelessPhy            ;# network interface type 802.11
set opt(mac)            Mac/802_11                 ;# MAC type 802.11
set opt(ifq)            Queue/DropTail  	  ;# interface queue type 802.11
set opt(ll)             LL                         ;# link layer type 802.11
set opt(ant)            Antenna/OmniAntenna        ;# antenna model 802.11
set opt(ifqlen)         50              	   ;# max packet in ifq 802.11
set opt(adhocRouting)   DSDV                       ;# routing protocol 802.11
set opt(umtsRouting)    ""                         ;# routing for UMTS (to reset node config)

set opt(x)		2000			   ;# X dimension of the topography
set opt(y)		2000			   ;# Y dimension of the topography
set opt(stop) 		100
set opt(seed)		50

# configure rate for 802.11
Mac/802_11 set basicRate_ 1Mb
Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set bandwidth_ 11Mb
# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}
if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}
#create the topography
set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)
#puts "Topology created"
set chan [new $opt(chan)]

# create God
create-god 31				                ;# give the number of nodes 

#set lan0 [$ns newLan $nodelist 10Mb 1ms \
	     # -llType LL -ifqType Queue/DropTail \
	      #-macType Mac/802_11 -chanType Channel -address 2.0.1]
#puts "lan created between router1 and router2"


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
                 -macTrace ON  \
                 -movementTrace OFF

# configure Base station 802.11
set bstation802 [$ns node 3.0.0] ;
$bstation802 set X_ 680.0
$bstation802 set Y_ 1000.0
$bstation802 set Z_ 0.0
puts "bstation802: tcl=$bstation802; id=[$bstation802 id]; addr=[$bstation802 node-addr]"
# we need to set the BSS for the base station
#set bstationMac [$bstation802 getMac 0]
#set AP_ADDR_0 [$bstationMac id]
#puts "bss_id for bstation 1=$AP_ADDR_0"
#$bstationMac bss_id $AP_ADDR_0
#$bstationMac enable-beacon
#$bstationMac set-channel 1

# creation of the wireless interface 802.11
$ns node-config -wiredRouting OFF \
                -macTrace ON 				
set iface4 [$ns node 3.0.1] 	                                   ;# node id is 8.	
$iface4 random-motion 0			                           ;# disable random motion
$iface4 base-station [AddrParams addr2id [$bstation802 node-addr]] ;#attach mn to basestation
$iface4 set X_ 480.0
$iface4 set Y_ 1000.0
$iface4 set Z_ 0.0
#[$iface1 set mac_(0)] set-channel 1
# define node movement. We start from outside the coverage, cross it and leave.
$ns at 0.5 "$iface4 setdest 160.0 100.0 3.0"
puts "iface4: tcl=$iface4; id=[$iface4 id]; addr=[$iface4 node-addr]"		    

set iface5 [$ns node 3.0.2] 	                                   ;# node id is 8.	
$iface5 random-motion 0			                           ;# disable random motion
$iface5 base-station [AddrParams addr2id [$bstation802 node-addr]] ;#attach mn to basestation
$iface5 set X_ 280.0
$iface5 set Y_ 500.0
$iface5 set Z_ 0.0
#[$iface1 set mac_(0)] set-channel 1
# define node movement. We start from outside the coverage, cross it and leave.
$ns at 0.5 "$iface5 setdest 1600.0 1000.0 3.0"
puts "iface5: tcl=$iface5; id=[$iface5 id]; addr=[$iface5 node-addr]"	
set iface6 [$ns node 3.0.3] 	                                   ;# node id is 8.	
$iface6 random-motion 0			                           ;# disable random motion
$iface6 base-station [AddrParams addr2id [$bstation802 node-addr]] ;#attach mn to basestation
$iface6 set X_ 180.0
$iface6 set Y_ 100.0
$iface6 set Z_ 0.0
#[$iface1 set mac_(0)] set-channel 1
# define node movement. We start from outside the coverage, cross it and leave.
$ns at 0.5 "$iface6 setdest 600.0 10.0 3.0"
puts "iface6: tcl=$iface6; id=[$iface6 id]; addr=[$iface6 node-addr]"	

set iface7 [$ns node 3.0.4] 	                                   ;# node id is 8.	
$iface7 random-motion 0			                           ;# disable random motion
$iface7 base-station [AddrParams addr2id [$bstation802 node-addr]] ;#attach mn to basestation
$iface7 set X_ 180.0
$iface7 set Y_ 600.0
$iface7 set Z_ 0.0
#[$iface1 set mac_(0)] set-channel 1
# define node movement. We start from outside the coverage, cross it and leave.
$ns at 0.5 "$iface7 setdest 160.0 700.0 3.0"
puts "iface7: tcl=$iface7; id=[$iface7 id]; addr=[$iface7 node-addr]"	
# add link to backbone
$ns duplex-link $bstation802 $router1 100Mb 15ms DropTail 

# add Wimax nodes
set opt(g)          Phy/WirelessPhy/OFDM       ;# network interface type 802.16
set opt(channel)            Mac/802_16                 ;# MAC type 802.16



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
                 -macTrace ON  \
                 -movementTrace OFF

# configure Base station 802.16
set bstation802_16 [$ns node 4.0.0] ;
$bstation802_16 set X_ 1000
$bstation802_16 set Y_ 1000
$bstation802_16 set Z_ 0.0
puts "bstation802_16: tcl=$bstation802_16; id=[$bstation802_16 id]; addr=[$bstation802_16 node-addr]"
#set clas [new SDUClassifier/Dest]
#[$bstation802_16 set mac_(0)] add-classifier $clas
#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
#set bs_sched [new WimaxScheduler/BS]
#[$bstation802_16 set mac_(0)] set-scheduler $bs_sched
#[$bstation802_16 set mac_(0)] set-channel 1

# creation of the wireless interface 802.11
$ns node-config -wiredRouting OFF \
                -macTrace ON 				
set iface8 [$ns node 4.0.1] 	                                   ;# node id is 8.	
$iface8 random-motion 0			                           ;# disable random motion
$iface8 base-station [AddrParams addr2id [$bstation802_16 node-addr]] ;#attach mn to basestation
$iface8 set X_ 380.0
$iface8 set Y_ 600.0
$iface8 set Z_ 0.0
#set clas [new SDUClassifier/Dest]
#[$iface3 set mac_(0)] add-classifier $clas
#set the scheduler for the node. Must be changed to -shed [new $opt(sched)]
#set ss_sched [new WimaxScheduler/SS]
#[$iface3 set mac_(0)] set-scheduler $ss_sched
#[$iface3 set mac_(0)] set-channel 1
# define node movement. We start from outside the coverage, cross it and leave.
$ns at 0.5 "$iface8 setdest 100.0 700.0 3.0"
puts "iface8: tcl=$iface8; id=[$iface8 id]; addr=[$iface8 node-addr]"		    


set iface9 [$ns node 4.0.2] 	                                   ;# node id is 8.	
$iface9 random-motion 0			                           ;# disable random motion
$iface9 base-station [AddrParams addr2id [$bstation802 node-addr]] ;#attach mn to basestation
$iface9 set X_ 180.0
$iface9 set Y_ 100.0
$iface9 set Z_ 0.0
#[$iface1 set mac_(0)] set-channel 1
# define node movement. We start from outside the coverage, cross it and leave.
$ns at 0.5 "$iface9 setdest 150.0 107.0 3.0"
puts "iface9: tcl=$iface9; id=[$iface9 id]; addr=[$iface9 node-addr]"

set iface10 [$ns node 4.0.3] 	                                   ;# node id is 8.	
$iface10 random-motion 0			                           ;# disable random motion
$iface10 base-station [AddrParams addr2id [$bstation802 node-addr]] ;#attach mn to basestation
$iface10 set X_ 1800.0
$iface10 set Y_ 1000.0
$iface10 set Z_ 0.0
#[$iface1 set mac_(0)] set-channel 1
# define node movement. We start from outside the coverage, cross it and leave.
$ns at 0.5 "$iface10 setdest 100.0 700.0 3.0"
puts "iface10: tcl=$iface10; id=[$iface10 id]; addr=[$iface10 node-addr]"
set iface11 [$ns node 4.0.4] 	                                   ;# node id is 8.	
$iface11 random-motion 0			                           ;# disable random motion
$iface11 base-station [AddrParams addr2id [$bstation802 node-addr]] ;#attach mn to basestation
$iface11 set X_ 280.0
$iface11 set Y_ 400.0
$iface11 set Z_ 0.0
#[$iface1 set mac_(0)] set-channel 1
# define node movement. We start from outside the coverage, cross it and leave.
$ns at 0.5 "$iface11 setdest 200.0 500.0 3.0"
puts "iface11: tcl=$iface11; id=[$iface11 id]; addr=[$iface11 node-addr]"
# add link to backbone

$ns duplex-link $bstation802_16 $router1 100Mb 15ms DropTail 





# do registration in UMTS. This will create the MACs in UE and base stations
$ns node-config -llType UMTS/RLC/AM \
		-downlinkBW 384kbs \
		-uplinkBW 384kbs \
		-downlinkTTI 20ms \
		-uplinkTTI 20ms \
   		-hs_downlinkTTI 2ms \
    		-hs_downlinkBW 384kbs
set s0 [new Agent/UDP]
$ns attach-agent $router2 $s0

set null0 [new Agent/Null]
$ns attach-agent $iface1 $null0

$ns connect $s0 $null0

set exp0 [new Application/Traffic/Exponential]
$exp0 set packetSize_ 210
$exp0 set burst_time_ 500ms
$exp0 set idle_time_ 500ms
$exp0 set rate_ 100k

$exp0 attach-agent $s0
set s1 [new Agent/UDP]
$ns attach-agent $router3 $s1

set null1 [new Agent/Null]
$ns attach-agent $iface3 $null1

$ns connect $s1 $null1

set exp1 [new Application/Traffic/Exponential]
$exp1 set packetSize_ 210
$exp1 set burst_time_ 500ms
$exp1 set idle_time_ 500ms
$exp1 set rate_ 100k

$exp1 attach-agent $s1
 
set s2 [new Agent/UDP]
$ns attach-agent $router4 $s2

set null2 [new Agent/Null]
$ns attach-agent $iface4 $null2

$ns connect $s2 $null2

set exp2 [new Application/Traffic/Exponential]
$exp2 set packetSize_ 210
$exp2 set burst_time_ 500ms
$exp2 set idle_time_ 500ms
$exp2 set rate_ 100k

$exp2 attach-agent $s2

set s3 [new Agent/UDP]
$ns attach-agent $router5 $s3

set null3 [new Agent/Null]
$ns attach-agent $iface5 $null3

$ns connect $s3 $null3

set exp3 [new Application/Traffic/Exponential]
$exp3 set packetSize_ 210
$exp3 set burst_time_ 500ms
$exp3 set idle_time_ 500ms
$exp3 set rate_ 100k

$exp3 attach-agent $s3

 

set s4 [new Agent/UDP]
$ns attach-agent $router6 $s4

set null4 [new Agent/Null]
$ns attach-agent $iface6 $null4

$ns connect $s4 $null4

set exp4 [new Application/Traffic/Exponential]
$exp4 set packetSize_ 210
$exp4 set burst_time_ 500ms
$exp4 set idle_time_ 500ms
$exp4 set rate_ 100k

$exp4 attach-agent $s4

set s5 [new Agent/UDP]
$ns attach-agent $router7 $s5

set null5 [new Agent/Null]
$ns attach-agent $iface7 $null5

$ns connect $s5 $null5

set exp5 [new Application/Traffic/Exponential]
$exp5 set packetSize_ 210
$exp5 set burst_time_ 500ms
$exp5 set idle_time_ 500ms
$exp5 set rate_ 100k

$exp5 attach-agent $s5
 
 
set s6 [new Agent/UDP]
$ns attach-agent $router8 $s6

set null6 [new Agent/Null]
$ns attach-agent $iface8 $null6

$ns connect $s6 $null6

set exp6 [new Application/Traffic/Exponential]
$exp6 set packetSize_ 210
$exp6 set burst_time_ 500ms
$exp6 set idle_time_ 500ms
$exp6 set rate_ 100k

$exp6 attach-agent $s6
 
set s7 [new Agent/UDP]
$ns attach-agent $router9 $s7

set null7 [new Agent/Null]
$ns attach-agent $iface9 $null7

$ns connect $s7 $null7

set exp7 [new Application/Traffic/Exponential]
$exp7 set packetSize_ 210
$exp7 set burst_time_ 500ms
$exp7 set idle_time_ 500ms
$exp7 set rate_ 100k

$exp7 attach-agent $s7

set s8 [new Agent/UDP]
$ns attach-agent $router10 $s8

set null8 [new Agent/Null]
$ns attach-agent $iface10 $null8

$ns connect $s8 $null8

set exp8 [new Application/Traffic/Exponential]
$exp8 set packetSize_ 210
$exp8 set burst_time_ 500ms
$exp8 set idle_time_ 500ms
$exp8 set rate_ 100k

$exp8 attach-agent $s8

set s9 [new Agent/UDP]
$ns attach-agent $router11 $s9

set null9 [new Agent/Null]
$ns attach-agent $iface11 $null9

$ns connect $s9 $null9

set exp9 [new Application/Traffic/Exponential]
$exp9 set packetSize_ 210
$exp9 set burst_time_ 500ms
$exp9 set idle_time_ 500ms
$exp9 set rate_ 100k

$exp9 attach-agent $s9 

set s10 [new Agent/UDP]
$ns attach-agent $router12 $s10

set null10 [new Agent/Null]
$ns attach-agent $iface0 $null10

$ns connect $s10 $null10

set exp10 [new Application/Traffic/Exponential]
$exp10 set packetSize_ 210
$exp10 set burst_time_ 500ms
$exp10 set idle_time_ 500ms
$exp10 set rate_ 100k

$exp10 attach-agent $s10 
$ns at 1.0 "$s0 listen"
$ns at 1.0 "$s1 listen"
$ns at 1.0 "$s2 listen"
$ns at 1.0 "$s3 listen"
$ns at 1.0 "$s4 listen"
$ns at 1.0 "$s5 listen"
$ns at 1.0 "$s6 listen"
$ns at 1.0 "$s7 listen"
$ns at 1.0 "$s8 listen"
$ns at 1.0 "$s9 listen"
$ns at 1.0 "$s10 listen"

$ns at 3.0 "$exp0 start"
$ns at 3.0 "$exp1 start"
$ns at 3.0 "$exp2 start"
$ns at 3.0 "$exp3 start"
$ns at 3.0 "$exp4 start"
$ns at 3.0 "$exp5 start"
$ns at 3.0 "$exp6 start"
$ns at 3.0 "$exp7 start"
$ns at 3.0 "$exp8 start"
$ns at 3.0 "$exp9 start"
$ns at 3.0 "$exp10 start"
$ns at 150.0 "$exp0 stop"
$ns at 150.0 "$exp1 stop"
$ns at 150.0 "$exp2 stop"
$ns at 150.0 "$exp3 stop"
$ns at 150.0 "$exp4 stop"
$ns at 150.0 "$exp5 stop"
$ns at 150.0 "$exp6 stop"
$ns at 150.0 "$exp7 stop"
$ns at 150.0 "$exp8 stop"
$ns at 150.0 "$exp9 stop"
$ns at 150.0 "$exp10 stop"
#$ns at 150.0 "$exp11 stop"



$ns at 100.0 "finish"

puts " Simulation is running ... please wait ..."
$ns run
 
