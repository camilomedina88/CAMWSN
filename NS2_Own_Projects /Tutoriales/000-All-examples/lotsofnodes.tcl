# This example uses the Java PAICommands class to 
# send data between two NS2 nodes.  The actual Java
# code specifies which nodes to communicate with.
# This simple example demonstrates how Java objects
# can be attached to an NS2 nodes and used to 
# create sockets and send data between nodes.

set val(nn) 500

# Create multicast enabled simulator instance
set ns_ [new Simulator]

for {set i 0} {$i < $val(nn) } {incr i} {
    set node_($i) [$ns_ node $i]
}


puts "Creating JavaAgent NS2 agents and attach them to the nodes..."   

for {set i 0} {$i < $val(nn) } {incr i} {
	set p($i) [new Agent/Agentj]
	$ns_ attach-agent $node_($i) $p($i)
	$ns_ at 0.0 "$p($i) initAgent"
   }

puts "Setting Java Object to use by each agent ..." 

for {set i 0} {$i < $val(nn) } {incr i} {
        puts "SCRIPT: Attaching Node ... $i"   
	$ns_ at 0.0 "$p($i) attach-agentj agentj.examples.udp.Client"
}

for {set i 0} {$i < $val(nn) } {incr i} {
	$ns_ at 0.0 "$p($i) agentj init"
}

$ns_ at 10.0 "finish $ns_"

proc finish {ns_} {
$ns_ halt
delete $ns_
}

$ns_ run

