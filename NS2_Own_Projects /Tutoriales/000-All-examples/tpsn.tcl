#			http://ube.ege.edu.tr/~erciyes/burak_kulakli_tez.pdf
source config.tcl

set ns_ [new Simulator on]
set chan [new $opt(chan)]
set prop [new $opt(prop)]

set tracefd [open $opt(tr) w]
$ns_ trace-all $tracefd
set namtracefd [open $opt(namtr) w]
$ns_ namtrace-all-wireless $namtracefd $opt(x) $opt(y)

set topo [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

create-god [expr $opt(nn)]

#Define a ’finish’ procedure
proc finish {} {
	global ns_ tracefd namtracefd opt
	$ns_ flush-trace
	close $namtracefd
	close $tracefd
	#exec nam $opt(namtr) &
	exit 0
}

$ns_ node-config -adhocRouting $opt(rp) \
-llType $opt(ll) \
-macType $opt(mac) \
-ifqType $opt(ifq) \
-ifqLen $opt(ifqlen) \
-antType $opt(ant) \
-propInstance $prop \
-phyType $opt(netif) \
-channel $chan \
-topoInstance $topo \
-agentTrace ON \
-routerTrace OFF \
-macTrace ON \
-movementTrace OFF

# Reset seed
expr srand(0)

for {set i 0} {$i < $opt(nn) } {incr i} {
   set node_($i) [$ns_ node]

   set dest_x [expr rand() * $opt(x)]
   set dest_y [expr rand() * $opt(y)]

   # Put node randomdy in a place
   $node_($i) set X_ $dest_x
   $node_($i) set Y_ $dest_y
   $node_($i) set Z_ 0

   # No move
   $node_($i) random-motion 0
   $ns_ at 0 "$node_($i) setdest $dest_x $dest_y 0"

   set udp_($i) [new Agent/TPSNUDP]
   $ns_ attach-agent $node_($i) $udp_($i)
   $udp_($i) set state_ 0
   $udp_($i) set interval_ $opt(interval)
   $udp_($i) set keep_clock_difference_around_ $opt(keep_diff)
   $udp_($i) set chain_sync_enabled_ $opt(chain_sync)
   $udp_($i) set chain_sync_enabled_for_all_ $opt(chain_sync_all)
   $udp_($i) set chain_sync_interrupt_enabled_ $opt(chain_sync_interrupt)
}

for {set i 0} {$i < [expr $opt(nn) - 1] } {incr i} {
   for {set j [expr $i + 1]} {$j < $opt(nn) } {incr j} {
	$ns_ connect $udp_($i) $udp_($j)

   #puts "Connecting $i to $j"
   #$ns_ at [expr 100 * ($i + 1)] "$udp_($i) sync"
  }
}

for {set i 0} {$i < $opt(nn) } {incr i} {
   $ns_ at [expr $opt(interval) * rand()] "$udp_($i) initialise"
}
for {set i 0} {$i < $opt(nn) } {incr i} {
$ns_ at [expr $opt(interval) * rand()] "$udp_($i) enable_child_sync_timer"
}
for {set i 0} {$i < $opt(nn)} {incr i} {
   $ns_ at 0 "$udp_($i) setasalive"
   $ns_ at 0 "$udp_($i) setmaxdepth$max_depth"
   $ns_ at 0 "$udp_($i) setmaxchild$max_child"
   $ns_ at 0 "$udp_($i) setmaxnodeincluster$max_node_in_cluster"
}

for {set i 0} {$i < $opt(nn) } {incr i} {
$ns_ at [expr $opt(stop) - $opt(interval)] "$udp_($i) local_clock"
}

for {set i 0} {$i < $opt(nn) } {incr i} {
$ns_ at [expr $opt(stop) - $opt(interval)] "$udp_($i) time_complexity"
}

#Call the finish procedure
$ns_ at $opt(stop) "finish"

#Run the simulation
puts "Starting Simulation..."
$ns_ run

