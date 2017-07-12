# This script is created by NSG2 beta1
# <http://wushoupong.googlepages.com/nsg>

#===================================
#     Simulation parameters setup
#===================================
Antenna/OmniAntenna set Gt_ 1              ;#Transmit antenna gain
Antenna/OmniAntenna set Gr_ 1              ;#Receive antenna gain
Phy/WirelessPhy set L_ 1.0                 ;#System Loss Factor
Phy/WirelessPhy set freq_ 9.14e+08          ;#channel
Phy/WirelessPhy set bandwidth_ 11Mb        ;#Data Rate
Phy/WirelessPhy set Pt_ 0.281838        ;#Transmit Power
Phy/WirelessPhy set RXThresh_ 3.65262e-10  ;#Receive Power Threshold
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 50                         ;# max packet in ifq
set val(nn)     6                          ;# number of mobilenodes
set val(rp)     WTRP                       ;# routing protocol
set val(x)      967                      ;# X dimension of topography
set val(y)      941                      ;# Y dimension of topography
set val(stop)   30.0                         ;# time of simulation end
set val(energymodel)   EnergyModel        ;# Energy model
set val(initialenergy) 100                ;

Mac/802_11 set RTSThreshold_ 3000
Mac/802_11 set basicRate_ 1Mb
Mac/802_11 set dataRate_ 2Mb

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open R6.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open R6.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
#     Mobile node parameter setup
#===================================
$ns node-config -adhocRouting  $val(rp) \
                -llType        $val(ll) \
                -macType       $val(mac) \
                -ifqType       $val(ifq) \
                -ifqLen        $val(ifqlen) \
                -antType       $val(ant) \
                -propType      $val(prop) \
                -phyType       $val(netif) \
                -energyModel   $val(energymodel) \
	       -initialEnergy $val(initialenergy) \
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace OFF

#===================================
#        Nodes Definition        
#===================================
#Create 5 nodes
set n0 [$ns node]
$n0 set X_ 562
$n0 set Y_ 529
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 664
$n1 set Y_ 534
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 607
$n2 set Y_ 840
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20
set n3 [$ns node]
$n3 set X_ 867
$n3 set Y_ 699
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20
set n4 [$ns node]
$n4 set X_ 267
$n4 set Y_ 745
$n4 set Z_ 0.0
$ns initial_node_pos $n4 20
set n5 [$ns node]
$n5 set X_ 613
$n5 set Y_ 113
$n5 set Z_ 0.0
$ns initial_node_pos $n5 20
#===================================
#        Generate movement          
#===================================
$ns at 0.5 " $n2 setdest 608 614 100 " 
$ns at 2.3 " $n3 setdest 743 621 100 " 
$ns at 2.4 " $n4 setdest 460 647 100 " 
$ns at 3.7 " $n5 setdest 613 459 100 "
#===================================
#        Agents Definition        
#===================================
$ns at 0.0 "[$n0 set ragent_] soliciting"
$ns at 1.5 "[$n2 set ragent_] soliciting"
$ns at 3.0 "[$n3 set ragent_] soliciting"
$ns at 5.7 "[$n4 set ragent_] soliciting"
$ns at 8.95 "[$n5 set ragent_] soliciting"

#===================================
#        Applications Definition        
#===================================
#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n5 $udp

set sink [new Agent/Null]
$ns attach-agent $n4 $sink

$ns connect $udp $sink
$udp set fid_ 2

#Setup a CBR over UDP connection
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 512
$cbr set rate_ 600Kb           ;#Set CBR rate to 200 Kbits/sec
#$cbr set interval_ 2
#$cbr set random_ false

$ns at 15.0 "$cbr start"
$ns at 30.0 "$cbr stop"

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam R6.nam &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
