if { [lindex $argv 0] == "" } {
  puts "Example: ./thiscommand.tcl 5"
  exit
}
set val(nn)  [lindex $argv 0]
set val(stop)  [lindex $argv 1]
#wireless stuff
set val(chan)           Channel/WirelessChannel     ;# channel type
set val(prop)           Propagation/TwoRayGround    ;# radio-propagation model
set val(netif)          Phy/WirelessPhy             ;# network interface type
set val(mac)            Mac/802_11                  ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue     ;# interface queue type
set val(ll)             LL                          ;# link layer type
set val(ant)            Antenna/OmniAntenna         ;# antenna model
set val(ifqlen)         50                          ;# max packet in ifq
set val(rp)             ProtolibManetKernel         ;# routing protocol
set val(x)              905                     ;# width of map
set val(y)              905                    ;# height of map
#set val(stop)           1000                      ;# simulation stop time
Queue/DropTail/PriQueue set Prefer_Routing_Protocols    1
Phy/WirelessPhy set Pt_ 0.5900

set ns_         [new Simulator]
set tracefd [open test-1.tr w]
$ns_ trace-all $tracefd

set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
set god_ [create-god $val(nn)]
$god_ off
$god_ allow_to_stop
$god_ num_data_types 1

#configure phenomenon node
set chan_1_ [new $val(chan)]

$ns_ node-config \
     -adhocRouting $val(rp) \
     -llType $val(ll) \
     -macType $val(mac) \
     -ifqType $val(ifq) \
     -ifqLen $val(ifqlen) \
     -antType $val(ant) \
     -propType $val(prop) \
     -phyType $val(netif) \
     -channel $chan_1_ \
     -topoInstance $topo \
     -agentTrace OFF \
     -routerTrace OFF \
     -macTrace OFF \
     -movementTrace OFF

for {set i 0} {$i < $val(nn) } {incr i} {
    set node_($i) [$ns_ node $i]
    $god_ new_node $node_($i)
    $ns_ initial_node_pos $node_($i) 10

    set p($i) [new Agent/NrlolsrAgent]
    $ns_ attach-agent $node_($i) $p($i)
    $ns_ at 0.0 "$p($i) startup -tcj .75 -hj .5 -tci 2.5 -hi .5 -flooding s-mpr -d 0 -unicast off -l /tmp/olsr.log"
    [$node_($i) set ragent_] attach-manet $p($i)
    $p($i) attach-protolibManetKernel [$node_($i) set ragent_]

    set v($i) [new Agent/GodviewAgent]
    $ns_ attach-agent $node_($i) $v($i)
    $v($i) start $i

    set j($i) [new Agent/Agentj]
    $ns_ attach-agent $node_($i) $j($i)
    $v($i) attach-Agentj $j($i)
  }

puts "Setting Java Object to use by each agent ..." 
for {set i 0} {$i < $val(nn) } {incr i} {
        puts "SCRIPT: Attaching Node ... $j($i)"   
	$ns_ at 0.0 "$j($i) attach-agentj agentj.examples.threads.ThreadedReceive"
}

for {set i 0} {$i < $val(nn) } {incr i} {
	$ns_ at 0.1 "$j($i) agentj init"
}

for {set t 1} {$t < $val(stop) } {incr t} {
    for {set i 0} {$i < $val(nn) } {incr i} {
	$ns_ at $t "$j($i) agentj test $t"
    }
}

$ns_ at $val(stop) "finish $ns_"

proc finish {ns_} {
$ns_ halt
delete $ns_
}

$ns_ run

