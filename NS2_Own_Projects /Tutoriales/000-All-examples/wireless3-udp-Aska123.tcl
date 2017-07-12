# 6    http://www.linuxquestions.org/questions/linux-software-2/no-output-in-xgraph-file-4175497572/#6


set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)           Phy/WirelessPhy            ;# network interface type
 
set val(mac)            Mac/802_11                ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue   ;# interface queue type
 
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             4                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol
set val(x)              500                        ;# X dimension of the topography
set val(y)              500                           ;# Y dimension of the topography
set opt(energymodel)    EnergyModel 
 
Mac/802_11 set RTSThreshold_  3000
Mac/802_11 set basicRate_ 1Mb
Mac/802_11 set dataRate_  2Mb

#=====================================================================
# Initialize trace file desctiptors
#=====================================================================
# *** Throughput Trace ***
set f0 [open out03.tr w]

 
# *** Packet Loss Trace ***
set f4 [open lost03.tr w]

 
# *** Packet Delay Trace ***
set f8 [open delay03.tr w]

#*** Throughput Trace ***
set f1 [open thro.tr w]

 
# *** Initialize Simulator ***
set ns_              [new Simulator]
 
# *** Initialize Trace file ***
set tracefd     [open trace3.tr w]
$ns_ trace-all $tracefd
 
# *** Initialize Network Animator ***
set namtrace [open sim3.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
 
# *** set up topography object ***
set topo       [new Topography]
$topo load_flatgrid 500 500

create-god $val(nn)
 
# configure nodes
        $ns_ node-config -adhocRouting $val(rp) \
                         -llType $val(ll) \
                         -macType $val(mac) \
                         -ifqType $val(ifq) \
                         -ifqLen $val(ifqlen) \
                         -antType $val(ant) \
                         -propType $val(prop) \
                         -phyType $val(netif) \
                         -channelType $val(chan) \
                         -topoInstance $topo \
                         -agentTrace ON \
                         -routerTrace ON \
                         -macTrace OFF \
                         -movementTrace OFF \
			-energyModel $opt(energymodel) \
			 -rxPower 0.3 \
			 -txPower 0.9                   
 
# Create Nodes
 
       # for {set i 0} {$i < $val(nn) } {incr i} {
        #        set node_($i) [$ns_ node]
         #       $node_($i) random-motion 0            ;# disable random motion
        #}
 
# Initialize Node Coordinates

$ns_ node-config -initialEnergy 1
set node_(0) [$ns_ node] 
$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0
 
$ns_ node-config -initialEnergy 0.1
set node_(1) [$ns_ node] 
$node_(1) set X_ 200.0
$node_(1) set Y_ 5.0
$node_(1) set Z_ 0.0

$ns_ node-config -initialEnergy 0.1
set node_(2) [$ns_ node]  
$node_(2) set X_ 5.0
$node_(2) set Y_ 50.0
$node_(2) set Z_ 0.0

$ns_ node-config -initialEnergy 0.1
set node_(3) [$ns_ node] 
$node_(3) set X_ 437.0
$node_(3) set Y_ 295.0
$node_(3) set Z_ 0.0

set agent1 [new Agent/UDP]            

$agent1 set prio_ 0                   

set sink [new Agent/LossMonitor]  

$ns_ attach-agent $node_(0) $agent1     ;# Attach Agent to source node

$ns_ attach-agent $node_(1) $sink          ;# Attach Agent to sink node

$ns_ connect $agent1 $sink                   ;# Connect the nodes

set app1 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app1 set packetSize_ 512               ;# Set Packet Size to 512 bytes
$app1 set rate_ 600Kb                    ;# Set CBR rate to 200 Kbits/sec
$app1 attach-agent $agent1             ;# Attach Application to agent

set agent2 [new Agent/UDP]             ;# Create UDP Agent
$agent2 set prio_ 1                   ;# Set Its priority to 1


$ns_ attach-agent $node_(2) $agent2

$ns_ connect $agent2 $sink


set app2 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app2 set packetSize_ 512               ;# Set Packet Size to 512 bytes
$app2 set rate_ 600Kb                    ;# Set CBR rate to 200 Kbits/sec
$app2 attach-agent $agent2             ;# Attach Application to agent

$ns_ attach-agent $node_(2) $agent2

$ns_ connect $agent2 $sink


set agent3 [new Agent/UDP]             ;# Create UDP Agent
$agent3 set prio_ 1                   ;# Set Its priority to 1


$ns_ attach-agent $node_(3) $agent3

$ns_ connect $agent3 $sink
set app3 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app3 set packetSize_ 512               ;# Set Packet Size to 512 bytes
$app3 set rate_ 600Kb                    ;# Set CBR rate to 200 Kbits/sec
$app3 attach-agent $agent3             ;# Attach Application to agent

# defines the node size in Network Animator
 
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 20
}
 
# Initialize Flags
set holdtime 0
set holdseq 0
 
set holdtime1 0
set holdseq1 0
 
set holdtime2 0
set holdseq2 0

set holdrate1 0
set holdrate2 0
set holdrate3 0


# Function To record Statistcis (Bit Rate, Delay, Drop)
 
proc record {} {
        global sink  f0  f4  f8 holdtime holdseq holdtime1 holdseq1 holdtime2 holdseq2  f8 f9 f10 f11 holdrate1  
       
	set ns [Simulator instance]
        set time 0.9 ;#Set Sampling Time to 0.9 Sec
 
set bw0 [$sink set bytes_]
set bw4 [$sink set nlost_]
set bw8 [$sink set lastPktTime_]
 set bw9 [$sink set npkts_]

 set now [$ns now]
   
   # Record Bit Rate in Trace Files
   puts $f0 "$now [expr (($bw0+$holdrate1)*8)/(2*$time*1000000)]"
     
 # Record Packet Loss Rate in File
        puts $f4 "$now [expr $bw4/$time]"
       
 # Record Packet Delay in File
        if { $bw9 > $holdseq } {
                puts $f8 "$now [expr ($bw8 - $holdtime)/($bw9 - $holdseq)]"
        } else {
                puts $f8 "$now [expr ($bw9 - $holdseq)]"
        }
             
 # Reset Variables
        $sink set bytes_ 0
        $sink set nlost_ 0
        set holdtime $bw8
        set holdseq $bw9
        set  holdrate1 $bw0
        
    $ns at [expr $now+$time] "record"   ;# Schedule Record after $time interval sec
}

# Start Recording at Time 0
$ns_ at 0.0 "record"
$ns_ at 1.4 "$app1 start"                 ;# Start transmission at time t = 1.4 Sec
$ns_ at 10.0 "$app2 start"               ;# Start transmission at time t = 10 Sec


# Stop Simulation at Time 80 sec
$ns_ at 80.0 "stop"
 
# Reset Nodes at time 80 sec
 
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 80.0 "$node_($i) reset";
}
 
# Exit Simulatoion at Time 80.01 sec
$ns_ at 80.01 "puts \"NS EXITING...\" ; $ns_ halt"
 
proc stop {} {
        global ns_ tracefd f0 f1 f4  f8  namtrace
 
        # Close Trace Files
        close $f0 
        close $f4 
        close $f8
close $f1

 # Plot Recorded Statistics
        exec xgraph out03.tr  -geometry 800x400 &
        exec xgraph lost03.tr  -geometry 800x400 &
        exec xgraph delay03.tr  -geometry 800x400 &

 # Reset Trace File
        $ns_ flush-trace
        close $tracefd
	close $namtrace
	exec nam sim3.nam &
       
        exit 0
}
 
puts "Starting Simulation..."
$ns_ run
