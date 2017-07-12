#Get config options
source opts.cfg


#Create a simulator object
set ns_         [new Simulator]

#Open the trace file
$ns_ use-newtrace
set tracefd     [open out.tr w]
$ns_ trace-all $tracefd

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
# Create God
create-god $val(nn)

# configure node
$ns_ node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -channel [new $val(chan)] \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace OFF \
    -macTrace ON \
    -numif  $val(ni) \
    -IncomingErrProc markov

proc uniform {} {
	global val
	set err [new ErrorModel]
	$err unit packet
	$err set rate_ $val(loss)
        $err drop-target [new Agent/Null]
	return $err
}

proc markov {} {
    global val
    set tmp [new ErrorModel]
    $tmp unit pkt
    $tmp set rate_ 0
    set tmp1 [new ErrorModel]
    $tmp1 unit pkt
    $tmp1 set rate_ 1
    set states [list $tmp $tmp1]
    set periods [list $val(pkt_dur) $val(pkt_dur)]
    set transmx {{0.98684 0.01316} {0.25 0.75}}
    set trunit pkt
    set sttype pkt
    set nstates 2
    set nstart $tmp
    set err [new ErrorModel/MultiState $states $periods $transmx $trunit $sttype $nstates $nstart]
    $err drop-target [new Agent/Null]	
    return $err
}


proc create_node { x y z } {
        global ns_ maxprg val
        BiConnector/WP2P_MAC set bandwidth_     $val(bw)
        BiConnector/WP2P_MAC set send_n_        $val(send_n)
        BiConnector/WP2P_MAC set recv_n_        $val(recv_n)
        set newnode [$ns_ node]
        $newnode random-motion 0
        $newnode set X_ $x
        $newnode set Y_ $y
        $newnode set Z_ $z
        return $newnode
}


proc create_cbr_connection { from to startTime interval packetSize fid } {
        global ns_
        set udp0 [new Agent/UDP]
        set src [new Application/Traffic/CBR]
        $udp0 set packetSize_ $packetSize
        $src set packetSize_ $packetSize
        $src set interval_ $interval
        $src set fid_ $fid
        set sink [new Agent/Null]

        $ns_ attach-agent $from $udp0
        $src attach-agent $udp0
        $ns_ attach-agent $to $sink

        $ns_ connect $udp0 $sink
        $ns_ at $startTime "$src start"
        return $udp0
}

proc create_tcp_connection { from to startTime size file} {
    global ns_
    set tcp [new Agent/TCP/Newreno]
    set sink [new Agent/TCPSink]
    $tcp set packetSize_ $size
    $ns_ attach-agent $from $tcp
    $ns_ attach-agent $to $sink
    $ns_ connect $tcp $sink
    set ftp [new Application/FTP]
    $ftp attach-agent $tcp
    $ns_ at  $startTime "$ftp start"
    $tcp attach $file
    $tcp trace cwnd_
    $tcp trace dupacks_
    $tcp trace ack_
    $tcp trace maxseq_
    $tcp trace rtt_
    $tcp trace ndatapack_
    $tcp trace nrexmit_
    $tcp trace nrexmitpack_

}

#create nodes and routing entries
#source the necessary file generated by topo.cc
puts "configuring nodes \n"
source topo.tcl

#create traffic
puts "create traffic \n"
for {set i 0} {$i < $val(nn) } {incr i} {
   if {$i == $val(lline)} {
        continue
   }
# set cbr$i [create_cbr_connection $node_($val(lline)) $node_($i) 0 0.002 $val(size) $i];
    set tcp_par "tcp-output/$i"
    set par($i) [open $tcp_par w]
    set tcp$i [create_tcp_connection $node_($val(lline)) $node_($i) 0.0 $val(size) $par($i)]
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 5.0 "$node_($i) reset";
}
$ns_ at 5.0 "stop"
$ns_ at 5.01 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ tracefd val
    $ns_ flush-trace
    for {set i 0} {$i < $val(nn)} {incr i} {
        if {$i == $val(lline)} {
            continue
        }
        close $par($i)
    }
    close $tracefd
}

puts "Starting Simulation..."
$ns_ run