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


# Script to Study Impact of CW size 
#V.B., 2005 

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
set val(nn)             25                          ;# default number of mobilenodes
set val(rp)             AODV                       ;# routing protocol
set val(sc)		"./scenario"		   ;# scenario file
set val(x)		150.0			   ;
set val(y)		150.0			   ;
set val(simtime)	25.0			   ; #sim time
set val(rlen)		5			   ;
# ======================================================================
# Main Program
# ======================================================================



if { $argc != 2 } {
        puts "Wrong no. of cmdline args."
	puts "Usage: ns cwsim.tcl -rlen <rlen>"
        exit 0
}


proc getopt {argc argv} {
        global val
        lappend optlist rlen
 
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
                set name [string range $arg 1 end]
                set val($name) [lindex $argv [expr $i+1]]
        }

	set val(nn) [expr $val(rlen) * $val(rlen)]	
         
}


 

getopt $argc $argv
#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open cwsim.tr w]
$ns_ trace-all $tracefd

set namtrace [open cwsim.nam w]           ;# for nam tracing
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
$ns_ use-newtrace

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#

set god_ [ create-god $val(nn) ]



$val(mac) set bandwidth_ 22.0e6 
$val(mac) set CWMin_ 31
$val(mac) set CWMax_ 31

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 

# configure node


        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace OFF \
			 -macTrace ON \
			 -movementTrace OFF



	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}




#
# Provide initial (X,Y, Z=0) co-ordinates for mobilenodes
#


	set gridspace [expr 150.0 / $val(rlen)]
	

	for {set i 0} {$i < $val(rlen) } {incr i} {
		for {set j 0} {$j < $val(rlen) } {incr j} {
			set a [expr $j + [expr $i * $val(rlen)]]
			$node_($a) set X_ [expr  0.0 + [ expr $i * $gridspace]]
			$node_($a) set Y_ [expr  0.0 + [ expr $j * $gridspace]]
			$node_($i) set Z_ 0.0
		}
	}



# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20



		set udp_($i) [new Agent/UDP]
		$ns_ attach-agent $node_($i) $udp_($i)
				
		set cbr_($i) [new Application/Traffic/CBR]
		$cbr_($i) set packetSize_ 512
		$udp_($i) set packetSize_ 512 
		$cbr_($i) set interval_ 0.01 
		$cbr_($i) set random_ 0.348 
		$cbr_($i) set maxpkts_ 1000000
		$cbr_($i) attach-agent $udp_($i)

		set null_($i) [new Agent/Null]
		$ns_ attach-agent $node_($i) $null_($i)


}

	
#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
		
		
    set dst [expr [expr $i + $val(rlen)] % $val(nn)] 
    $ns_ connect $udp_($i) $null_($dst)
    $ns_ at [expr 0.01 * $i] "$cbr_($i) start"
    $ns_ at $val(simtime) "$node_($i) reset";
}
$ns_ at $val(simtime) "stop"
$ns_ at $val(simtime).01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run

