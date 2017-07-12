# A simple NAM demo which illustrates how
# You can use Java to colour the nodes and change labels
# within NAM

# Create multicast enabled simulator instance
set ns_ [new Simulator -multicast on]
$ns_ multicast

set tracefd [open namdemo.tr w]
$ns_ trace-all $tracefd
set namtrace [open namdemo.nam w]
$ns_ namtrace-all $namtrace

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

set p1 [new Agent/Agentj]
$ns_ attach-agent $n1 $p1

set p2 [new Agent/Agentj]
$ns_ attach-agent $n2 $p2

$ns_ at 0.0 "$p1 initAgent"
$ns_ at 0.0 "$p2 initAgent"

#set up the class

$ns_ at 0.0 "$p1 attach-agentj agentj.examples.nam.NamDemo"
$ns_ at 0.0 "$p2 attach-agentj agentj.examples.nam.NamDemo"

puts "Starting simulation ..."

$ns_ at 0.0 "$p1 agentj init-server"
$ns_ at 0.0 "$p2 agentj init-client"

$ns_ at 1.0 "$p1 agentj receive"
$ns_ at 1.0 "$p2 agentj send"

$ns_ at 2.0 "$p1 agentj receive"
$ns_ at 2.0 "$p2 agentj send"

$ns_ at 3.0 "$p1 agentj receive"
$ns_ at 3.0 "$p2 agentj send"

$ns_ at 4.0 "$p1 agentj receive"
$ns_ at 4.0 "$p2 agentj send"

$ns_ at 6.0 "finish $ns_"

proc finish {ns_} {
  global tracefd namtrace
  $ns_ flush-trace
  close $tracefd
  close $namtrace
  $ns_ halt
  delete $ns_
}


$ns_ run



