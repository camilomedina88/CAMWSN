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
set val(ifqlen) 250                         ;# max packet in ifq
set val(nn)     30                         ;# number of mobilenodes
set val(rp)     WTRP                       ;# routing protocol
set val(x)      1311                      ;# X dimension of topography
set val(y)      943                      ;# Y dimension of topography
set val(stop)   200.0                         ;# time of simulation end
set val(energymodel)   EnergyModel        ;# Energy model
set val(initialenergy) 100                ;

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
set tracefile [open N30V8.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open N30V8.nam w]
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
                -channel       $chan \
                -topoInstance  $topo \
                -agentTrace    ON \
                -routerTrace   ON \
                -macTrace      ON \
                -movementTrace OFF \
                -energyModel   $val(energymodel) \
	       		-initialEnergy $val(initialenergy) \
	       		-txPower       0.07 \
	       		-rxPower       0.04
                
#===================================
#        Nodes Definition        
#===================================
#Create 30 nodes
set n0 [$ns node]
$n0 set X_ 800
$n0 set Y_ 295
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 799
$n1 set Y_ 530
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 1198
$n2 set Y_ 399
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20
set n3 [$ns node]
$n3 set X_ 150
$n3 set Y_ 399
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20
set n4 [$ns node]
$n4 set X_ 170
$n4 set Y_ 494
$n4 set Z_ 0.0
$ns initial_node_pos $n4 20
set n5 [$ns node]
$n5 set X_ 1782
$n5 set Y_ 255
$n5 set Z_ 0.0
$ns initial_node_pos $n5 20
set n6 [$ns node]
$n6 set X_ 1885
$n6 set Y_ 744
$n6 set Z_ 0.0
$ns initial_node_pos $n6 20
set n7 [$ns node]
$n7 set X_ 59
$n7 set Y_ 255
$n7 set Z_ 0.0
$ns initial_node_pos $n7 20
set n8 [$ns node]
$n8 set X_ 85
$n8 set Y_ 817
$n8 set Z_ 0.0
$ns initial_node_pos $n8 20
set n9 [$ns node]
$n9 set X_ 1804
$n9 set Y_ 194
$n9 set Z_ 0.0
$ns initial_node_pos $n9 20
set n10 [$ns node]
$n10 set X_ 22
$n10 set Y_ 361
$n10 set Z_ 0.0
$ns initial_node_pos $n10 20
set n11 [$ns node]
$n11 set X_ 1955
$n11 set Y_ 650
$n11 set Z_ 0.0
$ns initial_node_pos $n11 20
set n12 [$ns node]
$n12 set X_ 23
$n12 set Y_ 666
$n12 set Z_ 0.0
$ns initial_node_pos $n12 20
set n13 [$ns node]
$n13 set X_ 1955
$n13 set Y_ 363
$n13 set Z_ 0.0
$ns initial_node_pos $n13 20
set n14 [$ns node]
$n14 set X_ 83
$n14 set Y_ 181
$n14 set Z_ 0.0
$ns initial_node_pos $n14 20
set n15 [$ns node]
$n15 set X_ 1894
$n15 set Y_ 816
$n15 set Z_ 0.0
$ns initial_node_pos $n15 20
set n16 [$ns node]
$n16 set X_ 1869
$n16 set Y_ 802
$n16 set Z_ 0.0
$ns initial_node_pos $n16 20
set n17 [$ns node]
$n17 set X_ 74
$n17 set Y_ 843
$n17 set Z_ 0.0
$ns initial_node_pos $n17 20
set n18 [$ns node]
$n18 set X_ 27
$n18 set Y_ 782
$n18 set Z_ 0.0
$ns initial_node_pos $n18 20
set n19 [$ns node]
$n19 set X_ 7
$n19 set Y_ 558
$n19 set Z_ 0.0
$ns initial_node_pos $n19 20
set n20 [$ns node]
$n20 set X_ 14
$n20 set Y_ 480
$n20 set Z_ 0.0
$ns initial_node_pos $n20 20
set n21 [$ns node]
$n21 set X_ 17
$n21 set Y_ 251
$n21 set Z_ 0.0
$ns initial_node_pos $n21 20
set n22 [$ns node]
$n22 set X_ 62
$n22 set Y_ 154
$n22 set Z_ 0.0
$ns initial_node_pos $n22 20
set n23 [$ns node]
$n23 set X_ 96
$n23 set Y_ 220
$n23 set Z_ 0.0
$ns initial_node_pos $n23 20
set n24 [$ns node]
$n24 set X_ 1817
$n24 set Y_ 233
$n24 set Z_ 0.0
$ns initial_node_pos $n24 20
set n25 [$ns node]
$n25 set X_ 1617
$n25 set Y_ 168
$n25 set Z_ 0.0
$ns initial_node_pos $n25 20
set n26 [$ns node]
$n26 set X_ 1885
$n26 set Y_ 263
$n26 set Z_ 0.0
$ns initial_node_pos $n26 20
set n27 [$ns node]
$n27 set X_ 2000
$n27 set Y_ 482
$n27 set Z_ 0.0
$ns initial_node_pos $n27 20
set n28 [$ns node]
$n28 set X_ 1891
$n28 set Y_ 548
$n28 set Z_ 0.0
$ns initial_node_pos $n28 20
set n29 [$ns node]
$n29 set X_ 1881
$n29 set Y_ 766
$n29 set Z_ 0.0
$ns initial_node_pos $n29 20

#===================================
#       Nodes Displacement        
#===================================
$ns at 0.0 " $n2 setdest 998 399 220 "
$ns at 0.0 " $n3 setdest 650 399 250 "
$ns at 2.5 " $n4 setdest 555 494 200 "
$ns at 0.0 " $n5 setdest 1018 255 100 "
$ns at 0.0 " $n6 setdest 1020 644 100 "
$ns at 1.0 " $n7 setdest 560 255 100 "
$ns at 2.0 " $n8 setdest 725 717 100 "  
$ns at 6.0 " $n9 setdest 904 194 100 "
$ns at 10.0 " $n10 setdest 412 361 100 "
$ns at 11.0 " $n11 setdest 1195 550 100 "
$ns at 18.0 " $n12 setdest 489 617 100 "
$ns at 16.0 " $n13 setdest 1200 363 100 "
$ns at 20.0 " $n14 setdest 703 181 170 "
$ns at 23.0 " $n15 setdest 894 716 200 "
$ns at 25.0 " $n16 setdest 750 843 200 "
$ns at 26.0 " $n17 setdest 412 645 100 "
$ns at 34.0 " $n18 setdest 444 582 200 "
$ns at 38.0 " $n19 setdest 412 405 100 "
$ns at 44.0 " $n20 setdest 489 365 100 "
$ns at 50.0 " $n21 setdest 417 251 100 "
$ns at 63.0 " $n22 setdest 350 321 100 "
$ns at 65.0 " $n23 setdest 800 150 150 "
$ns at 70.0 " $n24 setdest 770 173 100 "
$ns at 80.0 " $n25 setdest 730 168 150 "
$ns at 83.0 " $n26 setdest 785 103 150 "
$ns at 90.0 " $n27 setdest 1198 403 200 "
$ns at 96.0 " $n28 setdest 1197 443 150 "
$ns at 99.0 " $n29 setdest 1196 483 150 "
#===================================
#       Nodes Initialization        
#===================================
$ns at 0.0 "[$n0 set ragent_] soliciting"
$ns at 0.8 "[$n2 set ragent_] soliciting"
$ns at 2.17 "[$n3 set ragent_] soliciting"
$ns at 4.49 "[$n4 set ragent_] soliciting"
$ns at 7.6 "[$n5 set ragent_] soliciting"
$ns at 10.19 "[$n6 set ragent_] soliciting"
$ns at 13.01 "[$n7 set ragent_] soliciting"
$ns at 16.57 "[$n8 set ragent_] soliciting"
$ns at 18.30 "[$n9 set ragent_] soliciting"
$ns at 19.88 "[$n10 set ragent_] soliciting"
$ns at 21.72 "[$n11 set ragent_] soliciting"
$ns at 23.52 "[$n12 set ragent_] soliciting"
$ns at 25.02 "[$n13 set ragent_] soliciting"
$ns at 26.92 "[$n14 set ragent_] soliciting"
$ns at 28.26 "[$n15 set ragent_] soliciting"
$ns at 30.30 "[$n16 set ragent_] soliciting"
$ns at 34.0 "[$n17 set ragent_] soliciting"
$ns at 38.8 "[$n18 set ragent_] soliciting"
$ns at 44.65 "[$n19 set ragent_] soliciting"
$ns at 50.42 "[$n20 set ragent_] soliciting"
$ns at 63.36 "[$n21 set ragent_] soliciting"
$ns at 70.32 "[$n22 set ragent_] soliciting"
$ns at 72.63 "[$n23 set ragent_] soliciting"
$ns at 80.84 "[$n24 set ragent_] soliciting"
$ns at 85.25 "[$n25 set ragent_] soliciting"
$ns at 90.72 "[$n26 set ragent_] soliciting"
$ns at 96.40 "[$n27 set ragent_] soliciting"
$ns at 99.17 "[$n28 set ragent_] soliciting"
$ns at 109.95 "[$n29 set ragent_] soliciting"
#===================================
#        Agents Definition        
#===================================
#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n16 $udp
set sink [new Agent/Null]
$ns attach-agent $n29 $sink

#Set values
$udp set fid_ 2
$udp set ttl_ 100

#Setup a CBR over UDP connection
set cbr_ [new Application/Traffic/CBR]
$cbr_ set packetSize_ 50
$cbr_ set interval_ .6554
$cbr_ set random_ 1
$cbr_ set maxpkts_ 10000
$cbr_ attach-agent $udp
$ns connect $udp $sink
$ns at 150.0 "$cbr_ start"
$ns at 170.0 "$cbr_ stop"
#===================================
#        Applications Definition        
#===================================

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam N30V8.nam &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run

