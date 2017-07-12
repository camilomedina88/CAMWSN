#      http://www.linuxquestions.org/questions/linux-software-2/tcl-error-4175522521/#3

#Create a simulator object
set ns [new Simulator]

#Open the output files
set f0 [open out_sip_test2.tr w]

$ns color 1 red
$ns color 2 blue
$ns color 3 yellow
$ns set-address-format hierarchical
AddrParams set domain_num_ 3

# Initializations
set f0 [open out_sip_test2.tr w]
set tf [open out_sip_test2.tr w]
set nf [open out_sip_test2.nam w]
$ns namtrace-all $nf
#$ns trace-all $tf

#finish procedure
proc finish {} {
	global ns tf nf
	$ns flush-trace
	#close $tf
	close $nf
	close $tf
	puts "NS-simulation finished!"
	exec nam out_sip_test2.nam &
	exec xgraph out_sip_test2.tr -geometry 800x400 &
	exit 0
}


# Routers
set n0 [$ns node 0.0.0]
set n1 [$ns node 1.0.0]
set n2 [$ns node 2.0.0]
set n3 [$ns node 1.1.0]
set n4 [$ns node 2.1.0]

# Proxies
set n5 [$ns node 1.0.1]
set n6 [$ns node 2.0.1]

# Terminals
set n7 [$ns node 1.1.2]
set n8 [$ns node 2.1.2]
set n9 [$ns node 1.1.3]
set n10 [$ns node 1.1.4]
set n11 [$ns node 2.1.1]
set n12 [$ns node 2.1.3]

# Set nodes' positions
$n0 set X_ 100
$n0 set Y_ 150
$n1 set X_ 60
$n1 set Y_ 110
$n2 set X_ 140
$n2 set Y_ 110
$n3 set X_ 60
$n3 set Y_ 60
$n4 set X_ 140
$n4 set Y_ 60
$n5 set X_ 10
$n5 set Y_ 110
$n6 set X_ 190
$n6 set Y_ 110
$n7 set X_ 60
$n7 set Y_ 10
$n8 set X_ 140
$n8 set Y_ 10
$n9 set X_ 30
$n9 set Y_ 10
$n10 set X_ 10
$n10 set Y_ 10
$n11 set X_ 170
$n11 set Y_ 10
$n12 set X_ 190
$n12 set Y_ 10

# Set nodes' colors
$n0 color black
$n1 color black
$n2 color black
$n3 color black
$n4 color black
$n5 color orange
$n6 color orange
$n7 color blue
$n8 color blue
$n9 color blue
$n10 color blue
$n11 color blue
$n12 color blue

proc record {} {
global null4 tf

set f0 [open out0.tr w]

#Get an instance of the simulator
set ns [Simulator instance]

#Set the time after which the procedure should be called again
set time 0.1

#How many bytes have been received by the traffic sinks?
set bw0 [$null4 set bytes_]

#Get the current time
set now [$ns now]

#Calculate the bandwidth (in MBit/s) and write it to the files
puts $tf "$now [expr $bw0/$time*8/1000000]"

#Reset the bytes_ values on the traffic sinks
$null4 set bytes_ 0

#Re-schedule the procedure
$ns at [expr $now+$time] "record"
}
proc Record2 {} {
global null0 tf

#Get an instance of the simulator
set ns_ [Simulator instance]

#Set the time after which the procedure should be called again
set time 0.01

#How many bytes have been received by the traffic sinks?
set DP [$null0 set nlost_]

#Get the current time
set now [$ns_ now]

#Calculate the bandwidth (in MBit/s) and write it to the files
puts $f0 "$now [expr $bw0/$time*8/1000000]"
puts $tf "$now $DP"
$null0 set nlost_ 0

#Reset the bytes_ values on the traffic sinks
$sink1 set bytes_ 0

#Re-schedule the procedure
set f0 [open out_sip_test2.tr w]
$ns_ at [expr $now+$time] "Record2"
}

# Routers
  $ns duplex-link $n0 $n1 1Mb 10ms DropTail
  $ns duplex-link $n0 $n2 1Mb 10ms DropTail
  $ns duplex-link $n1 $n3 1Mb 10ms DropTail
  $ns duplex-link $n2 $n4 1Mb 10ms DropTail
# Proxies

  $ns duplex-link $n1 $n5 1Mb 10ms DropTail
  $ns duplex-link $n2 $n6 1Mb 10ms DropTail
# Terminals

$ns duplex-link $n3 $n7 1Mb 10ms DropTail
$ns duplex-link $n4 $n8 1Mb 10ms DropTail
$ns duplex-link $n3 $n9 1Mb 10ms DropTail
$ns duplex-link $n3 $n10 1Mb 10ms DropTail
$ns duplex-link $n4 $n11 1Mb 10ms DropTail
$ns duplex-link $n4 $n12 1Mb 10ms DropTail

# Proxy servers
$n5 label "proxy.atlanta.com"
set serveraddrATL [$n5 node-addr]
set sipATL [new Agent/SIPProxy atlanta.com]
$sipATL set class_ 1
$ns attach-agent $n5 $sipATL
$n6 label "proxy.biloxi.com"
set serveraddrBLX [$n6 node-addr]
set sipBLX [new Agent/SIPProxy biloxi.com]
$sipBLX set class_ 1
$ns attach-agent $n6 $sipBLX

# User agents
$n7 label "alice@atlanta.com"
set sipalice [new Agent/SIPUA alice atlanta.com]
$sipalice set class_ 1
$ns attach-agent $n7 $sipalice

$n9 label "ku@atlanta.com"
set sipku [new Agent/SIPUA ku atlanta.com]
$sipku set class_ 1
$ns attach-agent $n9 $sipku

$n10 label "ran@atlanta.com"
set sipran [new Agent/SIPUA ran atlanta.com]
$sipran set class_ 1
$ns attach-agent $n10 $sipran

$n8 label "bob@biloxi.com"
set sipbob [new Agent/SIPUA bob biloxi.com]
$sipbob set class_ 1
$ns attach-agent $n8 $sipbob

$n11 label "gob@biloxi.com"
set sipgob [new Agent/SIPUA gob biloxi.com]
$sipgob set class_ 1
$ns attach-agent $n11 $sipgob

$n12 label "not@biloxi.com"
set sipnot [new Agent/SIPUA not biloxi.com]
$sipnot set class_ 1
$ns attach-agent $n12 $sipnot

# udp traffic for agents
set udp0 [new Agent/UDP]
$udp0 set class_ 2
$ns attach-agent $n7 $udp0
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp0
set null0 [new Agent/LossMonitor]
$ns attach-agent $n8 $null0
$ns connect $udp0 $null0
set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $n8 $udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
set null1 [new Agent/Null]
$ns attach-agent $n7 $null1
$ns connect $udp1 $null1
set udp2 [new Agent/UDP]
$ns attach-agent $n9 $udp2
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
set null2 [new Agent/LossMonitor]
$ns attach-agent $n11 $null2
$ns connect $udp2 $null2
set udp3 [new Agent/UDP]
$ns attach-agent $n11 $udp3
set cbr3 [new Application/Traffic/CBR]
$cbr3 attach-agent $udp3
set null3 [new Agent/Null]
$ns attach-agent $n9 $null3
$ns connect $udp3 $null3
set udp4 [new Agent/UDP]
$udp4 set class_ 3
$ns attach-agent $n10 $udp4
set cbr4 [new Application/Traffic/CBR]
$cbr4 attach-agent $udp4
set null4 [new Agent/LossMonitor]
$ns attach-agent $n12 $null4
$ns connect $udp4 $null4
set udp5 [new Agent/UDP]
$udp5 set class_ 3
$ns attach-agent $n12 $udp5
set cbr5 [new Application/Traffic/CBR]
$cbr5 attach-agent $udp5
set null5 [new Agent/Null]
$ns attach-agent $n10 $null5
$ns connect $udp5 $null5

# Setup outbound proxies
$sipalice set-proxy $serveraddrATL
$sipku set-proxy $serveraddrATL
$sipran set-proxy $serveraddrATL
$sipbob set-proxy $serveraddrBLX
$sipgob set-proxy $serveraddrBLX
$sipnot set-proxy $serveraddrBLX

# Set Record-Route on proxies
$sipATL set recordRoute_ 3
$sipBLX set recordRoute_ 3

# Register proxies with DNS "God"
DNSGod register proxy atlanta.com $serveraddrATL
DNSGod register proxy biloxi.com $serveraddrBLX

# Put nodes in place again
$ns at 0.0 "$ns dump-namnodes"

# Configure one terminal for complex response, waiting between 1 and 3
# seconds after ringing to pick up the phone
$sipbob set simple_ 0
$sipbob set minAnsDel_ 1.0
$sipbob set maxAnsDel_ 3.0
$sipgob set simple_ 0
$sipgob set minAnsDel_ 1.0
$sipgob set maxAnsDel_ 3.0
$sipnot set simple_ 0
$sipnot set minAnsDel_ 1.0
$sipnot set maxAnsDel_ 3.0

# Register nodes at home
$ns at 1.0 "$ns trace-annotate \"Registering alice@atlanta.com\""
$ns at 1.0 "$sipalice register"
$ns at 1.1 "$ns trace-annotate \"Registering bob@biloxi.com\""
$ns at 1.1 "$sipbob register"
$ns at 1.2 "$ns trace-annotate \"Registering ku@atlanta.com\""
$ns at 1.2 "$sipku register"
$ns at 1.3 "$ns trace-annotate \"Registering ran@atlanta.com\""
$ns at 1.3 "$sipran register"
$ns at 1.4 "$ns trace-annotate \"Registering gob@biloxi.com\""
$ns at 1.4 "$sipgob register"
$ns at 1.5 "$ns trace-annotate \"Registering not@biloxi.com\""
$ns at 1.5 "$sipnot register"
# Sessions

$ns at 2.0 "Record2"

$ns at 2.0 "$ns trace-annotate \"alice@atlanta.com starts session to
bob@biloxi.com\""
$ns at 2.0 "$sipalice invite bob biloxi.com bw 32kb 64kb"
$ns at 3.0 "$ns trace-annotate \"ku@atlanta.com starts session to
gob@biloxi.com\""
$ns at 3.0 "$sipku invite gob biloxi.com bw 32kb 64kb"
$ns at 4.0 "$ns trace-annotate \"ran@atlanta.com starts session to
not@biloxi.com\""
$ns at 4.0 "$sipran invite not biloxi.com bw 32kb 64kb"

 $ns at 3.634 "$cbr start"
 $ns at 7.0 "$cbr stop"
 $ns at 3.634 "$cbr1 start"
 $ns at 7.0 "$cbr1 stop"
 $ns at 5.744 "$cbr2 start"
 $ns at 8.0 "$cbr2 stop"
 $ns at 5.744 "$cbr3 start"
 $ns at 8.0 "$cbr3 stop"
 $ns at 5.66 "$cbr4 start"
 $ns at 9.0 "$cbr4 stop"
 $ns at 5.66 "$cbr5 start"
 $ns at 9.0 "$cbr5 stop"



$ns at 7.0 "$ns trace-annotate \"bob@biloxi.com ends session to
alice@atlanta.com (any side may terminate the call)\""
$ns at 7.0 "$sipbob bye"
$ns at 8.0 "$ns trace-annotate \"gob@biloxi.com ends session to
ku@atlanta.com (any side may terminate the call)\""
$ns at 8.0 "$sipgob bye"
$ns at 9.0 "$ns trace-annotate \"not@biloxi.com ends session to
ran@atlanta.com (any side may terminate the call)\""
$ns at 9.0 "$sipnot bye"
$ns at 10.0 "finish"
$ns run 
