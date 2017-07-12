#Create a simulator object
set ns [new Simulator]

set tf [open example3.tr w]
$ns trace-all $tf

#Open the nam trace file
set nf [open example3.nam w]
$ns namtrace-all $nf

#Define a 'finish' procedure
proc finish {} {
    global ns nf
    $ns flush-trace
    #Close the trace file
    close $nf
    #Execute nam on the trace file
    exec nam example3.nam &
    exit 0
}

# Insert your own code for topology creation
# and agent definitions, etc. here
for {set i 0} {$i < 7} {incr i} {
    set n($i) [$ns node]
}

for {set i 0} {$i < 7} {incr i} {
    $ns duplex-link $n($i) $n([expr ($i+1)%7]) 1Mb 10ms DropTail
}

set udp0 [new Agent/UDP]
$ns attach-agent $n(0) $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

set null0 [new Agent/Null]
$ns attach-agent $n(3) $null0

$ns connect $udp0 $null0

$ns rtmodel-at 1.0 down $n(1) $n(2)
$ns rtmodel-at 1.1 down $n(6) $n(5)

$ns rtproto DV

$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"
#Call the finish procedure after 5 seconds simulation time
$ns at 5.0 "finish"

#Run the simulation
$ns run


