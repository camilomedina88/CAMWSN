# sample ns2 simulation script 

# input parameters
set num_btnk        1 ;# number of bottleneck(s)
set btnk_bw        10 ;# bottleneck capacity, Mbps
set rttp           80 ;# round trip propagation delay, ms
set num_ftp_flow   10 ;# num of long-lived flows, forward path
set num_rev_flow   10 ;# num of long-lived flows, reverse path
set sim_time       50 ;# simulation time, sec

set SRC   TCP/BmccdSrc
set SINK  BmccdSink
set QUEUE DropTailBMCCD/BmccdQueue
set OTHERQUEUE DropTail

# switches
set ns_trace    1
set nam_trace   0

# topology parameters
set non_btnk_bw       [expr $btnk_bw * 2] ;# Mbps

set btnk_delay        [expr $rttp * 0.5 * 0.8]
set non_btnk_delay    [expr $rttp * 0.5 * 0.2 / 2.0]

set min_btnk_buf      [expr 2 * ($num_ftp_flow + $num_rev_flow)] ;# pkt, 2 per flow
set btnk_buf_bdp      1.0 ;# measured in bdp
set btnk_buf          [expr $btnk_buf_bdp * $btnk_bw * $rttp / 8.0] ;# in 1KB pkt
if { $btnk_buf < $min_btnk_buf } { set btnk_buf $min_btnk_buf }
set non_btnk_buf      [expr $btnk_buf]


# Create a simulator object
set ns [new Simulator]

# Open the ns and nam trace files
if { $ns_trace } {
    set ns_file [open ns.trace w]
    $ns trace-all $ns_file
}
if { $nam_trace } {
    set nam_file [open nam.trace w]
    $ns namtrace-all $nam_file
}

proc set-link-bw { n0 n1 } {

    set ns [Simulator instance]

    set link [$ns link $n0 $n1]
    set linkcap [expr [[$link set link_] set bandwidth_]]
    set queue [$link queue]
    $queue set-link-capacity [expr $linkcap]
    #puts "set-link-bw: [expr $linkcap/1000000.0] Mbps"
}

proc finish {} {
    global ns ns_trace nam_trace ns_file nam_file 

    $ns flush-trace
    if { $ns_trace }  { close $ns_file }
    if { $nam_trace } { close $nam_file }

    exit 0
}

# Begin: setup topology ----------------------------------------

# Create router/bottleneck nodes
for { set i 0 } { $i <= $num_btnk } { incr i } {
    set r($i) [$ns node]
}
# router -- router and queue size
for { set i 0 } { $i < $num_btnk } { incr i } {
    # fwd path
    $ns simplex-link $r($i) $r([expr $i+1]) [expr $btnk_bw]Mb [expr $btnk_delay]ms $QUEUE
    $ns queue-limit $r($i) $r([expr $i+1]) [expr $btnk_buf]
    set-link-bw $r($i) $r([expr $i+1])

    # rev path
    $ns simplex-link $r([expr $i+1]) $r($i) [expr $btnk_bw]Mb [expr $btnk_delay]ms $QUEUE
    $ns queue-limit $r([expr $i+1]) $r($i) [expr $btnk_buf]
    set-link-bw $r([expr $i+1]) $r($i)
}

# Create fwd path ftp nodes/links: src/dst -- router
for { set i 0 } { $i < $num_ftp_flow } { incr i } {
    set s($i) [$ns node]
    set d($i) [$ns node]

    $ns duplex-link $s($i) $r(0)         [expr $non_btnk_bw]Mb [expr $non_btnk_delay]ms $OTHERQUEUE
    $ns queue-limit $s($i) $r(0)         [expr $non_btnk_buf]
    $ns queue-limit $r(0)  $s($i)        [expr $non_btnk_buf]

    $ns duplex-link $d($i) $r($num_btnk) [expr $non_btnk_bw]Mb [expr $non_btnk_delay]ms $OTHERQUEUE
    $ns queue-limit $d($i) $r($num_btnk) [expr $non_btnk_buf]
    $ns queue-limit $r($num_btnk) $d($i) [expr $non_btnk_buf]
}

# Create rev path nodes/links: rsrc/rdst -- router
for { set i 0 } { $i < $num_rev_flow } { incr i } {
    set rs($i) [$ns node]
    set rd($i) [$ns node]

    $ns duplex-link $rs($i) $r($num_btnk) [expr $non_btnk_bw]Mb [expr $non_btnk_delay]ms $OTHERQUEUE
    $ns queue-limit $rs($i) $r($num_btnk) [expr $non_btnk_buf]
    $ns queue-limit $r($num_btnk) $rs($i) [expr $non_btnk_buf]

    $ns duplex-link $rd($i) $r(0)         [expr $non_btnk_bw]Mb [expr $non_btnk_delay]ms $OTHERQUEUE
    $ns queue-limit $rd($i) $r(0)         [expr $non_btnk_buf]
    $ns queue-limit $r(0) $rd($i)         [expr $non_btnk_buf]
}
# End: setup topology ------------------------------------------


# randomize flow start time
set start_time_RNG [new RNG]
$start_time_RNG next-substream
set start_time_rnd [new RandomVariable/Uniform]
$start_time_rnd set min_ 1   ;# ms
$start_time_rnd set max_ 300 ;# 
$start_time_rnd use-rng $start_time_RNG 


# Begin: agents and sources ------------------------------------
# Setup fwd connections and FTP sources
for { set i 0 } { $i < $num_ftp_flow } { incr i } {

	set tcp($i) [$ns create-connection $SRC $s($i) $SINK $d($i) $i]
	
	set ftp($i) [$tcp($i) attach-source FTP]

	set start_time [expr [$start_time_rnd value] / 1000.0]
	$ns at $start_time "$ftp($i) start"

	set stop_time  [expr $sim_time]
	$ns at $stop_time "$ftp($i) stop"
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

# Run the simulation
$ns at $sim_time "finish"
$ns run
