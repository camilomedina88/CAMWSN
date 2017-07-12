# Import the GridFTP class
source gridftp.tcl

# Create a simulator object
set ns [new Simulator]
# Open the trace file
set nd [open node3-p8.tr w]


set bandwith21 92.834
set bandwith31 [expr 1448.732/1024]

set parallel21  8
set parallel31  8

set start21_1 600.0
set stop21_1 618.6
set start21_2 1200.0
set stop21_2 1218.4


set start31 0.0
set stop31 1787.2


$ns trace-all $nd

# Define the 'finish' procedure
proc finish {} {
  global nd ns
  close $nd
  exit 0
}

# Create three nodes
set node1 [$ns node]
set node2 [$ns node]
set node3 [$ns node]

# Create links between the nodes
$ns duplex-link $node1 $node2 [expr $bandwith21]Mb 2ms DropTail
$ns duplex-link $node1 $node3 [expr $bandwith31]Mb 10ms DropTail

# Create an GridFTP application, then attach it to node2, node3, node4 and node5
set gridftp2 [new Application/GridFTP]
$gridftp2 setParallel $parallel21
$gridftp2 setPacketSize 1474
$gridftp2 setRatio 1:1:1:1:1:1:1:1
$gridftp2 setWindows 20
$ns attach-agent $node2 $gridftp2

set gridftp3 [new Application/GridFTP]
$gridftp3 setParallel $parallel31
$gridftp3 setPacketSize 1474
$gridftp3 setRatio 1:1:1:1:1:1:1:1
$gridftp3 setWindows 20
$ns attach-agent $node3 $gridftp3

# Create a GridFTP sink agent and attach it to node1
set gridftpsink21 [new Agent/GridFTPSink]
$gridftpsink21 setParallel $parallel21
$gridftpsink21 setPacketSize 66
$ns attach-agent $node1 $gridftpsink21
$ns connect $gridftp2 $gridftpsink21

set gridftpsink31 [new Agent/GridFTPSink]
$gridftpsink31 setParallel $parallel31
$gridftpsink31 setPacketSize 66
$ns attach-agent $node1 $gridftpsink31
$ns connect $gridftp3 $gridftpsink31

# Schedule events for all the connections
$ns at $start31 "$gridftp3 start"
$ns at $start21_1 "$gridftp2 start"
$ns at $stop21_1 "$gridftp2 stop"
$ns at $start21_2 "$gridftp2 start"
$ns at $stop21_2 "$gridftp2 stop"
$ns at $stop31 "$gridftp3 stop"

# Call the finish procedure
$ns at 1788 "finish"

# Run the simulation
$ns run