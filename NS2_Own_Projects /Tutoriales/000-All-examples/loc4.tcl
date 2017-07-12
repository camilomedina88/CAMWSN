#####################################################################################
 #	Copyright (c) 2012 CSIR.
 #	All rights reserved.
 #
 #	Redistribution and use in source and binary forms, with or without
 #	modification, are permitted provided that the following conditions
 #	are met:
 #		1. Redistributions of source code must retain the above copyright
 #			notice, this list of conditions and the following disclaimer.
 #		2. Redistributions in binary form must reproduce the above copyright
 #			notice, this list of conditions and the following disclaimer in the
 #			documentation and/or other materials provided with the distribution.
 #		3. All advertising materials mentioning features or use of this software
 #			must display the following acknowledgement:
 #
 #				This product includes software developed by the Advanced Sensor
 #				Networks Group at CSIR Meraka Institute.
 #
 #		4. Neither the name of the CSIR nor of the Meraka Institute may be used
 #			to endorse or promote products derived from this software without
 #			specific prior written permission.
 #
 #	THIS SOFTWARE IS PROVIDED BY CSIR MERAKA INSTITUTE ``AS IS'' AND
 #	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 #	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 #	ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 #	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 #	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 #	OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 #	HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 #	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 #	OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 #	SUCH DAMAGE.
 ####################################################################################
 #
 #		File: loc4.tcl	
 #
 #		Author: Adnan Abu-Mahfouz
 #
 #		Date: March 2012
 #
 #		Description: Example for localisation system in WSN
 # 					 There are 3 beacon nodes (which know their location) and 16 
 #						 unknown nodes (which do not know their location)
 #						 The nodes are distributed randomly
 #						 Consider the distance measurment error
 #
 #		Usage: ns loc4.tcl SEED METHOD
 #				 SEED: is the seed value used by RNG (0, 1, 2,...)
 #				 METHOD: is representing the localisation method that will be used in
 #				 the estimation, an integer value of 1,2 or 3 can be used to consider
 #				 one of the following localisation methods: general(1), nearest3(2),
 #				 refine(3)
  ####################################################################################

if {$argc != 2} {
	puts stderr "ERROR! Command syntax: ns loc4.tcl SEED METHOD   (SEED = 0, 1, 2, ...   METHOD = 1, 2 or 3)"
	exit 1
	} else {
		set val(seed) [lindex $argv 0]
		set val(method) [lindex $argv 1]
		}

# A simple example for wireless simulation

# =================================================================================
# Define options
# =================================================================================

set val(chan)		Channel/WirelessChannel		;# channel type
set val(prop)		Propagation/FreeSpace		;# radio-propagation model
set val(netif)		Phy/WirelessPhy				;# network interface type
set val(mac)		Mac/Simple						;# MAC type
set val(ifq)		Queue/DropTail/PriQueue		;# interface queue type
set val(ll)			LL									;# link layer type
set val(ant)		Antenna/OmniAntenna			;# antenna model
set val(ifqlen)	50									;# max packet in ifq
set val(nn)			19									;# number of mobilenodes
set val(nu)			16									;# number of unknown nodes
set val(nb)			3									;# number of beacon nodes
set val(rp)			AODV								;# routing protocol
set val(x)			50									;# X dimension of the topography
set val(y)			50									;# Y dimension of the topography
set val(stop)		200.0								;# stop time
set val(attr)		UNKNOWN							;# node attribute
set val(p_tx)		0.281838							;# transmitting power in watts
set val(p_rx)		0.281838							;# receiving power in watts
set val(p_idel)	0.0								;# idle power
set val(e_mod)		EnergyModel						;# energy model
set val(e_init)	2.0								;# initial energy in Joules
set val(th_rx)		7.69113e-08						;# receive sensitivity threshold
set val(th_cx)		5.3352e-6						;# carrier sense threshold
set val(g_tx)		1									;# transmitter antenna gain
set val(g_rx)		1									;# receiver antenna gain
set val(u_inc)		50									;# unknown region width
set val(b_inc)		50									;# beacon region width

# ================================================================================
# Main Program
# ================================================================================

# Initialize Global Variables

set ns_		[new Simulator]

set tracefd     [open location.tr w]
$ns_ trace-all $tracefd

set namtrace	[open simwrls.nam w]
$ns_ namtrace-all-wireless $namtrace  $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

# Create God
create-god $val(nn)

# Create channel #1
set chan_1_ [new $val(chan)]

# configure netif
$val(netif) set RXThresh_ $val(th_rx)
$val(netif) set CXThresh_ $val(th_cx)
$val(netif) set Gt_ $val(g_tx)
$val(netif) set Gr_ $val(g_rx)

# configure node
$ns_ node-config	-adhocRouting $val(rp) \
						-llType $val(ll) \
						-macType $val(mac) \
						-ifqType $val(ifq) \
						-ifqLen $val(ifqlen) \
						-antType $val(ant) \
						-propType $val(prop) \
						-phyType $val(netif) \
						-attribute $val(attr) \
						-channel $chan_1_ \
						-topoInstance $topo \
						-energyModel $val(e_mod) \
						-rxPower	$val(p_rx) \
						-txPower	$val(p_tx) \
						-initialEnergy $val(e_init) \
						-agentTrace OFF \
						-routerTrace OFF \
						-macTrace OFF \
						-movementTrace OFF

# unknown nodes						
for {set i 0} {$i < $val(nu)} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) color white
}

# beacon nodes
set val(attr)		BEACON

$ns_ node-config -attribute $val(attr)

for {set i $val(nu)} {$i < $val(nn)} {incr i} {
	set node_($i) [$ns_ node]
		$node_($i) color blue
}

# disable random motion
for {set i 0} {$i < $val(nn) } {incr i} {
	$node_($i) random-motion 0
}

# Provide random initial position:
set Rng1 [new RNG]
$Rng1 seed $val(seed)

set Rexp [new RandomVariable/Uniform]
$Rexp use-rng $Rng1
$Rexp set min_ 0.0
set n 0

# unknown nodes
set row [expr $val(y) / $val(u_inc)]
set column [expr $val(x) / $val(u_inc)]
set sub_nodes [expr $val(nu) / ($row * $column)]
$Rexp set max_ $val(u_inc)

for {set i 0} {$i < $row} {incr i} {
	for {set j 0} {$j < $column} {incr j} {
		for {set k 0} {$k < $sub_nodes} {incr k} {
			$node_($n) set X_ [expr $j * $val(u_inc) + [$Rexp value]]
			$node_($n) set Y_ [expr $i * $val(u_inc) + [$Rexp value]]
			incr n
		}
	}
}

# beacon nodes
set row [expr $val(y) / $val(b_inc)]
set column [expr $val(x) / $val(b_inc)]
set sub_nodes [expr $val(nb) / ($row * $column)]
$Rexp set max_ $val(b_inc)

for {set i 0} {$i < $row} {incr i} {
	for {set j 0} {$j < $column} {incr j} {
		set arrayX(0) [expr $j * $val(b_inc) + [$Rexp value]]
		set arrayY(0) [expr $i * $val(b_inc) + [$Rexp value]]
		$node_($n) set X_ $arrayX(0)
		$node_($n) set Y_ $arrayY(0)
		incr n
		set k 1
		while {$k < $sub_nodes} {
			set rx [$Rexp value]
			set ry [$Rexp value]
			set reject 0
			for {set l 0} {$l < $k} {incr l} {
				if { [expr abs($arrayX($l) - $rx)] < 5} {
					if { [expr abs($arrayY($l) - $ry)] < 5} {
						set reject 1
						break
					}
				}
			}
			if {$reject == 1} {
				continue
			}

			set arrayX($k) [expr $j * $val(b_inc) + $rx]
			set arrayY($k) [expr $i * $val(b_inc) + $ry]
			$node_($n) set X_ $arrayX($k)
			$node_($n) set Y_ $arrayY($k)
			incr k
			incr n
		}
	}
}
				
# unknown nodes have both request and response agent						
for {set i 0} {$i < $val(nu)} {incr i} {
	#Setup the request agent
	set lreq_($i) [new Agent/LocReq]
	$ns_ attach-agent $node_($i) $lreq_($i)

	#Setup the response agent
	set lres_($i) [new Agent/LocRes]
	$ns_ attach-agent $node_($i) $lres_($i)
	
	#Setup the location discovery application
	set ldis_($i) [new Application/LocDiscovery]
	$ldis_($i) attach-agent $lreq_($i)
	$ldis_($i) attach-agent $lres_($i)
}

# beacon nodes have only response agent
for {set i $val(nu)} {$i < $val(nn)} {incr i} {
	#Setup the response agent
	set lres_($i) [new Agent/LocRes]
	$ns_ attach-agent $node_($i) $lres_($i)
	
	#Setup the location discovery application
	set ldis_($i) [new Application/LocDiscovery]
	$ldis_($i) attach-agent $lres_($i)	
}

# start the locdis applications
for {set i 0} {$i < $val(nn)} {incr i} {
	$ldis_($i) set random_ 1
	$ldis_($i) set method_ $val(method)
	# to consider the distance measurment error set "distanceError_" to 1	
	$ldis_($i) set distanceError_ 1
   $ns_ at 0.0 "$ldis_($i) start"
}

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 3
}

# Tell nodes when the simulation end
for {set i 0} {$i < $val(nn) } {incr i} {
	$ns_ at $val(stop) "$node_($i) reset";
}

$ns_ at $val(stop) "stop"

$ns_ at [expr $val(stop) + 0.01] "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
	global ns_ tracefd namtrace val
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	$ns_ at $val(stop) "$ns_ nam-end-wireless $val(stop)"
	exec nam simwrls.nam &	
	exit 0
}

puts "Starting Simulation..."

$ns_ run
