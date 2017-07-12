# This example uses the Java PAICommands class to 
# send data between two NS2 nodes.  The actual Java
# code specifies which nodes to communicate with.
# This simple example demonstrates how Java objects
# can be attached to an NS2 nodes and used to 
# create sockets and send data between nodes.

# Create multicast enabled simulator instance
set ns_ [new Simulator -multicast on]
$ns_ multicast

# Create 9 nodes
set n0 [$ns_ node]
set n1 [$ns_ node]
set n2 [$ns_ node]
set n3 [$ns_ node]
set n4 [$ns_ node]
set n5 [$ns_ node]
set n6 [$ns_ node]
set n7 [$ns_ node]
set n8 [$ns_ node]

# Put a link between them
$ns_ duplex-link $n1 $n2 64kb 100ms DropTail
$ns_ queue-limit $n1 $n2 100
$ns_ duplex-link-op $n1 $n2 queuePos 0.5
$ns_ duplex-link-op $n1 $n2 orient right

$ns_ duplex-link $n1 $n3 64kb 100ms DropTail
$ns_ queue-limit $n1 $n3 100
$ns_ duplex-link-op $n1 $n3 queuePos 0.5
$ns_ duplex-link-op $n1 $n3 orient up-left

$ns_ duplex-link $n1 $n4 64kb 100ms DropTail
$ns_ queue-limit $n1 $n4 100
$ns_ duplex-link-op $n1 $n4 queuePos 0.5
$ns_ duplex-link-op $n1 $n4 orient down-left

$ns_ duplex-link $n1 $n5 64kb 100ms DropTail
$ns_ queue-limit $n1 $n5 100
$ns_ duplex-link-op $n1 $n5 queuePos 0.5
$ns_ duplex-link-op $n1 $n5 orient down

$ns_ duplex-link $n5 $n6 64kb 100ms DropTail
$ns_ queue-limit $n5 $n6 100
$ns_ duplex-link-op $n5 $n6 queuePos 0.5
$ns_ duplex-link-op $n5 $n6 orient down-left

$ns_ duplex-link $n5 $n7 64kb 100ms DropTail
$ns_ queue-limit $n5 $n7 100
$ns_ duplex-link-op $n5 $n7 queuePos 0.5
$ns_ duplex-link-op $n5 $n7 orient down-right

$ns_ duplex-link $n2 $n0 64kb 100ms DropTail
$ns_ queue-limit $n2 $n0 100
$ns_ duplex-link-op $n2 $n0 queuePos 0.5
$ns_ duplex-link-op $n2 $n0 orient up-right

$ns_ duplex-link $n2 $n8 64kb 100ms DropTail
$ns_ queue-limit $n2 $n8 100
$ns_ duplex-link-op $n2 $n8 queuePos 0.5
$ns_ duplex-link-op $n2 $n8 orient down-right

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

$ns_ at 0.0 "$p2 attach-agentj agentj.examples.udp.RespondingServer"
$ns_ at 0.0 "$p1 attach-agentj agentj.examples.udp.ConvergentSender"

puts "Starting simulation ..." 

$ns_ at 0.0 "$p2 agentj init"

$ns_ at 1.0 "$p1 agentj send [$n2 node-addr]"

$ns_ at 100.0 "finish $ns_"

proc finish {ns_} {
$ns_ halt
delete $ns_
}

$ns_ run

