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
# Modified for new node structure

# ======================================================================
# Define options
# ======================================================================
set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
set opt(mac)		Mac/802_11
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)		LL
set opt(ant)            Antenna/OmniAntenna

#set opt(x)		670	;# X dimension of the topography
#set opt(y)		670		;# Y dimension of the topography
#set opt(cp)		"mobility/scene/cbr-50-10-4-512"
#set opt(sc)		"mobility/scene/scen-670x670-50-600-20-0"

set opt(ifqlen)		50		;# max packet in ifq
set opt(nn)		57		;# number of nodes
set opt(seed)		0.0
set opt(stop)		50000.0		;# simulation time
set opt(tr)		wy.tr	;# trace file
set opt(rp)             PEGASIS            ;# routing protocol script
set opt(lm)             "off"           ;# log movement
#set opt(agent)          Agent/DSDV
set opt(energymodel)    EnergyModel     ;
set opt(initialenergy)  10j               ;# Initial energy in Joules
#set opt(logenergy)      "on"           ;# log energy every 150 seconds
set pi         3.141592653589

# ======================================================================
# needs to be fixed later
set AgentTrace			ON
set RouterTrace			ON
set MacTrace			OFF

LL set mindelay_		50us
LL set delay_			25us
LL set bandwidth_		0	;# not used

Agent/Null set sport_		0
Agent/Null set dport_		0

Agent/CBR set sport_		0
Agent/CBR set dport_		0


Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1



# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
Phy/WirelessPhy set CPThresh_ 10.0
Phy/WirelessPhy set CSThresh_ 1.559e-11
Phy/WirelessPhy set RXThresh_ 3.652e-10
Phy/WirelessPhy set Rb_ 2*1e6
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0

# ======================================================================

proc usage { argv0 }  {
	puts "Usage: $argv0"
	puts "\tmandatory arguments:"
	puts "\t\t\[-x MAXX\] \[-y MAXY\]"
	puts "\toptional arguments:"
	puts "\t\t\[-cp conn pattern\] \[-sc scenario\] \[-nn nodes\]"
	puts "\t\t\[-seed seed\] $ns_ trace-all $tracefd\[-stop sec\] \[-tr tracefile\]\n"
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

# ======================================================================
# Main Program
# ======================================================================
#getopt $argc $argv

#source ../lib/ns-bsnode.tcl
#source ../mobility/com.tcl

# do the get opt again incase the routing protocol file added some more
# options to look for
#getopt $argc $argv


#
# Initialize Global Variables
#
set ns_		[new Simulator]
set topo	[new Topography]
$topo load_flatgrid 600 300

set tracefd	[open $opt(tr) w]
$ns_ trace-all $tracefd
$ns_ use-newtrace

set namtrace    [open wy.nam w]
$ns_ namtrace-all-wireless $namtrace 600 300

#$topo load_flatgrid $opt(x) $opt(y)



#
# Create God
#
create-god $opt(nn)
set channel [new Channel/WirelessChannel]
$channel set errorProbability_ 0.0

#
#  Create the specified number of nodes $opt(nn) and "attach" them
#  the channel.
#  Each routing protocol script is expected to have defined a proc
#  create-mobile-node that builds a mobile node and inserts it into the
#  array global $node_($i)
#

	#global node setting

        $ns_ node-config -adhocRouting $opt(rp) \
			 -llType $opt(ll) \
			 -macType $opt(mac) \
			 -ifqType $opt(ifq) \
			 -ifqLen $opt(ifqlen) \
			 -antType $opt(ant) \
			 -propType $opt(prop) \
			 -phyType $opt(netif) \
			 -channelType $opt(chan) \
			 -topoInstance $topo \
			 -energyModel $opt(energymodel) \
			 -rxPower 0.3 \
			 -txPower 0.6 \
			 -initialEnergy $opt(initialenergy)
			 
for {set i 0} {$i < $opt(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0;	
	}
for {set i 0} {$i < $opt(nn)} {incr i} {    $ns_ initial_node_pos $node_($i) 10
}
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
set i 0
#start zone 0
for {set j 0} {$j < 2} {incr j} {
            $node_($i) set X_ [expr 130-(130*cos(($pi/10)+$pi*16*$j/180))]
            $node_($i) set Y_ [expr 130*sin($pi/10+$pi*16*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 00 2 0
            incr i
}
$node_(0) set zone 0 00 2 1
for {set j 2} {$j < 5} {incr j} {
            $node_($i) set X_ [expr 130-(130*cos(($pi/10)+$pi*16*$j/180))]
            $node_($i) set Y_ [expr 130*sin($pi/10+$pi*16*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 01 3 0
            incr i
}
$node_(2) set zone 2 01 3 1
for {set j 5} {$j < 7} {incr j} {
            $node_($i) set X_ [expr 130-(130*cos(($pi/10)+$pi*16*$j/180))]
            $node_($i) set Y_ [expr 130*sin($pi/10+$pi*16*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 02 2 0
            incr i
}
$node_(5) set zone 5 02 2 1
for {set j 7} {$j < 10} {incr j} {
            $node_($i) set X_ [expr 130-(130*cos(($pi/10)+$pi*16*$j/180))]
            $node_($i) set Y_ [expr 130*sin($pi/10+$pi*16*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 03 3 0
            incr i
}
$node_(7) set zone 7 03 3 1
#end zone 0

#start zone 1
for {set j 0} {$j < 3} {incr j} {
            $node_($i) set X_ [expr 130-(160*cos(($pi/10)+$pi*12.3*$j/180))]
            $node_($i) set Y_ [expr 160*sin($pi/10+$pi*12.3*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 10 3 0
            incr i
}
$node_(10) set zone 10 10 3 1
for {set j 3} {$j < 6} {incr j} {
            $node_($i) set X_ [expr 130-(160*cos(($pi/10)+$pi*12.3*$j/180))]
            $node_($i) set Y_ [expr 160*sin($pi/10+$pi*12.3*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 11 3 0
            incr i
}
$node_(13) set zone 13 11 3 1
for {set j 6} {$j < 9} {incr j} {
            $node_($i) set X_ [expr 130-(160*cos(($pi/10)+$pi*12.3*$j/180))]
            $node_($i) set Y_ [expr 160*sin($pi/10+$pi*12.3*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 12 3 0
            incr i
}
$node_(16) set zone 16 12 3 1
for {set j 9} {$j < 13} {incr j} {
            $node_($i) set X_ [expr 130-(160*cos(($pi/10)+$pi*12.3*$j/180))]
            $node_($i) set Y_ [expr 160*sin($pi/10+$pi*12.3*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 13 4 0
            incr i
}
$node_(19) set zone 19 13 3 1
#end zone 1
#start  zone 2
for {set j 0} {$j < 3} {incr j} {
            $node_($i) set X_ [expr 130-(190*cos(($pi/10)+$pi*10.7*$j/180))]
            $node_($i) set Y_ [expr 190*sin($pi/10+$pi*10.7*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 20  3 0
            incr i
}
$node_(23) set zone 23 20 3 1
for {set j 3} {$j < 7} {incr j} {
            $node_($i) set X_ [expr 130-(190*cos(($pi/10)+$pi*10.7*$j/180))]
            $node_($i) set Y_ [expr 190*sin($pi/10+$pi*10.7*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 21  4 0
            incr i
}
$node_(26) set zone 26 21 4 1
for {set j 7} {$j < 11} {incr j} {
            $node_($i) set X_ [expr 130-(190*cos(($pi/10)+$pi*10.7*$j/180))]
            $node_($i) set Y_ [expr 190*sin($pi/10+$pi*10.7*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 22  4 0
            incr i
}
$node_(30) set zone 30 22 4 1
for {set j 11} {$j < 15} {incr j} {
            $node_($i) set X_ [expr 130-(190*cos(($pi/10)+$pi*10.7*$j/180))]
            $node_($i) set Y_ [expr 190*sin($pi/10+$pi*10.7*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 23  4 0
            incr i
}
$node_(34) set zone 34 23 4 1
#end zone 2

#start zone 3
for {set j 0} {$j < 4} {incr j} {
            $node_($i) set X_ [expr 130-(220*cos(($pi/10)+$pi*8.89*$j/180))]
            $node_($i) set Y_ [expr 220*sin($pi/10+$pi*8.89*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 30  4 0
            incr i
}
$node_(38) set zone 38 30 4 1
for {set j 4} {$j < 9} {incr j} {
            $node_($i) set X_ [expr 130-(220*cos(($pi/10)+$pi*8.89*$j/180))]
            $node_($i) set Y_ [expr 220*sin($pi/10+$pi*8.89*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 31  5 0
            incr i
}
$node_(42) set zone 42 31 5 1
for {set j 9} {$j < 13} {incr j} {
            $node_($i) set X_ [expr 130-(220*cos(($pi/10)+$pi*8.89*$j/180))]
            $node_($i) set Y_ [expr 220*sin($pi/10+$pi*8.89*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 32  4 0
            incr i
}
$node_(47) set zone 47 32 4 1
for {set j 13} {$j < 18} {incr j} {
            $node_($i) set X_ [expr 130-(220*cos(($pi/10)+$pi*8.89*$j/180))]
            $node_($i) set Y_ [expr 220*sin($pi/10+$pi*8.89*$j/180)+50]
            $node_($i) set Z_ 0;
            $node_($i) set zone $i 33  5 0
            incr i
}
$node_(51) set zone 51 33 5 1
#end zone 3


$node_(56) set X_ 130
$node_(56) set Y_ 50
$node_(56) set Z_ 0




set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp_(0) 

set udp_(1) [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp_(1)

set udp_(2) [new Agent/UDP]
$ns_ attach-agent $node_(2) $udp_(2)

set udp_(3) [new Agent/UDP]
$ns_ attach-agent $node_(4) $udp_(3)

set udp_(4) [new Agent/UDP]
$ns_ attach-agent $node_(5) $udp_(4)
set udp_(5) [new Agent/UDP]
$ns_ attach-agent $node_(6) $udp_(5)

set udp_(6) [new Agent/UDP]
$ns_ attach-agent $node_(7) $udp_(6)
set udp_(7) [new Agent/UDP]
$ns_ attach-agent $node_(9) $udp_(7)

set udp_(8) [new Agent/UDP]
$ns_ attach-agent $node_(10) $udp_(8)
set udp_(9) [new Agent/UDP]
$ns_ attach-agent $node_(12) $udp_(9)

set udp_(10) [new Agent/UDP]
$ns_ attach-agent $node_(13) $udp_(10)
set udp_(11) [new Agent/UDP]
$ns_ attach-agent $node_(15) $udp_(11)

set udp_(12) [new Agent/UDP]
$ns_ attach-agent $node_(16) $udp_(12)

set udp_(13) [new Agent/UDP]
$ns_ attach-agent $node_(18) $udp_(13)

set udp_(14) [new Agent/UDP]
$ns_ attach-agent $node_(19) $udp_(14)
set udp_(15) [new Agent/UDP]
$ns_ attach-agent $node_(22) $udp_(15)

set udp_(16) [new Agent/UDP]
$ns_ attach-agent $node_(23) $udp_(16)
set udp_(17) [new Agent/UDP]
$ns_ attach-agent $node_(25) $udp_(17)

set udp_(18) [new Agent/UDP]
$ns_ attach-agent $node_(26) $udp_(18)
set udp_(19) [new Agent/UDP]
$ns_ attach-agent $node_(29) $udp_(19)

set udp_(20) [new Agent/UDP]
$ns_ attach-agent $node_(30) $udp_(20)
set udp_(21) [new Agent/UDP]
$ns_ attach-agent $node_(33) $udp_(21)

set udp_(22) [new Agent/UDP]
$ns_ attach-agent $node_(34) $udp_(22)
set udp_(23) [new Agent/UDP]
$ns_ attach-agent $node_(37) $udp_(23)

set udp_(24) [new Agent/UDP]
$ns_ attach-agent $node_(38) $udp_(24)
set udp_(25) [new Agent/UDP]
$ns_ attach-agent $node_(41) $udp_(25)

set udp_(26) [new Agent/UDP]
$ns_ attach-agent $node_(42) $udp_(26)
set udp_(27) [new Agent/UDP]
$ns_ attach-agent $node_(46) $udp_(27)

set udp_(28) [new Agent/UDP]
$ns_ attach-agent $node_(47) $udp_(28)
set udp_(29) [new Agent/UDP]
$ns_ attach-agent $node_(50) $udp_(29)

set udp_(30) [new Agent/UDP]
$ns_ attach-agent $node_(51) $udp_(30)
set udp_(31) [new Agent/UDP]
$ns_ attach-agent $node_(55) $udp_(31)


set null_(0) [new Agent/Null]
$ns_ attach-agent $node_(56) $null_(0)

for {set j 0} {$j < 32} {incr j} {
  $ns_ connect $udp_($j) $null_(0)
}
for {set j 0} {$j < 32}  {incr j} {
set cbr_($j) [new Application/Traffic/CBR]
$cbr_($j) set packetSize_ 512
$cbr_($j) set rate_ 512
$cbr_($j) attach-agent $udp_($j)
$ns_ at 10.0 "$cbr_($j) start"
incr j
}
for {set j 1} {$j < 32} {incr j} {
set cbr_($j) [new Application/Traffic/CBR]
$cbr_($j) set packetSize_ 512
$cbr_($j) set rate_ 512
$cbr_($j) attach-agent $udp_($j)
$ns_ at 15.0 "$cbr_($j) start"
incr j
}


#
# Source the Connection and Movement scripts
#
#if { $opt(cp) == "" } {
#	puts "*** NOTE: no connection pattern specified."
#        set opt(cp) "none"
#} else {
#	puts "Loading connection pattern..."
#	source $opt(cp)
#}


#
# Tell all the nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).000000001 "$node_($i) reset";
}
$ns_ at $opt(stop).0 "stop"
$ns_ at $opt(stop).00000001 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd

    #exec nam mflood.nam &
	puts "\nSimulation finished"
    exit 0
}

#if { $opt(sc) == "" } {
#	puts "*** NOTE: no scenario file specified."
#        set opt(sc) "none"
#} else {
#	puts "Loading scenario file..."
#	source $opt(sc)
#	puts "Load complete..."
#}

#puts $tracefd "M 0.0 nn $opt(nn) x $opt(x) y $opt(y) rp $opt(rp)"
#puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."
$ns_ run

