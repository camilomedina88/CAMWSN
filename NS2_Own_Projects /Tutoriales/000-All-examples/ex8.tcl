#
# example 2:
#
# Demonstrates the use of multiple graphs in the same simulation output
# to the xdvi plotdevice.
#
# author: David Harrison

source $env(NS)/tcl/rpi/graph.tcl

# creates two columns of graphs on each page output by the plot device.  
# The graphs are displayed left-to-right and then top-to-bottom on the page. 
# For example, the first graph appears in the upper-left corner of the page, 
# the second appears to its right.  Note that this is only supported by
# PlotDevice objects that use latex PlotDevice.  In other words,
# n_plots_per_row_ works with xdvi, acroread, and latex.  It is ignored
# by other PlotDevice objects.
latex set n_plots_per_row_ 2

# If acroread, gnuplot, or pdflatex is not installed on your machine then 
# you will need to choose some other plot device to run this example.
set pd [new acroread]
Graph set plot_device_ $pd
$pd output-latex {\title{Example 8 Simulation Results}\maketitle}

Agent/TCP set window_ 1000000   ;# sooo high so it will never hit it!

# bw-rtt product for 1.544Mbps and 24ms rtt is 4.632 packets.
Queue set limit_ 10

set ns [new Simulator]

proc finish {} {
  global qlen_graph pd

  $qlen_graph display

  $qlen_graph add-hline 10 "Buffer size"
  $qlen_graph set title_ "Bottleneck Queue Length Versus Time"
  $qlen_graph set ylabel_ "Queue Length (in packets)"
  $qlen_graph set xlabel_ "Simulation Time (in seconds)"
  $qlen_graph set caption_ "Two TCP connections traverse this bottleneck."
  $qlen_graph set comment_ "Instantaneous queue"
  $qlen_graph set xcomment_ .3
  $qlen_graph set ycomment_ .65
  $qlen_graph set yhigh_ 11
  $qlen_graph display

  $pd output-latex "We now want to generate another plot." 
  $qlen_graph set xhigh_ 2
  $qlen_graph display

  $pd close

  exit 0
}

# create a topology containing two sources and two destinations.
set s0 [$ns node]
set d0 [$ns node]
set s1 [$ns node]
set d1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]

# create links.
$ns duplex-link $s0 $n0 10M 4ms DropTail
$ns duplex-link $s1 $n0 10M 4ms DropTail
$ns duplex-link $n0 $n1 1.544M 4ms DropTail
$ns duplex-link $n1 $d0 10M 4ms DropTail
$ns duplex-link $n1 $d1 10M 4ms DropTail

set tcp0 [lindex [create-ftp-over-reno $s0 $d0 0.5 0] 0]
set tcp1 [lindex [create-ftp-over-reno $s1 $d1 0.8 1] 0]

set qlen_graph [new Graph/QLenVersusTime $n0 $n1]

$ns at 5 finish
$ns run

