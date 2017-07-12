# ======================================================================
# Default Script Options
# ======================================================================
set opt(nn)		0		;# Number of Nodes
set opt(seed)		0.0

# ======================================================================

proc getopt {argc argv} {
	global opt
	lappend optlist nn seed

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		if {[string range $arg 0 0] != "-"} continue

		set name [string range $arg 1 end]
		set opt($name) [lindex $argv [expr $i+1]]
	}
}

#
# Set up TCP connections
#
proc create-tcp-connection { src dst } {
	global rng tcp_cnt

	set stime [$rng uniform 0.0 180.0]

	puts "#\n# $src connecting to $dst at time $stime\n#"

	puts "set tcp_($tcp_cnt) \[\$ns_ create-connection \
		TCP \$node_($src) TCPSink \$node_($dst) 0\]";
	puts "\$tcp_($tcp_cnt) set window_ 32"

	puts "set ftp_($tcp_cnt) \[\$tcp_($tcp_cnt) attach-source FTP\]"


	puts "\$ns_ at $stime \"\$ftp_($tcp_cnt) start\""

	incr tcp_cnt
}


# ======================================================================

getopt $argc $argv

if { $opt(nn) == 0 || $opt(seed) == 0.0 } {
	puts "\nusage: $argv0 \[-nn nodes\] \[-seed seed\]\n"
	exit
}

puts "#\n# Random Number Generator Seed: $opt(seed)\n#"

set rng [new RNG]
$rng seed $opt(seed)

set u [new RandomVariable/Uniform]
$u set min_ 0
$u set max_ 100
$u use-rng $rng

set tcp_cnt 0
set src_cnt 0

for {set i 1} {$i <= $opt(nn) } {incr i} {

	set x [$u value]

	if {$x < 50} {continue;}

	incr src_cnt

	set dst [expr ($i+1) % [expr $opt(nn) + 1] ]
	if { $dst == 0 } {
		set dst [expr $dst + 1]
	}

	create-tcp-connection $i $dst

	if {$x < 75} {continue;}

	set dst [expr ($i+2) % [expr $opt(nn) + 1] ]
	if { $dst == 0 } {
		set dst [expr $dst + 1]
	}

	create-tcp-connection $i $dst
}

puts "#\n#Total TCP sources/connections: $src_cnt/$tcp_cnt\n#"


