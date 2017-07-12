# Queue-monitor usage illustration

# Basic ns setup
set ns [new Simulator]

# dummy.tr is a dummy file, no use at all
set f [open dummy.tr w] 

# setup queue monitor, monitoring queue between node $n(1) and $n(0)
set qmon [$ns monitor-queue $n(1) $n(0) $f]

# drop.trace record both instantaneous queue size and
#            drop rate (over last T secs) 
set df [open drop.trace w]

# at 100.0 clean-up counters in queue-monitor
$ns at 100.0 "clean-up $qmon"

proc clean-up { qmon } {

	# parrivals_ -- # of pkts arrived so far
        # pdrops_    -- # of pkts drops
	$qmon set parrivals_ 0 
	$qmon set pdrops_ 0 
}

# at 120.0 compute the drop rate over 20.0 seconds interval
$ns at 120.0 "trace-droprate $df 20.0"

proc trace-droprate { fptr intv } {
    global ns qmon 

    set now [$ns now]
    # get parrival_ and pdrops_ over the last $intv seconds
    set arr [$qmon set parrivals_]
    set drop [$qmon set pdrops_]

    # pkts_ records the current *instantaneous* queue size
    # to get average queue size (e.g. exponential-moving-average)
    # you have to modify queue-monitor.cc file to do it 
    # on the fly (modify in(), out(), drop() functions)
    set pkt [$qmon set pkts_]

    # clear counters again
    $qmon set parrivals_ 0
    $qmon set pdrops_ 0

    # compute loss rate (pdrops_ / $parrivals_)
    if { $arr > 0 } {
	set dr [expr $drop*1.0/$arr]
    } else {
	set dr 0
    }

    # record them in the output file
    puts $fptr "$now $pkt $dr"

    # recursively call this function
    $ns at [expr $now + $intv] "trace-droprate $fptr $intv"
}


## Start the simulation
$ns at $simtime "finish"

proc finish {} {
	global ns df 
	$ns flush-trace

	close $df
	exit 0
}

puts "ns started"
$ns run

