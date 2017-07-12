# A Java example, which also implements the ProtoApp
# scenario but this timer uses a multicast address
# to send the data between the nodes.  The first node
# sends the data to the multicast address and the second
# node listens to this address and gets notified when 
# something happens

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


puts "Creating Java Broker Agents ..."   
# Create two Protean example agents and attach to nodes
set p1 [new Agent/Agentj]
$ns_ attach-agent $n1 $p1

set p2 [new Agent/Agentj]
$ns_ attach-agent $n2 $p2

puts "CREATED OK          ....... ..." 
    
# Initialize C++ agents

puts "In script: Initializing  ..." 
	
$ns_ at 0.0 "$p1 initAgent"
$ns_ at 0.0 "$p2 initAgent"

#set up the class

$ns_ at 0.0 "$p1 attach-agentj agentj.examples.udp.TimerMulticast"
$ns_ at 0.0 "$p2 attach-agentj agentj.examples.udp.TimerMulticast"

puts "Starting simulation ..." 

$ns_ at 0.0 "$p1 agentj init"
$ns_ at 0.0 "$p2 agentj init"

$ns_ at 1.0 "$p2 agentj receive"
$ns_ at 2.0 "$p1 agentj send"

$ns_ at 100.0 "finish $ns_"

proc finish {ns_} {
$ns_ halt
delete $ns_
}

$ns_ run

