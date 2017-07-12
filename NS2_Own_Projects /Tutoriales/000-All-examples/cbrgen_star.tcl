# The copyright for the original script lies with the following author. 
#
#  Copyright (c) 1999 by the University of Southern California
#  All rights reserved.

# Modified by:
# Vaddina Prakash Rao
# Chair of Telecommunications
# TU Dresden

# Traffic source generator from CMU's mobile code.

# Program to generate random traffic sources out of nodes, with the coordinator as the destination.

# ======================================================================
# Default Script Options
# ======================================================================
# The following default values are used when not provided

set opt(nn)		0		;# Number of Nodes
set opt(seed)	0.0		;# Random number generator seed value
set opt(mc)		0		;# Number of sources
set opt(pktsize)	70		;# Packet size

set opt(rate)		0		;# Datarate
set opt(interval)	0.0		;# inverse of rate
set opt(type)           ""		;# Traffic type
set opt(starttime)	20.0;#Traffic start time
set opt(timegap)	5.0		;# Default traffic gap time
#array set sources {}
# ======================================================================

proc usage {} {
    global argv0

    puts "\nusage: $argv0 \[-type cbr|tcp\] \[-nn nodes\] \[-seed seed\] \[-mc connections\] \[-rate rate\] \[-starttime st\] \[-timegap tg\]\n"
}

proc getopt {argc argv} {
	global opt
	lappend optlist nn seed mc rate type starttime timegap

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		if {[string range $arg 0 0] != "-"} continue

		set name [string range $arg 1 end]
		set opt($name) [lindex $argv [expr $i+1]]
	}
}

proc create-cbr-connection { src dst stime } {
	global rng cbr_cnt opt

# The following line specifies the interval within which the flows will start.
	#set stime [$rng uniform 0.0 10.0]

	puts "#\n# $src connecting to $dst at time $stime\n#"

	##puts "set cbr_($cbr_cnt) \[\$ns_ create-connection \
		##CBR \$node_($src) CBR \$node_($dst) 0\]";
	puts "set udp_($cbr_cnt) \[new Agent/UDP\]"
	puts "\$ns_ attach-agent \$node_($src) \$udp_($cbr_cnt)"
	puts "set null_($cbr_cnt) \[new Agent/Null\]"
	puts "\$ns_ attach-agent \$node_($dst) \$null_($cbr_cnt)"
	puts "set cbr_($cbr_cnt) \[new Application/Traffic/CBR\]"
	puts "\$cbr_($cbr_cnt) set packetSize_ $opt(pktsize)"
	puts "\$cbr_($cbr_cnt) set interval_ $opt(interval)"
	puts "\$cbr_($cbr_cnt) set random_ 1"
	puts "\$cbr_($cbr_cnt) set maxpkts_ 10000"
	puts "\$cbr_($cbr_cnt) attach-agent \$udp_($cbr_cnt)"
	puts "\$ns_ connect \$udp_($cbr_cnt) \$null_($cbr_cnt)"

	puts "\$ns_ at $stime \"\$cbr_($cbr_cnt) start\""

	incr cbr_cnt
}

proc create-tcp-connection { src dst stime } {
	global rng cbr_cnt opt

	#set stime [$rng uniform 0.0 180.0]

	puts "#\n# $src connecting to $dst at time $stime\n#"

	puts "set tcp_($cbr_cnt) \[\$ns_ create-connection \
		TCP \$node_($src) TCPSink \$node_($dst) 0\]";
	puts "\$tcp_($cbr_cnt) set window_ 32"
	puts "\$tcp_($cbr_cnt) set packetSize_ $opt(pktsize)"

	puts "set ftp_($cbr_cnt) \[\$tcp_($cbr_cnt) attach-source FTP\]"


	puts "\$ns_ at $stime \"\$ftp_($cbr_cnt) start\""

	incr cbr_cnt
}

# ======================================================================

getopt $argc $argv

if { $opt(type) == "" } {
    usage
    exit
} elseif { $opt(type) == "cbr" } {
    if { $opt(nn) == 0 || $opt(seed) == 0.0 || $opt(mc) == 0 || $opt(rate) == 0 } {
	usage
	exit
    }

    set opt(interval) [expr 1 / $opt(rate)]
    if { $opt(interval) <= 0.0 } {
	puts "\ninvalid sending rate $opt(rate)\n"
	exit
    }
}

puts "#\n# nodes: $opt(nn), max conn: $opt(mc), send rate: $opt(interval), seed: $opt(seed)\n#"

set rng [new RNG]
$rng seed $opt(seed)

set u [new RandomVariable/Uniform]
$u set min_ 0
$u set max_ $opt(nn)
$u use-rng $rng

set cbr_cnt 0
set src_cnt 0
set flag 0
set loopcount $opt(nn)


for {set i 0} {$i < $loopcount } {incr i} {


	while {1} {
	set x [$u value]
	set x [expr $x/0.01]
	if {$x < $opt(nn)} {
	    set src [expr round($x)]
	    break
	}
	}

	if { $src >= $opt(nn) } {
	set src [expr $opt(nn)-1]
	}

	# Add the generated source to the list unless we already had the source before
	if {[array size sources] == 0} {
	    set sources(0) $src
	} else {
	    # Comparing each source in the list to the currently generated source, to see if there is a match
	    for {set p 0} {$p < [array size sources]} {incr p 1} {
		if {$src == $sources($p)} {
		    set flag 1
		    break
		}
	    }

	    if {$src == 0} {
		set flag 1
	    }

	    # If there is a match, break from the current loop (discard the source)
	    if {$flag == 1} {
		set flag 0
		incr loopcount 1
		continue
	    } else {
		set size [array size sources]
		set sources($size) $src
	    }
	}

	# We always want the destination to be node-0.
	set dst 0

	if { $opt(type) == "cbr" } {
		incr src_cnt 1
		create-cbr-connection $src $dst $opt(starttime)
	} else {
		create-tcp-connection $src $dst $opt(starttime)
	}

	if { $src_cnt == $opt(mc) } {
	# You have created the required number of sources. So break now !!
		break
	} else {
	# The required number of sources have not been reached yet, even though it is highly unlikely.
	    set temp $loopcount
	    incr temp -1
	    if {$i == $temp} {
		incr loopcount 1
	    }
	}

	set opt(starttime) [expr $opt(starttime)+$opt(timegap)]
}

puts "#\n#Total sources: $src_cnt\n#"



