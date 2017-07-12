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
Phy/WirelessPhy set CPThresh_ 10.0         ;#Collision Threshold
Phy/WirelessPhy set CSThresh_ 5.011872e-12 ;#Carrier Sense Power
Phy/WirelessPhy set RXThresh_ 3.65262e-10  ;#Receive Power Threshold
set val(chan)   Channel/WirelessChannel    ;# channel type
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)  Phy/WirelessPhy            ;# network interface type
set val(mac)    Mac/802_11                 ;# MAC type
set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(ifqlen) 500                         ;# max packet in ifq
set val(nn)     5                          ;# number of mobilenodes
set val(rp)     WTRP                       ;# routing protocol
set val(x)      1002                      ;# X dimension of topography
set val(y)      640                      ;# Y dimension of topography
set val(stop)   10.0                         ;# time of simulation end
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
set tracefile [open 6N4V.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open 6N4V.nam w]
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
#Create 6 nodes
set n0 [$ns node]
$n0 set X_ 600
$n0 set Y_ 442
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 902
$n1 set Y_ 499
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 600
$n2 set Y_ 540
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20
set n3 [$ns node]
$n3 set X_ 300
$n3 set Y_ 498
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20
set n4 [$ns node]
$n4 set X_ 249
$n4 set Y_ 194
$n4 set Z_ 0.0
$ns initial_node_pos $n4 20
#set n5 [$ns node]
#$n5 set X_ 876
#$n5 set Y_ 120
#$n5 set Z_ 0.0
#$ns initial_node_pos $n5 20

#===================================
#        Generate movement          
#===================================
$ns at 1.0 " $n1 setdest 687 489 150 " 
$ns at 1.0 " $n3 setdest 514 491 150 " 
$ns at 2.5 " $n4 setdest 320 400 300 " 
#$ns at 6.0 " $n5 setdest 686 313 200 " 

#===================================
#        Agents Definition        
#===================================
Agent/WTRP set sort_repliers_by_ 0
set myAgent_ [new Agent/WTRP]
$myAgent_ set sort_repliers_by_ 0

$ns at 0.0 "[$n0 set ragent_] soliciting"
$ns at 2.0 "[$n1 set ragent_] soliciting"
$ns at 3.0 "[$n3 set ragent_] soliciting"
$ns at 6.0 "[$n4 set ragent_] soliciting"
#$ns at 6.9 "[$n5 set ragent_] soliciting"

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
    exec nam 6N4V.nam &
    exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
