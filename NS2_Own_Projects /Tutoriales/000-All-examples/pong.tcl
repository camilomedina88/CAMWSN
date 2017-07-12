#
# Copyright (c) 2007 Regents of the SIGNET lab, University of Padova.
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
#

# CBR sample

# Two nodes are created, with only one CBR module 
# per layer. A unidirectional Module/Link connects the two nodes.
# A single CBR flow is started from one node to the other.

source dynlibutils.tcl

dynlibload Miracle 
dynlibload miraclelink
dynlibload miraclepong
dynlibload pongtracer

#dynlibload Trace ../../trace/.libs/

proc finish {} {
	global ns tf opt sm
        puts "done!"

	$ns flush-trace
	close $tf

	set rtt [$sm getRTT]
	puts "Round Trip Time     :   $rtt"
	
	puts "Tracefile     : $opt(tracefile)"
}

set ns [new Simulator]
$ns use-Miracle

# Module/Pong set debug_ 1
Module/IP set debug_ 0

set opt(tracefile)   "/tmp/${argv0}.tr"
set tf [open $opt(tracefile) w]
$ns trace-all $tf


set node1 [$ns create-M_Node] 
set sm [new Module/Pong] 
set ipif1 [new Module/IP]
$node1 addModule 2 $sm 0 "SMPONG " 
$node1 addModule 1 $ipif1 0 "SMIPIF "
$node1 setConnection $sm $ipif1 1


set node2 [$ns create-M_Node]
set rm [new Module/Pong]
set ipif2 [new Module/IP]
$node2 addModule 2 $rm 0 "RMPONG " 
$node2 addModule 1 $ipif2 0 "RMIPIF "
$node2 setConnection $rm $ipif2 1


set link [new Module/DuplexLink]
$link delay      0.01
$link bandwidth  1000000
$link qsize      5
$link settags    "CHAN "
$link connect $node1 $ipif1 1 $node2 $ipif2 1 
#$link print-params 

set stop 3

$ns at 0.5 "$sm send [$ipif2 addr]"



#for {set t 0} {$t < $stop} {set t [expr $t + ($stop / 40.0)  ]} {
#   $ns at $t "puts -nonewline . ; flush stdout"
#}

$ns at 1 "finish"


puts -nonewline "Simulating"
$ns run
