#   https://abdusyarif.wordpress.com/2012/01/17/ns-2-tcl-script-antnet-project/


#Number of nodes
set sz 14

#Create event Schedular
set ns [ new Simulator ]

#colors
$ns color 1 Blue
$ns color 2 Red

#Open the Trace file
set tf [open antnet_trace.out w]
$ns trace-all $tf

#Create 14 nodes
for {set i 0} {$i < $sz} {incr i} {
set n($i) [$ns node]
$n($i) color “Blue”
}

#Create links between the nodes
$ns duplex-link $n(0) $n(1) 512Mb 155ms DropTail
$ns duplex-link $n(0) $n(2) 512Mb 155ms DropTail
$ns duplex-link $n(1) $n(2) 512Mb 155ms DropTail
$ns duplex-link $n(1) $n(3) 512Mb 155ms DropTail
$ns duplex-link $n(2) $n(4) 512Mb 155ms DropTail
$ns duplex-link $n(3) $n(4) 512Mb 155ms DropTail
$ns duplex-link $n(3) $n(5) 512Mb 155ms DropTail
$ns duplex-link $n(4) $n(6) 512Mb 155ms DropTail
$ns duplex-link $n(5) $n(6) 512Mb 155ms DropTail
$ns duplex-link $n(5) $n(10) 512Mb 155ms DropTail
$ns duplex-link $n(6) $n(9) 512Mb 155ms DropTail
$ns duplex-link $n(4) $n(7) 512Mb 155ms DropTail
$ns duplex-link $n(3) $n(9) 512Mb 155ms DropTail
$ns duplex-link $n(4) $n(10) 512Mb 155ms DropTail
$ns duplex-link $n(7) $n(8) 512Mb 155ms DropTail
$ns duplex-link $n(8) $n(10) 512Mb 155ms DropTail
$ns duplex-link $n(9) $n(10) 512Mb 155ms DropTail
$ns duplex-link $n(9) $n(11) 512Mb 155ms DropTail
$ns duplex-link $n(10) $n(12) 512Mb 155ms DropTail
$ns duplex-link $n(11) $n(12) 512Mb 155ms DropTail
$ns duplex-link $n(11) $n(13) 512Mb 155ms DropTail
$ns duplex-link $n(12) $n(13) 512Mb 155ms DropTail

$ns duplex-link-op $n(0) $n(1) orient right-up
$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(2) orient down
$ns duplex-link-op $n(1) $n(3) orient right
$ns duplex-link-op $n(2) $n(4) orient right
$ns duplex-link-op $n(3) $n(4) orient down
$ns duplex-link-op $n(3) $n(5) orient right-up
$ns duplex-link-op $n(4) $n(6) orient right-up
$ns duplex-link-op $n(5) $n(10) orient right-down
$ns duplex-link-op $n(5) $n(6) orient right
$ns duplex-link-op $n(6) $n(9) orient right-down
$ns duplex-link-op $n(4) $n(7) orient right-down
$ns duplex-link-op $n(3) $n(9) orient right
$ns duplex-link-op $n(4) $n(10) orient right
$ns duplex-link-op $n(7) $n(8) orient right
$ns duplex-link-op $n(8) $n(10) orient right-up
$ns duplex-link-op $n(9) $n(10) orient down
$ns duplex-link-op $n(9) $n(11) orient right
$ns duplex-link-op $n(10) $n(12) orient right
$ns duplex-link-op $n(11) $n(12) orient down
$ns duplex-link-op $n(11) $n(13) orient right-down
$ns duplex-link-op $n(12) $n(13) orient right-up

$ns duplex-link-op $n(1) $n(2) queuePos 0.5
$ns duplex-link-op $n(1) $n(3) queuePos 0.5
$ns duplex-link-op $n(2) $n(4) queuePos 0.5
$ns duplex-link-op $n(3) $n(4) queuePos 0.5
$ns duplex-link-op $n(3) $n(5) queuePos 0.5
$ns duplex-link-op $n(4) $n(6) queuePos 0.5
$ns duplex-link-op $n(5) $n(10) queuePos 0.5
$ns duplex-link-op $n(5) $n(6) queuePos 0.5
$ns duplex-link-op $n(6) $n(9) queuePos 0.5
$ns duplex-link-op $n(4) $n(7) queuePos 0.5
$ns duplex-link-op $n(3) $n(9) queuePos 0.5
$ns duplex-link-op $n(4) $n(10) queuePos 0.5
$ns duplex-link-op $n(7) $n(8) queuePos 0.5
$ns duplex-link-op $n(8) $n(10) queuePos 0.5
$ns duplex-link-op $n(9) $n(10) queuePos 0.5
$ns duplex-link-op $n(9) $n(11) queuePos 0.5
$ns duplex-link-op $n(10) $n(12) queuePos 0.5
$ns duplex-link-op $n(11) $n(12) queuePos 0.5
$ns duplex-link-op $n(11) $n(13) queuePos 0.5
$ns duplex-link-op $n(12) $n(13) queuePos 0.5

#Create Antnet agents
for {set i 0} {$i < $sz} {incr i} {
set nn($i) [ new Agent/Antnet $i]
}

#Attach each node with Antnet agent
for {set i 0} {$i < $sz} {incr i} {
$ns attach-agent $n($i) $nn($i)
}

#Create connection between the nodes
$ns connect $nn(0) $nn(1)
$ns connect $nn(1) $nn(0)
$ns connect $nn(0) $nn(2)
$ns connect $nn(2) $nn(0)
$ns connect $nn(1) $nn(3)
$ns connect $nn(3) $nn(1)
$ns connect $nn(2) $nn(4)
$ns connect $nn(4) $nn(2)
$ns connect $nn(1) $nn(2)
$ns connect $nn(2) $nn(1)
$ns connect $nn(3) $nn(4)
$ns connect $nn(4) $nn(3)
$ns connect $nn(3) $nn(5)
$ns connect $nn(5) $nn(3)
$ns connect $nn(5) $nn(6)
$ns connect $nn(6) $nn(5)
$ns connect $nn(4) $nn(6)
$ns connect $nn(6) $nn(4)
$ns connect $nn(4) $nn(7)
$ns connect $nn(7) $nn(4)
$ns connect $nn(7) $nn(8)
$ns connect $nn(8) $nn(7)
$ns connect $nn(5) $nn(10)
$ns connect $nn(10) $nn(5)
$ns connect $nn(6) $nn(9)
$ns connect $nn(9) $nn(6)
$ns connect $nn(3) $nn(9)
$ns connect $nn(9) $nn(3)
$ns connect $nn(4) $nn(10)
$ns connect $nn(10) $nn(4)
$ns connect $nn(9) $nn(10)
$ns connect $nn(10) $nn(9)
$ns connect $nn(9) $nn(11)
$ns connect $nn(11) $nn(9)
$ns connect $nn(11) $nn(12)
$ns connect $nn(12) $nn(11)
$ns connect $nn(10) $nn(12)
$ns connect $nn(12) $nn(10)
$ns connect $nn(11) $nn(13)
$ns connect $nn(13) $nn(11)
$ns connect $nn(12) $nn(13)
$ns connect $nn(13) $nn(12)

#Add neighbors
$ns at now "$nn(0) add-neighbor $n(0) $n(1)"
$ns at now "$nn(0) add-neighbor $n(0) $n(2)"
$ns at now "$nn(0) add-neighbor $n(1) $n(2)"
$ns at now "$nn(0) add-neighbor $n(1) $n(3)"
$ns at now "$nn(0) add-neighbor $n(2) $n(4)"
$ns at now "$nn(0) add-neighbor $n(3) $n(4)"
$ns at now "$nn(0) add-neighbor $n(3) $n(5)"
$ns at now "$nn(0) add-neighbor $n(3) $n(9)"
$ns at now "$nn(0) add-neighbor $n(4) $n(6)"
$ns at now "$nn(0) add-neighbor $n(4) $n(7)"
$ns at now "$nn(0) add-neighbor $n(4) $n(10)"
$ns at now "$nn(0) add-neighbor $n(5) $n(6)"
$ns at now "$nn(0) add-neighbor $n(5) $n(10)"
$ns at now "$nn(0) add-neighbor $n(6) $n(9)"
$ns at now "$nn(0) add-neighbor $n(7) $n(8)"
$ns at now "$nn(0) add-neighbor $n(8) $n(10)"
$ns at now "$nn(0) add-neighbor $n(9) $n(10)"
$ns at now "$nn(0) add-neighbor $n(9) $n(11)"
$ns at now "$nn(0) add-neighbor $n(10) $n(12)"
$ns at now "$nn(0) add-neighbor $n(11) $n(12)"
$ns at now "$nn(0) add-neighbor $n(11) $n(13)"
$ns at now "$nn(0) add-neighbor $n(12) $n(13)"

#Create a UDP agent and attach it to node n(13)
set udp(0) [new Agent/UDP]
$udp(0) set class_ 1
ns attach-agent $n(0) $udp(0)

set cbr(0) [new Application/Traffic/CBR]
$cbr(0) set packetSize_ 1835008
$cbr(0) set interval_ 0.010
$cbr(0) attach-agent $udp(0)

set udp(1) [new Agent/UDP]
$udp(1) set class_ 2
ns attach-agent $n(1) $udp(1)

set cbr(1) [new Application/Traffic/CBR]
$cbr(1) set packetSize_ 1835008
$cbr(1) set interval_ 0.010
$cbr(1) attach-agent $udp(1)

set null(0) [new Agent/Null]
$ns attach-agent $n(13) $null(0)

$ns connect $udp(0) $null(0)
$ns connect $udp(1) $null(0)

$ns at 0.5 "$cbr(0) start"
$ns at 1.0 "$cbr(1) start"
$ns at 80.0 "$cbr(1) stop"
$ns at 90.5 "$cbr(0) stop"

# Set parameters and start time
for {set i 0} {$i < $sz} {incr i} {
$nn($i) set num_nodes_ $sz
$nn($i) set timer_ant_ 0.03
$nn($i) set r_factor_ 0.05
$ns at 0.5 "$nn($i) start"
}

#Set stop time for AntNet algorithm
for {set i 0} {$i < $sz} {incr i} {
$ns at 96.0 "$nn($i) stop"
}

#Print routing tables generated by AntNet
for {set i 0} {$i < $sz} {incr i} {
$ns at 100.0 "$nn($i) print_rtable"
}

# Final Wrap up
proc Finish {} {
global ns tf nf
$ns flush-trace
#close $nf
#Close the Trace file
close $tf
}

$ns at 100.0 "Finish"

# Start the simulator
$ns run
