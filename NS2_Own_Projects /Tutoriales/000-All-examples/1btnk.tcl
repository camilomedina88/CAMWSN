# vcp ns2 simulation script for one bottleneck with settable 
# capacity, delay, forward/reverse long-/short-lived traffic, etc. 
# by yong xia (xy12180@gmail.com)

# input parameters
set btnk_bw       [lindex $argv 0]  ;# bottleneck capacity, Mbps
set rttp          [lindex $argv 1]  ;# round trip propagation delay, ms
set rtt_diff      [lindex $argv 2]  ;# flow rtt difference, ms
set num_fwd_flow  [lindex $argv 3]  ;# num of long-lived flows, forward path
set num_rev_flow  [lindex $argv 4]  ;# num of long-lived flows, reverse path
set rate_web_flow [lindex $argv 5]  ;# arrival rate of short-lived flows, forward path
set sim_time      [lindex $argv 6]  ;# simulation time, sec

set num_btnk                    1   ;# number of bottleneck(s)

# Dave Harrison's graphing tool
# Install from http://networks.ecse.rpi.edu/~harrisod/graph.html if you have not.
source $env(NS)/tcl/rpi/script-tools.tcl
source $env(NS)/tcl/rpi/file-tools.tcl
source $env(NS)/tcl/rpi/link-stats.tcl
source $env(NS)/tcl/rpi/tcp-stats.tcl
source $env(NS)/tcl/rpi/graph.tcl

# base scheme: tcp sack + red queue for btnk + droptail queue for non btnk
set SRC   TCP/Sack1
set SINK  TCPSink/Sack1
set BTNK_QUEUE    RED
set NONBTNK_QUEUE DropTail

# main switch: sack, reno, hstcp, htcp, stcp, bic, cubic, fast, xcp, or vcp
set scheme vcp
if { $scheme == "vcp" } {
    set SRC   TCP/Reno/VcpSrc
    set SINK  VcpSink
    set BTNK_QUEUE DropTail2/VcpQueue
    
} elseif { $scheme == "xcp" } {
    set SRC   TCP/Reno/XCP
    set SINK  TCPSink/XCPSink
    set BTNK_QUEUE    XCP
    set NONBTNK_QUEUE XCP
    #Agent/TCP set minrto_ 1 ;# from xcp sample script
    #Queue/DropTail2/XCPQ set queue_in_bytes_ true;
    
} elseif { $scheme == "reno" } {
    set SRC   TCP/Reno
    set SINK  TCPSink
    
} elseif { $scheme == "fast" } {
    set SRC   TCP/Fast
    #set BTNK_QUEUE REM

} elseif { $scheme == "hstcp" } {
    Agent/TCP set windowOption_ 8

} elseif { $scheme == "stcp" } {
    Agent/TCP set windowOption_ 9

} elseif { $scheme == "htcp" } {
    Agent/TCP set windowOption_ 10
    
} elseif { $scheme == "bic" } {
    Agent/TCP set windowOption_ 12
    
} elseif { $scheme == "cubic" } {
    Agent/TCP set windowOption_ 13
}

#puts "source tcp: $SRC"
#puts "sink   tcp: $SINK"
#puts "btnk queue: $BTNK_QUEUE"
#puts "non-btnk q: $NONBTNK_QUEUE"

# switches
set ns_trace    0
set nam_trace   0

set begin_time [clock seconds]

set show_progress    0
set show_graphs_fwd   1 
set show_graphs_rev   0
set show_graphs_util   1
set show_graphs_qlen   1
set show_graphs_cwnd   1
set show_graphs_rate   1
set show_graphs_srtt   0
set show_graphs_rtt    0
set show_graphs_seqno  0


set delay_diff        [expr $rtt_diff / 4.0]  ;# ms
set btnk_delay        [expr $rttp * 0.5 * 0.8]
set non_btnk_delay    [expr $rttp * 0.5 * 0.2 / 2.0]

# randomize flow start time
set start_time_RNG [new RNG]
$start_time_RNG next-substream
set start_time_rnd [new RandomVariable/Uniform]
$start_time_rnd set min_ 1   ;# ms
$start_time_rnd set max_ 300 ;# [expr 2 * $rttp + $num_fwd_flow * $rtt_diff]
$start_time_rnd use-rng $start_time_RNG 

set non_btnk_bw       [expr $btnk_bw * 2] ;# Mbps

set min_btnk_buf      [expr 2 * ($num_fwd_flow + $num_rev_flow)] ;# pkt, 2 per flow
set btnk_buf_bdp      1.0 ;# measured in bdp
set avg_rtt           [expr $rttp + $rtt_diff * ($num_fwd_flow - 1) / 2]
set btnk_buf          [expr $btnk_buf_bdp * $btnk_bw * $avg_rtt / 8.0] ;# in 1KB pkt
if { $btnk_buf < $min_btnk_buf } { set btnk_buf $min_btnk_buf }
set non_btnk_buf      [expr $btnk_buf]

set neglect_time      [expr $sim_time / 5] ;# s

# measure run time and print topology info
puts ""; puts ">>>>>> start running at "; exec date &;
puts "--------------------------------------------------------"
puts "settings:" 
puts "--------"
puts "  scheme:          $scheme" 
puts "  btnk #:          $num_btnk" 
puts "  btnk bw:         $btnk_bw Mbps" 
puts "  rtt:             $rttp ms" 
puts "  rtt diff:        $rtt_diff ms" 
puts "  btnk buf:        $btnk_buf pkts (1KB pkt size)" 
puts "  ftp flows (fwd): $num_fwd_flow" 
puts "  ftp flows (rev): $num_rev_flow" 
puts "  web flows (fwd): $rate_web_flow /s" 
puts "  simulation time: $sim_time s"
puts "--------------------------------------------------------"

# Create a gragh object
if { $show_graphs_fwd || $show_graphs_rev } {
    Graph set plot_device [new ghostview]
    set tmp_directory_ [create-tmp-directory] 
}

# Create a simulator object
set ns [new Simulator]
# ns2 calendar queue implementation is very slow in high bdp environment
$ns use-scheduler Heap

# Open the ns and nam trace files
if { $ns_trace } {
    set ns_file [open ns.trace w]
    $ns trace-all $ns_file
}
if { $nam_trace } {
    set nam_file [open nam.trace w]
    $ns namtrace-all $nam_file
}

# Define a procedure to set link bw
proc set-link-bw { n0 n1 } {
 
    set ns [Simulator instance]
 
    set link [$ns link $n0 $n1]
    set linkcap [expr [[$link set link_] set bandwidth_]]
    set queue [$link queue]
    $queue set-link-capacity [expr $linkcap]
    #puts "set-link-bw: [expr $linkcap/1000000.0] Mbps"
}

# Define a 'finish' procedure
proc finish {} {
    global scheme vcp xcp reno sack ns ns_trace nam_trace ns_file nam_file stats0 stats neglect_time
    global btnk_bw rttp num_btnk num_fwd_flow num_rev_flow rate_web_flow btnk_buf meausure_time begin_time
    global tcp rtcp ctcp show_graphs_fwd show_graphs_rev show_graphs_util show_graphs_qlen 
    global show_graphs_cwnd show_graphs_rate show_graphs_srtt show_graphs_rtt show_graphs_seqno
    global util_graph qlen_graph cwnd_graph rate_graph srtt_graph rtt_graph seqno_graph 
    global r_util_graph r_qlen_graph r_cwnd_graph r_rate_graph r_srtt_graph r_rtt_graph r_seqno_graph 

    $ns flush-trace
    if { $ns_trace }  { close $ns_file }
    if { $nam_trace } { close $nam_file; exec nam nam.trace & }

    # accounting
    set end_time [clock seconds]
    set min [expr ($end_time - $begin_time) / 60]
    set sec [expr ($end_time - $begin_time) % 60]
    
    # output link statistics
    for { set i 0 } { $i < $num_btnk } { incr i } {
	puts [format "  btnk no.:        %d th" $i]
	puts [format "  btnk util:       %.3f (%.3f including 0~%ds)" [$stats($i) get-utilization] [$stats0($i) get-utilization] $neglect_time]
	set pq [$stats0($i) get-mean-packet-queue-length] ;# in packets
	set bq [$stats0($i) get-mean-byte-queue-length]   ;# in bytes
	set pq_min [$stats0($i) get-min-packet-queue-length]
	set bq_min [$stats0($i) get-min-byte-queue-length]
	set pq_max [$stats0($i) get-max-packet-queue-length]
	set bq_max [$stats0($i) get-max-byte-queue-length]
	puts [format "  btnk avg queue:  %.1f pkt (%.2f%% buf), %.1f KB (%.2f%% buf)" $pq [expr 100.0*$pq/$btnk_buf] [expr $bq/1000.0] [expr $bq/(10.0*$btnk_buf)]]
	puts [format "  btnk min queue:  %.1f pkt (%.2f%% buf), %.1f KB (%.2f%% buf)" $pq_min [expr 100.0*$pq_min/$btnk_buf] [expr $bq_min/1000.0] [expr $bq_min/(10.0*$btnk_buf)]]
	puts [format "  btnk max queue:  %.1f pkt (%.2f%% buf), %.1f KB (%.2f%% buf)" $pq_max [expr 100.0*$pq_max/$btnk_buf] [expr $bq_max/1000.0] [expr $bq_max/(10.0*$btnk_buf)]]
	
	set pd [$stats0($i) get-packet-drops]
	set bd [$stats0($i) get-byte-drops]
	set pa [$stats0($i) get-packet-arrivals]
	set ba [$stats0($i) get-byte-arrivals]
	set pl [$stats0($i) get-packet-departures]
	set bl [$stats0($i) get-byte-departures]
	puts [format "  bntk drops:      %d pkt (%.2f%% arrival), %d B (%.2f%% arrival)" $pd [expr 100.0*$pd/$pa] $bd [expr 100.0*$bd/$ba]]
	#puts [format "  bntk arrivals:   %d pkt, %d B" $pa $ba]
	#puts [format "  bntk departures: %d pkt, %d B" $pl $bl]
	puts "--------------------------------------------------------"
    }

    set total_rate 0
    for { set i 0 } { $i < $num_fwd_flow } { incr i } {
	set rate_i [expr [$tcp($i) get-throughput-bps] / 1000000.0] ;# Mbps
	set total_rate [expr $total_rate + $rate_i]
	puts [format "  fwd ftp flow %d thruput:    %.3f Mbps" $i $rate_i]
    }

    puts "--------------------------------------------------------"
    puts [format "  fwd ftp flow thruput sum:  %.3f Mbps" $total_rate]
    puts "--------------------------------------------------------"

    puts "<<<<<< finished running at "; exec date &;
    puts "Time taken to run this simulation: $min min $sec sec."
    puts ""
    
    if { $show_graphs_fwd } {
	if {$show_graphs_util}  { $util_graph display }
	if {$show_graphs_qlen}  { $qlen_graph display }
	for { set i 1 } { $i < $num_fwd_flow } { incr i } {
	    if {$show_graphs_cwnd}  { $cwnd_graph(0) overlay $cwnd_graph($i) }
	    if {$show_graphs_rate}  { $rate_graph(0) overlay $rate_graph($i) }
	    if {$show_graphs_srtt}  { $srtt_graph(0) overlay $srtt_graph($i) }
	    if {$show_graphs_rtt}   { $rtt_graph(0) overlay $rtt_graph($i) }
	    if {$show_graphs_seqno} { $seqno_graph(0) overlay $seqno_graph($i) "Fwd Flow $i " }
	}
	if { $num_fwd_flow } {
	    if {$show_graphs_cwnd}  { $cwnd_graph(0) display }
	    if {$show_graphs_rate}  { $rate_graph(0) display }
	    if {$show_graphs_srtt}  { $srtt_graph(0) display }
	    if {$show_graphs_rtt}   { $rtt_graph(0) display }
	    if {$show_graphs_seqno} { $seqno_graph(0) display }
	}
    }

    if { $show_graphs_rev } { 
	if {$show_graphs_util}  { $r_util_graph display }
	if {$show_graphs_qlen}  { $r_qlen_graph display }
	for { set i 1 } { $i < $num_rev_flow } { incr i } {
	    if {$show_graphs_cwnd}  { $r_cwnd_graph(0) overlay $r_cwnd_graph($i) }
	    if {$show_graphs_rate}  { $r_rate_graph(0) overlay $r_rate_graph($i) }
	    if {$show_graphs_srtt}  { $r_srtt_graph(0) overlay $r_srtt_graph($i) }
	    if {$show_graphs_rtt}   { $r_rtt_graph(0) overlay $r_rtt_graph($i) }
	    if {$show_graphs_seqno} { $r_seqno_graph(0) overlay $r_seqno_graph($i) "Rev Flow $i " }
	}
	if { $num_rev_flow } {
	    if {$show_graphs_cwnd}  { $r_cwnd_graph(0) display }
	    if {$show_graphs_rate}  { $r_rate_graph(0) display }
	    if {$show_graphs_srtt}  { $r_srtt_graph(0) display }
	    if {$show_graphs_rtt}   { $r_rtt_graph(0) display }
	    if {$show_graphs_seqno} { $r_seqno_graph(0) display }
	}
    }
    
    if { $show_graphs_fwd || $show_graphs_rev } { [Graph set plot_device] close }
    exit 0
}

# Begin: setup topology ----------------------------------------
# Create router/bottleneck nodes
for { set i 0 } { $i <= $num_btnk } { incr i } {
    set r($i) [$ns node]
}
# router -- router and queue size
for { set i 0 } { $i < $num_btnk } { incr i } {
    # fwd path link and queue
    $ns simplex-link $r($i) $r([expr $i+1]) [expr $btnk_bw]Mb [expr $btnk_delay]ms $BTNK_QUEUE
    $ns queue-limit $r($i) $r([expr $i+1]) [expr $btnk_buf]
    if { $BTNK_QUEUE == "DropTail2/VcpQueue" || $BTNK_QUEUE == "XCP" } {
	set-link-bw $r($i) $r([expr $i+1])
	#puts "set-link-capacity fwd direction: [expr $linkcap / 1000000.0] Mbps"
    }

    # rev path link and queue
    $ns simplex-link $r([expr $i+1]) $r($i) [expr $btnk_bw]Mb [expr $btnk_delay]ms $BTNK_QUEUE
    $ns queue-limit $r([expr $i+1]) $r($i) [expr $btnk_buf]
    if { $BTNK_QUEUE == "DropTail2/VcpQueue" || $BTNK_QUEUE == "XCP" } {
	set-link-bw $r([expr $i+1]) $r($i)
	#puts "set-link-capacity rev direction: [expr $linkcap / 1000000.0] Mbps"
    }
}

# Create fwd path ftp/web nodes/links: src/dst -- router, last one for web traffic
for { set i 0 } { $i <= $num_fwd_flow } { incr i } {
    set s($i) [$ns node]
    set d($i) [$ns node]

    $ns duplex-link $s($i) $r(0)         [expr $non_btnk_bw]Mb [expr $non_btnk_delay + $i*$delay_diff]ms $NONBTNK_QUEUE
    $ns queue-limit $s($i) $r(0)         [expr $non_btnk_buf]
    $ns queue-limit $r(0)  $s($i)        [expr $non_btnk_buf]
    if { $NONBTNK_QUEUE == "XCP" } {
	set-link-bw $s($i) $r(0)
	set-link-bw $r(0) $s($i)
    }

    $ns duplex-link $d($i) $r($num_btnk) [expr $non_btnk_bw]Mb [expr $non_btnk_delay + $i*$delay_diff]ms $NONBTNK_QUEUE
    $ns queue-limit $d($i) $r($num_btnk) [expr $non_btnk_buf]
    $ns queue-limit $r($num_btnk) $d($i) [expr $non_btnk_buf]
    if { $NONBTNK_QUEUE == "XCP" } {
	set-link-bw $d($i) $r($num_btnk)
	set-link-bw $r($num_btnk) $d($i)
    }
}

# Create rev path nodes/links: rsrc/rdst -- router
for { set i 0 } { $i < $num_rev_flow } { incr i } {
    set rs($i) [$ns node]
    set rd($i) [$ns node]

    $ns duplex-link $rs($i) $r($num_btnk) [expr $non_btnk_bw]Mb [expr $non_btnk_delay + $i*$delay_diff]ms $NONBTNK_QUEUE
    $ns queue-limit $rs($i) $r($num_btnk) [expr $non_btnk_buf]
    $ns queue-limit $r($num_btnk) $rs($i) [expr $non_btnk_buf]
    if { $NONBTNK_QUEUE == "XCP" } {
	set-link-bw $rs($i) $r($num_btnk)
	set-link-bw $r($num_btnk) $rs($i)
    }

    $ns duplex-link $rd($i) $r(0)         [expr $non_btnk_bw]Mb [expr $non_btnk_delay + $i*$delay_diff]ms $NONBTNK_QUEUE
    $ns queue-limit $rd($i) $r(0)         [expr $non_btnk_buf]
    $ns queue-limit $r(0) $rd($i)         [expr $non_btnk_buf]
    if { $NONBTNK_QUEUE == "XCP" } {
	set-link-bw $rd($i) $r(0)
	set-link-bw $r(0) $rd($i)
    }
}
# End: setup topology ------------------------------------------

# bottleneck statistics
for { set i 0 } { $i < $num_btnk } { incr i } {
    set stats0($i) [new LinkStats $r($i) $r([expr $i+1])]
    set stats($i)  [new LinkStats $r($i) $r([expr $i+1])]
    $ns at $neglect_time "$stats($i) reset"
}

# Begin: agents and sources ------------------------------------
# Setup fwd connections and FTP/web sources
if { $num_fwd_flow == 0 } { 
    set web_per_ftp 0
    set left_web    [expr $rate_web_flow]
} else { 
    set web_per_ftp [expr round($rate_web_flow / $num_fwd_flow)]
    set left_web    [expr $rate_web_flow % $num_fwd_flow]
}
#puts "web_per_ftp: $web_per_ftp"
#puts "left_web:    $left_web"
if { $web_per_ftp } { 
    set interrequest_time1 [expr 1.0 / $web_per_ftp]
    #puts "interrequest_time1: $interrequest_time1"
}
if { $left_web } { 
    set interrequest_time2 [expr 1.0 / $left_web]
    #puts "interrequest_time2: $interrequest_time2"
}

for { set i 0 } { $i <= $num_fwd_flow } { incr i } {

    if { $i < $num_fwd_flow } { # $num_fwd_flow != 0
	set tcp($i) [$ns create-connection $SRC $s($i) $SINK $d($i) $i]
	
	set ftp($i) [$tcp($i) attach-source FTP]
	set start_time [expr [$start_time_rnd value] / 1000.0]
	$ns at $start_time "$ftp($i) start"
	set stop_time  [expr $sim_time]
	$ns at $stop_time "$ftp($i) stop"

	$tcp($i) init-stats
	$ns at [expr $start_time + $neglect_time] "$tcp($i) init-stats"

	# mice web traffic per ftp
	if { $web_per_ftp } { 
	    # file size = 30KB, pareto shape parameter = 1.35
	    create-mice-over-sth $SRC $s($i) $SINK $d($i) $interrequest_time1 30000 1.35 1 18888
	}
    } else {
	# left mice web traffic, put on the last src/dst node pair
	if { $left_web } { 
	    # file size = 30KB, pareto shape parameter = 1.35
	    create-mice-over-sth $SRC $s($i) $SINK $d($i) $interrequest_time2 30000 1.35 1 19999
	}
    }

}

# Setup reverse path connections and FTP sources
for { set i 0 } { $i < $num_rev_flow } { incr i } {
    set rtcp($i) [$ns create-connection $SRC $rs($i) $SINK $rd($i) [expr 40000+$i]]

    set rftp($i) [$rtcp($i) attach-source FTP]
    set start_time [expr [$start_time_rnd value] / 1000.0]
    $ns at $start_time "$rftp($i) start"
    set stop_time [expr $sim_time]
    $ns at $stop_time "$rftp($i) stop"
}
# End: agents and sources --------------------------------------


# Begin: create graphs -----------------------------------------
if { $show_graphs_fwd } {

    if {$show_graphs_util} { 
	set util_graph [new Graph/UtilizationVersusTime $r(0) $r(1) 0.5]
	$util_graph set title_ "Bottleneck Utilization"
    }
    if {$show_graphs_qlen} { 
	set qlen_graph [new Graph/QLenVersusTime $r(0) $r(1) 0.01]
	$qlen_graph set title_ "Bottleneck Queue Length"
    }
    for { set i 0 } { $i < $num_fwd_flow } { incr i } {
	if {$show_graphs_cwnd} { 
	    set cwnd_graph($i) [new Graph/CWndVersusTime $tcp($i) 0.01]
	    $cwnd_graph($i) set title_ "Congestion Window"
	}
	if {$show_graphs_rate} { 
	    #set rate_graph($i) [new Graph/RateVersusTime $s($i) $r(0) 0.5]
	    set rate_graph($i) [new Graph/RateVersusTime $r($num_btnk) $d($i) 0.5]
	    $rate_graph($i) set title_ "Throughput"
	}
	if {$show_graphs_srtt} { 
	    set srtt_graph($i) [new Graph/SRTTVersusTime $tcp($i) 0.01]
	    $srtt_graph($i) set title_ "SRTT"
	}
	if {$show_graphs_rtt} { 
	    set rtt_graph($i) [new Graph/RTTVersusTime $tcp($i) 0.01]
	    $rtt_graph($i) set title_ "RTT"
	}
	if {$show_graphs_seqno} { 
	    set seqno_graph($i) [new Graph/Sequence $s($i) $r(0) 200000000]
	    $seqno_graph($i) set title_ "Sequence Num"
	}
    }
}

if { $show_graphs_rev } {

    if {$show_graphs_util} { 
	set r_util_graph [new Graph/UtilizationVersusTime $r(1) $r(0) 0.5]
	$r_util_graph set title_ "Rev Bottleneck Utilization"
    }
    if {$show_graphs_qlen} { 
	set r_qlen_graph [new Graph/QLenVersusTime $r(1) $r(0) 0.01]
	$r_qlen_graph set title_ "Rev Bottleneck Queue Length"
    }
    for { set i 0 } { $i < $num_rev_flow } { incr i } {
	if {$show_graphs_cwnd} { 
	    set r_cwnd_graph($i) [new Graph/CWndVersusTime $rtcp($i) 0.01]
	    $r_cwnd_graph($i) set title_ "Rev Congestion Window"
	}
	if {$show_graphs_rate} { 
	    #set r_rate_graph($i) [new Graph/RateVersusTime $rs($i) $r($num_btnk) 0.5]
	    #$r_rate_graph($i) set title_ "Rev Throughput (bps)"
	    set r_rate_graph($i) [new Graph/RateVersusTime $r(0) $rd($i) 0.5]
	    $r_rate_graph($i) set title_ "Rev Throughput"
	}
	if {$show_graphs_srtt} {
	    set r_srtt_graph($i) [new Graph/SRTTVersusTime $rtcp($i) 0.01]
	    $r_srtt_graph($i) set title_ "Rev SRTT"
	}
	if {$show_graphs_rtt} { 
	    set r_rtt_graph($i) [new Graph/RTTVersusTime $rtcp($i) 0.01]
	    $r_rtt_graph($i) set title_ "Rev RTT"
	}
	if {$show_graphs_seqno} { 
	    set r_seqno_graph($i) [new Graph/Sequence $rs($i) $r($num_btnk) 200000000]
	    $r_seqno_graph($i) set title_ "Rev Sequence Num"
	}
    }
}
# End: create graphs -------------------------------------------

# progress indicator
proc progress { time } { puts "time: $time s" }
if { $show_progress } {
    for { set i 0 } { $i < $sim_time } { incr i } {
	if { $i % 5 == 0 } { $ns at $i "progress { $i }" }
    }
}

# Run the simulation
$ns at $sim_time "finish"
$ns run
