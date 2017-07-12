#Agent/UDP set packetSize_ 6000

# ======================================================================
# Define options
# ======================================================================
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             57                          ;# number of mobilenodes
set val(rp)             PEGASIS                     ;# routing protocol
set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(stop)	      5000
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
$ns_ use-newtrace

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
            $node_($i) set zone $i 00 2 0
            incr i
}
$node_(0) set zone 0 00 2 1
for {set j 2} {$j < 5} {incr j} {
            $node_($i) set X_ [expr 130-(130*cos(($pi/10)+$pi*16*$j/180))]
            $node_($i) set Y_ [expr 130*sin($pi/10+$pi*16*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 01 3 0
            incr i
}
$node_(2) set zone 2 01 3 1
for {set j 5} {$j < 7} {incr j} {
            $node_($i) set X_ [expr 130-(130*cos(($pi/10)+$pi*16*$j/180))]
            $node_($i) set Y_ [expr 130*sin($pi/10+$pi*16*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 02 2 0
            incr i
}
$node_(5) set zone 5 02 2 1
for {set j 7} {$j < 10} {incr j} {
            $node_($i) set X_ [expr 130-(130*cos(($pi/10)+$pi*16*$j/180))]
            $node_($i) set Y_ [expr 130*sin($pi/10+$pi*16*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 03 3 0
            incr i
}
$node_(7) set zone 7 03 3 1
#end zone 0

#start zone 1
for {set j 0} {$j < 3} {incr j} {
            $node_($i) set X_ [expr 130-(160*cos(($pi/10)+$pi*12.3*$j/180))]
            $node_($i) set Y_ [expr 160*sin($pi/10+$pi*12.3*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 10 3 0
            incr i
}
$node_(10) set zone 10 10 3 1
for {set j 3} {$j < 6} {incr j} {
            $node_($i) set X_ [expr 130-(160*cos(($pi/10)+$pi*12.3*$j/180))]
            $node_($i) set Y_ [expr 160*sin($pi/10+$pi*12.3*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 11 3 0
            incr i
}
$node_(13) set zone 13 11 3 1
for {set j 6} {$j < 9} {incr j} {
            $node_($i) set X_ [expr 130-(160*cos(($pi/10)+$pi*12.3*$j/180))]
            $node_($i) set Y_ [expr 160*sin($pi/10+$pi*12.3*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 12 3 0
            incr i
}
$node_(16) set zone 16 12 3 1
for {set j 9} {$j < 13} {incr j} {
            $node_($i) set X_ [expr 130-(160*cos(($pi/10)+$pi*12.3*$j/180))]
            $node_($i) set Y_ [expr 160*sin($pi/10+$pi*12.3*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 13 4 0
            incr i
}
$node_(19) set zone 19 13 3 1
#end zone 1
#start  zone 2
for {set j 0} {$j < 3} {incr j} {
            $node_($i) set X_ [expr 130-(190*cos(($pi/10)+$pi*10.7*$j/180))]
            $node_($i) set Y_ [expr 190*sin($pi/10+$pi*10.7*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 20  3 0
            incr i
}
$node_(23) set zone 23 20 3 1
for {set j 3} {$j < 7} {incr j} {
            $node_($i) set X_ [expr 130-(190*cos(($pi/10)+$pi*10.7*$j/180))]
            $node_($i) set Y_ [expr 190*sin($pi/10+$pi*10.7*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 21  4 0
            incr i
}
$node_(26) set zone 26 21 4 1
for {set j 7} {$j < 11} {incr j} {
            $node_($i) set X_ [expr 130-(190*cos(($pi/10)+$pi*10.7*$j/180))]
            $node_($i) set Y_ [expr 190*sin($pi/10+$pi*10.7*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 22  4 0
            incr i
}
$node_(30) set zone 30 22 4 1
for {set j 11} {$j < 15} {incr j} {
            $node_($i) set X_ [expr 130-(190*cos(($pi/10)+$pi*10.7*$j/180))]
            $node_($i) set Y_ [expr 190*sin($pi/10+$pi*10.7*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 23  4 0
            incr i
}
$node_(34) set zone 34 23 4 1
#end zone 2

#start zone 3
for {set j 0} {$j < 4} {incr j} {
            $node_($i) set X_ [expr 130-(220*cos(($pi/10)+$pi*8.89*$j/180))]
            $node_($i) set Y_ [expr 220*sin($pi/10+$pi*8.89*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 30  4 0
            incr i
}
$node_(38) set zone 38 30 4 1
for {set j 4} {$j < 9} {incr j} {
            $node_($i) set X_ [expr 130-(220*cos(($pi/10)+$pi*8.89*$j/180))]
            $node_($i) set Y_ [expr 220*sin($pi/10+$pi*8.89*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 31  5 0
            incr i
}
$node_(42) set zone 42 31 5 1
for {set j 9} {$j < 13} {incr j} {
            $node_($i) set X_ [expr 130-(220*cos(($pi/10)+$pi*8.89*$j/180))]
            $node_($i) set Y_ [expr 220*sin($pi/10+$pi*8.89*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 32  4 0
            incr i
}
$node_(47) set zone 47 32 4 1
for {set j 13} {$j < 18} {incr j} {
            $node_($i) set X_ [expr 130-(220*cos(($pi/10)+$pi*8.89*$j/180))]
            $node_($i) set Y_ [expr 220*sin($pi/10+$pi*8.89*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 33  5 0
            incr i
}
$node_(51) set zone 51 33 5 1
#end zone 3




$node_(56) set X_ 130
$node_(56) set Y_ 50
$node_(56) set Z_ 0
#$node_($i) set zone $i 50  1

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
$ns_ attach-agent $node_(6) $udp_(5)

set udp_(6) [new Agent/UDP]
$ns_ attach-agent $node_(7) $udp_(6)
set udp_(7) [new Agent/UDP]
$ns_ attach-agent $node_(9) $udp_(7)

set udp_(8) [new Agent/UDP]
$ns_ attach-agent $node_(10) $udp_(8)
set udp_(9) [new Agent/UDP]
$ns_ attach-agent $node_(12) $udp_(9)

set udp_(10) [new Agent/UDP]
$ns_ attach-agent $node_(13) $udp_(10)
set udp_(11) [new Agent/UDP]
$ns_ attach-agent $node_(15) $udp_(11)

set udp_(12) [new Agent/UDP]
$ns_ attach-agent $node_(16) $udp_(12)

set udp_(13) [new Agent/UDP]
$ns_ attach-agent $node_(18) $udp_(13)

set udp_(14) [new Agent/UDP]
$ns_ attach-agent $node_(19) $udp_(14)
set udp_(15) [new Agent/UDP]
$ns_ attach-agent $node_(22) $udp_(15)

set udp_(16) [new Agent/UDP]
$ns_ attach-agent $node_(23) $udp_(16)
set udp_(17) [new Agent/UDP]
$ns_ attach-agent $node_(25) $udp_(17)

set udp_(18) [new Agent/UDP]
$ns_ attach-agent $node_(26) $udp_(18)
set udp_(19) [new Agent/UDP]
$ns_ attach-agent $node_(29) $udp_(19)

set udp_(20) [new Agent/UDP]
$ns_ attach-agent $node_(30) $udp_(20)
set udp_(21) [new Agent/UDP]
$ns_ attach-agent $node_(33) $udp_(21)

set udp_(22) [new Agent/UDP]
$ns_ attach-agent $node_(34) $udp_(22)
set udp_(23) [new Agent/UDP]
$ns_ attach-agent $node_(37) $udp_(23)

set udp_(24) [new Agent/UDP]
$ns_ attach-agent $node_(38) $udp_(24)
set udp_(25) [new Agent/UDP]
$ns_ attach-agent $node_(41) $udp_(25)

set udp_(26) [new Agent/UDP]
$ns_ attach-agent $node_(42) $udp_(26)
set udp_(27) [new Agent/UDP]
$ns_ attach-agent $node_(46) $udp_(27)

set udp_(28) [new Agent/UDP]
$ns_ attach-agent $node_(47) $udp_(28)
set udp_(29) [new Agent/UDP]
$ns_ attach-agent $node_(50) $udp_(29)

set udp_(30) [new Agent/UDP]
$ns_ attach-agent $node_(51) $udp_(30)
set udp_(31) [new Agent/UDP]
$ns_ attach-agent $node_(55) $udp_(31)


set null_(0) [new Agent/Null]
$ns_ attach-agent $node_(56) $null_(0)

for {set j 0} {$j < 32} {incr j} {
  $ns_ connect $udp_($j) $null_(0)
}
for {set j 0} {$j < 32}  {incr j} {
set cbr_($j) [new Application/Traffic/CBR]
$cbr_($j) set packetSize_ 512
$cbr_($j) set rate_ 512
$cbr_($j) attach-agent $udp_($j)
$ns_ at 10.0 "$cbr_($j) start"
incr j
}
for {set j 1} {$j < 32} {incr j} {
set cbr_($j) [new Application/Traffic/CBR]
$cbr_($j) set packetSize_ 512
$cbr_($j) set rate_ 512
$cbr_($j) attach-agent $udp_($j)
$ns_ at 15.0 "$cbr_($j) start"
incr j
}


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






