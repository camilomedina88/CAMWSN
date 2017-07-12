# Create a simulator object
set ns [new Simulator]

# Open a nam trace file
set nf [open dtn-demo-small.nam w]
$ns namtrace-all $nf

# Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
        close $nf
        exec nam dtn-demo-small.nam &
        exit 0
}

# Setup packet type colours for nam.
$ns color 1 Blue
$ns color 2 Chocolate
$ns color 3 Darkgreen
$ns color 4 Purple

# Create nodes
set node1  [$ns node]
set node2  [$ns node]
set node3  [$ns node]
  
# Connect the nodes with links.
$ns duplex-link $node1  $node2 100kb 1ms DropTail
$ns duplex-link $node2  $node3 100kb 1ms DropTail
   
# Create and attach agents.
set dtn1 [new Agent/DTNAgent]
$ns attach-agent $node1 $dtn1
set dtn2 [new Agent/DTNAgent]
$ns attach-agent $node2 $dtn2
set dtn3 [new Agent/DTNAgent]
$ns attach-agent $node3 $dtn3

# Set local region.
$dtn1 region "REGION1"
$dtn2 region "REGION2"
$dtn3 region "REGION3"

# Setup routing table
$dtn1  add "REGION2" $node2 1 1 1500
$dtn1  add "REGION3" $node2 1 2 1500
$dtn2  add "REGION1" $node1 1 1 1500
$dtn2  add "REGION3" $node3 1 1 1500
$dtn3  add "REGION1" $node2 1 2 1500
$dtn3  add "REGION2" $node2 1 1 1500

# Callback functions
Agent/DTNAgent instproc indData {sid did rid cos options lifespan adu} {
    $self instvar node_
    $self instvar $adu
    puts "node [$node_ id] ($did) received bundle from \
              $sid : '$adu'"    
}

Agent/DTNAgent instproc indSendError {sid did rid cos options lifespan adu} {
    $self instvar node_
    puts "node [$node_ id] ($sid) got send error on bundle to \
              $did : '$adu'"
}

Agent/DTNAgent instproc indSendToken {binding sendtoken} {
    $self instvar node_
    puts "node [$node_ id] Send binding $binding bound to token $sendtoken"
    if { [string equal $binding "deleteme" ] } {
        $self cancel $sendtoken
    }
}

Agent/DTNAgent instproc indRegToken {binding regtoken} {
    $self instvar node_
    puts "node [$node_ id] Reg binding $binding bound to token $regtoken"
}

# Register a destination and enable delivery.
$dtn3 register DEFER bindR1 REGION3,$node3:100
# First registration get token 1.
$dtn3 start_delivery 1

# Defina a message to send and send it.
set MESSAGE "HELLO NETWORK"
$ns at 0.1 "$dtn1 send \
            REGION1,$node1:1 \
            REGION3,$node3:100 \
            REGION1,$node1:0 \
            NORMAL \
            CUST,REPFWD,REPCUST,EERCPT \
            300 \
            bindM1 \
            MESSAGE \
            200"

# Set endtime
$ns at 100.0 "finish"

# Run the simulation
$ns run

