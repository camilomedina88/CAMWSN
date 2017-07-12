#*****************************************************************************#
#   File Name:  dream.tcl                                                     # 
#   Purpose: DREAM protocol for ns2 - tcl script                      # 
#   Original Author: Jeff Boleng                                              # 
#   Modified by:                                                              # 
#   Date Created: some time in 2002                                           # 
#
#   Copyright (C) 2004  Toilers Research Group -- Colorado School of Mines    #
#
#   Please see COPYRIGHT.TXT and LICENSE.TXT for copyright and license        #
#   details.
#******************************************************************************#

# This is a new style 
# ======================================================================
# Define options
# ======================================================================

set opt(chan)   Channel/WirelessChannel
set opt(prop)   Propagation/TwoRayGround
set opt(netif)  Phy/WirelessPhy
set opt(mac)    Mac/802_11
set opt(ifq)    Queue/DropTail/PriQueue
set opt(ll)             LL
set opt(ant)        Antenna/OmniAntenna
set opt(x)              300   ;# X dimension of the topography
set opt(y)              600   ;# Y dimension of the topography
set opt(ifqlen) 50            ;# max packet in ifq
set opt(seed)   0.0
set opt(tr)             brad.tr    ;# trace file
set opt(nam)            brad.nam   ;# nam trace file
set opt(tf)     "./mob.2"
set opt(mf)     "./lar2.mob"
set opt(adhocRouting)   AODV
set opt(nn)             50             ;# how many nodes are simulated
set opt(stop)           20.0            ;# simulation time

### set opt(tr)     [lindex $argv 0] ;# trace file
### set opt(mf)     [lindex $argv 1] ;# mobility  file


# =====================================================================
# DREAM options
# =====================================================================
# This is the earliest time a location packet might be sent
set locationStartTime 1.1
# Location packets will be started uniform randomly between $locationStartTime
#  and $locationStartTime + $locationStartOffset
set locationStartOffset 5

# Set the seed of the default random number generator.
#ns-random 538474442L

# This is the random variable that determines when the location
#  information will start sending.
set randomVar [new RandomVariable/Uniform]
$randomVar set min_ $locationStartTime
$randomVar set max_ [expr $locationStartTime + $locationStartOffset]

# =====================================================================
# Other default settings

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
remove-all-packet-headers
add-packet-header IP 
add-packet-header TCP 
add-packet-header Common 
add-packet-header Dream
add-packet-header AODV
add-packet-header Flags
add-packet-header LL
add-packet-header Mac

# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#

# create simulator instance

set ns_         [new Simulator]

# set wireless channel, radio-model and topography objects

#set wchan      [new $opt(chan)]
#set wprop      [new $opt(prop)]
set wtopo       [new Topography]

# create trace object for ns and nam

#set nt     [open "|awk -f ./dream2.awk > $opt(tr)" w]
set nt     [open "$opt(tr)" w]
#set nf    [open $opt(nam) w]

$ns_ use-newtrace
$ns_ trace-all $nt
#$ns_ namtrace-all-wireless $nf $opt(x) $opt(y)

# define topology
$wtopo load_flatgrid $opt(x) $opt(y)

#$wprop topography $wtopo

#
# Create God
#
set god_ [create-god $opt(nn)]


# New API to config node: 
# 1. Create channel (or multiple-channels);
# 2. Specify channel in node-config (instead of channelType);
# 3. Create nodes for simulations.

# Create channel #1
set chan_1_ [new $opt(chan)]

#
# define how node should be created
#

#global node setting

$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 #-channelType $opt(chan) \
                 -channel $chan_1_ \
                 -topoInstance $wtopo \
                 -agentTrace OFF \
                 -routerTrace OFF \
                 -macTrace ON

#
#  Create the specified number of nodes [$opt(nn)] and "attach" them
#  to the channel. 
for {set i 0} {$i < $opt(nn) } {incr i} {
  set node_($i) [$ns_ node]
  $node_($i) random-motion 0              ;# disable random motion
}

#Define a 'finish' procedure
proc finish {} {
#        global ns_ nf nt
        global ns_ nt
        $ns_ flush-trace
#        close $nf
        close $nt
#        exec nam out.nam &
        exit 0
}

#Provide initial positions for the nodes
puts "loading mobility file"
source $opt(mf)

puts "done loading mob file"

# Define node initial position in nam
for {set i 0} {$i < $opt(nn)} {incr i} {
  # 20 defines the node size in nam, must adjust it according to your scenario
  # The function must be called after mobility model is defined
  $ns_ initial_node_pos $node_($i) 20
}

# ==========================================================

#Create dream agents and attach them to the nodes
for {set i 0} {$i < $opt(nn)} {incr i} {
  set d($i) [new Agent/Dream]
  $node_($i) attach $d($i) 253

  # need to tell the geocast agents about their link layers
  set ll($i) [$node_($i) set ll_(0)]
  $ns_ at 0.0 "$d($i) set-ll $ll($i)"

  # need to tell the geocast agents which nodes they're on also
  $ns_ at 0.0 "$d($i) set-node $node_($i)"

  # This is the number of short location packets per long packet
  $ns_ at 0.0 "$d($i) set-freqOfLongLocationPackets 13"

  # This is the transmission distance of the node, so that the 
  # dream agent can make the right size circle.
  $ns_ at 0.0 "$d($i) set-neighborDistance 100"

  # This is the distance that a short location packet will travel.
  # If set to -1 the packet will travel the whole screen and if set to
  # 0 then only one packet will be sent per locaiton packet except
  # if there are two nodes in the exact same place.
  # 100 for old way
  $ns_ at 0.0 "$d($i) set-shortLocationPacketDistance 0"
  #$ns_ at 0.0 "$d($i) set-shortLocationPacketDistance 0"

  # This is the transmission distance of the long location packets
  #  this is set to -1 for and infinite transmission distance (entire net)
  $ns_ at 0.0 "$d($i) set-longLocationPacketDistance -1"

  # This is the number of seconds that location time is considered good
  $ns_ at 0.0 "$d($i) set-locationGoodTime 46"

  # This is the number of seconds that a dream agent will wait for an ack
  # packet for a data packet before it resorts to the recovery method
  $ns_ at 0.0 "$d($i) set-maxPacketTimeout 1"

  $ns_ at 0.0 "$d($i) set-bradsDreamFactor 10"

  $ns_ at 0.0 "$d($i) set-bradsDreamLongTime 23"
    
  # This is the maximum node velocity in grid units per second
  # We do not need this line if we are not using a global max node velocity.
  # Add 1 to speed of mobility file for this
  #$ns_ at 0.0 "$d($i) set-maxNodeVelocity 0"

  # This is the debug value, set to -1 for no output
  $ns_ at 0.0 "$d($i) set-debugLevel -1"
}

puts "Scheduling the location events"

# This sets the time when the location packets start being sent.
for {set i 0} {$i < $opt(nn) } {incr i} {
  set locationStart_($i) [$randomVar value]
  #puts "Location Start Time for node($i) = $locationStart_($i)"
}

for {set i 0} {$i < $opt(nn)} {incr i} {
  $ns_ at $locationStart_($i) "$d($i) startLocationService"
}

puts "Scheduling the send events"
#$ns_ at 2.5 "$d(2) sendData 10"
#$ns_ at 2.5 "$d(5) sendData 14"
#$ns_ at 2.5 "$d(8) sendData 18"

# doesn't work right away
#$ns_ at 2.5 "$d(10) sendData 2"

#$ns_ at 2.5 "$d(14) sendData 2"
source $opt(tf)

for {set i 0} {$i < $opt(nn)} {incr i} {
  $ns_ at $opt(stop) "$d($i) printLocationTable"
}

# =====================================================================

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).000000001 "$node_($i) reset";
}
# tell nam the simulation stop time
#$ns_ at  $opt(stop)     "$ns_ nam-end-wireless $opt(stop)"
$ns_ at  $opt(stop).000000001 "puts \"NS EXITING...\" ; $ns_ halt"

# Create some feedback for hov far we are into the simulation
for {set i 0} {$i < 100} {incr i} {
	$ns_ at [expr $i * $opt(stop) / 100] "puts \" ... $i % into sim ....\""
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
