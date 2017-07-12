# Copyright (c) 2009 Regents of the SIGNET lab, University of Padova and DOCOMO Communications Laboratories Europe GmbH.
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
 # 3. Neither the name of the University of Padova (SIGNET lab) nor the 
 #    names of its contributors may be used to endorse or promote products 
 #    derived from this software without specific prior written permission.
 #
 # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 # "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
 # TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
 # PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
 # CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
 # PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
 # OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 # WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
 # OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 # ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11               ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(rp)             NCR                        ;# routing protocol
set val(nn)             100                        ;# number of mobilenodes
set val(x)		1250
set val(y)		1250
set val(stop_sim)	100
set val(print)		80
set val(flooding)	0
set val(probabilistic_nc) 1
set val(force_first)	1
set val(send_count)	1
set val(statistics)	1
set val(gen_mngt)	5
set val(pseudo)         1
set val(sc)		1
set val(dist)		250
set data_size 		8
set data_rate		12Kb
set step		0.004
set BROADCAST		-1


# Setting input arguments
if {[llength $argv]>0} {
	set val(send_count) [lindex $argv 0]; # it si an integer
}
if {[llength $argv]>1} {
	set val(sc) [lindex $argv 1]; # it si an integer
}
if {[llength $argv]>2} {
	set val(nn) [lindex $argv 2];  # Number of nodes
}
if {[llength $argv]>3} {
	set val(dist) [lindex $argv 3];  # Number of nodes
}
#if {[llength $argv]>3} {
#	set val(x) [lindex $argv 3]; # x size
#}
#if {[llength $argv]>4} {
#	set val(y) [lindex $argv 4]; # y size
#}
#if {[llength $argv]>5} {
#	set val(probabilistic_routing) [lindex $argv 5];  # Probabilistic routing 0-no, 1-yes
#}
#if {[llength $argv]>6} {
#	set val(force_first) [lindex $argv 6]; # Force first: 0-no, 1-yes
#}
#if {[llength $argv]>7} {
#	set val(statistics) [lindex $argv 7]; # set to 1 to collect statistic
#}
#if {[llength $argv]>8} {
#	set val(gen_mngt) [lindex $argv 8]; # an integer
#}


# NCR parameters
Agent/NCR set probabilistic_nc $val(probabilistic_nc)
Agent/NCR set force_first $val(force_first)
Agent/NCR set send_count $val(send_count)
Agent/NCR set statistics $val(statistics)
Agent/NCR set generation_management $val(gen_mngt)
Agent/NCR set flooding $val(flooding)
Agent/NCR set pseudo $val(pseudo)
Agent/NCR set scenario $val(sc)
Agent/NCR set topology 1
Agent/NCR set topo_dimension [expr sqrt($val(nn))]
Mac/802_11 set send_count $val(send_count)
Mac/802_11 set flooding $val(flooding)
Mac/802_11 set RTSThreshold_ 0

# ======================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#
set ns_		[new Simulator]
#set tracefd     [open ./Traces/SquareNet_$val(nn)_$val(dist)_$val(send_count)_$val(sc).tr w]
set tracefd     [open ./Traces/out.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]

#$topo load_flatgrid $val(x) $val(y)

# ------------
# Create God
# -----------
create-god $val(nn)


# ------------
# Configure the nodes
# -----------

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
			 -agentTrace OFF \
			 -routerTrace OFF \
			 -macTrace OFF \
			 -movementTrace OFF			

puts "...Create nodes..."
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}

puts "..OK!"

# -----------------
# TOPOLOGY
# -----------------

puts "... Create topology..."

source "./Network_topology/GridNetwork/gridNet_$val(nn)_$val(dist).tcl"

puts "...OK!"

# -------------------
# TRAFFIC
# -------------------

puts "...Create traffic..."

# All sources

   for {set i 0} {$i < $val(nn)} {incr i} {   

	set udp_($i) [new Agent/UDP]
	$ns_ attach-agent $node_($i) $udp_($i)

	set cbr_($i) [new Application/Traffic/CBR]
   	$cbr_($i) set rate_ $data_rate
   	$cbr_($i) set packetSize_ $data_size
   	$cbr_($i) attach-agent $udp_($i)
	
	set null_($i) [new Agent/Null]
   	$ns_ attach-agent $node_($i) $null_($i)	
   }

   #for {set i 0} {$i < $val(nn)} {incr i} {   
	#for {set k 0} {$k < $val(nn)} {incr k} {
		$ns_ connect $udp_(0) $null_([expr $val(nn) -1])
	#}
   #}

set rng1 [new RNG]
$rng1 seed 13113

set e [new RandomVariable/Uniform]
$e use-rng $rng1
#$e set avg_ 1; #sec 
set start 2


for {set i 0} {$i < [expr $val(sc)*10 - $val(sc)]} {incr i} {
	set tmp [$e value]
}
    
   for {set i 0} {$i < $val(nn)} {incr i} {
	#set start_my [expr $start + [$e value]]
	set start_my [expr $start + [$e value]*0.1]
	set stop_my [expr $start_my + $step]
    	$ns_ at $start_my "$cbr_($i) start"
    	$ns_ at $stop_my "$cbr_($i) stop"
   }	

puts "...OK!"	

#-----------

# Print statistics

# ---------


for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(print) "$node_($i) print_stat";
}


#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop_sim) "$node_($i) reset";
}
$ns_ at $val(stop_sim) "stop"
$ns_ at [expr $val(stop_sim) + 1] "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run

