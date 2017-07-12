# ---------------------------------------------------------------------------------
#  Two station scenario			 
# ---------------------------------------------------------------------------------

# Get default options
source hdtv-default_options.tcl

# Station position
#puts "---------------------------------------------------------------------"
for {set i 1} {$i < $val(nn)+1 } {incr i 1} {
	$node_([expr $i-1]) set X_ [expr $val(X)-$i]
	$node_([expr $i-1]) set Y_ [expr $val(Y)-$i]
	$node_([expr $i-1]) set Z_ 0.0
#	puts "node_([expr $i-1]) position: [expr $val(X)-$i],	[expr $val(Y)-$i],	0.0"
}
#puts "---------------------------------------------------------------------"


# Flow from this station to all the others
#puts "---------------------------------------------------------------------"
set flowid 0
	
# only one flow
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

for {set i 0} {$i < $val(nn) } {incr i 1} {
	set udp($flowid) [new Agent/UDP]
	set null($flowid) [new Agent/Null]
	$ns_ attach-agent $node_($i) $udp($flowid)
	$ns_ attach-agent $node_([expr ($i+1) % $val(nn)]) $null($flowid)
	$ns_ connect $udp($flowid) $null($flowid)
	set cbr($flowid) [new Application/Traffic/CBR]
	$cbr($flowid) attach-agent $udp($flowid)
#	$ns_ at [expr $val(start)+[expr $i / 1000]] "$cbr($flowid) start" 
#	$ns_ at [expr $val(start)+ $i]] "$cbr($flowid) start" 
	$ns_ at $val(start) "$cbr($flowid) start" 
	set flowid [expr $flowid + 1]
}

#puts "---------------------------------------------------------------------"



