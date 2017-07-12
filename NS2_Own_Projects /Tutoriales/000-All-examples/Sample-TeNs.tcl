#  #6  http://www.linuxquestions.org/questions/linux-software-2/error-on-example-simulation-on-ns2-using-add-on-for-directional-antenna-833449/#6  
#This is a sample Tcl script file for using with TeNs

#####################################################


set val(chan) Channel/WirelessChannel ;# channel type

set val(prop) Propagation/Shadowing ;# radio-propagation model

set val(netif) Phy/WirelessPhy ;# network interface type

set val(mac) Mac/802_11 ;# MAC type

set val(ifq) Queue/DropTail/PriQueue ;# interface queue type

set val(ll) LL ;# link layer type

set val(ant) Antenna/DirAntenna ;# antenna model

set val(ifqlen) 50 ;# max packet in ifq

set val(nn) 4 ;# number of mobilenodes



#One can use AODV also , all other wireless protocols currently don't work

set val(rp) AODV ;# routing protocol



set val(ni) 1



#This type of modulation is a new addition

set opt(mod) Modulation/BPSK



# ======================================================================

# Main Program

# ======================================================================





#

# Initialize Global Variables

#



set ns_ [new Simulator]

set tracefd [open simple.tr w]

#set par [open param.tr w]

$ns_ trace-all $tracefd

$ns_ use-newtrace

# set up topography object

set topo [new Topography]



$topo load_flatgrid 10000 10000



#$val(nn)



#

# Create the specified number of mobilenodes [$val(nn)] and "attach" them

# to the channel.

# Here two nodes are created : node(0) and node(1)



# configure node

$ns_ node-config -adhocRouting $val(rp) \

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

-macTrace ON \

-numif $val(ni) \



create-god 6



proc create_node { x y z } {

global ns_

#Mac/802_11 MAC_RTSThreshold 2000

#Mac/802_11 MAC_FragmentationThreshold 2500

#Mac/802_11 DSSS_AirPropagationTime 0.000003

Mac/802_11 set dataRate_ 2mb

Mac/802_11 set basicRate_ 1mb



# This statement can be used to enable BPSK Modulation scheme

# If one does not want to use this then it can be set to zero.

# By default it is set to zero.

Phy/WirelessPhy set modulationscheme_ 1



set newnode [$ns_ node]

$newnode random-motion 0

$newnode set X_ $x

$newnode set Y_ $y

$newnode set Z_ $z



return $newnode

}



proc create_cbr_connection { from to startTime interval packetSize } {

global ns_

set udp0 [new Agent/UDP]

set src [new Application/Traffic/CBR]

$udp0 set packetSize_ $packetSize

$src set packetSize_ $packetSize

$src set interval_ $interval



set sink [new Agent/Null]



$ns_ attach-agent $from $udp0

$src attach-agent $udp0

$ns_ attach-agent $to $sink



$ns_ connect $udp0 $sink

$ns_ at $startTime "$src start"

return $udp0

}



proc create_tcp_connection { from to startTime } {

global ns_ par

set tcp [new Agent/TCP]

$tcp set packetSize_ 1500

$tcp set class_ 2

set sink [new Agent/TCPSink]

$ns_ attach-agent $from $tcp

$ns_ attach-agent $to $sink

$ns_ connect $tcp $sink

set ftp [new Application/FTP]

$ftp set packetSize_ 1500

$ftp attach-agent $tcp

$ns_ at $startTime "$ftp start"

$tcp attach $par



$tcp trace cwnd_

$tcp trace maxseq_

$tcp trace rtt_

$tcp trace dupacks_

$tcp trace ack_

$tcp trace ndatabytes_

$tcp trace ndatapack_

$tcp trace nrexmit_

$tcp trace nrexmitpack_

return $tcp

}





$ns_ node-config -numif 1

set node_(0) [create_node 10 10 0]



[$node_(0) set netif_(0)] set channel_number_ 1



[$node_(0) set netif_(0)] set Pt_ 0.1



set a [new Antenna/DirAntenna]

$a setType 1

$a setAngle 90

#$a setWidth 10



[$node_(0) set netif_(0)] dir-antenna $a



#This is to set the number of interfaces in one node, in this case the no. of

#interfaces in node is set to 1

$ns_ node-config -numif 2



#This is the way a node is created (situated at 10,60,0)

set node_(1) [create_node 10 60 0]



#This is the method of setting the power at which a particular network interface of a node

# will transmit at. For eg. in this case the interface no.0 of node no 1 will work at 0.005W

[$node_(1) set netif_(0)] set Pt_ 0.1



#This is the method of setting the channel at which a particular network interface of a node

#will work at. For eg. in this case the interface no.0 of node no 1 will work at channel 1

[$node_(1) set netif_(0)] set channel_number_ 1



#This is the method of setting the power at which a particular network interface of a

#node will transmit at. For eg. in this case the interface no.1 of node no 1 will work at 0.005W



[$node_(1) set netif_(1)] set Pt_ 0.1

#This is the method of setting the channel at which a particular network interface of

#a node will work at. For eg. in this case the interface no.1 of node no 1 will work at channel 1

[$node_(1) set netif_(1)] set channel_number_ 6



#This is the way a new directional antenna is created

set a [new Antenna/DirAntenna]



#The type can be set to zero if you want to use directional antennae in the following form :

#A packet is received if the path between the sender and receiver fall in the

#cone(parallelogram) formed by the directional antennae of the sender and receiver



$a setType 1

#This sets the start angle of the directional antenna

$a setAngle 265

#This sets the angle of cone of the directional antenna

#$a setWidth 10

#Thus the above antenna will cover all area between angle 265 to 275(anticlockwise +x axis)

#with the node as the origin.

#Note: ALL ANGLES ARE IN DEGREES

#Note: Directional Antennae specification can also be given by setting the type as an integer

#ranging from 1-8. In that case there is no need to give the setWidth command. One only needs to do the following:

#e.g.: $a setType 7

# $a setAngle 30 #This 30 gives the angle in degrees(anticlockwise from +ve x axis) of the direction of maximum gain, with the node at the center.



#This attaches the node to the directional antenna to the interface 0 of node1

[$node_(1) set netif_(0)] dir-antenna $a

set a [new Antenna/DirAntenna]

$a setType 1

$a setAngle 0

$a setWidth 10



#This attaches the node to the directional antenna to the interface 1 of node1

[$node_(1) set netif_(1)] dir-antenna $a



$ns_ node-config -numif 2

set node_(2) [create_node 60 60 0]

[$node_(2) set netif_(0)] set Pt_ 0.1

[$node_(2) set netif_(0)] set channel_number_ 6

[$node_(2) set netif_(1)] set Pt_ 0.1

[$node_(2) set netif_(1)] set channel_number_ 11



set a [new Antenna/DirAntenna]

$a setType 1

$a setAngle 180

$a setWidth 10

[$node_(2) set netif_(0)] dir-antenna $a



set a [new Antenna/DirAntenna]

$a setType 1

$a setAngle 90

#$a setWidth 10

[$node_(2) set netif_(1)] dir-antenna $a



$ns_ node-config -numif 1

set node_(3) [create_node 60 6100 0]

[$node_(3) set netif_(0)] set Pt_ 0.1

[$node_(3) set netif_(0)] set channel_number_ 11

set a [new Antenna/DirAntenna]

$a setType 1

$a setAngle 270

#$a setWidth 10

[$node_(3) set netif_(0)] dir-antenna $a





#These following set of commands manually makes a routing table for "wlstatic"

#the syntax is as follows:

#[$node_(0) set ragent_] addstaticroute <number of hops> <next hop> <destination node> <interface to use>

#[$node_(0) set ragent_] addstaticroute 1 1 1 0

#[$node_(0) set ragent_] addstaticroute 2 1 2 0

#[$node_(0) set ragent_] addstaticroute 3 1 3 0

#[$node_(1) set ragent_] addstaticroute 1 0 0 0

#[$node_(1) set ragent_] addstaticroute 1 2 2 1

#[$node_(1) set ragent_] addstaticroute 2 2 3 1

#[$node_(2) set ragent_] addstaticroute 2 1 0 0

#[$node_(2) set ragent_] addstaticroute 1 1 1 0

#[$node_(2) set ragent_] addstaticroute 1 3 3 1

#[$node_(3) set ragent_] addstaticroute 3 2 0 0

#[$node_(3) set ragent_] addstaticroute 2 2 1 0

#[$node_(3) set ragent_] addstaticroute 1 2 2 0



set tcp0 [create_cbr_connection $node_(0) $node_(3) 1.0 0.005 1500]



#

# Tell nodes when the simulation ends

#

for {set i 0} {$i < $val(nn) } {incr i} {

$ns_ at 110.0 "$node_($i) reset";

}

$ns_ at 110.0 "stop"

$ns_ at 110.01 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {

global ns_ tracefd par

$ns_ flush-trace

close $tracefd

#close $par

}



puts "Starting Simulation..."

$ns_ run
