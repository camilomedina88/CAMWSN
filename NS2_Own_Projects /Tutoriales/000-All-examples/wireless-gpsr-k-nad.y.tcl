# Posts #1 and #3   http://www.linuxquestions.org/questions/linux-software-2/problem-ns2-wireless-moving-nodes-4175524759/


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
# $Header: /home/cvs/repository/kliu/ns2/gpsr/wireless-gpsr.tcl,v 1.8 2005/12/01 00:03:17 kliu Exp $
#
# Ported from CMU/Monarch's code, nov'98 -Padma.

# ======================================================================
# Default Script Options
# ======================================================================
set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
set opt(mac)		Mac/802_15_4
set opt(ifq)		Queue/DropTail/PriQueue	;# for dsdv
set opt(ll)		LL
set opt(ant)            Antenna/OmniAntenna

set opt(x)		500		;# X dimension of the topography
set opt(y)		1000		;# Y dimension of the topography
set opt(cp)		"./cbr100"
set opt(sc)		"./nn200"

set opt(ifqlen)		50		;# max packet in ifq
set opt(nn)		20		;# number of nodes
set opt(seed)		0.0
set opt(stop)		200.0		;# simulation time
set opt(tr)		trace_Scn3.tr		;# trace file
set opt(nam)            nam.Scn3.tr
set opt(rp)             gpsr		;# routing protocol script (dsr or dsdv)
set opt(lm)             "off"		;# log movement

# ======================================================================

LL set mindelay_		50us
LL set delay_			25us
LL set bandwidth_		0	;# not used

Agent/Null set sport_		0
Agent/Null set dport_		0

Agent/CBR set sport_		0
Agent/CBR set dport_		0

Agent/TCPSink set sport_	0
Agent/TCPSink set dport_	0

Agent/TCP set sport_		0
Agent/TCP set dport_		0
Agent/TCP set packetSize_	1460

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
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0


# The transimssion radio range 
#Phy/WirelessPhy set Pt_ 6.9872e-4    ;# ?m
#Phy/WirelessPhy set Pt_ 8.5872e-4    ;# 40m  **comment it
#Phy/WirelessPhy set Pt_ 1.33826e-3   ;# 50m
#Phy/WirelessPhy set Pt_ 7.214e-3     ;# 100m
Phy/WirelessPhy set Pt_ 0.2818       ;# 250m   **uncomment this line to change radio range to 250m
# ======================================================================

# Agent/GPSR setting
Agent/GPSR set planar_type_  1   ;#1=GG planarize, 0=RNG planarize
Agent/GPSR set hello_period_   1.0 ;#Hello message period **reduce the time tinterval to 1.0s

# ======================================================================

proc usage { argv0 }  {
	puts "Usage: $argv0"
	puts "\tmandatory arguments:"
	puts "\t\t\[-x MAXX\] \[-y MAXY\]"
	puts "\toptional arguments:"
	puts "\t\t\[-cp conn pattern\] \[-sc scenario\] \[-nn nodes\]"
	puts "\t\t\[-seed seed\] \[-stop sec\] \[-tr tracefile\]\n"
}


proc getopt {argc argv} {
	global opt
	lappend optlist cp nn seed sc stop tr x y

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		if {[string range $arg 0 0] != "-"} continue

		set name [string range $arg 1 end]
		set opt($name) [lindex $argv [expr $i+1]]
	}
}


#proc cmu-trace { ttype atype node } {
#	global ns_ tracefd
#
#        puts ABC
#	if { $tracefd == "" } {
#		return ""
#	}
#	puts BCD
#	set T [new CMUTrace/$ttype $atype]
#	$T target [$ns_ set nullAgent_]
#	$T attach $tracefd
#        $T set src_ [$node id]
#	
#        $T node $node
#
#	return $T
#}




proc log-movement {} {
    global logtimer ns_ ns

    set ns $ns_
    source ../tcl/mobility/timer.tcl
    Class LogTimer -superclass Timer
    LogTimer instproc timeout {} {
	global opt node_;
	for {set i 0} {$i < $opt(nn)} {incr i} {
	    $node_($i) log-movement
	}
	$self sched 0.1
    }

    set logtimer [new LogTimer]
    $logtimer sched 0.1
}

# ======================================================================
# Main Program
# ======================================================================
#
# Source External TCL Scripts
#
#source ../lib/ns-mobilenode.tcl

#if { $opt(rp) != "" } {
	#source ../mobility/$opt(rp).tcl
	#} elseif { [catch { set env(NS_PROTO_SCRIPT) } ] == 1 } {
	#puts "\nenvironment variable NS_PROTO_SCRIPT not set!\n"
	#exit
#} else {
	#puts "\n*** using script $env(NS_PROTO_SCRIPT)\n\n";
        #source $env(NS_PROTO_SCRIPT)
#}
#source ../tcl/lib/ns-cmutrace.tcl
source ../tcl/lib/ns-bsnode.tcl
source ../tcl/mobility/com.tcl

# do the get opt again incase the routing protocol file added some more
# options to look for
getopt $argc $argv

if { $opt(x) == 0 || $opt(y) == 0 } {
	usage $argv0
	exit 1
}

if {$opt(seed) > 0} {
	puts "Seeding Random number generator with $opt(seed)\n"
	ns-random $opt(seed)
}

#
# Initialize Global Variables
#
set ns_		[new Simulator]
set chan	[new $opt(chan)]
set prop	[new $opt(prop)]
set topo	[new Topography]

set tracefd   [open $opt(tr) w]
$ns_ trace-all  $tracefd

set namfile [open $opt(nam) w]
#$ns_ namtrace-all $namfile
$ns_ namtrace-all-wireless $namfile $opt(x) $opt(y)

$topo load_flatgrid $opt(x) $opt(y)

$prop topography $topo

#
# Create God
#
set god_ [create-god $opt(nn)]


#
#  Create the specified number of nodes $opt(nn) and "attach" them
#  the channel.
#  Each routing protocol script is expected to have defined a proc
#  create-mobile-node that builds a mobile node and inserts it into the
#  array global $node_($i)
#

$ns_ node-config -adhocRouting gpsr \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 #-channelType $opt(chan) \
                 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace OFF \
		 -channel $opt(chan)

source ./gpsr.tcl

#for {set i 0} {$i < $opt(nn) } {incr i} {
#    gpsr-create-mobile-node $i
#}
#replace above func with this one
for {set i 0} {$i < $opt(nn) } {incr i} {
    gpsr-create-mobile-node $i
    $node_($i) namattach $namfile
}


#
# Source the Connection and Movement scripts
#
if { $opt(cp) == "" } {
	puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
	puts "Loading connection pattern..."
	source $opt(cp)
}




#
# Tell all the nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).000000001 "$node_($i) reset";
}
$ns_ at $opt(stop).00000001 "puts \"NS EXITING...\" ; $ns_ halt"


if { $opt(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
	puts "Loading scenario file..."
	source $opt(sc)
#new loop by NAD
        for {set i 0} {$i < $opt(nn) } {incr i} {
             $ns_ initial_node_pos $node_($i) 10
        } 
	puts "Load complete..."
}

puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp $opt(rp)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."

proc finish {} {
    global ns_ tracefd namfile
    $ns_ flush-trace
    close $tracefd
    close $namfile
    exit 0
}

$ns_ at $opt(stop) "finish"

$ns_ run
