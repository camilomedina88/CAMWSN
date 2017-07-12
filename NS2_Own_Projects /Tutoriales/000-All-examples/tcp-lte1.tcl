# Fazz Antho  https://groups.google.com/forum/?fromgroups=#!topic/ns-users/MjAzQNkoUeA

# This LTE project starts from Nov. 2008.
# Author: Qiu Qinlong

# Define the multicast mechanism
set ns [new Simulator -multicast on]

# Predefine tracing
set f [open out.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf
set window [open cwnd2 w]

# Set the number of subscribers
set number 5

#set up color flow
$ns color 1 Blue

# Define the LTE topology
# UE(i) <--> eNB <--> aGW <--> server
# Other configuration parameters see ~ns/tcl/lib/ns-default.tcl

# step 1: define the nodes, the order is fixed!!
set eNB [$ns node];#node id is 0
set aGW [$ns node];#node id is 1
set server [$ns node];#node id is 2
for { set i 0} {$i<$number} {incr i} {
	set UE($i) [$ns node];#node id is > 2
}

# step 2: define the links to connect the nodes
for { set i 0} {$i<$number} {incr i} {
	$ns simplex-link $UE($i) $eNB 500Mb 2ms LTEQueue/ULAirQueue 
	$ns simplex-link $eNB $UE($i) 1000Mb 2ms LTEQueue/DLAirQueue 
}

$ns simplex-link $eNB $aGW 5000Mb 10ms LTEQueue/ULS1Queue 
$ns simplex-link $aGW $eNB 5000Mb 10ms LTEQueue/DLS1Queue 

# The bandwidth between aGW and server is not the bottleneck.
$ns duplex-link $aGW $server 10Gb 100ms DropTail


# step 3.4 define the background traffic
# no parameters to be configured by FTP
# we can configue TCP and TCPSink parameters here.
for { set i 0} {$i<$number} {incr i} {
	set tcp($i) [new Agent/TCP/Linux]
	$tcp($i) set timestamps_ true
	$tcp($i) set window_ 2000
	$tcp($i) set interval_ 0.000002
	$tcp($i) set fid_ 1
	$ns attach-agent $server $tcp($i)
	set sink($i) [new Agent/TCPSink/Sack1]
	$sink($i) set ts_echo_rfc1323_ true
	$ns attach-agent $UE($i) $sink($i)
	$ns connect $sink($i) $tcp($i)
	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tcp($i)
	

#loss module
set loss_module [new ErrorModel]
$loss_module set rate_ 0.02
$loss_module ranvar [new RandomVariable/Normal]
$loss_module drop-target [new Agent/Null]
$ns lossmodel $loss_module $UE($i) $eNB

$ns at 0 "$tcp($i) select_ca bic"
$ns at 0.1 "$ftp($i) start"
$ns at 10 "$ftp($i) stop"
}

proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 0.1 "plotWindow $tcp(1) $window"


# finish tracing
$ns at 10 "finish"
proc finish {} {
	#global ns f log
	global ns f nf
	$ns flush-trace
	close $f
	close $nf
	puts "running nam..."
	exec nam out.nam &
	exit 0
}

# Finally, start the simulation.
$ns run

