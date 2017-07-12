set sink1 5
set sink2 95

set pktsize [lindex $argv 0]
set datarate [lindex $argv 1]

set null_($sink1) [new Agent/Null]
$ns_ attach-agent $node_($sink1) $null_($sink1)

set null_($sink2) [new Agent/Null]
$ns_ attach-agent $node_($sink2) $null_($sink2)

$ns_ at 0.000001 "$ragent_($sink1) startSink [lindex $argv 2]"
$ns_ at 0.000001 "$ragent_($sink2) startSink [lindex $argv 2]"

#for {set j 0} {$j < $opt(nn)} {incr j} {
#    $ns_ at 10.0 "$ragent_($j) sinkdump"
#}

for {set j 0} {$j < 20} {incr j} {
    set nid [expr $j + 34]

    set udp_($j) [new Agent/UDP]
    $ns_ attach-agent $node_($nid) $udp_($j)

    set cbr_($j) [new Application/Traffic/CBR]
    $cbr_($j) set packetSize_ $pktsize
    $cbr_($j) set interval_ $datarate
    $cbr_($j) set random_ 1
    $cbr_($j) attach-agent $udp_($j)

    $ns_ connect $udp_($j) $null_($sink1)

    set udp_([expr $j + 20]) [new Agent/UDP]
    $ns_ attach-agent $node_($nid) $udp_([expr $j + 20])

    set cbr_([expr $j + 20]) [new Application/Traffic/CBR]
    $cbr_([expr $j + 20]) set packetSize_ $pktsize
    $cbr_([expr $j + 20]) set interval_ $datarate
    $cbr_([expr $j + 20]) set random_ 1
    $cbr_([expr $j + 20]) attach-agent $udp_([expr $j + 20])
 
    $ns_ connect $udp_([expr $j + 20]) $null_($sink2)

    $ns_ at 15.0 "$cbr_($j) start"
    $ns_ at 40.0 "$cbr_($j) stop"
    $ns_ at 15.0 "$cbr_([expr $j + 20]) start"
    $ns_ at 40.0 "$cbr_([expr $j + 20]) stop"
}
