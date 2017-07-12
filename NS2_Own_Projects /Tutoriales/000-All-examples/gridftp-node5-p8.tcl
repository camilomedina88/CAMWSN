# Import the GridFTP class
source gridftp.tcl

# Create a simulator object
set ns [new Simulator]
# Open the trace file
set nd [open node5-p8.tr w]


set bandwith21 52.087
set bandwith31 46.415
set bandwith41 [expr 848.543/1024]
set bandwith51 [expr 848.423/1024]

set parallel21 8
set parallel31 8
set parallel41 8
set parallel51 8

set start21_1 600.0
set stop21_1 632.7
set start21_2 1200.0
set stop21_2 1231.7

set start31_1 600.0
set stop31_1 636.8
set start31_2 1200.0
set stop31_2 1236.9

set start41 0.0
set stop41 1779.4

set start51 0.0
set stop51 1773.8

$ns trace-all $nd

# Define the 'finish' procedure
proc finish {} {
  global nd ns
  close $nd
  exit 0
}

# Create five nodes
set node1 [$ns node]
set node2 [$ns node]
set node3 [$ns node]
set node4 [$ns node]
set node5 [$ns node]

# Create links between the nodes
$ns duplex-link $node1 $node2 [expr $bandwith21]Mb 15ms DropTail
$ns duplex-link $node1 $node3 [expr $bandwith31]Mb 15ms DropTail
$ns duplex-link $node1 $node4 [expr $bandwith41]Mb 10ms DropTail
$ns duplex-link $node1 $node5 [expr $bandwith51]Mb 10ms DropTail

# Monitor the queue for the link between node 2 and node 3
$ns duplex-link-op $node1 $node2 queuePos 0.5

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

set gridftp4 [new Application/GridFTP]
$gridftp4 setParallel $parallel41
$gridftp4 setPacketSize 1474
$gridftp4 setRatio 1:1:1:1:1:1:1:1
$gridftp4 setWindows 20
$ns attach-agent $node4 $gridftp4

set gridftp5 [new Application/GridFTP]
$gridftp5 setParallel $parallel51
$gridftp5 setPacketSize 1474
$gridftp5 setRatio 1:1:1:1:1:1:1:1
$gridftp5 setWindows 20
$ns attach-agent $node5 $gridftp5

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

set gridftpsink41 [new Agent/GridFTPSink]
$gridftpsink41 setParallel $parallel41
$gridftpsink41 setPacketSize 66
$ns attach-agent $node1 $gridftpsink41
$ns connect $gridftp4 $gridftpsink41

set gridftpsink51 [new Agent/GridFTPSink]
$gridftpsink51 setParallel $parallel51
$gridftpsink51 setPacketSize 66
$ns attach-agent $node1 $gridftpsink51
$ns connect $gridftp5 $gridftpsink51

# Schedule events for all the connections
$ns at $start41 "$gridftp4 start"
$ns at $start51 "$gridftp5 start"
$ns at $start21_1 "$gridftp2 start"
$ns at $start31_1 "$gridftp3 start"
$ns at $stop21_1 "$gridftp2 stop"
$ns at $stop31_1 "$gridftp3 stop"
$ns at $start21_2 "$gridftp2 start"
$ns at $start31_2 "$gridftp3 start"
$ns at $stop21_2 "$gridftp2 stop"
$ns at $stop31_2 "$gridftp3 stop"
$ns at $stop41 "$gridftp4 stop"
$ns at $stop51 "$gridftp5 stop"

# Call the finish procedure
$ns at 1780 "finish"

# Run the simulation
$ns run