# Create a simulator object
set ns [new Simulator]

# Open the nam trace file, associated with nf, log
set nf [open out.nam w]

# Define a 'finish' procedure
proc finish {} {
        global ns 
        $ns flush-trace

                              
        exit 0
}

#Create two nodes
set caller_node [$ns node]
set proxy1_node [$ns node]


set proxy2_node [$ns node]
set callee_node [$ns node]

set node0 [$ns node]


#Create a duplex link between the nodes

$ns duplex-link $caller_node $node0 1000Mb 0ms DropTail
$ns duplex-link $proxy1_node $node0 1000Mb 0ms DropTail
$ns duplex-link $proxy2_node $node0 1000Mb 0ms DropTail
$ns duplex-link $callee_node $node0 1000Mb 0ms DropTail

# create caller
#Create a sip agent and attach it to node caller_node
set caller [new Agent/sipAgent]
$ns attach-agent $caller_node $caller
# Create a SIP traffic source and attach it to udp0
set caller_traffic [new Application/Traffic/SIP]
$caller_traffic set packetSize_ 10
$caller_traffic set interval_ 0.1
$caller_traffic set lambda 180
$caller_traffic set from_ 2
$caller_traffic set to_ 3
$caller_traffic set pc 0
$caller_traffic set named 0 # means that this is caller
$caller_traffic attach-agent $caller
$caller_traffic set up 1
$caller_traffic set down 0

#create Proxy server
set proxy1_traffic [new Application/Traffic/SIP]
$proxy1_traffic set packetSize_ 500
$proxy1_traffic set interval_ 1
$proxy1_traffic set lambda 180
$proxy1_traffic set from_ 2
$proxy1_traffic set to_ 3
$proxy1_traffic set pc 1
$proxy1_traffic set named 1 # means that this is proxy server
$proxy1_traffic set capacity 190
$proxy1_traffic set down 0
$proxy1_traffic set up 2
  
  
set proxy1 [new Agent/sipAgent]
$ns attach-agent $proxy1_node $proxy1
$proxy1_traffic attach-agent $proxy1

# create proxy server 2
set proxy2_traffic [new Application/Traffic/SIP]
$proxy2_traffic set packetSize_ 500
$proxy2_traffic set interval_ 1
$proxy2_traffic set from_ 2
$proxy2_traffic set to_ 3
$proxy2_traffic set pc 2
$proxy2_traffic set named 2 # means that this is proxy server
$proxy2_traffic set capacity 200
$proxy2_traffic set up 3
$proxy2_traffic set down 1

set proxy2 [new Agent/sipAgent]
$ns attach-agent $proxy2_node $proxy2
$proxy2_traffic attach-agent $proxy2


#create callee
#Create a sip agent and attach it to node caller_node
set callee [new Agent/sipAgent]
$ns attach-agent $callee_node $callee

set callee_traffic [new Application/Traffic/SIP]
$callee_traffic set packetSize_ 500
$callee_traffic set interval_ 0.1
$callee_traffic set from_ 2
$callee_traffic set to_ 3
$callee_traffic set pc 3
$callee_traffic set named 3 # means that this is caller
$callee_traffic set down 2
$callee_traffic set up 3

$callee_traffic attach-agent $callee

#set nodeA [new Agent/sipAgentr]
#$ns attach-agent $node0 $nodeA





#Connect the traffic source with the traffic sink
$ns connect $caller $callee
#$ns connect $proxy1 $proxy2  
#$ns connect $proxy2 $callee 
#$ns connect $callee $nodeA


# Schedule events for the CBR agent
$ns at 0.5 "$caller_traffic start"
$ns at 0.25 "$proxy1_traffic start"
$ns at 0.25 "$proxy2_traffic start"
$ns at 90 "$caller_traffic set lambda 500"
$ns at 90 "$proxy1_traffic set lambda 500"

#$ns at 2 "$caller_traffic stop"
$ns at 200 "finish"
# Run the simulation
$ns run

