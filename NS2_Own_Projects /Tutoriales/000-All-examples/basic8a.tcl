#  Copyright (c) University of Maryland, Baltimore County, 2003.
#   Original Authors: Ramakrishna Shenai, Sunil Gowda and Krishna Sivalingam.

#   This software is developed at the University of Maryland, Baltimore County under
#   grants from Cisco Systems Inc and the University of Maryland, Baltimore County.

#   Permission to use, copy, modify, and distribute this software and its
#   documentation in source and binary forms for non-commercial purposes
#   and without fee is hereby granted, provided that the above copyright
#   notice appear in all copies and that both the copyright notice and
#   this permission notice appear in supporting documentation. and that
#   any documentation, advertising materials, and other materials related
#   to such distribution and use acknowledge that the software was
#   developed by the University of Maryland, Baltimore County.  The name of
#   the University may not be used to endorse or promote products derived from
#   this software without specific prior written permission.

#   Copyright (C) 2000-2003 Washington State University. All rights reserved.
#   This software was originally developed at Alcatel USA and subsequently modified
#   at Washington State University, Pullman, WA  through research work which was
#   supported by Alcatel USA, Inc and Cisco Systems Inc.

#   The  following notice is in adherence to the Washington State University
#   copyright policy follows.

#   License is granted to copy, to use, and to make and to use derivative
#   works for research and evaluation purposes, provided that Washington
#   State University is acknowledged in all documentation pertaining to any such
#   copy or derivative work. Washington State University grants no other
#   licenses expressed or implied. The Washington State University name
#   should not be used in any advertising without its written permission.

#   WASHINGTON STATE UNIVERSITY MAKES NO REPRESENTATIONS CONCERNING EITHER
#   THE MERCHANTABILITY OF THIS SOFTWARE OR THE SUITABILITY OF THIS SOFTWARE
#   FOR ANY PARTICULAR PURPOSE.  The software is provided "as is"
#   without express or implied warranty of any kind. These notices must
#   be retained in any copies of any part of this software.




# Example demo topology as shown below :
#
#    ___________          ___________          ___________
#   |           |        |           |        |           |
#   | Edge node |========| Core node |========| Edge node |
#   |___________|        |___________|        |___________|
#
#

StatCollector set debug_ 0
Classifier/BaseClassifier/EdgeClassifier set type_ 0
Classifier/BaseClassifier/CoreClassifier set type_ 1
# Per node bhp processing time is 1 micro-second
source ../lib/ns-obs-lib.tcl
source ../lib/ns-obs-defaults.tcl
source ../lib/ns-optic-link.tcl 

set ns [new Simulator]
set nf [open basic8a.nam w]
set sc [new StatCollector]
set tf [open trace8a.tr w]
set ndf [open ndtrace8a.tr w]

# dump all the traces out to the nam file
$ns namtrace-all $nf

$ns trace-all $tf
$ns nodetrace-all $ndf


#====================================================================#
# constant definitions
# set the offset time To to 20 microseconds
#BurstManager offsettime 0.00002
BurstManager offsettime 0.002
BurstManager maxburstsize 1250
BurstManager bursttimeout 0.1
# set the bhp processing time 1 microsecond
Classifier/BaseClassifier/CoreClassifier set bhpProcTime 0.000006
Classifier/BaseClassifier/EdgeClassifier set bhpProcTime 0.000006
Classifier/BaseClassifier set proc_time 0.0
OBSFiberDelayLink set FDLdelay 0.000005

# total number of edge nodes
set edge_count 2
# total number of core routers
set core_count 1

# total bandwidth/channel (1mb = 1000000)
set bwpc 1000000
#set bwpc 
# delay in milliseconds
set delay 1ms

# total number of channels per link
set maxch 14
# number of control channels per link
set ncc 4
# number of data-channels
set ndc 10

# set the variables too.
$ns set bwpc_  $bwpc
$ns set maxch_ $maxch
$ns set ncc_ $ncc
$ns set ndc_ $ndc

#====================================================================#
# support procedures

# finish procedure
proc finish {} {
    global ns nf sc tf
    $ns flush-trace
    $ns flush-nodetrace
    close $nf
    close $tf
    
    $sc display-sim-list

    #Execute NAM on the trace file
    #exec nam p2p.nam &

    puts "Simulation complete";
    exit 0
}




#create a edge-core-edge topology
Simulator instproc  create_topology { } {
    $self instvar Node_
    global E C 
    global edge_count core_count
    global bwpc maxch ncc ndc delay

    set i 0
    # set up the edge nodes
    while { $i < $edge_count } {
	set E($i) [$self create-edge-node $edge_count]
        set nid [$E($i) id]
        set string1 "E($i) node id:     $nid"
        puts $string1
	incr i
    }
    
    set i 0
    # set up the core nodes
    while { $i < $core_count } {
	set C($i) [$self create-core-node $core_count]
        set nid [$C($i) id]
        set string1 "C($i) node id:     $nid"
        puts $string1
	incr i
    }
    
    $self createDuplexFiberLink $E(0) $C(0) $bwpc $delay $ncc $ndc $maxch
    $self createDuplexFiberLink $C(0) $E(1) $bwpc $delay $ncc $ndc $maxch

    $self build-routing-table
   
}




$ns create_topology
#set ftp0 [$ns create-ftp-connection $E(0) $E(1)]

#puts "constructed a ftp connection between Edge node 0 and 1 "
#$ns at 1.0 "$ftp0 start"
#$ns at 1000.0 "$ftp0 stop"

Agent/UDP set packetSize_ 1250

set udp0 [new Agent/UDP]
$ns attach-agent $E(0) $udp0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 1250
$cbr0 set interval_ 0.0005
$cbr0 attach-agent $udp0

set null0 [new Agent/Null]
$ns attach-agent $E(1) $null0

$ns connect $udp0 $null0

$ns at 1.0 "$cbr0 start"
$ns at 6.0 "$cbr0 stop"

$ns at 7.0 "finish"
$ns run





