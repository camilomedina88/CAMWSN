#      https://groups.google.com/forum/?fromgroups=#!topic/ns-users/hHLAISWEyHw


# This LTE project starts from Nov. 2008.
# Author: Qiu Qinlong

# Define the multicast mechanism
set ns [new Simulator -multicast on]

# Predefine tracing
set nf [open t-down-th.nam w]
$ns namtrace-all $nf
set f [open t-down-th.tr w]
$ns trace-all $f

#set up color flow
$ns color 1 Blue

# Define the LTE topology
# UE(i) <--> eNB <--> aGW <--> server
# Other configuration parameters see ~ns/tcl/lib/ns-default.tcl

# step 1: define the nodes, the order is fixed!!
set eNB [$ns node];#node id is 0
set aGW [$ns node];#node id is 1
set server [$ns node];#node id is 2
set UE1 [$ns node]
set UE2 [$ns node]
set UE3 [$ns node]
set UE4 [$ns node]
set UE5 [$ns node]

# step 2: define the links to connect the nodes
$ns simplex-link $UE1 $eNB 75Mb 2ms LTEQueue/ULAirQueue 
$ns simplex-link $eNB $UE1 150Mb 2ms LTEQueue/DLAirQueue 
$ns simplex-link $UE2 $eNB 75Mb 2ms LTEQueue/ULAirQueue 
$ns simplex-link $eNB $UE2 150Mb 2ms LTEQueue/DLAirQueue 
$ns simplex-link $UE3 $eNB 75Mb 2ms LTEQueue/ULAirQueue 
$ns simplex-link $eNB $UE3 150Mb 2ms LTEQueue/DLAirQueue 
$ns simplex-link $UE4 $eNB 75Mb 2ms LTEQueue/ULAirQueue 
$ns simplex-link $eNB $UE4 150Mb 2ms LTEQueue/DLAirQueue 
$ns simplex-link $UE5 $eNB 75Mb 2ms LTEQueue/ULAirQueue 
$ns simplex-link $eNB $UE5 150Mb 2ms LTEQueue/DLAirQueue 

$ns simplex-link $eNB $aGW 250Mb 2ms LTEQueue/ULS1Queue 
$ns simplex-link $aGW $eNB 300Mb 2ms LTEQueue/DLS1Queue 

# The bandwidth between aGW and server is not the bottleneck.
$ns duplex-link $server $aGW 1Gb 2ms DropTail

# step 3.4 define the background traffic
# no parameters to be configured by FTP
# we can configue TCP and TCPSink parameters here.
	set tcp1 [new Agent/TCP/Linux]
	$tcp1 set timestamps_ true
	$tcp1 set fid_ 1
	$ns attach-agent $server $tcp1
	set sink1 [new Agent/TCPSink/Sack1]
	$ns attach-agent $UE1 $sink1
	$ns connect $sink1 $tcp1
	set ftp1 [new Application/FTP]
	$ftp1 attach-agent $tcp1
	$ftp1 set type_ FTP

	set tcp2 [new Agent/TCP/Linux]
	$tcp2 set timestamps_ true
	$tcp2 set fid_ 1
	$ns attach-agent $server $tcp2
	set sink2 [new Agent/TCPSink/Sack1]
	$ns attach-agent $UE2 $sink2
	$ns connect $sink2 $tcp2
	set ftp2 [new Application/FTP]
	$ftp2 attach-agent $tcp2
	$ftp2 set type_ FTP

	set tcp3 [new Agent/TCP/Linux]
	$tcp3 set timestamps_ true
	$tcp3 set fid_ 1
	$ns attach-agent $server $tcp3
	set sink3 [new Agent/TCPSink/Sack1]
	$ns attach-agent $UE3 $sink3
	$ns connect $sink3 $tcp3
	set ftp3 [new Application/FTP]
	$ftp3 attach-agent $tcp3
	$ftp3 set type_ FTP

	set tcp4 [new Agent/TCP/Linux]
	$tcp4 set timestamps_ true
	$tcp4 set fid_ 1
	$ns attach-agent $server $tcp4
	set sink4 [new Agent/TCPSink/Sack1]
	$ns attach-agent $UE4 $sink4
	$ns connect $sink4 $tcp4
	set ftp4 [new Application/FTP]
	$ftp4 attach-agent $tcp4
	$ftp4 set type_ FTP

	set tcp5 [new Agent/TCP/Linux]
	$tcp5 set timestamps_ true
	$tcp5 set fid_ 1
	$ns attach-agent $server $tcp5
	set sink5 [new Agent/TCPSink/Sack1]
	$ns attach-agent $UE5 $sink5
	$ns connect $sink5 $tcp5
	set ftp5 [new Application/FTP]
	$ftp5 attach-agent $tcp5
	$ftp5 set type_ FTP

#loss module
set loss_module1 [new ErrorModel]
$loss_module1 set rate_ 0.02
$loss_module1 ranvar [new RandomVariable/Uniform]
$loss_module1 drop-target [new Agent/Null]
$ns lossmodel $loss_module1 $eNB $UE1

set loss_module2 [new ErrorModel]
$loss_module2 set rate_ 0.02
$loss_module2 ranvar [new RandomVariable/Uniform]
$loss_module2 drop-target [new Agent/Null]
$ns lossmodel $loss_module2 $eNB $UE2

set loss_module3 [new ErrorModel]
$loss_module3 set rate_ 0.02
$loss_module3 ranvar [new RandomVariable/Uniform]
$loss_module3 drop-target [new Agent/Null]
$ns lossmodel $loss_module3 $eNB $UE3

set loss_module4 [new ErrorModel]
$loss_module4 set rate_ 0.02
$loss_module4 ranvar [new RandomVariable/Uniform]
$loss_module4 drop-target [new Agent/Null]
$ns lossmodel $loss_module4 $eNB $UE4

set loss_module5 [new ErrorModel]
$loss_module5 set rate_ 0.02
$loss_module5 ranvar [new RandomVariable/Uniform]
$loss_module5 drop-target [new Agent/Null]
$ns lossmodel $loss_module5 $eNB $UE5

set loss_module6 [new ErrorModel]
$loss_module6 set rate_ 0.0002
$loss_module6 ranvar [new RandomVariable/Uniform]
$loss_module6 drop-target [new Agent/Null]
$ns lossmodel $loss_module6 $aGW $eNB

set loss_module7 [new ErrorModel]
$loss_module7 set rate_ 0.00002
$loss_module7 ranvar [new RandomVariable/Uniform]
$loss_module7 drop-target [new Agent/Null]
$ns lossmodel $loss_module7 $server $aGW

$ns at 0 "$tcp1 select_ca bic"
$ns at 0 "$tcp2 select_ca bic"
$ns at 0 "$tcp3 select_ca bic"
$ns at 0 "$tcp4 select_ca bic"
$ns at 0 "$tcp5 select_ca bic"
$ns at 1.0 "$ftp1 start"
$ns at 30 "$ftp1 stop"
$ns at 2.0 "$ftp2 start"
$ns at 30 "$ftp2 stop"
$ns at 3.0 "$ftp3 start"
$ns at 30 "$ftp3 stop"
$ns at 4.0 "$ftp4 start"
$ns at 30 "$ftp4 stop"
$ns at 5.0 "$ftp5 start"
$ns at 30 "$ftp5 stop"


# finish tracing
$ns at 30 "finish"
proc finish {} {
	#global ns f log
	global ns nf f
	$ns flush-trace
	close $f
	close $nf
	puts "running nam..."
	exec nam t-down-th.nam &
	exit 0
}

# Finally, start the simulation.
$ns run
