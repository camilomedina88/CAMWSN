#  ankita http://byuvraj.blogspot.dk/p/ns-2-awk-scripts.html
#  ankita 13 April 2013 20:18 : I have generated the following scenario using script generator
#
#
#
#===================================
# Simulation parameters setup
#===================================
Antenna/OmniAntenna set Gt_ 1 ;#Transmit antenna gain
Antenna/OmniAntenna set Gr_ 1 ;#Receive antenna gain
Phy/WirelessPhy set L_ 1.0 ;#System Loss Factor
Phy/WirelessPhy set freq_ 2.472e9 ;#channel
Phy/WirelessPhy set bandwidth_ 11Mb ;#Data Rate
Phy/WirelessPhy set Pt_ 0.031622777 ;#Transmit Power
Phy/WirelessPhy set CPThresh_ 10.0 ;#Collision Threshold
Phy/WirelessPhy set CSThresh_ 5.011872e-12 ;#Carrier Sense Power
Phy/WirelessPhy set RXThresh_ 5.82587e-09 ;#Receive Power Threshold
Mac/802_11 set dataRate_ 11Mb ;#Rate for Data Frames
Mac/802_11 set basicRate_ 1Mb ;#Rate for Control Frames

set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 6 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 700 ;# X dimension of topography
set val(y) 4767 ;# Y dimension of topography
set val(stop) 10.0 ;# time of simulation end

#===================================
# Initialization
#===================================
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#Open the NS trace file
set tracefile [open 6.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open 6.nam w]
$ns namtrace-all $namfile
$ns namtrace-all-wireless $namfile $val(x) $val(y)
set chan [new $val(chan)];#Create wireless channel

#===================================
# Mobile node parameter setup
#===================================
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
-movementTrace ON


#===================================
# Nodes Definition
#===================================
#Create 6 nodes
set n0 [$ns node]
$n0 set X_ 100
$n0 set Y_ 401
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 300
$n1 set Y_ 401
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
set n2 [$ns node]
$n2 set X_ 500
$n2 set Y_ 401
$n2 set Z_ 0.0
$ns initial_node_pos $n2 20
set n3 [$ns node]
$n3 set X_ 100
$n3 set Y_ 201
$n3 set Z_ 0.0
$ns initial_node_pos $n3 20
set n4 [$ns node]
$n4 set X_ 300
$n4 set Y_ 201
$n4 set Z_ 0.0
$ns initial_node_pos $n4 20
set n5 [$ns node]
$n5 set X_ 500
$n5 set Y_ 201
$n5 set Z_ 0.0
$ns initial_node_pos $n5 20

#===================================
# Generate movement
#===================================
$ns at 1 " $n0 setdest 200 400 10 "
$ns at 1 " $n1 setdest 400 400 10 "
$ns at 1 " $n2 setdest 500 400 10 "
$ns at 1 " $n3 setdest 150 201 10 "
$ns at 1 " $n4 setdest 400 200 10 "
$ns at 1 " $n5 setdest 600 200 10 "

#===================================
# Agents Definition
#===================================
#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink3 [new Agent/TCPSink]
$ns attach-agent $n3 $sink3
$ns connect $tcp0 $sink3
$tcp0 set packetSize_ 1500

#Setup a TCP connection
set tcp1 [new Agent/TCP]
$ns attach-agent $n1 $tcp1
set sink4 [new Agent/TCPSink]
$ns attach-agent $n4 $sink4
$ns connect $tcp1 $sink4
$tcp1 set packetSize_ 1500

#Setup a TCP connection
set tcp2 [new Agent/TCP]
$ns attach-agent $n2 $tcp2
set sink5 [new Agent/TCPSink]
$ns attach-agent $n5 $sink5
$ns connect $tcp2 $sink5
$tcp2 set packetSize_ 1500


#===================================
# Applications Definition
#===================================
#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 1.0 "$ftp0 start"
$ns at 2.0 "$ftp0 stop"

#Setup a FTP Application over TCP connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 2.0 "$ftp1 start"
$ns at 4.0 "$ftp1 stop"

#Setup a FTP Application over TCP connection
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns at 5.0 "$ftp2 start"
$ns at 10.0 "$ftp2 stop"


#===================================
# Termination
#===================================
#Define a 'finish' procedure
proc finish {} {
global ns tracefile namfile
$ns flush-trace
close $tracefile
close $namfile
exec nam 6.nam &
exit 0
}
for {set i 0} {$i < $val(nn) } { incr i } {
$ns at $val(stop) "\$n$i reset"
}
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at $val(stop) "puts \"done\" ; $ns halt"
$ns run
