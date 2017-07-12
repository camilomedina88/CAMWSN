# Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# simple-wireless.tcl
# A simple example for wireless simulation

# ======================================================================
# Define options
# ======================================================================

set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         500                        ;# max packet in ifq
set val(nn)             3                          ;# number of mobilenodes
set val(rp)             AODV                       ;# routing protocol


# routing: 0 # XCHARM
# routing: 1 # AODV-MR


# ======================================================================
# Main Program
# ======================================================================


#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open simple.tr w]
$ns_ trace-all $tracefd

#set namtrace    [open $val(seed)".nam" w]
#$ns_ namtrace-all-wireless $namtrace 1000 1000


# set up topography object
set topo       [new Topography]

$topo load_flatgrid 1000 1000


#create PUMap
set pumap [new PUMap]

set smap [new SpectrumMap]

set repository [new CrossLayerRepository]

$pumap set_input_map "map.txt"
$smap set_input_map "channel.txt"

#
# Create God
#
create-god $val(nn)

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

#create channels
set chan_0_ [new $val(chan)]
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]
set chan_3_ [new $val(chan)]
set chan_4_ [new $val(chan)]
set chan_5_ [new $val(chan)]
set chan_6_ [new $val(chan)]
set chan_7_ [new $val(chan)]
set chan_8_ [new $val(chan)]
set chan_9_ [new $val(chan)]
set chan_10_ [new $val(chan)]






# configure node

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace OFF \
			 -macTrace ON \
			 -movementTrace OFF			

	$ns_ node-config -channel $chan_0_\
		         -channel2 $chan_1_\
			 -channel3 $chan_2_\
			 -channel4 $chan_3_\
			 -channel5 $chan_4_\
  			 -channel6 $chan_5_\
			 -channel7 $chan_6_\
			 -channel8 $chan_7_\
			 -channel9 $chan_8_\
  			 -channel10 $chan_9_\
		 	 -channel11 $chan_10_\

			 # Add Here more channels 


			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
    		$node_($i) node-CR-configure $pumap $repository $smap

	}



# set transmissionn range

#Phy/WirelessPhy set RXThresh_ 3.652e-10        ;# transmission range of 175 m
#Phy/WirelessPhy set CSThresh_ 3.652e-10        ;# transmission range of 175 m






ns-random 1

$node_(0) set X_ 100
$node_(0) set Y_ 100
$node_(0) set Z_ 0.0

$node_(1) set X_ 200
$node_(1) set Y_ 200
$node_(1) set Z_ 0.0

$node_(2) set X_ 90
$node_(2) set Y_ 90
$node_(2) set Z_ 0.0

set udp_(0) [new Agent/UDP]
set sink_(0) [new Agent/Null]
$ns_ attach-agent $node_(0) $udp_(0)
$ns_ attach-agent $node_(1) $sink_(0)
$ns_ connect $udp_(0) $sink_(0)
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 1000
$cbr_(0) set rate_ 100000
$cbr_(0) attach-agent $udp_(0)
$ns_ at 0.0 "$cbr_(0) start" 

set udp_(1) [new Agent/UDP]
set sink_(1) [new Agent/Null]
$ns_ attach-agent $node_(0) $udp_(1)
$ns_ attach-agent $node_(2) $sink_(1)
$ns_ connect $udp_(1) $sink_(1)
set cbr_(1) [new Application/Traffic/CBR]
$cbr_(1) set packetSize_ 1000
$cbr_(1) set rate_ 100000
$cbr_(1) attach-agent $udp_(1)
$ns_ at 3.0 "$cbr_(1) start" 




for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined

    $ns_ initial_node_pos $node_($i) 20
}


#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 200.0 "$node_($i) reset";
}

$ns_ at 200.0 "stop"
$ns_ at 200.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run

