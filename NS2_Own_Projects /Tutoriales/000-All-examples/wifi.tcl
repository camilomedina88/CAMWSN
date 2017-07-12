# author: C.Cicconetti <claudio.cicconetti@iet.unipi.it>

;# system parameters
set opt(n)         2      ;# number of wireless nodes
set opt(lambda)    100    ;# area length, in meters
set opt(radius)    20     ;# QAP distance, in meters
set opt(run)       0      ;# replic ID
set opt(duration)  170.0   ;# run duration, in seconds
set opt(warm)      50.0   ;# run duration, in seconds
set opt(out)       "out"  ;# FIFO out
set opt(trc)       "/dev/null"

proc getopt {argc argv} {
   global opt

   for {set i 0} {$i < $argc} {incr i} {
      set arg [lindex $argv $i]
      if {[string range $arg 0 0] != "-"} continue

      set name [string range $arg 1 end]
      set opt($name) [lindex $argv [expr $i+1]]
   }
}


proc finish {} {
   global ns opt      ;# input

	# flush traces
	$ns flush-trace

	# close trace files
	close $opt(trace)

	$ns stat print

   exit 0
}

proc init {} {
   global opt defaultRNG ns

	# create the simulator instance
   set ns [new Simulator]  ;# create a new simulator instance
	$defaultRNG seed 1

	# initialize statistics collection
	$ns run-identifier $opt(run)
	$ns stat file "$opt(out)"
	$ns at $opt(warm) "$ns stat on"
	$ns at $opt(duration) "finish"

   # open trace files
	set opt(trace) [open $opt(trc) w]

   $ns use-newtrace
	$ns trace-all $opt(trace)
}

proc create_topology {} {
   global ns opt topo sta defaultRNG

	;# set PHY parameters (IEEE802.11b)
	Mac/802_11 set SlotTime_          0.000020        ;# 20us
	Mac/802_11 set SIFS_              0.000010        ;# 10us
	Mac/802_11 set PreambleLength_    144             ;# 144 bits
	Mac/802_11 set PLCPHeaderLength_  48              ;# 48 bits
	Mac/802_11 set PLCPDataRate_      1.0e6           ;# 1Mbps
	Mac/802_11 set dataRate_          2.0e6           ;# 11Mbps
	Mac/802_11 set basicRate_         1.0e6           ;# 1Mbps

	;# set MAC parameters
	Mac/802_11 set CWMin_             31      ;# minimum contention window
	Mac/802_11 set CWMax_             1023    ;# maximum contention window
	Mac/802_11 set RTSThreshold_      2500    ;# RTS threshold
	Mac/802_11 set ShortRetryLimit_   7       ;# short retry limit
	Mac/802_11 set LongRetryLimit_    4       ;# long retry limit

   set topo [new Topography]      ;# Create topography
   create-god [expr $opt(n) + 1]  ;# create the General Operations Director
   $topo load_flatgrid $opt(lambda) $opt(lambda) ;# load a flat grid
   set chan_1 [new Channel/WirelessChannel]      ;# create the wireless channel

	;# set the node configuration
   $ns node-config \
	   -adhocRouting AODV \
      -llType LL \
      -macType Mac/802_11 \
      -ifqType Queue/DropTail/PriQueue \
      -ifqLen 50 \
      -antType Antenna/OmniAntenna \
      -propType Propagation/TwoRayGround \
      -phyType Phy/WirelessPhy \
      -topoInstance $topo \
      -agentTrace ON \
      -routerTrace ON \
      -macTrace  ON \
      -movementTrace  ON \
      -channel $chan_1

	# turn on the End of Transmission trace
	Simulator set EotTrace_ ON

   # creating mobile nodes
   for {set i 0} {$i <= $opt(n)} {incr i} {
      set sta($i) [$ns node]      ;# create new node
      $sta($i) random-motion 0    ;# disable random motion

		if { $i > 0 } {
			set angle [expr (2 * acos(-1.0) / $opt(n)) * $i]
			$sta($i) set X_ [expr $opt(lambda) / 2.0 + $opt(radius) * sin($angle)]
			$sta($i) set Y_ [expr $opt(lambda) / 2.0 - $opt(radius) * cos($angle)]
		} else {
			$sta($i) set X_ [expr $opt(lambda) / 2.0]
			$sta($i) set Y_ [expr $opt(lambda) / 2.0]
		}
		$sta($i) set Z_ 0
      $ns initial_node_pos $sta($i) 20

      puts "node $i ([$sta($i) set X_], [$sta($i) set Y_]) created"
   }
}

proc create_connections {} {
	global sta ns opt defaultRNG

	for { set dir 0 } { $dir <= 1 } { incr dir } {
		for { set j 1 } { $j <= $opt(n) } { incr j } {

			# i is even => downlink (dir = 0)
			# i is odd  => uplink   (dir = 1)
			set i [expr 2 * $j - $dir]

			# create application
			set rng($i) [new RNG]
			set application($i) [new Application/Traffic/Exponential]
			$application($i) use-rng $rng($i)
			$application($i) set burst_time_ 1.004  ;# talkspurt (seconds)
			$application($i) set idle_time_  1.587  ;# silence (seconds)
			$application($i) set rate_       64000  ;# bits/s (G.711 codec)
			$application($i) set packetSize_ 160    ;# bytes
			$ns at [expr ($i - 1) * 5] "$application($i) start"
			$ns at [expr ($i - 1) * 5 + 0.01]  "$application($i) stop"
			$ns at [expr 1 + 2 * $opt(n) * 5 + [$defaultRNG uniform 0 1]] "$application($i) start"

			# create agents
			set agtsrc($i) [new Agent/UDP]
			set agtdst($i) [new Agent/UDP]
			$agtsrc($i) set class_ [expr $i]

			# connect agents
			if { $dir == 0 } {
				$ns attach-agent $sta(0) $agtsrc($i)
				$ns attach-agent $sta($j) $agtdst($i)
			} else {
				$ns attach-agent $sta($j) $agtsrc($i)
				$ns attach-agent $sta(0) $agtdst($i)
			}
			$ns connect $agtsrc($i) $agtdst($i)
			$application($i) attach-agent $agtsrc($i)

			# connect e2e tagger and monitor
			set tagger($i)  [new e2et]
			set monitor($i) [new e2em]
			$agtsrc($i) attach-e2et $tagger($i)
			$agtdst($i) attach-e2em $monitor($i)
			$monitor($i) start-log
		}
	}
}

# main body starts here
getopt $argc $argv

# compute run duration and warmup time
set opt(duration)  [expr 1 + 2 * 5 * $opt(n) + 160 * ( 1 + $opt(n))]
set opt(warm)      [expr 1 + 2 * 5 * $opt(n) + 20  * ( 1 + $opt(n))]

init
create_topology
create_connections

$ns run
