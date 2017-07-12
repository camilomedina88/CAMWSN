
# #4      http://www.linuxquestions.org/questions/linux-software-2/location-aided-routing-procol-simulation-in-ns2-error-in-box-tcl-file-4175463906/#4

#*****************************************************************************#
#   File Name: ARP_TCP-box.tcl / Deolasi-box.tcl                              # 
#   Purpose: #
#   Original Author: #
#   Modified by: #
#   Date Created: #
#
#   Copyright (C) 2004  Toilers Research Group -- Colorado School of Mines     #
#
#   Please see COPYRIGHT.TXT and LICENSE.TXT for copyright and license         #
#   details.                                                                   #
#******************************************************************************/

set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
#set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)          300
set val(y)          600
set val(ifqlen)     50
set val(rp)         AODV
#set val(rp)          DSR
#set val(rp)         DSDV
set val(nn)         50
set val(txPower)    0.0075  ; #100 meters
set val(rxPower)    1
set val(sc)         "lar2.mob"		

set val(dataStart)  100.0
set val(dataStop)   300.0
set val(signalStop) 305.0
set val(finish)     310.0

if { $val(rp) == "DSR" } {
set val(ifq)      CMUPriQueue
} else {
 set val(ifq)       Queue/DropTail/PriQueue
}




# =====================================================================
# Other default settings

puts "setting other default settings..."

LL set mindelay_                50us
LL set delay_                   25us
LL set bandwidth_               0       ;# not used

Agent/Null set sport_           0
Agent/Null set dport_           0

Agent/CBR set sport_            0
Agent/CBR set dport_            0

Agent/TCPSink set sport_        0
Agent/TCPSink set dport_        0

Agent/TCP set sport_            0
Agent/TCP set dport_            0
Agent/TCP set packetSize_       512

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1

# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2*1e6
#this was the default
#Phy/WirelessPhy set Pt_ 0.2818
# This is for 100m
Phy/WirelessPhy set Pt_ 7.214e-3
# This is for 40m
#Phy/WirelessPhy set Pt_ 8.5872e-4
# This is for 250m
#Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6
Phy/WirelessPhy set L_ 1.0

# =====================================================================
# This puts in only the headers that we need.
# =====================================================================
puts "removing unecessary packet headers..."
remove-all-packet-headers
add-packet-header IP
add-packet-header Common
add-packet-header LAR
add-packet-header LL
add-packet-header Mac
add-packet-header ARP
add-packet-header Flags
add-packet-header TCP 
add-packet-header AODV 


#Create a simulator object
set ns_ [new Simulator]
$ns_ use-scheduler Heap

#Open a trace file

set nt [open lar50mobi.tr w]
$ns_ use-newtrace
$ns_ trace-all $nt

set nf [open lar50mobi.nam w]
$ns_ namtrace-all-wireless $nf $val(x) $val(y)


set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

# New API to config node:
# 1. Create channel (or multiple-channels);
# 2. Specify channel in node-config (instead of channelType);
# 3. Create nodes for simulations.

# Create channel #1
puts "creating channel..."
set chan_1_ [new $val(chan)]

#
# define how node should be created
#



#global node setting
puts "setting global node values..."
$ns_ node-config -adhocRouting $val(rp) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 #-channelType $val(chan) \
                 -channel $chan_1_ \
                 -topoInstance $topo \
                 -agentTrace OFF \
                 -routerTrace OFF \
                 -macTrace ON \
                 -movementTrace OFF \
                 -txPower $val(txPower) \
                 -rxPower $val(rxPower)

# create the nodes
puts "creating the nodes..."

# create the nodes			 
for {set i 0} {$i < $val(nn) } {incr i} {
  set node_($i) [$ns_ node]	
  $node_($i) random-motion 0           ;# disable random motion
}

#
#Define a 'finish' procedure
proc finish {} {
        global ns_ nt
        $ns_ flush-trace
        close $nt
        exit 0
}

# Load the movement file
puts "Loading the mobility file..."
source $val(sc)

#Create lar agents and attach them to the nodes
puts "creating lar agents and attaching them to nodes..."
for {set i 0} {$i < $val(nn)} {incr i} {
  set g($i) [new Agent/LAR]
  $node_($i) attach $g($i) 254

  # need to tell the lar agents about their link layers
  set ll($i) [$node_($i) set ll_(0)]
  $ns_ at 0.0 "$g($i) set-ll $ll($i)"

  # need to tell the lar agents which nodes they're on also
  $ns_ at 0.0 "$g($i) set-node $node_($i)"
}

# the format now for the lar send is
#
# "$nodeId sendData <dest ID> <size> <method>"
#
# this will be used to test in a static configuration, and will
# change once the mobility portion is figured out.
#Schedule events

puts "Scheduling the send events"
for {set k $val(dataStart)} {$k < $val(dataStop)} {set k [expr $k + 0.25] } \
{
  $ns_ at $k "$g(0) sendData 49 64 B"
  $ns_ at [expr $k + .0001] "$g(1) sendData 48 64 B"
  $ns_ at [expr $k + .0002] "$g(2) sendData 47 64 B"
  $ns_ at [expr $k + .0003] "$g(3) sendData 46 64 B"
  $ns_ at [expr $k + .0004] "$g(4) sendData 45 64 B"
  $ns_ at [expr $k + .0005] "$g(5) sendData 44 64 B"
  $ns_ at [expr $k + .0006] "$g(6) sendData 43 64 B"
  $ns_ at [expr $k + .0007] "$g(7) sendData 42 64 B"
  $ns_ at [expr $k + .0008] "$g(8) sendData 41 64 B"
  $ns_ at [expr $k + .0009] "$g(9) sendData 40 64 B"
  $ns_ at [expr $k + .0010] "$g(10) sendData 39 64 B"
  $ns_ at [expr $k + .0011] "$g(11) sendData 38 64 B"
  $ns_ at [expr $k + .0012] "$g(12) sendData 37 64 B"
  $ns_ at [expr $k + .0013] "$g(13) sendData 36 64 B"
  $ns_ at [expr $k + .0014] "$g(14) sendData 35 64 B"
  $ns_ at [expr $k + .0015] "$g(15) sendData 34 64 B"
  $ns_ at [expr $k + .0016] "$g(16) sendData 33 64 B"
  $ns_ at [expr $k + .0017] "$g(17) sendData 32 64 B"
  $ns_ at [expr $k + .0018] "$g(18) sendData 31 64 B"
  $ns_ at [expr $k + .0019] "$g(19) sendData 30 64 B"
}


# this is done to make the simulator continue running and "settle" things out
for {set i 0} {$i < $val(nn)} {incr i} {
  $ns_ at $val(signalStop) "$g($i) larDone"
}

$ns_ at $val(finish) "finish"
$ns_ at [expr $val(finish) + 0.1] "puts \"NS Exiting...\" ; $ns_ halt"


# Create some feedback for hov far we are into the simulation
for {set i 0} {$i < 100} {incr i} {
	$ns_ at [expr $i * $val(finish) / 100] "puts \" ... $i % into sim ....\""
}


#Run the simulation
puts ""
puts ""
puts "***********************************************"
puts "***********************************************"
puts "***********************************************"
puts ""
puts "Running the simulation"
puts ""
puts "***********************************************"
puts "***********************************************"
puts "***********************************************"
puts ""
puts ""
$ns_ run

