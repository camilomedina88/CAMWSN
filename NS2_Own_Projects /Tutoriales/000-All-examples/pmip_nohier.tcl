#variable settings
set opt(debug)          0
set opt(bwtracetime)    0.01
set opt(dfLinkDelay)    10ms	;#default link delay
set opt(cnLinkDelay)    50ms	;#cn-lma link delay
set opt(agentType)      Agent/UDP
set opt(sinkType)       Agent/LossMonitor
set opt(trafficType)    Application/Traffic/CBR

#if traffic is CBR
set opt(cbrInterval)    0.1
set opt(cbrPacketSize)  1000

#debug messages
Agent/PMIPv6 set debug_ $opt(debug)
Agent/PMIPv6/MAG set debug_ $opt(debug)
Agent/PMIPv6/LMA set debug_ $opt(debug)

#defines function for flushing and closing files
proc finish {} {
        global ns tf
        $ns flush-trace
				close $tf
				
       	exit 
}

#create the simulator
set ns [new Simulator]

$ns use-scheduler RealTime

#give random seed
#ns-random 0

#open file for trace
set tf [open trace.out w]
$ns trace-all $tf

#creates the in first addressing space.
set router [$ns node]

set lma [$ns node]

#attach Agent/PMIPv6/LMA to the LMA
set lma_pm [$lma install-lma]

set cn [$ns node]

#BE CAREFUL!. PMIPv6 agent must be installed before connecting link(duplex-link)
$ns duplex-link $cn $lma 100Mb $opt(cnLinkDelay) DropTail
$ns duplex-link $lma $router 100Mb $opt(dfLinkDelay) DropTail

#create MAG1
set mag1 [$ns node]

#install PMIPv6/MAG agent to the MAG1
set mag1_pm [$mag1 install-mag]
set lmaa [$lma node-addr]
$mag1_pm set-lmaa [AddrParams addr2id $lmaa]

#Create MAG2
set mag2 [$ns node]

#install PMIPv6/MAG agent to the MAG1
set mag2_pm [$mag2 install-mag]
$mag2_pm set-lmaa [AddrParams addr2id $lmaa]

#ALSO, installing PMIPv6/MAG must come first before duplex-link
$ns duplex-link $mag1 $router 100Mb $opt(dfLinkDelay) DropTail
$ns duplex-link $mag2 $router 100Mb $opt(dfLinkDelay) DropTail

#Create mobile node
set mn [$ns node]

#add MN-ID to the prefix_pool of LMA
#with ns-2, node's address cannot be changed.
#so, we use full MN's address as if it were MN's prefix
$lma_pm register-mn-addr [$mn id] [$mn node-addr]

#create dynamic link between MN and MAGs

$ns duplex-link $mag1 $mn 11Mb $opt(dfLinkDelay) DropTail
$ns duplex-link $mag2 $mn 11Mb $opt(dfLinkDelay) DropTail

#make links dynamic
[$ns link $mn $mag1] dynamic
[$ns link $mag1 $mn] dynamic
[$ns link $mn $mag2] dynamic
[$ns link $mag2 $mn] dynamic

#Traffic setup
set agent [new $opt(agentType)]
$agent set class_ 2
$ns attach-agent $cn $agent

set traffic [new $opt(trafficType)]
$traffic attach-agent $agent

if { $opt(trafficType) == "Application/Traffic/CBR" } {
	$traffic set packetSize_ $opt(cbrPacketSize)
	$traffic set interval_ $opt(cbrInterval)
}

set sink [new $opt(sinkType)]
$ns attach-agent $mn $sink

$ns connect $agent $sink

#attached to MAG1
$ns rtmodel-at 0.1 down $mn $mag2
$ns at 0.2 "$mag1_pm new-mn [$mn id]"

#attached to MAG2
$ns rtmodel-at 10.0 down $mn $mag1
$ns rtmodel-at 10.1 up $mn $mag2
$ns at 10.2 "$mag2_pm new-mn [$mn id]"

$ns at 0.5 "$traffic start"
$ns at 19.5 "$traffic stop"

$ns at 20 "finish"

$ns run
