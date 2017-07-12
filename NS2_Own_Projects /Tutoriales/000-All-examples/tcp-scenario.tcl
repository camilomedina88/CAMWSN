# Get default options
source tcp-default_options.tcl

# Station position
for {set i 1} {$i < $val(nn)+1 } {incr i 1} {
	$node_([expr $i-1]) set X_ [expr $val(X)-$i]
	$node_([expr $i-1]) set Y_ [expr $val(Y)-$i]
	$node_([expr $i-1]) set Z_ 0.0
}


# Flow from this station to all the others
set flowid 0
	


# multi flows: Sack TCP
# ----------------------------------------------------------------------
for {set i 0} {$i < $val(nn) } {incr i 1} {
    # tcp source
    set tcp($flowid) [new Agent/TCP/Sack1]
    $tcp($flowid) set class_ 0
    $tcp($flowid) set prio_ 2
    $tcp($flowid) set ssthresh_ 100
    $tcp($flowid) set window_ 10000

    # tcp sink
    set sink($flowid) [new Agent/TCPSink/Sack1/DelAck]
    $sink($flowid) set prio_ 2
    $sink($flowid) set class_ 0

	$ns_ attach-agent $node_($i) $tcp($flowid)
	$ns_ attach-agent $node_([expr ($i+1) % $val(nn)]) $sink($flowid)
	$ns_ connect $tcp($flowid) $sink($flowid)

#    set app($flowid) [new Application]
    set app($flowid) [new Application/FTP]
	$app($flowid) attach-agent $tcp($flowid)

    # start app
    $ns_ at $val(start) "$app($flowid) start" 
#    $ns_ at $val(start) "$app($flowid) send -1" 

	set flowid [expr $flowid + 1]
}
# ----------------------------------------------------------------------



# multi flows: TCP Tahoe
# ----------------------------------------------------------------------
# for {set i 0} {$i < $val(nn) } {incr i 1} {
# # tcp source
#     set tcp($flowid) [new Agent/TCP]
#     $tcp($flowid) set class_ 0
#     $tcp($flowid) set prio_ 2
#     $tcp($flowid) set ssthresh_ 100
#     $tcp($flowid) set window_ 10000
# 
#     # tcp sink
#     set sink($flowid) [new Agent/TCPSink]
#     $sink($flowid) set prio_ 2
#     $sink($flowid) set class_ 0
# 
#     $ns_ attach-agent $node_($i) $tcp($flowid)
#     $ns_ attach-agent $node_([expr ($i+1) % $val(nn)]) $sink($flowid)
#     $ns_ connect $tcp($flowid) $sink($flowid)
# 
# #    set app($flowid) [new Application]
#     set app($flowid) [new Application/FTP]
#     $app($flowid) attach-agent $tcp($flowid)
# 
#     $ns_ at $val(start) "$app($flowid) start" 
#     set flowid [expr $flowid + 1]
# }
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
#	How to generate poisson
# ----------------------------------------------------------------------

# set e [new Application/Traffic/Exponential] 
# $e set packetSize_ 210 
# $e set burst_time_ 500ms 
# $e set idle_time_ 500ms 
# $e set rate_ 100k

# The Exponential On/Off generator can be con gured to behave as a Poisson process by setting the variable burst_time_ to 0 and the variable rate_ to a very large value.

