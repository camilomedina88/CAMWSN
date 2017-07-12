# This example uses the Java PAICommands class to 
# send data between two NS2 nodes.  The actual Java
# code specifies which nodes to communicate with.
# This simple example demonstrates how Java objects
# can be attached to an NS2 nodes and used to 
# create sockets and send data between nodes.

# Create multicast enabled simulator instance
set ns_ [new Simulator -multicast on]
$ns_ multicast

# Create two nodes
set n1 [$ns_ node]
set n2 [$ns_ node]

# Put a link between them
$ns_ duplex-link $n1 $n2 64kb 100ms DropTail
$ns_ queue-limit $n1 $n2 100
$ns_ duplex-link-op $n1 $n2 queuePos 0.5
$ns_ duplex-link-op $n1 $n2 orient right

# Configure multicast routing for topology
set mproto DM
set mrthandle [$ns_ mrtproto $mproto  {}]
 if {$mrthandle != ""} {
     $mrthandle set_c_rp [list $n1]
}


puts "Creating JavaAgent NS2 agents and attach them to the nodes..."   
set p1 [new Agent/Agentj]
$ns_ attach-agent $n1 $p1

set p2 [new Agent/Agentj]
$ns_ attach-agent $n2 $p2

puts "In script: Initializing agents  ..." 
	
$ns_ at 0.0 "$p1 initAgent"
$ns_ at 0.0 "$p2 initAgent"

puts "Setting Java Object to use by each agent ..." 

$ns_ at 0.0 "$p1 attach-agentj agentj.examples.tcp.UDPAndTCPClient"
$ns_ at 0.0 "$p2 attach-agentj agentj.examples.tcp.UDPAndTCPServer"

puts "Starting simulation ..." 

# Use multicast discovery to find out the server's address

$ns_ at 0.0 "$p1 agentj initUDP"
$ns_ at 1.0 "$p2 agentj initUDP"

$ns_ at 2.0 "$p1 agentj getUDPMessage"
$ns_ at 3.0 "$p2 agentj sendUDPMessage"

# Now open up a TCP connection and send a message to the server

$ns_ at 6.0 "$p2 agentj open"
$ns_ at 7.0 "$p2 agentj accept"

$ns_ at 8.0 "$p1 agentj open"
$ns_ at 9.0 "$p1 agentj send"

$ns_ at 100.0 "finish $ns_"

proc finish {ns_} {
$ns_ halt
delete $ns_
}

$ns_ run
