# Simple example showing how you can change the delimiter of 
# how you choose to split up
# your commands that you want to send to your Java program
#

puts "Starting..."   

# Create simulator instance
set ns_ [new Simulator]

# Create two nodes
set n1 [$ns_ node]
set n2 [$ns_ node]

# Put a link between them
$ns_ duplex-link $n1 $n2 64kb 100ms DropTail
$ns_ queue-limit $n1 $n2 100
$ns_ duplex-link-op $n1 $n2 queuePos 0.5
$ns_ duplex-link-op $n1 $n2 orient right
   
puts "Creating JavaAgent NS2 agents and attach them to the nodes..."   
set p1 [new Agent/Agentj]
$ns_ attach-agent $n1 $p1

set p2 [new Agent/Agentj]
$ns_ attach-agent $n2 $p2
    
puts "In script: Initializing  ..." 
	
$ns_ at 0.0 "$p1 initAgent"
$ns_ at 0.0 "$p2 initAgent"

puts "Setting Java Object to use by each agent ..." 

$ns_ at 0.0 "$p1 attach-agentj agentj.examples.basic.ChangeDelimiter"

$ns_ at 0.0 "$p2 attach-agentj agentj.examples.basic.ChangeDelimiter"

# Delimiters are global and can be set through any node

$ns_ at 0.0 "$p1 agentj setDelimiter -" 

$ns_ at 0.0 "$p2 agentj hello A-String-From-P2" 

$ns_ at 10.0 "finish $ns_"

proc finish {ns_} {
$ns_ halt
delete $ns_
}

$ns_ run

