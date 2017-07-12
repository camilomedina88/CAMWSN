#Agent/UDP set packetSize_ 6000

# ======================================================================
# Define options
# ======================================================================
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             13                          ;# number of mobilenodes
set val(rp)             PEGASIS                     ;# routing protocol
set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(stop)	      28
set pi         3.141592653589
#set opt(energymodel)    EnergyModel     ;
#set opt(initialenergy)  1j               ;# Initial energy in Joules
#set val(energymodel)    EnergyModel     ;
#set val(initialenergy)  0.01   


# ======================================================================
# Main Program
# ======================================================================
# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0
Phy/WirelessPhy set bandwidth_ 2e6
#ns-random 0
# Initialize Global Variables
set ns_ [new Simulator]
set tracefd [open mf.tr w]
$ns_ trace-all $tracefd

set namtrace    [open mflood.nam w]
$ns_ namtrace-all-wireless $namtrace 600 600

# set up topography
set topo [new Topography]
$topo load_flatgrid 600 300

# Create God
create-god $val(nn)


# Create the specified number of mobilenodes [$val(nn)] and "attach" them
# to the channel. 
# configure node
set channel [new Channel/WirelessChannel]
$channel set errorProbability_ 0.0

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel $channel \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON\
			 -macTrace OFF \
			 -movementTrace OFF\
                       
                        		
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0;	
	}

# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
set i 0
#start zone 0
for {set j 0} {$j < 2} {incr j} {
            $node_($i) set X_ [expr 130-(130*cos(($pi/10)+$pi*16*$j/180))]
            $node_($i) set Y_ [expr 130*sin($pi/10+$pi*16*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) setzone $i 100 2 0
            incr i
}
$node_(0) setzone 0 100 2 1
#end zone 0

#start zone 1
for {set j 0} {$j < 3} {incr j} {
            $node_($i) set X_ [expr 130-(160*cos(($pi/10)+$pi*12.3*$j/180))]
            $node_($i) set Y_ [expr 160*sin($pi/10+$pi*12.3*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) setzone $i 110 3 0
            incr i
}
$node_(2) setzone 2 110 3 1
#end zone 1
#start  zone 2
for {set j 0} {$j < 3} {incr j} {
            $node_($i) set X_ [expr 130-(190*cos(($pi/10)+$pi*10.7*$j/180))]
            $node_($i) set Y_ [expr 190*sin($pi/10+$pi*10.7*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) setzone $i 120  3 0
            incr i
}
$node_(5) setzone 5 120 3 1
#end zone 2

#start zone 3
for {set j 0} {$j < 4} {incr j} {
            $node_($i) set X_ [expr 130-(220*cos(($pi/10)+$pi*8.89*$j/180))]
            $node_($i) set Y_ [expr 220*sin($pi/10+$pi*8.89*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) setzone $i 130  4 0
            incr i
}
$node_(8) setzone 8 130 4 1
#end zone 3




$node_(12) set X_ 130
$node_(12) set Y_ 50
$node_(12) set Z_ 0
#$node_($i) setzone $i 50  1

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined

    $ns_ initial_node_pos $node_($i) 10
}

set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp_(0) 

set udp_(1) [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp_(1)

set udp_(2) [new Agent/UDP]
$ns_ attach-agent $node_(2) $udp_(2)

set udp_(3) [new Agent/UDP]
$ns_ attach-agent $node_(4) $udp_(3)

set udp_(4) [new Agent/UDP]
$ns_ attach-agent $node_(5) $udp_(4)
set udp_(5) [new Agent/UDP]
$ns_ attach-agent $node_(7) $udp_(5)

set udp_(6) [new Agent/UDP]
$ns_ attach-agent $node_(8) $udp_(6)
set udp_(7) [new Agent/UDP]
$ns_ attach-agent $node_(11) $udp_(7)

#for {set j 0} {$j < 8}  {incr j} {
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 375
$cbr_(0) set rate_ 375
$cbr_(0) attach-agent $udp_(0)
$ns_ at 10.0 "$cbr_(0) start"
#incr j
#}
set cbr_(2) [new Application/Traffic/CBR]
$cbr_(2) set packetSize_ 375
$cbr_(2) set rate_ 375
$cbr_(2) attach-agent $udp_(2)
$ns_ at 11.0 "$cbr_(2) start"

set cbr_(4) [new Application/Traffic/CBR]
$cbr_(4) set packetSize_ 375
$cbr_(4) set rate_ 375
$cbr_(4) attach-agent $udp_(4)
$ns_ at 12.0 "$cbr_(4) start"

set cbr_(6) [new Application/Traffic/CBR]
$cbr_(6) set packetSize_ 375
$cbr_(6) set rate_ 375
$cbr_(6) attach-agent $udp_(6)
$ns_ at 13.0 "$cbr_(6) start"

#for {set j 1} {$j < 8} {incr j} {
set cbr_(1) [new Application/Traffic/CBR]
$cbr_(1) set packetSize_ 375
$cbr_(1) set rate_ 375
$cbr_(1) attach-agent $udp_(1)
$ns_ at 14.0 "$cbr_(1) start"
#incr j
#}
set cbr_(3) [new Application/Traffic/CBR]
$cbr_(3) set packetSize_ 375
$cbr_(3) set rate_ 375
$cbr_(3) attach-agent $udp_(3)
$ns_ at 15.0 "$cbr_(3) start"

set cbr_(5) [new Application/Traffic/CBR]
$cbr_(5) set packetSize_ 375
$cbr_(5) set rate_ 375
$cbr_(5) attach-agent $udp_(5)
$ns_ at 16.0 "$cbr_(5) start"

set cbr_(7) [new Application/Traffic/CBR]
$cbr_(7) set packetSize_ 375
$cbr_(7) set rate_ 375
$cbr_(7) attach-agent $udp_(7)
$ns_ at 17.0 "$cbr_(7) start"

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}
$ns_ at $val(stop).0 "stop"
$ns_ at $val(stop).01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd

    exec nam mflood.nam &
    exit 0
}

puts "Starting Simulation..."
$ns_ run





