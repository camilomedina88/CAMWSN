# Set variables.
set DATALOAD 8000
set MTU 1500
set PACKETSIZE 100

Agent/DTNAgent set custodian_ 1
Agent/DTNAgent set retransmit_ 0.5

# Create a simulator object
set ns [new Simulator]

# Open a trace file
set nf [open dtn-demo-large.nam w]
$ns namtrace-all $nf

# Setup packet type colours for nam.
$ns color 1 Blue
$ns color 2 Chocolate
$ns color 3 Darkgreen
$ns color 4 Purple

# Define a 'finish' procedure
proc finish {} {
        global ns nf
        $ns flush-trace
        close $nf
        exec nam dtn-demo-large.nam &
        exit 0
}

# Create nodes
set t0n0 [$ns node]
set t0n1 [$ns node]
set t0n2 [$ns node]
set t0n3 [$ns node]

set t1n0 [$ns node]
set t1n1 [$ns node]
set t1n2 [$ns node]
set t1n3 [$ns node]

set t2n0 [$ns node]
set t2n1 [$ns node]
set t2n2 [$ns node]
set t2n3 [$ns node]

set t3n0 [$ns node]
set t3n1 [$ns node]
set t3n2 [$ns node]
set t3n3 [$ns node]

# Connect the nodes with links.
$ns duplex-link $t0n0 $t0n1 1Mb 10ms DropTail
$ns duplex-link $t0n0 $t0n2 1Mb 10ms DropTail
$ns duplex-link $t0n0 $t0n3 1Mb 10ms DropTail

$ns duplex-link $t1n0 $t1n1 1Mb 10ms DropTail
$ns duplex-link $t1n0 $t1n2 1Mb 10ms DropTail
$ns duplex-link $t1n0 $t1n3 1Mb 10ms DropTail

$ns duplex-link $t2n0 $t2n1 1Mb 10ms DropTail
$ns duplex-link $t2n0 $t2n2 1Mb 10ms DropTail
$ns duplex-link $t2n0 $t2n3 1Mb 10ms DropTail

$ns duplex-link $t3n0 $t3n1 1Mb 10ms DropTail
$ns duplex-link $t3n0 $t3n2 1Mb 10ms DropTail
$ns duplex-link $t3n0 $t3n3 1Mb 10ms DropTail

$ns duplex-link $t0n0 $t1n0 1Mb 10ms DropTail
$ns duplex-link $t0n0 $t2n0 1Mb 10ms DropTail
$ns duplex-link $t0n0 $t3n0 1Mb 10ms DropTail
$ns duplex-link $t1n0 $t2n0 1Mb 10ms DropTail

# Create and attach agents.
set d0 [new Agent/DTNAgent]
$ns attach-agent $t0n0 $d0
set d1 [new Agent/DTNAgent]
$ns attach-agent $t0n1 $d1
set d2 [new Agent/DTNAgent]
$ns attach-agent $t0n2 $d2
set d3 [new Agent/DTNAgent]
$ns attach-agent $t0n3 $d3
set d4 [new Agent/DTNAgent]
$ns attach-agent $t1n0 $d4
set d5 [new Agent/DTNAgent]
$ns attach-agent $t1n1 $d5
set d6 [new Agent/DTNAgent]
$ns attach-agent $t1n2 $d6
set d7 [new Agent/DTNAgent]
$ns attach-agent $t1n3 $d7
set d8 [new Agent/DTNAgent]
$ns attach-agent $t2n0 $d8
set d9 [new Agent/DTNAgent]
$ns attach-agent $t2n1 $d9
set d10 [new Agent/DTNAgent]
$ns attach-agent $t2n2 $d10
set d11 [new Agent/DTNAgent]
$ns attach-agent $t2n3 $d11
set d12 [new Agent/DTNAgent]
$ns attach-agent $t3n0 $d12
set d13 [new Agent/DTNAgent]
$ns attach-agent $t3n1 $d13
set d14 [new Agent/DTNAgent]
$ns attach-agent $t3n2 $d14
set d15 [new Agent/DTNAgent]
$ns attach-agent $t3n3 $d15

# Set local Region
$d0  region "R0"
$d1  region "R0"
$d2  region "R0"
$d3  region "R0"

$d4  region "R1"
$d5  region "R1"
$d6  region "R1"
$d7  region "R1"

$d8  region "R2"
$d9  region "R2"
$d10 region "R2"
$d11 region "R2"

$d12 region "R3"
$d13 region "R3"
$d14 region "R3"
$d15 region "R3"

# Setup routing tables.
# R0
$d0  add "R1" $t1n0 1 1 $MTU
$d0  add "R1" $t2n0 1 2 $MTU
$d0  add "R2" $t2n0 1 1 $MTU
$d0  add "R2" $t1n0 1 2 $MTU
$d0  add "R3" $t3n0 1 1 $MTU
$d1  add "*"  $t0n0 1 0 $MTU
$d2  add "*"  $t0n0 1 0 $MTU
$d3  add "*"  $t0n0 1 0 $MTU

# R1
$d4  add "R0" $t0n0 1 1 $MTU
$d4  add "R0" $t2n0 1 2 $MTU
$d4  add "R2" $t2n0 1 1 $MTU
$d4  add "R2" $t0n0 1 2 $MTU
$d4  add "R3" $t0n0 1 2 $MTU
$d4  add "R3" $t2n0 1 3 $MTU
$d5  add "*"  $t1n0 1 0 $MTU
$d6  add "*"  $t1n0 1 0 $MTU
$d7  add "*"  $t1n0 1 0 $MTU

# R2
$d8  add "R0" $t0n0 1 1 $MTU
$d8  add "R0" $t1n0 1 2 $MTU
$d8  add "R1" $t1n0 1 1 $MTU
$d8  add "R1" $t0n0 1 2 $MTU
$d8  add "R3" $t0n0 1 2 $MTU
$d8  add "R3" $t1n0 1 3 $MTU
$d9  add "*"  $t2n0 1 0 $MTU
$d10 add "*"  $t2n0 1 0 $MTU
$d11 add "*"  $t2n0 1 0 $MTU

# R3
$d12 add "R0" $t0n0 1 1 $MTU
$d12 add "R1" $t0n0 1 2 $MTU
$d12 add "R2" $t0n0 1 2 $MTU
$d13 add "*"  $t3n0 1 0 $MTU
$d14 add "*"  $t3n0 1 0 $MTU
$d15 add "*"  $t3n0 1 0 $MTU

# Callback functions
Agent/DTNAgent instproc indData {sid did rid cos options lifespan adu} {
    $self instvar node_
    $self instvar $adu
    puts "node [$node_ id] ($did) received bundle from \
              $sid : '$adu'"
}

Agent/DTNAgent instproc indSendError {sid did rid cos options lifespan adu} {
    $self instvar node_
    puts "node [$node_ id] ($sid) got send error on bundle to \
              $did : '$adu'"
}

Agent/DTNAgent instproc indSendToken {binding sendtoken} {
    $self instvar node_
    puts "node [$node_ id] Send binding $binding bound to token $sendtoken"
    if { [string equal $binding "deleteme" ] } {
	$self cancel $sendtoken
    }
}

Agent/DTNAgent instproc indRegToken {binding regtoken} {
    $self instvar node_
    puts "node [$node_ id] Reg binding $binding bound to token $regtoken"
    if { [string equal $binding "t1n3:1" ] } {
        $self deregister $regtoken
    }
}

# Create a CBR traffic source. 
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ $PACKETSIZE
$cbr0 set rate_ [ expr 8 * $DATALOAD ]
$cbr0 attach-agent $d1

# Setup application interface.
$d1 app src      R0,$t0n1:10
$d1 app dest     R1,$t1n1:42
$d1 app rpt_to   R0,$t0n1:11
$d1 app cos      NORMAL
$d1 app options  CUST,REPCUST,EERCPT,REPRCPT,REPFWD
$d1 app lifespan 300

# Register a destination action.
$d5 register SINK t1n1:42 R1,$t1n1:42

# Run the CBR for 0.5 seconds.
$ns at 0.1 "$cbr0 start"
$ns at 0.6 "$cbr0 stop"

# Cause "link failure"
for {set x 0} {$x<5} {incr x} {
    $ns rtmodel-at [expr 0.05+0.20*$x]  down $t0n0 $t1n0
    $ns rtmodel-at [expr 0.06+0.20*$x]  down $t2n0 $t1n0
    $ns rtmodel-at [expr 0.07+0.20*$x]  up   $t0n0 $t1n0
    $ns rtmodel-at [expr 0.08+0.20*$x]  up   $t2n0 $t1n0
}

$ns at 100.0 "finish"

#Run the simulation
$ns run

