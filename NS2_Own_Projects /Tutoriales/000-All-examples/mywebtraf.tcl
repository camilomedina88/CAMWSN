# Copyright (C) 1999 by USC/ISI
# All rights reserved.                                            
#                                                                
# Redistribution and use in source and binary forms are permitted
# provided that the above copyright notice and this paragraph are
# duplicated in all such forms and that any documentation, advertising
# materials, and other materials related to such distribution and use
# acknowledge that the software was developed by the University of
# Southern California, Information Sciences Institute.  The name of the
# University may not be used to endorse or promote products derived from
# this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
# 
# An example script that simulates large-scale web traffic. 
# See web-traffic.tcl for a smaller scale web traffic simulation.
#
# This is intended to be a simpler version than the large-scale-web-traffic.tcl
# but consists of more than one objects per page. 
#
# Created by Polly Huang (huang@catarina.usc.edu)
# Modified by Haobo Yu (haoboy@isi.edu)
# Modified by Liang Guo <guol@cs.bu.edu>

global num_node n b c s verbose
set verbose 0
source varybell.tcl

# Basic ns setup
set ns [new Simulator]

Agent/TCP set packetSize_ 500
Agent/TCP set rtxcur_init_ 3.0

if {$argc == 10} {
    set simtime [lindex $argv 0]
    set qtype   [lindex $argv 1]
    set bw      [lindex $argv 2]
    set n_svr   [lindex $argv 3]
    set n_clnt  [lindex $argv 4]
    set tcpver  [lindex $argv 5]
    set wait    [lindex $argv 6]
    set ecn	[lindex $argv 7]
    set dyn	[lindex $argv 8]
    set weight  [lindex $argv 9]
} else {

    puts ""
    puts ""
    puts ""
    puts "  Usage: ns $argv0 simtime queue-type bandw n_svr n_clnt tcpver wait ecn dyn weight"
    puts ""
    puts ""
    exit 1
}

Queue set limit_ 800
if { $qtype == "myRIO" } {
	Queue/RED/myRIO set wait_ $wait
	Queue/RED/myRIO set gentle_ true
	Queue/RED/myRIO set thresh_ 150
	Queue/RED/myRIO set maxthresh_ 450
	Queue/RED/myRIO set weight_ $weight
} else {
	Queue/RED set gentle_ true
	Queue/RED set thresh_ 150
	Queue/RED set maxthresh_ 450
	Queue/$qtype set wait_ $wait
	if { $qtype == "PIRED" } {
		Queue/PIRED set obj_q_ 250
	} elseif { ($qtype == "dualPIRED") || ($qtype == "myRED") } {
		Queue/$qtype set obj_q1_ 250
		Queue/$qtype set obj_q2_ 300
	}
}

Agent/TCP set window_ 256

if {$tcpver == "Sack1"} {
	set ss "/Sack1"
} else {
	set ss ""
}
PagePool/WebTraf set TCPSINKTYPE_ TCPSink$ss

if {$tcpver == "Tahoe"} {
	set tt ""
} else {
	set tt "/$tcpver"
}
PagePool/WebTraf set TCPTYPE_ TCP$tt

if { (($qtype == "RED") || ($qtype == "myRED") || ($qtype == "myRIO") || ($qtype == "PIRED") || ($qtype == "dualPIRED")) && ($ecn == 1) } {
	if { $qtype == "myRIO" } {
		Queue/RED/myRIO set setbit_ true
	} else {
		Queue/$qtype set setbit_ true
	}
	Agent/TCP set ecn_ true
}


# Create generic packet trace
# $ns trace-all [open my-largescale.out w]

set sizethr 50
set tmr_intv 2.0
# Defined in varybell.tcl
create_topology $n_svr $n_clnt $qtype $bw $sizethr $tmr_intv $dyn

# compute bandwidth-delay product
set bdp [expr 0.5 * $bw * (20 + $n_svr + $num_node * 0.1)]
if {$bdp < 8} {
	set bdp 8
}

set traceecn 0

if { ($qtype == "RED") || ($qtype == "myRED") || ($qtype == "myRIO") ||
	($qtype == "PIRED") || ($qtype == "dualPIRED") } {

	if { $ecn == 1 } {
		set traceecn 1
	}
	# buffer size set to 2.5 times bw * twoway-delay
	set buffer [expr int(2.5*$bdp)]

	set redq [[$ns link $n(1) $n(0)] queue]
	if { $qtype == "RED" } {
		$redq set q_weight_ [expr 1.0/512]
		$redq set thresh_ [expr int($buffer * 0.02)]
		$redq set maxthresh_ [expr int($buffer * 0.5)]
	} elseif { $qtype == "myRED" } {
		$redq set min_N_ 50
		$redq set max_RTT_ [expr 0.01*(20+$n_svr+$num_node*0.1)]
#		$redq set obj_q1_ [expr int($buffer * 0.15)]
#		$redq set obj_q2_ [expr int($buffer * 0.15)]
		$redq set obj_q1_ [expr int($buffer * 0.2)]
		$redq set obj_q2_ [expr int($buffer * 0.1)]
		$redq sample-interval 0.005
	} elseif { $qtype == "myRIO" } {
		$redq set q_weight_ [expr 1.0/512]
		$redq set thresh_ [expr int($buffer * 0.02)]
		$redq set in_maxthresh_ [expr int($buffer * 0.5)]
		$redq set linterm_ 12
	} elseif { $qtype == "PIRED" } {
		$redq set min_N_ 50
                $redq set max_RTT_ [expr 0.01*(20+$n_svr+$num_node*0.1)]
                $redq set obj_q_ [expr int($buffer * 0.3)]
                $redq sample-interval 0.005
	} elseif { $qtype == "dualPIRED" } {
		$redq set min_N_ 50
                $redq set max_RTT_ [expr 0.01*(20+$n_svr+$num_node*0.1)]
                $redq set obj_q1_ [expr int($buffer * 0.2)]
                $redq set obj_q2_ [expr int($buffer * 0.3)]
                $redq sample-interval 0.005
        }
} else {
	# 1.5 times for FIFO (best performance)
	set buffer [expr int(1.5*$bdp)]
}

$ns queue-limit $n(1) $n(0) $buffer

set f [open dummy.tr w]
if { $traceecn == 0 } {
	set qmon [$ns monitor-queue $n(1) $n(0) $f]
} else {
	set qmon [new QueueMonitor/ED]

	set ll [$ns link $n(1) $n(0)]
	set redq [$ll queue]
	set isnoop [new SnoopQueue/In]
	set osnoop [new SnoopQueue/Out]
	set dsnoop [new SnoopQueue/Drop]
	set edsnoop [new SnoopQueue/EDrop]

	$ll attach-monitors $isnoop $osnoop $dsnoop $qmon
	$edsnoop set-monitor $qmon
	$redq early-drop-target $edsnoop
	$edsnoop target [$ns set nullAgent_]

	$redq drop-target $dsnoop
}

set df [open drop.$qtype w]
$ns at 100.0 "clean-up"

proc clean-up { } {
	global qmon traceecn

	$qmon set parrivals_ 0 
	$qmon set pdrops_ 0 
	if {$traceecn == 1} {
		$qmon set epmarks_ 0 
	}
}

$ns at 120.0 "trace-droprate $df 20.0"

proc trace-droprate { fptr intv } {
    global ns qmon traceecn

    set now [$ns now]
    set arr [$qmon set parrivals_]
    set drop [$qmon set pdrops_]

    $qmon set parrivals_ 0
    $qmon set pdrops_ 0

    if { $traceecn == 1 } {
	set emark [$qmon set epmarks_]
	$qmon set epmarks_ 0

	if { $arr > 0 } {
		set edr [expr $emark*1.0/$arr]
	} else {
		set edr 0
	}
    }

    if { $arr > 0 } {
	set dr [expr $drop*1.0/$arr]
    } else {
	set dr 0
    }

    if { $traceecn == 0 } {
	puts $fptr "$now $dr"
    } else {
	puts $fptr "$now $dr $edr"
    }

    $ns at [expr $now + $intv] "trace-droprate $fptr $intv"
}


########################### Modify From Here #####################

# Create page pool
set pool [new PagePool/WebTraf]

# Setup servers and clients
$pool set-num-client $n_clnt
$pool set-num-server $n_svr
for {set i 0} {$i < $n_clnt} {incr i} {
	$pool set-client $i $c($i)
}
for {set i 0} {$i < $n_svr} {incr i} {
	$pool set-server $i $s($i)
}

set ftr [open "| getresp resp.$qtype [expr $num_node - $n_clnt - $n_svr] $n_svr $n_clnt" w]
#set ftr [open "| awk \"{ print \$4,\$5 }\" | getavg 90 4 1 1.1 $qtype.avg" w]
$pool attach $ftr
$pool set warmup_time_ 1000

# Number of Sessions
set numSession 150

# Inter-session Interval
set interSession [new RandomVariable/Exponential]
$interSession set avg_ 1

## Number of Pages per Session
set sessionSize [new RandomVariable/Constant]
$sessionSize set val_ 50000

# Random seed at every run
global defaultRNG
$defaultRNG seed 0

# use my own random variable for fair comparison
set myrng1 [new RNG]
set myrng2 [new RNG]
set myrng3 [new RNG]
set myrng4 [new RNG]
set myrng5 [new RNG]
set myrng6 [new RNG]

# these values were picked up from rng.cc
$myrng1 seed 762772169L
$myrng2 seed 437720306L
$myrng3 seed 939612284L
$myrng4 seed 425414105L
$myrng5 seed 1998078925L
$myrng6 seed 981631283L


# Create sessions
$pool set-num-session $numSession
set launchTime 0
for {set i 0} {$i < $numSession} {incr i} {
	set numPage [$sessionSize value]
#	puts "Session $i has $numPage pages"
	set interPage [new RandomVariable/Exponential]
	$interPage set avg_ 8.2
	$interPage use-rng $myrng2
	set pageSize [new RandomVariable/Uniform]
	$pageSize set min_ 2
	$pageSize set max_ 7
	$pageSize use-rng $myrng5
	set interObj [new RandomVariable/Exponential]
	$interObj set avg_ 0.05
	$interObj use-rng $myrng3
	set objSize [new RandomVariable/BPareto]
	$objSize set min_ 4
	$objSize set max_ 200000
	$objSize set shape_ 1.2
	$objSize use-rng $myrng4
	$pool create-session $i $numPage [expr $launchTime + 0.1] \
			$interPage $pageSize $interObj $objSize
	set launchTime [expr $launchTime + [$interSession value]]
}

################## Create Foreground Traffic ##########################
###  10 long and 10 shorts


proc build-fore-tcp { idx size intv stime } {
	global ns tt ss ftcp fsink

	set ftcp($idx) [new Agent/TCP$tt]
	set fsink($idx) [new Agent/TCPSink$ss]

	$ns at $stime "start-conn 1 $idx $intv $size"
}

proc start-conn { firsttime idx intv size } {
	global ns ftcp fsink s c

	set now [$ns now]

	if { $firsttime == 0 } {
		$ns detach-agent $s($idx) $ftcp($idx)
		$ns detach-agent $c($idx) $fsink($idx)
		$ftcp($idx) reset
		$fsink($idx) reset
	}
	$ns attach-agent $s($idx) $ftcp($idx)
	$ns attach-agent $c($idx) $fsink($idx)
	$ns connect $ftcp($idx) $fsink($idx)

	$ftcp($idx) proc done {} "close-conn $idx $now $size"
	$ftcp($idx) advanceby $size
	$ns at [expr $now + $intv] "start-conn 0 $idx $intv $size"
}

set sum_gdput 0
proc close-conn { idx oldtime size } {
	global ns foremon sum_gdput

	set now [$ns now]
	puts $foremon "$oldtime $idx [expr $now - $oldtime]"

	incr sum_gdput $size
}

set forel_intv 125
set fores_intv 25
set ssize 10
set lsize 1000
set foremon [open "fxtime.$qtype" w]
for { set i 0 } { $i < 10 } { incr i } {
	build-fore-tcp $i $ssize $fores_intv 1.0]
	build-fore-tcp [expr $i+10] $lsize $forel_intv 1.0]
}

## Start the simulation
$ns at $simtime "finish"

$ns at 0.0 "show-simtime"

proc show-simtime {} {
        global ns
	puts [$ns now]
	$ns at [expr [$ns now]+500.0] "show-simtime"
}

proc finish {} {
	global ns ftr df s n_svr sum_gdput
	$ns flush-trace

	for { set i 0 } { $i < $n_svr } {incr i} {
		$s($i) instvar agents_

		foreach a $agents_ {
			if { [string match "Agent\/TCP" [$a info class]] ||
				[string match "Agent\/TCP\/*" [$a info class]] } {
				incr sum_gdput [$a set ack_]
			}
		}	
        }


	puts "remaining goodput = $sum_gdput"

	close $ftr
	close $df
	exit 0
}

puts "ns started"
$ns run

