#
# ex9.tcl
#
# This demonstrates the use of Graph/XY class.  This example
# creates N connections, runs a simultion for a period of time, 
# then collects throughput statistics for each connection.
# It then treats throughput as y values, and plots them as a function
# of round-trip propagation delay.  This gives us a notion of the
# effects of delay on throughput.
#
# author: David Harrison

source $env(NS)/tcl/rpi/graph.tcl


# If ghostview or gnuplot is not installed on your machine then 
# you will need to choose some other plot device to run this example.
# For example you can use xgraph if xgraph is installed.
Graph set plot_device_ [new ghostview]
#Graph set plot_device_ [new xgraph]

set N 8

proc uniform { high } {
  set u [expr ([ns-random] % 10000) * 1.0 / 10000. ]
  return [expr $high * $u]
}


# reset the link statistics.
proc reset {} {
  global lstats N

  for { set i 0 } { $i < $N } { incr i } {
    $lstats($i) reset
  }
}

proc finish {} {
  global xy_graph lstats N

  set fp [open "ex9_thruput_vs_rtpd.txt" "w"]
  for { set i 0 } { $i < $N } { incr i } {
    set thruput [$lstats($i) get-throughput]
    puts $fp "[expr ($i * 4 + 4 + 4) * 2] $thruput"
  }
  close $fp

  $xy_graph display

  [Graph set plot_device_] close
  exit 0
}

set ns [new Simulator]

set xy_graph [new Graph/XY "ex9_thruput_vs_rtpd.txt"]
$xy_graph set title_ \
  "Connection Throughput versus Round-trip Propagation Delay"
$xy_graph set xlabel_ \
  "Round-trip Propagation Delay (in ms)"
$xy_graph set ylabel_ \
  "Throughput (in bps)"


# create a topology containing two sources and two destinations.
for { set i 0 } { $i < $N } { incr i } {
  set s($i) [$ns node]
  set d($i) [$ns node]
}
set b0 [$ns node]
set b1 [$ns node]

# create links.
for { set i 0 } { $i < $N } { incr i } {
  $ns duplex-link $s($i) $b0 10M [expr 4 * $i]ms DropTail
  $ns duplex-link $b1 $d($i) 10M 4ms DropTail
}

$ns duplex-link $b0 $b1 1.544M 4ms DropTail

for { set i 0 } { $i < $N } { incr i } {
  create-ftp-over-reno $s($i) $d($i) [expr 0.5 * $i] $i
}

# create link statistics gathering objects
for { set i 0 } { $i < $N } { incr i } {
  set lstats($i) [new LinkStats $b1 $d($i)]
}

# reset link statistics.
$ns at [expr $N * 0.5 * 2] "reset"
$ns at 30 "finish"
$ns run
