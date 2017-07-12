set val(chan)          Channel/WirelessChannel      ;# channel type
set val(prop)          Propagation/TwoRayGround     ;# radio-propagation model
set val(netif)         Phy/WirelessPhy     ;# network interface type
set val(mac)           Mac/802_11                 ;# MAC type
set val(ifq)           Queue/DropTail/PriQueue      ;# interface queue type
set val(ll)            LL                           ;# link layer type
set val(ant)           Antenna/OmniAntenna          ;# antenna model
set val(ifqlen)        500	         	    ;# two packet per node
set val(nn)            23			    ;# number of mobile nodes
set val(rp)            WTRP		    ;# protocol type
set val(x)             200			    ;# X dimension of topography
set val(y)             200			    ;# Y dimension of topography
set val(stop)          80			    ;# simulation period
set val(stopsolicit)   25	              ;# stop solicit entering 
set val(energymodel)   EnergyModel		    ;# Energy Model
set val(initialenergy) 100			    ;# value

set ns        		[new Simulator]
set tracefd       	[open trace-23nodes_with-varal_wtrp_802-15-4.tr w]
set namtrace      	[open nam-23nodes_with-varal_wtrp_802-15-4.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

#
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

#Phy/WirelessPhy set CSThresh_ $dist(20m) we don't need carrier sense for while
Phy/WirelessPhy set RXThresh_ $dist(20m)
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set bandwidth_ 1MB
Phy/WirelessPhy set Pt_ 0.2818W

# SET UP TOPOGRAPHY OBJECT
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)


# THE NODES CONFIGURATION
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
             -movementTrace OFF

#ENERGY MODEL
$ns node-config -energyModel $val(energymodel) \
             -initialEnergy $val(initialenergy) \
             -rxPower 35.28e-3 \
             -txPower 31.32e-3 \
	         -idlePower 0.0 \
	         -sleepPower 0.0 #144e-9
	     
#CREATING NODE OBJECTS
for {set i 0} {$i < $val(nn)} {incr i} {
	set node_($i) [$ns node]
}

#INITIAL LOCATION OF NODES
$node_(0) set X_ [ expr {$val(x)/2 - 30} ]
$node_(0) set Y_ [ expr {$val(y)/2 - 30} ]
$node_(0) set Z_ 0.0

$node_(1) set X_ 50
$node_(1) set Y_ [ expr {$val(y)/2} ]
$node_(1) set Z_ 0.0

$node_(2) set X_ [ expr {$val(x)/2 - 30} ]
$node_(2) set Y_ [ expr {$val(y)/2 + 30} ]
$node_(2) set Z_ 0.0

$node_(3) set X_ [ expr {$val(x)/2 + 30} ]
$node_(3) set Y_ [ expr {$val(y)/2 + 30} ]
$node_(3) set Z_ 0.0

$node_(4) set X_ [ expr {$val(x)/2 + 30 + 30} ]
$node_(4) set Y_ [ expr {$val(y)/2} ]
$node_(4) set Z_ 0.0

$node_(5) set X_ [ expr {$val(x)/2 + 30} ]
$node_(5) set Y_ [ expr {$val(y)/2 - 30} ]
$node_(5) set Z_ 0.0

$node_(6) set X_ 80
$node_(6) set Y_ 60
$node_(6) set Z_ 0.0

$node_(7) set X_ 73
$node_(7) set Y_ 27
$node_(7) set Z_ 0.0

$node_(8) set X_ 60
$node_(8) set Y_ 25
$node_(8) set Z_ 0.0

$node_(9) set X_ 60
$node_(9) set Y_ 63
$node_(9) set Z_ 0.0

$node_(10) set X_ 38
$node_(10) set Y_ 80
$node_(10) set Z_ 0.0

$node_(11) set X_ 20
$node_(11) set Y_ 100
$node_(11) set Z_ 0.0

$node_(12) set X_ 38
$node_(12) set Y_ [ expr {$val(y)/2 + 15} ]
$node_(12) set Z_ 0.0

$node_(13) set X_ [ expr {$val(x)/2 - 50} ] 
$node_(13) set Y_ [ expr {$val(y)/2 + 40} ]
$node_(13) set Z_ 0.0

$node_(14) set X_ [ expr {$val(x)/2 - 10} ]
$node_(14) set Y_ [ expr {$val(y)/2 + 30 + 15} ] 
$node_(14) set Z_ 0.0

$node_(15) set X_ [ expr {$val(x)/2 + 30 + 15} ]
$node_(15) set Y_ [ expr {$val(y)/2 + 40} ]
$node_(15) set Z_ 0.0

$node_(16) set X_ 170
$node_(16) set Y_ 117
$node_(16) set Z_ 0.0

$node_(17) set X_ 170
$node_(17) set Y_ 110
$node_(17) set Z_ 0.0

$node_(18) set X_ 149
$node_(18) set Y_ 66
$node_(18) set Z_ 0.0

$node_(19) set X_ 155
$node_(19) set Y_ 60
$node_(19) set Z_ 0.0

$node_(20) set X_ 152
$node_(20) set Y_ 22
$node_(20) set Z_ 0.0

$node_(21) set X_ 140
$node_(21) set Y_ 30
$node_(21) set Z_ 0.0

$node_(22) set X_ 130
$node_(22) set Y_ 60
$node_(22) set Z_ 0.0

#POSITION IN NAM
for {set i 0} {$i < $val(nn)} {incr i} {
 	$ns initial_node_pos $node_($i) 3
}

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at [ expr $i.0 + 0.$i] "[$node_($i) set ragent_] soliciting"
}


#TEMPORARY

#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $node_(7) $udp

set sink [new Agent/Null]
$ns attach-agent $node_(13) $sink



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
    $ns at $val(stop) "$node_($i) reset;"
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
