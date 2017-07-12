#    http://www.linuxquestions.org/questions/showthread.php?p=5298944#post5298944
 

# Copyright (c) 1999 Regents of the University of Southern California.
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
# wireless1.tcl
# A simple example for wireless simulation

# ======================================================================
# Define options
# ======================================================================

set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL
set val(ant)        Antenna/OmniAntenna
set val(x)              800   ;# X dimension of the topography
set val(y)              800   ;# Y dimension of the topography
set val(ifqlen)         50            ;# max packet in ifq
set val(seed)           1.0
set val(adhocRouting)   Antnet
set val(adhocRouting2)  blackholeAODV
#set val(adhocRouting3)  grayholeAODV
#set val(adhocRouting4)   secAODV
set val(nn)             10            ;# how many nodes are simulated
set val(cp)             "10cbrgen"
set val(sc)             "10setdest1"
set val(stop)           50.0           ;# simulation time

# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

# create simulator instance

set ns_		[new Simulator]

# setup topography object

set topo	[new Topography]

# create trace object for ns and nam

set tracefd	[open 10a_1.tr w]
set namtrace    [open 10a_1.nam w]

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# define topology
$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
set god_ [create-god $val(nn)]

#
# define how node should be created
#

#global node setting

$ns_ node-config -adhocRouting $val(adhocRouting) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -channelType $val(chan) \
		 -topoInstance $topo \
#		 -energyModel EnergyModel \
#		 -initialEnergy 100.0 \
#		 -rxPower 0.3 \
#		 -txPower 0.6 \
		 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace OFF

#
#  Create the specified number of nodes [$val(nn)] and "attach" them
#  to the channel. 
proc finish {} {
        exec nam -r 5m 10a_1.nam &
	exit 0
}

$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(0) [$ns_ node]

$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(1) [$ns_ node]

$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(2) [$ns_ node]

$ns_ node-config -adhocRouting $val(adhocRouting)
#$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(3) [$ns_ node]
#$ns_ at 0.01 "$node_(3) label \"Grayhole node\""

#$ns_ node-config -adhocRouting grayholeAODV
$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(4) [$ns_ node]

$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(5) [$ns_ node]

$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(6) [$ns_ node]

$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(7) [$ns_ node]

$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(8) [$ns_ node]

$ns_ node-config -adhocRouting $val(adhocRouting)
set node_(9) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(10) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(11) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(12) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(13) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(14) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(15) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(16) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(17) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(18) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(19) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(20) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(21) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(22) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(23) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(24) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(25) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(26) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(27) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(28) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#set node_(29) [$ns_ node]

#$ns_ node-config -adhocRouting $val(adhocRouting)
#for {set i 0} {$i < [expr $val(nn) - 1] } {incr i} {
#	set node_($i) [$ns_ node]	
#	$node_($i) random-motion 0		;# disable random motion
#}

#$ns_ node-config -adhocRouting grayholeAODV
#set node_($val(nn)) [$ns_ node]

# 
# Define node movement model
#
puts "Loading connection pattern..."
source $val(cp)

# 
# Define traffic model
#
puts "Loading scenario file..."
source $val(sc)

# Define node initial position in nam

for {set i 0} {$i < $val(nn) } {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 30
}


#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

#$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $val(stop).0002 "finish"

puts $tracefd "M 0.0 nn $val(nn) x $val(x) y $val(y) rp $val(adhocRouting)"
puts $tracefd "M 0.0 sc $val(sc) cp $val(cp) seed $val(seed)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"

puts "Starting Simulation..."
$ns_ run



