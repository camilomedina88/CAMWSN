# Generated by Topology Generator for Network Simulator (c) Elmurod Talipov
set val(chan)          Channel/WirelessChannel      ;# channel type
set val(prop)          Propagation/TwoRayGround     ;# radio-propagation model
set val(netif)         Phy/WirelessPhy/802_15_4     ;# network interface type
set val(mac)           Mac/802_15_4                 ;# MAC type
set val(ifq)           Queue/DropTail/PriQueue      ;# interface queue type
set val(ll)            LL                           ;# link layer type
set val(ant)           Antenna/OmniAntenna          ;# antenna model
set val(ifqlen)        100	         	    ;# max packet in ifq
set val(nn)            23          ;#5			    ;# number of mobile nodes
set val(rp)            WTRP		    ;# protocol type
set val(x)             200             ;#120			    ;# X dimension of topography
set val(y)             200             ;#120			    ;# Y dimension of topography
set val(stop)          50			    ;# simulation period
set val(stopsolicit)   5                ;# stop solicit entering 
set val(energymodel)   EnergyModel		    ;# Energy Model
set val(initialenergy) 100			    ;# value

set ns        		[new Simulator]
set tracefd       	[open trace-wtrp-802-15-4.tr w]
set namtrace      	[open nam-wtrp-802-15-4.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
Phy/WirelessPhy set CSThresh_ $dist(20m)
Phy/WirelessPhy set RXThresh_ $dist(20m)

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

# configure the nodes
$ns node-config -adhocRouting $val(rp) \
            -llType $val(ll) \
             -macType $val(mac) \
             -ifqType $val(ifq) \
             -ifqLen $val(ifqlen) \
             -antType $val(ant) \
             -propType $val(prop) \
             -phyType $val(netif) \
             -channel [new $val(chan)] \
             -topoInstance $topo \
             -agentTrace ON \
             -routerTrace ON \
             -macTrace  OFF \
             -movementTrace OFF \
             -energyModel $val(energymodel) \
             -initialEnergy $val(initialenergy) \
             -rxPower 35.28e-3 \
             -txPower 31.32e-3 \
	     -idlePower 0.0 \
	     -sleepPower 144e-9 

for {set i 0} {$i < $val(nn) } { incr i } {
        set mnode_($i) [$ns node]
#        $ns at [ expr 1.0 + 0.$i] "[$mnode_($i) set ragent_] solicit_entering"
}

#NODES INITIALIZATION
$ns at 0.5 "[$mnode_(0) set ragent_] soliciting"
$ns at 2.5 "[$mnode_(1) set ragent_] soliciting"
$ns at 3.0 "[$mnode_(2) set ragent_] soliciting"
$ns at 3.5 "[$mnode_(3) set ragent_] soliciting"

$ns at 6.0 "[$mnode_(4) set ragent_] soliciting"

#for {set i 1} {$i < $val(nn) } { incr i } {
#	$mnode_($i) set X_ [ expr {$val(x) * rand()} ]
#	$mnode_($i) set Y_ [ expr {$val(y) * rand()} ]
#	$mnode_($i) set Z_ 0
#}

# Position of Sink
#$mnode_(0) set X_ [ expr {$val(x)/2} ]
#$mnode_(0) set Y_ [ expr {$val(y)/2} ]
#$mnode_(0) set Z_ 0.0
#$mnode_(0) label "Sink"

#$mnode_(1) set X_ 73
#$mnode_(1) set Y_ 74
#$mnode_(1) set Z_ 0.0

#$mnode_(2) set X_ 60
#$mnode_(2) set Y_ 88
#$mnode_(2) set Z_ 0.0

#$mnode_(3) set X_ 47
#$mnode_(3) set Y_ 74
#$mnode_(3) set Z_ 0.0

#$mnode_(4) set X_ 47
#$mnode_(4) set Y_ [ expr {$val(y)/2} ]
#$mnode_(4) set Z_ 0.0

#INITIAL LOCATION OF NODES
$mnode_(0) set X_ [ expr {$val(x)/2 - 30} ]
$mnode_(0) set Y_ [ expr {$val(y)/2 - 30} ]
$mnode_(0) set Z_ 0.0

$mnode_(1) set X_ 50
$mnode_(1) set Y_ [ expr {$val(y)/2} ]
$mnode_(1) set Z_ 0.0

$mnode_(2) set X_ [ expr {$val(x)/2 - 30} ]
$mnode_(2) set Y_ [ expr {$val(y)/2 + 30} ]
$mnode_(2) set Z_ 0.0

$mnode_(3) set X_ [ expr {$val(x)/2 + 30} ]
$mnode_(3) set Y_ [ expr {$val(y)/2 + 30} ]
$mnode_(3) set Z_ 0.0

$mnode_(4) set X_ [ expr {$val(x)/2 + 30 + 30} ]
$mnode_(4) set Y_ [ expr {$val(y)/2} ]
$mnode_(4) set Z_ 0.0

$mnode_(5) set X_ [ expr {$val(x)/2 + 30} ]
$mnode_(5) set Y_ [ expr {$val(y)/2 - 30 - 1} ]
$mnode_(5) set Z_ 0.0

$mnode_(6) set X_ 80
$mnode_(6) set Y_ 60
$mnode_(6) set Z_ 0.0

$mnode_(7) set X_ 73
$mnode_(7) set Y_ 27
$mnode_(7) set Z_ 0.0

$mnode_(8) set X_ 60
$mnode_(8) set Y_ 25
$mnode_(8) set Z_ 0.0

$mnode_(9) set X_ 60
$mnode_(9) set Y_ 63
$mnode_(9) set Z_ 0.0

$mnode_(10) set X_ 38
$mnode_(10) set Y_ 80
$mnode_(10) set Z_ 0.0

$mnode_(11) set X_ 20
$mnode_(11) set Y_ 100
$mnode_(11) set Z_ 0.0

$mnode_(12) set X_ 38
$mnode_(12) set Y_ [ expr {$val(y)/2 + 15} ]
$mnode_(12) set Z_ 0.0

$mnode_(13) set X_ [ expr {$val(x)/2 - 50} ] 
$mnode_(13) set Y_ [ expr {$val(y)/2 + 40} ]
$mnode_(13) set Z_ 0.0

$mnode_(14) set X_ [ expr {$val(x)/2 - 10} ]
$mnode_(14) set Y_ [ expr {$val(y)/2 + 30 + 15} ] 
$mnode_(14) set Z_ 0.0

$mnode_(15) set X_ [ expr {$val(x)/2 + 30 + 15} ]
$mnode_(15) set Y_ [ expr {$val(y)/2 + 40} ]
$mnode_(15) set Z_ 0.0

$mnode_(16) set X_ 170
$mnode_(16) set Y_ 117
$mnode_(16) set Z_ 0.0

$mnode_(17) set X_ 171
$mnode_(17) set Y_ 96
$mnode_(17) set Z_ 0.0

$mnode_(18) set X_ 149
$mnode_(18) set Y_ 66
$mnode_(18) set Z_ 0.0

$mnode_(19) set X_ 155
$mnode_(19) set Y_ 60
$mnode_(19) set Z_ 0.0

$mnode_(20) set X_ 152
$mnode_(20) set Y_ 22
$mnode_(20) set Z_ 0.0

$mnode_(21) set X_ 140
$mnode_(21) set Y_ 30
$mnode_(21) set Z_ 0.0

$mnode_(22) set X_ 130
$mnode_(22) set Y_ 60
$mnode_(22) set Z_ 0.0


#start sending solicit entering message
#$ns at 1.0 "[$mnode_(0) set ragent_] solicit_entering"

for {set i 0} {$i < $val(nn)} { incr i } {
	$ns initial_node_pos $mnode_($i) 3
}


#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $mnode_(2) $udp

set sink [new Agent/Null]
$ns attach-agent $mnode_(0) $sink



$ns connect $udp $sink
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 50
$cbr set rate_ 0.1Mb
$cbr set interval_ 2
#$cbr set random_ false

$ns at 13.0 "$cbr start"
$ns at [expr $val(stop) - 5] "$cbr stop"

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$mnode_($i) reset;"
}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at [expr $val(stop) + 1.0] "puts \"end simulation\"; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
}

$ns run
