#in 30 nodes, 3 source and 2 query, Rumor Routing with S-MAC (A)
#run for 785 seconds
# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/SMAC                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             31                          ;# number of mobilenodes
set val(rp)             RUMOR                       ;# routing protocol
set val(x)              2500   			   ;# X dimension of topography
set val(y)              1900   			   ;# Y dimension of topography  
set val(stop)		785			   ;# time of simulation end
set opt(energymodel)    EnergyModel     ;
set opt(initialenergy)  1               ;# Initial energy in Joules

set ns		  [new Simulator]
set tracefd       [open wrls-rumor-a30node.tr w]
set namtrace      [open wrls-rumor-a30node.nam w]    

$ns color 2 Red

$ns use-newtrace
$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)


# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

#
#  Create nn mobilenodes [$val(nn)] and attach them to the channel. 
#

# configure the nodes
        $ns node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace ON \
			 -energyModel $opt(energymodel) \
			 -rxPower 0.1 \
			 -txPower 0.6 \
			 -initialEnergy $opt(initialenergy)



	for {set i 0} {$i < $val(nn) } { incr i } {
		set node_($i) [$ns node]	
	}

# Provide initial location of mobilenodes

$node_(4) set X_ 230
$node_(4) set Y_ 830
$node_(4) set Z_ 0.0

$node_(3) set X_ 900.0
$node_(3) set Y_ 1470
$node_(3) set Z_ 0.0

$node_(2) set X_ 1600.0
$node_(2) set Y_ 750.0
$node_(2) set Z_ 0.0

$node_(1) set X_ 950.75
$node_(1) set Y_ 145.25
$node_(1) set Z_ 0.0

$node_(5) set X_ 1135.75
$node_(5) set Y_ 1220.25
$node_(5) set Z_ 0.0

$node_(6) set X_ 1145
$node_(6) set Y_ 405
$node_(6) set Z_ 0.0

$node_(7) set X_ 1040.0
$node_(7) set Y_ 620.0
$node_(7) set Z_ 0.0

$node_(8) set X_ 800.75
$node_(8) set Y_ 1120.25
$node_(8) set Z_ 0.0

$node_(9) set X_ 430.25
$node_(9) set Y_ 917.75
$node_(9) set Z_ 0.0

$node_(10) set X_ 252
$node_(10) set Y_ 626.0
$node_(10) set Z_ 0.0

$node_(11) set X_ 780.75
$node_(11) set Y_ 650.25
$node_(11) set Z_ 0.0

$node_(12) set X_ 1360.0
$node_(12) set Y_ 685.0
$node_(12) set Z_ 0.0

$node_(13) set X_ 450.75
$node_(13) set Y_ 1049.0
$node_(13) set Z_ 0.0

$node_(14) set X_ 780.75
$node_(14) set Y_ 970.25
$node_(14) set Z_ 0.0

$node_(15) set X_ 418.0
$node_(15) set Y_ 1217.0
$node_(15) set Z_ 0.0

$node_(16) set X_ 1090.0
$node_(16) set Y_ 320.75
$node_(16) set Z_ 0.0

$node_(17) set X_ 1380.0
$node_(17) set Y_ 1110
$node_(17) set Z_ 0.0

$node_(18) set X_ 618
$node_(18) set Y_ 1150.0
$node_(18) set Z_ 0.0

$node_(19) set X_ 1340.0
$node_(19) set Y_ 910.0
$node_(19) set Z_ 0.0

$node_(20) set X_ 650.25
$node_(20) set Y_ 795.75
$node_(20) set Z_ 0.0                

$node_(21) set X_ 1490.75
$node_(21) set Y_ 480.25
$node_(21) set Z_ 0.0

$node_(22) set X_ 513.75
$node_(22) set Y_ 520.0
$node_(22) set Z_ 0.0

$node_(23) set X_ 870.0
$node_(23) set Y_ 1320.75
$node_(23) set Z_ 0.0

$node_(24) set X_ 820.25
$node_(24) set Y_ 130.75
$node_(24) set Z_ 0.0

$node_(25) set X_ 684.0
$node_(25) set Y_ 330.0
$node_(25) set Z_ 0.0

$node_(26) set X_ 1195.75
$node_(26) set Y_ 1005.0
$node_(26) set Z_ 0.0

$node_(27) set X_ 1505.75
$node_(27) set Y_ 1105.25
$node_(27) set Z_ 0.0

$node_(28) set X_ 980
$node_(28) set Y_ 810.0
$node_(28) set Z_ 0.0

$node_(29) set X_ 1200
$node_(29) set Y_ 770
$node_(29) set Z_ 0.0

$node_(30) set X_ 980.25
$node_(30) set Y_ 980.75
$node_(30) set Z_ 0.0





                set udp [new Agent/UDP]
		$ns attach-agent $node_(11) $udp
                set null [new Agent/Null]
		$ns attach-agent $node_(16) $null
		$ns connect $udp $null
		
		set cbr [new Application/Traffic/CBR]
		$cbr attach-agent $udp
		$cbr set packet_size_ 100
		$cbr set interval_ 0.005
		$cbr set rate_ 1mb
		$ns at 14.5 "$cbr start"    
		#$ns at 25.5 "$cbr stop"      

                set udp [new Agent/UDP]
		$ns attach-agent $node_(9) $udp
                set null [new Agent/Null]
		$ns attach-agent $node_(17) $null
		$ns connect $udp $null
		
		set cbr [new Application/Traffic/CBR]
		$cbr attach-agent $udp
		$cbr set packet_size_ 100
		$cbr set interval_ 0.005
		$cbr set rate_ 1mb
		$ns at 6.5 "$cbr start"    
		#$ns at 18.5 "$cbr stop"  
                set udp [new Agent/UDP]
		$ns attach-agent $node_(5) $udp
                set null [new Agent/Null]
		$ns attach-agent $node_(17) $null
		$ns connect $udp $null
		
		set cbr [new Application/Traffic/CBR]
		$cbr attach-agent $udp
		$cbr set packet_size_ 100
		$cbr set interval_ 0.005
		$cbr set rate_ 1mb
		$ns at 6.5 "$cbr start"    
		#$ns at 18.5 "$cbr stop"  


# Define node initial position in nam
for {set i 1} {$i < $val(nn)} { incr i } {
# 50 defines the node size for nam
$ns initial_node_pos $node_($i) 50
}

# Telling nodes when the simulation ends
for {set i 1} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 785 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    #Execute nam on the trace file
    exec nam wrls-rumor-a30node.nam &
    exit 0
}

#Call the finish procedure after 5 seconds of simulation time
$ns run

