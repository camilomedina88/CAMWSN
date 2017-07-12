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
# wirelessmulticast.tcl
# A simple example for wireless simulation within AgentJ - taken from NRLOLSR's
# simple-working.tcl example


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
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             10                          ;# number of mobilenodes
set val(rp)             ProtolibMK                 ;# routing protocol
set val(x)	600
set val(y)	500


puts "this is a mobile network test program"
# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

set ns_		[new Simulator]
set tracefd     [open wirelessmulticast.tr w]
$ns_ trace-all $tracefd


#
set namtrace [open wirelessmulticast.nam w]

$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

$ns_ color 0 red
$ns_ color 1 blue

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
create-god $val(nn)

# configure node
set chan_1_ [new $val(chan)]

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel $chan_1_ \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace ON

	for {set i 0} {$i < $val(nn) } {incr i} {
	        set node_($i) [$ns_ node]
		$node_($i) random-motion 1
				;# enable random motion
	}
	for {set i 0} {$i < $val(nn) } {incr i} {
		$ns_ initial_node_pos $node_($i) 25		;# disable random motion
	}
if {$val(rp) == "ProtolibMK"} {
    for {set i 0} {$i < $val(nn) } {incr i} {
	set p($i) [new Agent/NrlolsrAgent]
	$ns_ attach-agent $node_($i) $p($i)
	$ns_ at 0.0 "$p($i) startup -tcj 0 -hj 0 -tci 4.2 -hi 1.0 -d 8 -l /tmp/olsr.log"
	[$node_($i) set ragent_] attach-manet $p($i)
	$p($i) attach-protolibmk [$node_($i) set ragent_]

#flooding command is turns on flooding of all broadcast packets
#based upon port settings.  off is the default option.
#"off", "simple", "ns-mpr" (non source specific), and "s-mpr" (source specific)
#are valid options.  See mcastForward in nrlolsrAgent to see what they do
	$p($i) -flooding s-mpr
    }
}

#puts [$ns_ info vars]

source wirelessmotionfile.tcl

set totaltime 600.0
set runtime $totaltime

$ns_ at 0.0

proc ranstart { first last } {
	global agentstart
	set interval [expr $last - $first]
	set maxrval [expr pow(2,31)]
	set intrval [expr $interval/$maxrval]
	set agentstart [expr ([ns-random] * $intrval) + $first]
}


#ns-random 0 # seed the thing heuristically

set p1 [new Agent/Agentj]
$ns_ attach-agent $node_(0) $p1

set p2 [new Agent/Agentj]
$ns_ attach-agent $node_(1) $p2

puts "CREATED OK          ....... ..."

# Initialize C++ agents

puts "In script: Initializing  ..."

$ns_ at 10.0 "$p1 startup"
$ns_ at 10.0 "$p2 startup"

#set up the class

$ns_ at 10.0 "$p1 attach-agentj agentj.examples.udp.SimpleMulticast"
$ns_ at 10.0 "$p2 attach-agentj agentj.examples.udp.SimpleMulticast"

$ns_ at 10.0 "$p1 agentj enable-wireless-multicast"

puts "Starting simulation ..."

$ns_ at 20.0 "$p1 agentj init"
$ns_ at 20.0 "$p2 agentj init"

$ns_ at 100.0 "$p1 agentj receive"
$ns_ at 100.0 "$p2 agentj receive"

$ns_ at 150.0 "$p1 agentj send"

$ns_ at 200.0 "$p1 agentj receive-unicast"

$ns_ at 250.0 "$p2 agentj send-unicast 0"


#Tell nodes when the simulation ends
#
for {set i 1 } {$i < $val(nn) } {incr i} {
    $ns_ at $runtime "$node_($i) reset";
}

$ns_ at $runtime "$p1 shutdown"
$ns_ at $runtime "$p2 shutdown"

$ns_ at $runtime "stop $ns_"

proc stop {ns_} {
        puts "Agentj multicast manet tcl file ran correctly"
        global tracefd namtrace runtime
        $ns_ flush-trace
        close $tracefd
        close $namtrace
        exit 0
    }

puts "Starting Simulation..."

$ns_ run

