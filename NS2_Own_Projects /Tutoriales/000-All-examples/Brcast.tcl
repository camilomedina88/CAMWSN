#    http://www.codeforge.com/read/238743/Brcast.tcl__html

			
			  # Create scheduler
  #Create an event scheduler wit multicast turned o
  set ns [new Simulator -multicast on]
  #$ns multicast
  #Turn on Tracing
  set tf [open output.tr w]
  $ns trace-all $tf
# Turn on nam Tracing
set fd [open mcast.nam w]
$ns namtrace-all $fd
# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Create links
$ns duplex-link $n0  $n2 1.5Mb 10ms DropTail
$ns duplex-link $n0  $n1 1.5Mb 10ms DropTail
$ns duplex-link $n0  $n3 1.5Mb 10ms DropTail
$ns duplex-link $n0  $n4 1.5Mb 10ms DropTail

# Routing protocol: say distance vector
#Protocols: CtrMcast, DM, ST, BST
set mproto DM
set mrthandle [$ns mrtproto $mproto {}]
# Allocate group addresses
set group1 [Node allocaddr]

# UDP Transport agent for the traffic source
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
$udp0 set dst_addr_ $group1
$udp0 set dst_port_ 0
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp0


# Create receiver
set rcvr1 [new Agent/Null]
$ns attach-agent $n1 $rcvr1
$ns at 0.1 "$n1 join-group $rcvr1 $group1"
set rcvr2 [new Agent/Null]
$ns attach-agent $n2 $rcvr2
$ns at 0.1 "$n2 join-group $rcvr2 $group1"
set rcvr3 [new Agent/Null]
$ns attach-agent $n3 $rcvr3
$ns at 0.1 "$n3 join-group $rcvr3 $group1"

set rcvr4 [new Agent/Null]
$ns attach-agent $n4 $rcvr4
$ns at 0.1 "$n4 join-group $rcvr4 $group1"


#$ns at 4.0 "$n1 leave-group $rcvr1 $group1"
#$ns at 4.5 "$n2 leave-group $rcvr2 $group1"
#$ns at 5.0 "$n3 leave-group $rcvr3 $group1"

# Schedule events
$ns at 0.5 "$cbr1 start"
$ns at 9.5 "$cbr1 stop"
#post-processing
$ns at 10.0 "finish"
proc finish {} {
   global ns tf
   $ns flush-trace
   close $tf
   exec nam mcast.nam &
   exit 0
}
# For nam
#Colors for packets from two mcast groups
$ns color 10 red
$ns color 11 green
$ns color 30 purple
$ns color 31 green
# Manual layout: order of the link is significant
#$ns duplex-link-op $n0 $n1 orient right
#$ns duplex-link-op $n0 $n2 orient right-up
#$ns duplex-link-op $n0 $n3 orient right-down
# Show queue on simplex link n0->n1
#$ns duplex-link-op $n2 $n3 queuePos 0.5
# Group 0 source
$udp0 set fid_ 10
$n0 color red
$n0 label "Source 1"
# Group 1 source

$n1 label "Receiver 1"
$n1 color blue
$n2 label "Receiver 2"
 $n2 color blue

 $n3 label "Receiver 3"
 $n3 color blue
 $n4 label "Receiver 4"
 $n4 color blue
 #$n2 add-mark m0 red
 #$n2 delete-mark m0"
 # Animation rate
 $ns set-animation-rate 3.0ms
 $ns run
