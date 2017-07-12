#
# Copyright (c) 1998 University of Southern California.
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


# This test suite is for validating wireless lans 
# To run all tests: test-all-wireless-lan
# to run individual test:
# ns test-suite-wireless-lan.tcl dsr
# ns test-suite-wireless-lan.tcl wired-cum-wireless
# ns test-suite-wireless-lan.tcl wireless-mip
# ....
#
# To view a list of available test to run with this script:
# ns test-suite-wireless-lan.tcl
#

# 
#

Class TestSuite

Class Test/gpsr -superclass TestSuite
# wireless model using GPSR

Class Test/dsr -superclass TestSuite
# wireless model using dynamic source routing

proc usage {} {
    global argv0
    puts stderr "usage: ns $argv0 <tests> "
    puts stderr "usage: ns $argv0 <tfile> <bint> <bdesync> <bexp> <pint> <pdesync>"
    puts "Valid Tests: dsr gpsr"
    exit 1
}


proc default_options {} {
    global opt
    set opt(chan)	Channel/WirelessChannel
    set opt(prop)	Propagation/TwoRayGround
    set opt(netif)	Phy/WirelessPhy
    set opt(mac)	Mac/802_11
    set opt(ifq)	Queue/DropTail/PriQueue
    set opt(ll)		LL
    set opt(ant)        Antenna/OmniAntenna
    set opt(x)		1500 ;# X dimension of the topography
    set opt(y)		300 ;# Y dimension of the topography
#    set opt(radius)     250  ;# radius of communication (XXX -- compute it)
    set opt(ifqlen)	50	      ;# max packet in ifq
    set opt(seed)	0.0
    set opt(tr)		temp.rands    ;# trace file
    set opt(lm)         "off"          ;# log movement
    set opt(pint)       8.0
    set opt(pdesync)    0.5
    set opt(bint)       3.0
    set opt(bdesync)    0.5
    set opt(bexp)       13.5
    set opt(sc)         "sc-x2000-y2000-n40-s25-t40"
}


# =====================================================================
# Other default settings

set AgentTrace			ON
set RouterTrace			ON
set MacTrace			OFF

LL set mindelay_		50us
LL set delay_			25us
LL set bandwidth_		0	;# not used
LL set off_prune_		0	;# not used
LL set off_CtrMcast_		0	;# not used

Agent/Null set sport_		0
Agent/Null set dport_		0

Agent/CBR set sport_		0
Agent/CBR set dport_		0

Agent/TCPSink set sport_	0
Agent/TCPSink set dport_	0

Agent/TCP set sport_		0
Agent/TCP set dport_		0
Agent/TCP set packetSize_	1460

Queue/DropTail/PriQueue set Prefer_Routing_Protocols    0

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
Phy/WirelessPhy set Pt_ 0.2818
Phy/WirelessPhy set freq_ 914e+6 
Phy/WirelessPhy set L_ 1.0

#Agent/GPSR set verbose_ 1
Agent/GPSR set use_mac_ 1
Agent/GPSR set use_peri_ 1
#Agent/GPSR set drop_debug_ 1
Agent/GPSR set peri_proact_ 0
Agent/GPSR set use_implicit_beacon_ 1
Agent/GPSR set use_planar_ 1
# =====================================================================

TestSuite instproc init {} {
	global opt tracefd topo chan prop 
	global node_ god_ gkeeper
	$self instvar ns_ testName_
	set ns_         [new Simulator]
    if {[string compare $testName_ "dsr"] && \
	    [string compare $testName_ "gpsr"] } {
	     $ns_ set-address-format hierarchical
	     AddrParams set domain_num_ 3
	     lappend cluster_num 2 1 1
	     AddrParams set cluster_num_ $cluster_num
	     lappend eilastlevel 1 1 4 1
	     AddrParams set nodes_num_ $eilastlevel
        }  
	set chan	[new $opt(chan)]
	set prop	[new $opt(prop)]
	set topo	[new Topography]
	set tracefd	[open $opt(tr) w]

	#set opt(rp) $testName_
	$topo load_flatgrid $opt(x) $opt(y)
	$prop topography $topo
	#
	# Create God
	#
	$self create-god $opt(nn)
	
	#
	# log the mobile nodes movements if desired
	#
	if { $opt(lm) == "on" } {
		$self log-movement
	}

	puts $tracefd "M 0.0 nn:$opt(nn) x:$opt(x) y:$opt(y) rp:$opt(rp)"
	puts $tracefd "M 0.0 sc:$opt(sc) cp:$opt(cp) seed:$opt(seed)"
	puts $tracefd "M 0.0 prop:$opt(prop) ant:$opt(ant)"
}

TestSuite instproc create_gridkeeper { } {

        global gkeeper opt node_
                
        set gkeeper [new GridKeeper]
        
        #initialize the gridkeeper
                
        $gkeeper dimension $opt(x) $opt(y)
 
        #
        # add mobile node into the gridkeeper, must be added after
        # scenario file
        #       


        for {set i 0} {$i < $opt(nn) } {incr i} {
	    $gkeeper addnode $node_($i)
        
	    $node_($i) radius $opt(radius)
        }       
}

Test/gpsr instproc init {} {
    global opt node_ god_ ldb_ ragent_ MacTrace
    $self instvar ns_ testName_
    set testName_       gpsr
    set opt(rp)         gpsr
    set opt(ragent)     Agent/GPSR
    set opt(cp)		"cbr-50-2Kbps"
    set opt(nn)		50
    set opt(stop)	900.0

    $self next

    $ns_ set-address-format expanded
    set ldb_ [new LocDbase]
    $ldb_ nnodes $opt(nn)
    for {set i 0} {$i < $opt(nn) } {incr i} {
	$testName_-create-mobile-node $i
#	if { [Agent/GPSR set use_mac_] && $MacTrace == "OFF" } {
#	    set macdropt [cmu-trace Drop "MAC" $node_($i)]
#	    [$node_($i) set mac_(0)] drop-target $macdropt
#	}
	$ragent_($i) install-tap [$node_($i) set mac_(0)]
	$ldb_ register [$node_($i) address?] $node_($i)
	$ragent_($i) ldb $ldb_
    }
    puts "Loading connection pattern..."
    source $opt(cp)
    
    puts "Loading scenario file..."
    source $opt(sc)
    puts "Load complete..."

    #
    # Tell all the nodes when the simulation ends
    #
    for {set i 0} {$i < $opt(nn) } {incr i} {
	$ns_ at $opt(stop).000000001 "$node_($i) reset";
    }
    
    $ns_ at $opt(stop).000000001 "puts \"NS EXITING...\" ;" 
    #$ns_ halt"
    $ns_ at $opt(stop).1 "$self finish"
}

Test/gpsr instproc run {} {
    $self instvar ns_
    puts "Starting Simulation..."
    $ns_ run
}


Test/dsr instproc init {} {
    global opt node_ god_
    $self instvar ns_ testName_
    set testName_       dsr
    set opt(rp)         dsr
#    set opt(cp)         "../mobility/scene/cbr-50-20-4-512"
#    set opt(sc)         "../mobility/scene/scen-670x670-50-600-20-0" ;
    set opt(nn)         50
    set opt(stop)       900.0
    set opt(cp)		"cbr-50-2Kbps"

    $self next

    for {set i 0} {$i < $opt(nn) } {incr i} {
        $testName_-create-mobile-node $i
    }
    puts "Loading connection pattern..."
    source $opt(cp)

    puts "Loading scenario file..."
    source $opt(sc)
    puts "Load complete..."

    #
    # Tell all the nodes when the simulation ends
    #
    for {set i 0} {$i < $opt(nn) } {incr i} {
        $ns_ at $opt(stop).000000001 "$node_($i) reset";
    }

    $ns_ at $opt(stop).000000001 "puts \"NS EXITING...\" ;"
    #$ns_ halt"
    $ns_ at $opt(stop).1 "$self finish"
}



Test/dsr instproc run {} {
    $self instvar ns_
    puts "Starting Simulation..."
    $ns_ run
}

proc cmu-trace { ttype atype node } {
	global ns tracefd
    
        set ns [Simulator instance]
	if { $tracefd == "" } {
		return ""
	}
	set T [new CMUTrace/$ttype $atype]
	$T target [$ns set nullAgent_]
	$T attach $tracefd
        $T set src_ [$node id]

        $T node $node

	return $T
}

TestSuite instproc finish {} {
	$self instvar ns_
	global quiet

	$ns_ flush-trace
        #if { !$quiet } {
        #        puts "running nam..."
        #        exec nam temp.rands.nam &
        #}
	puts "finishing.."
	exit 0
}

TestSuite instproc create-god { nodes } {
	global tracefd god_
	$self instvar ns_

	set god_ [new God]
	$god_ num_nodes $nodes
}

TestSuite instproc log-movement {} {
	global ns
	$self instvar logtimer_ ns_

	set ns $ns_
	source ../mobility/timer.tcl
	Class LogTimer -superclass Timer
	LogTimer instproc timeout {} {
		global opt node_;
		for {set i 0} {$i < $opt(nn)} {incr i} {
			$node_($i) log-movement
		}
		$self sched 0.1
	}

	set logtimer_ [new LogTimer]
	$logtimer_ sched 0.1
}

TestSuite instproc create-tcp-traffic {id src dst start} {
    $self instvar ns_
    set tcp_($id) [new Agent/TCP]
    $tcp_($id) set class_ 2
    set sink_($id) [new Agent/TCPSink]
    $ns_ attach-agent $src $tcp_($id)
    $ns_ attach-agent $dst $sink_($id)
    $ns_ connect $tcp_($id) $sink_($id)
    set ftp_($id) [new Application/FTP]
    $ftp_($id) attach-agent $tcp_($id)
    $ns_ at $start "$ftp_($id) start"
    
}


TestSuite instproc create-udp-traffic {id src dst start} {
    $self instvar ns_
    set udp_($id) [new Agent/UDP]
    $ns_ attach-agent $src $udp_($id)
    set null_($id) [new Agent/Null]
    $ns_ attach-agent $dst $null_($id)
    set cbr_($id) [new Application/Traffic/CBR]
    $cbr_($id) set packetSize_ 512
    $cbr_($id) set interval_ 4.0
    $cbr_($id) set random_ 1
    $cbr_($id) set maxpkts_ 10000
    $cbr_($id) attach-agent $udp_($id)
    $ns_ connect $udp_($id) $null_($id)
    $ns_ at $start "$cbr_($id) start"

}

proc runtest {arg} {
	global quiet opt
	set quiet 0

	set b [llength $arg]
	if {$b == 4} {
	    set test [lindex $arg 0]
	    set opt(tr) [lindex $arg 1]
	    set opt(sc) [lindex $arg 2]
	    set opt(mac) [lindex $arg 3]
	} elseif {$b == 2} {
	    set test [lindex $arg 0]
	} elseif {$b == 5} {
	    set test [lindex $arg 0]
	    if {[string compare $test "gpsr"]} {
		usage
	    } else {
		set opt(tr) [lindex $arg 1]
		set opt(sc) [lindex $arg 2]
		set opt(mac) [lindex $arg 3]
		Agent/GPSR set bint_ [lindex $arg 4]
		Agent/GPSR set bexp_ [expr 4.5 * [Agent/GPSR set bint_]]
	    }
	} elseif {$b == 9} {
	    set test [lindex $arg 0]
	    if {[string compare $test "gpsr"]} {
		usage
	    } else {
		set opt(tr) [lindex $arg 1]
		set opt(sc) [lindex $arg 2]
		set opt(mac) [lindex $arg 3]
		Agent/GPSR set pint_ [lindex $arg 4]
		Agent/GPSR set pdesync_ [lindex $arg 5]
		Agent/GPSR set bint_ [lindex $arg 6]
		Agent/GPSR set bdesync_ [lindex $arg 7]
		Agent/GPSR set bexp_ [lindex $arg 8]
	    }
	} else {
	    usage
	}
	set t [new Test/$test]
	$t run
}

global argv arg0
default_options
runtest $argv
