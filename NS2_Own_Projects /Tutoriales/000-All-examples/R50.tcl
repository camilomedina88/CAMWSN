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
set val(ifqlen) 300                         ;# max packet in ifq
set val(nn)     50                         ;# number of mobilenodes
set val(rp)     WTRP                       ;# routing protocol
set val(x)      1311                      ;# X dimension of topography
set val(y)      943                      ;# Y dimension of topography
set val(stop)   430.0                         ;# time of simulation end
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
set tracefile [open R50.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open R50.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#USES NEW TRACE
#$ns use-newtrace
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
#Create 50 nodes
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
set n30 [$ns node]
$n30 set X_ 1990
$n30 set Y_ 805
$n30 set Z_ 0.0
$ns initial_node_pos $n30 20
set n31 [$ns node]
$n31 set X_ 1856
$n31 set Y_ 840
$n31 set Z_ 0.0
$ns initial_node_pos $n31 20
set n32 [$ns node]
$n32 set X_ 1900
$n32 set Y_ 470
$n32 set Z_ 0.0
$ns initial_node_pos $n32 20
set n33 [$ns node]
$n33 set X_ 10.0
$n33 set Y_ 645
$n33 set Z_ 0.0
$ns initial_node_pos $n33 20
set n34 [$ns node]
$n34 set X_ 12
$n34 set Y_ 803
$n34 set Z_ 0.0
$ns initial_node_pos $n34 20
set n35 [$ns node]
$n35 set X_ 0
$n35 set Y_ 530
$n35 set Z_ 0.0
$ns initial_node_pos $n35 20
set n36 [$ns node]
$n36 set X_ 1930
$n36 set Y_ 530
$n36 set Z_ 0.0
$ns initial_node_pos $n36 20
set n37 [$ns node]
$n37 set X_ 5
$n37 set Y_ 455
$n37 set Z_ 0.0
$ns initial_node_pos $n37 20
set n38 [$ns node]
$n38 set X_ 3
$n38 set Y_ 430
$n38 set Z_ 0.0
$ns initial_node_pos $n38 20
set n39 [$ns node]
$n39 set X_ 1900
$n39 set Y_ 400
$n39 set Z_ 0.0
$ns initial_node_pos $n39 20
set n40 [$ns node]
$n40 set X_ 1955
$n40 set Y_ 300
$n40 set Z_ 0.0
$ns initial_node_pos $n40 20
set n41 [$ns node]
$n41 set X_ 7
$n41 set Y_ 400
$n41 set Z_ 0.0
$ns initial_node_pos $n41 20
set n42 [$ns node]
$n42 set X_ 10.0
$n42 set Y_ 295
$n42 set Z_ 0.0
$ns initial_node_pos $n42 20
set n43 [$ns node]
$n43 set X_ 8.0
$n43 set Y_ 190
$n43 set Z_ 0.0
$ns initial_node_pos $n43 20
set n44 [$ns node]
$n44 set X_ 15
$n44 set Y_ 220
$n44 set Z_ 0.0
$ns initial_node_pos $n44 20
set n45 [$ns node]
$n45 set X_ 11
$n45 set Y_ 16
$n45 set Z_ 0.0
$ns initial_node_pos $n45 20
set n46 [$ns node]
$n46 set X_ 20
$n46 set Y_ 101
$n46 set Z_ 0.0
$ns initial_node_pos $n46 20
set n47 [$ns node]
$n47 set X_ 1800
$n47 set Y_ 220
$n47 set Z_ 0.0
$ns initial_node_pos $n47 20
set n48 [$ns node]
$n48 set X_ 2010
$n48 set Y_ 280
$n48 set Z_ 0.0
$ns initial_node_pos $n48 20
set n49 [$ns node]
$n49 set X_ 2010
$n49 set Y_ 120
$n49 set Z_ 0.0
$ns initial_node_pos $n49 20

#===================================
#       Nodes Displacement        
#===================================
$ns at 0.0 " $n2 setdest 998 399 220 "
$ns at 0.0 " $n3 setdest 650 399 250 "
$ns at 2.5 " $n4 setdest 555 494 200 "
$ns at 0.0 " $n5 setdest 1018 255 100 "
$ns at 0.0 " $n6 setdest 1020 644 100 "
$ns at 1.0 " $n7 setdest 560 255 100 "
$ns at 2.0 " $n8 setdest 655 717 100 "  
$ns at 6.0 " $n9 setdest 904 194 100 "
$ns at 12.0 " $n10 setdest 412 361 100 "
$ns at 11.0 " $n11 setdest 1195 550 100 "
$ns at 22.0 " $n12 setdest 489 500 100 "
$ns at 22.0 " $n13 setdest 1200 363 100 "
$ns at 18.0 " $n14 setdest 703 181 100 "
$ns at 30.0 " $n15 setdest 894 716 100 "
$ns at 44.0 " $n16 setdest 799 702 200 "
$ns at 40.0 " $n17 setdest 549 645 100 "
$ns at 50.0 " $n18 setdest 400 582 50 "
$ns at 59.0 " $n19 setdest 545 405 100 "
$ns at 64.0 " $n20 setdest 489 365 100 "
$ns at 70.0 " $n21 setdest 417 251 50 "
$ns at 83.0 " $n22 setdest 550 204 100 "
$ns at 89.0 " $n23 setdest 789 220 100 "
$ns at 100.0 " $n24 setdest 817 233 100 "
$ns at 105.0 " $n25 setdest 1020 168 100 "
$ns at 115.0 " $n26 setdest 1185 245 100 "
$ns at 120.0 " $n27 setdest 1189 440 100 "
$ns at 127.0 " $n28 setdest 1189 477 100 "
$ns at 135.0 " $n29 setdest 1189 720 100 "
$ns at 147.0 " $n30 setdest  1020 803 200 "
$ns at 147.0 " $n31 setdest  817 840 100 "
$ns at 155.0 " $n32 setdest  1289 645 100 "
$ns at 147.0 " $n33 setdest  800 645 50 "
$ns at 153.0 " $n34 setdest  500 803 75 "
$ns at 160.0 " $n35 setdest  450 550 75 "
$ns at 164.0 " $n36 setdest  1289 530 100 "
$ns at 190.0 " $n37 setdest  390 450 100 "
$ns at 209.0 " $n38 setdest  409 440 100 "
$ns at 200.0 " $n39 setdest  1300 399 100 "
$ns at 235.0 " $n40 setdest  1260 400 100 "
$ns at 222.0 " $n41 setdest  340 440 50 "
$ns at 260.0 " $n42 setdest  430 295 100 "
$ns at 273.0 " $n43 setdest  489 220 100 "
$ns at 290.0 " $n44 setdest  644 220 100 "
$ns at 304.0 " $n45 setdest  645 101 100 "
$ns at 320.0 " $n46 setdest  746 130 100 "
$ns at 330.0 " $n47 setdest   1130 220 100 "
$ns at 344.0 " $n48 setdest   1310 300 100 "
$ns at 358.0 " $n49 setdest   899 120 100 "
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
$ns at 19.65 "[$n9 set ragent_] soliciting"
$ns at 23.94 "[$n10 set ragent_] soliciting"
$ns at 27.66 "[$n11 set ragent_] soliciting"
$ns at 31.04 "[$n12 set ragent_] soliciting"
$ns at 34.92 "[$n13 set ragent_] soliciting"
$ns at 39.77 "[$n14 set ragent_] soliciting"
$ns at 44.75 "[$n15 set ragent_] soliciting"
$ns at 49.3 "[$n16 set ragent_] soliciting"
$ns at 55.0 "[$n17 set ragent_] soliciting"
$ns at 59.8 "[$n18 set ragent_] soliciting"
$ns at 65.65 "[$n19 set ragent_] soliciting"
$ns at 74.45 "[$n20 set ragent_] soliciting"
$ns at 83.36 "[$n21 set ragent_] soliciting"
$ns at 89.52 "[$n22 set ragent_] soliciting"
$ns at 98.63 "[$n23 set ragent_] soliciting"
$ns at 107.84 "[$n24 set ragent_] soliciting"
$ns at 116.25 "[$n25 set ragent_] soliciting"
$ns at 123.72 "[$n26 set ragent_] soliciting"
$ns at 130.40 "[$n27 set ragent_] soliciting"
$ns at 137.17 "[$n28 set ragent_] soliciting"
$ns at 145.95 "[$n29 set ragent_] soliciting"
$ns at 151.98 "[$n30 set ragent_] soliciting"
$ns at 159.06 "[$n31 set ragent_] soliciting"
$ns at 165.93 "[$n32 set ragent_] soliciting"
$ns at 173.53 "[$n33 set ragent_] soliciting"
$ns at 182.82 "[$n34 set ragent_] soliciting"
$ns at 189.36 "[$n35 set ragent_] soliciting"
$ns at 199.03 "[$n36 set ragent_] soliciting"
$ns at 209.4 "[$n37 set ragent_] soliciting"
$ns at 221.00 "[$n38 set ragent_] soliciting"
$ns at 235.27 "[$n39 set ragent_] soliciting"
$ns at 246.1 "[$n40 set ragent_] soliciting"
$ns at 259.26 "[$n41 set ragent_] soliciting"
$ns at 273.17 "[$n42 set ragent_] soliciting"
$ns at 289.08 "[$n43 set ragent_] soliciting"
$ns at 303.19 "[$n44 set ragent_] soliciting"
$ns at 319.31 "[$n45 set ragent_] soliciting"
$ns at 331.74 "[$n46 set ragent_] soliciting"
$ns at 343.00 "[$n47 set ragent_] soliciting"
$ns at 356.63 "[$n48 set ragent_] soliciting"
$ns at 371.51 "[$n49 set ragent_] soliciting"
#===================================
#        Agents Definition        
#===================================

#===================================
#        Applications Definition        
#===================================
#Setup a UDP connection
set udp [new Agent/UDP]
$ns attach-agent $n24 $udp
set sink [new Agent/Null]
$ns attach-agent $n43 $sink

#Set values
$udp set fid_ 2
$udp set ttl_ 100

#Setup a CBR over UDP connection
set cbr_ [new Application/Traffic/CBR]
$cbr_ set packetSize_ 50
$cbr_ set interval_ .6554 #0.25
$cbr_ set random_ false
$cbr_ set maxpkts_ 10000
$cbr_ attach-agent $udp
$ns connect $udp $sink
$ns at 400.0 "$cbr_ start"
$ns at 420.0 "$cbr_ stop"

#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam R50.nam &
    exec gedit R50.txt &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
