set ns_ [new Simulator]
set val(nn) 100

for {set i 0} {$i < $val(nn) } {incr i} {
    set node_($i) [$ns_ node $i]
}


puts "Creating JavaAgent NS2 agents and attach them to the nodes..."   

for {set i 0} {$i < $val(nn) } {incr i} {
	set p($i) [new Agent/Agentj]
	$ns_ attach-agent $node_($i) $p($i)
	$ns_ at 0.0 "$p($i) startup"
   }

puts "Setting Java Object to use by each agent ..." 

for {set i 0} {$i < $val(nn) } {incr i} {
        puts "SCRIPT: Attaching Node ... $p($i)"   
	$ns_ at 0.0 "$p($i) attach-agentj agentj.examples.basic.ChangeDelimiter"
}


for {set i 0} {$i < $val(nn) } {incr i} {
	$ns_ at 1.0 "$p($i) agentj setDelimiter -"
	$ns_ at 2.0 "$p($i) agentj hello A-String-From-$i"
}

$ns_ at 100.0 "finish $ns_"

proc finish {ns_} {
$ns_ halt
delete $ns_
}

$ns_ run

