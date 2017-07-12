# Get default options
source sta_voip-default_options.tcl

# Station position
for {set i 1} {$i < $val(nn)+1 } {incr i 1} {
	$node_([expr $i-1]) set X_ [expr $val(X)-$i]
	$node_([expr $i-1]) set Y_ [expr $val(Y)-$i]
	$node_([expr $i-1]) set Z_ 0.0
}


# Flow from this station to all the others
set flowid 0
	
# only one flow
# ----------------------------------------------------------------------
# 	set i 0
# 	set udp($flowid) [new Agent/UDP]
# 	set null($flowid) [new Agent/Null]
# 	$ns_ attach-agent $node_($i) $udp($flowid)
# 	$ns_ attach-agent $node_([expr ($i+1) % $val(nn)]) $null($flowid)
# 	$ns_ connect $udp($flowid) $null($flowid)
# 	set cbr($flowid) [new Application/Traffic/CBR]
# 	$cbr($flowid) attach-agent $udp($flowid)
# #	$ns_ at [expr $val(start)+[expr $i / 1000]] "$cbr($flowid) start" 
# 	$ns_ at [expr $val(start)+ $i]] "$cbr($flowid) start" 
# 	set flowid [expr $flowid + 1]


# multi flows
# ----------------------------------------------------------------------
for {set i 0} {$i < $val(nn) } {incr i 1} {
	set udp($flowid) [new Agent/UDP]
	set null($flowid) [new Agent/Null]
	$ns_ attach-agent $node_($i) $udp($flowid)
	$ns_ attach-agent $node_([expr ($i+1) % $val(nn)]) $null($flowid)
	$ns_ connect $udp($flowid) $null($flowid)
	set cbr($flowid) [new Application/Traffic/Exponential]
	$cbr($flowid) attach-agent $udp($flowid)
	$ns_ at $val(start) "$cbr($flowid) start" 
	set flowid [expr $flowid + 1]
}
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

