# create a simulator object
source gridftp.tcl
set ns [new Simulator]

# define different colors for nam data flows
$ns color 1 blue
$ns color 2 green
$ns color 3 red
$ns color 4 yellow

# open the nam trace file
set nam_trace_fd [open gridftp-simple-out.nam w]
$ns namtrace-all $nam_trace_fd

#Define a 'finish' procedure
proc finish {} {
        global ns nam_trace_fd

        # close the nam trace file
        $ns flush-trace
        close $nam_trace_fd
        # execute nam on the trace file
        exec nam gridftp-simple-out.nam
        exit 0
}

# create four nodes
set node1 [$ns node]
set node2 [$ns node]

# create links between the nodes
$ns duplex-link $node1 $node2 20Mb 20ms DropTail

# monitor the queue for the link between node 2 and node 3
$ns duplex-link-op $node1 $node2 queuePos 0.5

#Setting for nam
$ns duplex-link-op $node1 $node2 orient right-down

# create an GridFTP application and attach it to node node1
set gridftp [new Application/GridFTP]
$gridftp setParallel 4
$gridftp setPacketSize 1474
#The default ratio is 1:1:1:1
$gridftp setRatio 1:1:1:1
#The default bandwith is 1.0Mb. This should be the same as the bandwith setted to node1 node2
#warning bandwith must is decimal float type, integer is not enough.
$gridftp setBandwith 20.0 
$gridftp setWindows 20
$ns attach-agent $node1 $gridftp

## create a GridFTP sink agent and attach it to node node2
set gridftpsink [new Agent/GridFTPSink]
$gridftpsink setParallel 4 
$gridftpsink setPacketSize 66
$ns attach-agent $node2 $gridftpsink

## connect gridftp and gridftpsink
$ns connect $gridftp $gridftpsink

### schedule events for all the flows
$ns at 0.25 "$gridftp start"
$ns at 1.0 "$gridftp stop"
##
### call the finish procedure
$ns at 6 "finish"

# run the simulation
$ns run
