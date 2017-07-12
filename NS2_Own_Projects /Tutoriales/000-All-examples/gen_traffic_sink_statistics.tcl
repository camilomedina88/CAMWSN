# Copyright (c) 2009 Rice University.
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
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE UNIVERSITY OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# Scripts for RI-MAC simulation. Created by Yanjun at the Monarch group 
# of Rice University, 2009
#

# read parameters from command line
proc getopt {argc lst} {
	global opt
	for { set i 0 } { $i < $argc } { incr i } {
		set arg [lindex $lst $i]
		if {[string range $arg 0 0] != "-" } { 
			continue
		}
		set name [string range $arg 1 end]
		set opt($name) [lindex $lst [expr $i+1]]
		puts "have read opt($name) = $opt($name)"
	}
}

# generate and attach traffic

#proc attach-traffic { node sink size interval id start stopSource} {
proc attach-traffic { node sink size tmpinput id start stopSource} {
   
	global god_ opt

    set ns [Simulator instance]
    set source [new Agent/UDP]
	$source set packetSize_ $size
    $ns attach-agent $node $source

	$god_ addUdpAgent [$node id] $source

    $ns connect $source $sink
    
    set traffic [new Application/Traffic/CBR]
	$traffic set packetSize_ $size
    $traffic set random_ 1
    $traffic set interval_ $tmpinput
	#$traffic set rate_ $rate
    $traffic set maxpkts_ 2684354560 
    #puts "set rate to $rate"
    $traffic attach-agent $source
    
    $ns at $start "$traffic start"
    $ns at $stopSource "$traffic stop"
    $source set fid_ $id
    return $source

}

# read topology and flow assignment from file
set u [new RNG]
$u seed $opt(nsseed)
set opt(NumFlows) 1
set ftop [open $opt(filetopology) r]
set cur_time $opt(start0);
for { set i 1 } { $i <= $opt(nn) } { incr i } {
	gets $ftop line
	set id [lindex $line 0]
	if { $id != $i } { puts "error: read index $id , expected index $i" ; exit; }
	$node_($i) set X_     [lindex $line 1]
	$node_($i) set Y_     [lindex $line 2]
	$node_($i) set Z_     0.00
	if { [lindex $line 3] == "-1" } { continue }
	for { set j 3 } { $j < [llength $line]} { incr j } {
		set destination [lindex $line $j]
		set mynull [new Agent/Null]
		$ns_ attach-agent $node_($destination) $mynull
##		set start $cur_time
	    set start [$u uniform $opt(start0) $opt(start1)]
#set cur_time [expr $cur_time + 5]
		#call the proc attach-traffic to set up the flow parameters and connect
		#set source [attach-traffic $node_($i) $mynull $opt(size) $opt(interval) $i $start $opt(stopSource)]
		set tmpi [expr $j + 1];
		if { $tmpi < [llength $line] } {
			if { [lindex $line $tmpi] == "@" } {
				incr j;
				incr j;
				set tmpinput [lindex $line $j];
			} else {
				set tmpinput $opt(interval);
				#set tmpinput $opt(udp_rate);
			}
		} else {
			#set tmpinput $opt(udp_rate)
			set tmpinput $opt(interval);
		}
		set source($opt(NumFlows)) [attach-traffic $node_($i) $mynull $opt(cbrpktsize) $tmpinput $i $start $opt(stopSource)]
#puts "flow $opt(NumFlows) src $i dst $destination rate w/ interval: $tmpinput, pktsize: $opt(cbrpktsize) B, rate: [expr 8*$opt(cbrpktsize)/$tmpinput] bps"


#	set source($opt(NumFlows)) [attach-traffic $node_($i) $mynull $opt(cbrpktsize) $opt(udp_rate) $i $start $opt(stopSource)]
	    #Theodoros
	    set sink($opt(NumFlows)) [new Agent/MyNull]
	    $ns_ attach-agent $node_($destination) $sink($opt(NumFlows))
	    $ns_ connect $source($opt(NumFlows))  $sink($opt(NumFlows))
	    set opt(NumFlows) [expr $opt(NumFlows) +1]
	}
}
set opt(NumFlows) [expr $opt(NumFlows) -1]
puts "gen_traffic.tcl::opt(NumFlows)=$opt(NumFlows)"
close $ftop

#Setup a source from a source node to a destination node 
#for {set i 0} {$i < $opt(nn) } {incr i} {
#    set null_($i) [new Agent/Null]
#    $ns_ attach-agent $node_($destination($i)) $null_($i)
#    set start [$u uniform $opt(start0) $opt(start1)]
#    #call the proc attach-traffic to set up the flow parameters and connect
#    set source($i) [attach-traffic $node_($i) $null_($i) $opt(size) $opt(interval) $i $start $opt(stopSource)]
#}
