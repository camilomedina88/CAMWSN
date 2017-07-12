
set ns_ [new Simulator]

set n1 [$ns_ node]

puts "Creating AgentJ Agents ..."   

set p1 [new Agent/Agentj]
$ns_ attach-agent $n1 $p1

$ns_ at 0.0 "$p1 initAgent"

#set up the class

$ns_ at 0.0 "$p1 attach-agentj agentj.examples.basic.SimpleTimer"

puts "Starting simulation ..." 

$ns_ at 0.0 "$p1 agentj init"

$ns_ at 1.0 "$p1 agentj go"

$ns_ at 100.0 "finish $ns_"

proc finish {ns_} {
$ns_ halt
delete $ns_
}

$ns_ run

