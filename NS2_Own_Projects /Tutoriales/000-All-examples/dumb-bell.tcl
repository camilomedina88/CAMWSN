#######################
#######################

set val(simDur) 5.0 ;#simulation duration

set val(basename)  dumb-bell;#basename for this project or scenario

set val(statIntvl) 0.5 ;#statistics collection interval
set val(statStart) 0.1 ;

set val(cbrStart) 0.1 ;#CBR start time
set val(cbrStop) 4.5 ;#CBR start time
set val(ftpStart) 1.0 ;#CBR start time
set val(ftpStop) 1.0 ;#CBR start time

set val(cbrIntvl) 0.001 ;#CBR traffic interval
set val(cbrRate) 1mb ;#

set val(mac)            Mac/802_3                 ;# MAC type
set val(ifq)            DropTail		   ;# interface queue type
set val(ifqlen)         50                         ;# max packet in ifq
set val(ll)             LL                         ;# link layer type
set val(nn)             4                          ;# number of mobilenodes

#######################
#######################
#Initialize and create output files
#Create a simulator instance
set ns [new Simulator]

#Crate a trace file and animation record
set tracefd [open $val(basename).tr w]
$ns trace-all $tracefd
set namtracefd [open $val(basename).nam w]
$ns namtrace-all $namtracefd 

set outfd0 [open udp.out w]
set outfd1 [open tcp.out w]

#######################
#######################
#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 

# configure node

#$ns node-config -llType $val(ll) \
#		 -macType $val(mac) \
#		 -ifqType $val(ifq) \
#		 -ifqLen $val(ifqlen) \
#		 -agentTrace ON \
#		 -routerTrace OFF \
#		 -macTrace OFF
#
for {set i 0} {$i < $val(nn) } {incr i} {
	set node($i) [$ns node]
}


$ns duplex-link $node(0) $node(2) 2M 10ms $val(ifq)
$ns duplex-link $node(1) $node(2) 2M 10ms $val(ifq)
$ns duplex-link $node(2) $node(3) 1.7M 20ms $val(ifq)

$ns duplex-link-op $node(0) $node(2) orient right-down
$ns duplex-link-op $node(1) $node(2) orient right-up
$ns duplex-link-op $node(2) $node(3) orient right

#########################
#########################
#Modify these variables accordingly
#########################
set src $node(1)
set dst $node(3)
#########################

    #Create a udp agent on node0
    set udp [new Agent/UDP]
    $ns attach-agent $src $udp

    # Create a CBR traffic source on node0
    set cbr0 [new Application/Traffic/CBR]
    $cbr0 set type_ CBR
    $cbr0 set packetSize_ 1000
    $cbr0 set rate_ $val(cbrRate)
    $cbr0 set random_ 0
    $cbr0 attach-agent $udp

    #Create a Null agent (a traffic sink) on node1
    set sink0 [new Agent/LossMonitor]
    $ns attach-agent $dst $sink0

    #Connet source and dest Agents
    $ns connect $udp $sink0
    $ns at $val(cbrStart) "$cbr0 start"
    $ns at $val(cbrStop) "$cbr0 stop"

    set src $node(0)
    #Create a tcp agent on the source node
    set tcp [new Agent/TCP]
    $tcp set class_ 2
    $ns attach-agent $src $tcp

    # Create a CBR traffic source on node0
    set ftp [new Application/FTP]
    $ftp attach-agent $tcp

    #Create a sink(a traffic sink) on the destination node
    set sink1 [new Agent/TCPSink]
    $ns attach-agent $dst $sink1

    #Connet source and dest Agents
    $ns connect $tcp $sink1
    $ns at $val(ftpStart) "$ftp start"
    $ns at $val(ftpStop) "$ftp stop"

#########################
#a procedure to record stats
proc record {} {
    global sink0 sink1 ns outfd0 outfd1 val
    set bytes_(0) [$sink0 set bytes_]
    set bytes_(1) [$sink1 set bytes_]
    set now [$ns now]
    puts $outfd0 "$now $bytes_(0)"
    puts $outfd1 "$now $bytes_(1)"
    $sink0 set bytes_ 0
    $sink1 set bytes_ 0
    $ns at [expr $now+$val(statIntvl)] "record"
}

#########################
#a procedure to close trace file and nam file
proc finish {} {

	global ns tracefd namtracefd basename val
	$ns flush-trace

	close $tracefd
	close $namtracefd
	
	exit 0
}

#
#Schedule trigger events
$ns at $val(statStart) "record"

#Call the finish procedure after 5s (of simulated time)
$ns at $val(simDur) "finish"

#Run the simulation
$ns run




