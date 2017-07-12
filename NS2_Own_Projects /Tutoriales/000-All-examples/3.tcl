set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(rp) DumbAgent
 

set a [lindex $argv 0]
set b [lindex $argv 1]
if {[string length $a ]} {
set rate $a
puts $a
} else {
set rate 0.95Mb
puts def
}
set ns [new Simulator]
if {[string length $b ]} { 
Mac/802_11 set RTSThreshold_    0
} else {
Mac/802_11 set RTSThreshold_    3000	
}
Mac/802_11 set dataRate_ 11Mb
 
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5 
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0
 
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 5.659e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set bandwidth_ 2e6
Phy/WirelessPhy set Pt_ 0.28183815
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.0  

$ns use-newtrace
set f [open raw/testCTS.$rate w]
$ns trace-all $f
$ns eventtrace-all
set nf [open test.nam w]
$ns namtrace-all-wireless $nf 500 500
 
# set up topography object
set topo       [new Topography]
$topo load_flatgrid 500 500
 
# Create God
create-god 3
 
# create channel 
set chan [new $val(chan)]
 
$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -channel $chan \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace ON \
                -movementTrace OFF 
for {set i 0} {$i < 3} {incr i} {
        set node_($i) [$ns node]
        $node_($i) random-motion 0
}
 
$node_(0) set X_ 30.0
$node_(0) set Y_ 30.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 200.0
$node_(1) set Y_ 30.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 450.0
$node_(2) set Y_ 30.0
$node_(2) set Z_ 0.0
 
set udp [new Agent/UDP]
$ns attach-agent $node_(0) $udp
set null [new Agent/Null]
$ns attach-agent $node_(1) $null
$ns connect $udp $null
 
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ $rate
$cbr set random_ false
$ns at 0.0 "$cbr start"
$ns at 15.0 "$cbr stop"
 
set udp2 [new Agent/UDP]
$ns attach-agent $node_(2) $udp2
set null2 [new Agent/Null]
$ns attach-agent $node_(1) $null2
$ns connect $udp2 $null2
 
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ $rate
puts [$cbr2 set rate_ ]
$cbr2 set random_ false
$ns at 1.0 "$cbr2 start"
$ns at 15.0 "$cbr2 stop"
 
for {set i 0} {$i < 3} {incr i} {
        $ns initial_node_pos $node_($i) 30
        $ns at 20.0 "$node_($i) reset";
}
 
$ns at 20.0 "finish"
$ns at 20.1 "puts \"NS EXITING...\"; $ns halt"
 
#INSERT ANNOTATIONS HERE
proc finish {} {
        global ns f nf val
        $ns flush-trace
        close $f
        close $nf
}
 
puts "Starting Simulation..."
$ns run