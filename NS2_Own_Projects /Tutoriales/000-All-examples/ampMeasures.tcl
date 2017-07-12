# ====================================================================
# Define Node Configuration paramaters
#====================================================================
set val(mac)            Mac/BNEP                 ;# MAC type
set val(nn)             4                        ;# number of mobilenodes
set val(numberOfMACs)   6                        ;# total number of MACs
set val(palType) PAL/802_11
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(chan)   Channel/WirelessChannel    ;# channel type

set val(x)              50                        ;# X dimension of the topography
set val(y)              50                          ;# Y dimension of the topography

#=====================================================================
# Initialize trace file desctiptors
#=====================================================================

# *** Throughput Trace ***

set f0 [open out02.tr w]
set f1 [open out12.tr w]

# *** Packet Loss Trace ***

set f4 [open lost02.tr w]
set f5 [open lost12.tr w]


# *** Packet Delay Trace ***

set f8 [open delay02.tr w]
set f9 [open delay12.tr w]


# *** Bytes Received Trace ***

set f12 [open data02.tr w]
set f13 [open data12.tr w]

# *** Initialize Simulator ***

set ns_              [new Simulator]

# *** Initialize Trace file ***

set tracefd     [open trace2.tr w]

$ns_ trace-all $tracefd

 

# *** Initialize Network Animator ***

set namtrace [open sim12.nam w]

$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

 

# *** set up topography object ***
set chan [new $val(chan)];#Create wireless channel
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

 

# Create  General Operations Director (GOD) object. It is used to store global information about the state of the environment, network, or nodes that an

# omniscent observer would have, but that should not be made known to any participant in the simulation.

 

create-god $val(numberOfMACs)

 

# configure nodes

	$ns_ node-config -macType $val(mac) \
                         -agentTrace ON \
                         -routerTrace ON \
                         -macTrace ON \
                         -movementTrace OFF
# Create Nodes

        for {set i 0} {$i < $val(nn) } {incr i} {

                set node_($i) [$ns_ node $i]
		$node_($i) rt AODV
		$node_($i) on
		#$ns_ initial_node_pos $node_($i) 10
		[$node_($i) set l2cap_] set ifq_limit_ 30 ;#set the size of the queue for the L2CAP layer
		set bb($i) [$node_($i) set bb_]
		#$bb($i) set energyMin_ 0.1
	#	$node($i) set-rate 1	;# set 1mb high rate
		$bb($i) set energy_ 3 ;# 3 watt hour
		$bb($i) set activeEnrgConRate_ 1.667E-5 ;# 60 mwh
        }

 	############# Add 802.11 PAL #####################
	$node_(0) add-PAL $val(palType) $topo $chan $val(prop)
	$node_(1) add-PAL $val(palType) $topo $chan $val(prop)

set ifq [new Queue/DropTail] ;#Declaration of the queue or buffer
$ifq set limit_ 20 ;#Limit the queue (packet)

# Initialize Node Coordinates


#$node_(0) pos 5.0 5.0

#$node_(1) pos 15.0 5.0

#$node_(2) pos 5.0 50.0

#$node_(3) pos 15.0 50.0

 

# Setup traffic flow between nodes

# UDP connections between node_(0) and node_(1)

# Create Constant four Bit Rate Traffic sources
set agent1 [new Agent/UDP]             ;# Create UDP Agent
$agent1 set prio_ 0                   ;# Set Its priority to 0
set sink [new Agent/LossMonitor]  ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(0) $agent1     ;# Attach Agent to source node
$ns_ attach-agent $node_(1) $sink ;# Attach Agent to sink node
$ns_ connect $agent1 $sink            ;# Connect the nodes
set app1 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app1 set packetSize_ 512               ;# Set Packet Size to 512 bytes
$app1 set rate_ 600Kb                    ;# Set CBR rate to 200 Kbits/sec
$app1 attach-agent $agent1             ;# Attach Application to agent

 
set agent2 [new Agent/UDP]             ;# Create UDP Agent
$agent2 set prio_ 1                   ;# Set Its priority to 1
set sink2 [new Agent/LossMonitor]         ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(2) $agent2     ;# Attach Agent to source node
$ns_ attach-agent $node_(3) $sink2        ;# Attach Agent to sink node
$ns_ connect $agent2 $sink2                  ;# Connect the nodes

set app2 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app2 set packetSize_ 512               ;# Set Packet Size to 512 bytes
$app2 set rate_ 600Kb                    ;# Set CBR rate to 200 Kbits/sec
$app2 attach-agent $agent2             ;# Attach Application to agent
 

# defines the node size in Network Animator
#for {set i 0} {$i < $val(nn)} {incr i} {
#    $ns_ initial_node_pos $node_($i) 20
#}

 

# Initialize Flags

set holdtime 0
set holdseq 0

set holdtime1 0
set holdseq1 0

set holdrate1 0
set holdrate2 0

set receivedBytes1 0
set receivedBytes2 0
# Function To record Statistcis (Bit Rate, Delay, Drop)

 

proc record {} {

        global sink sink2 f0 f1 f4 f5 f8 f9 f12 f13 holdtime holdseq holdtime1 holdseq1 holdrate1 holdrate2 receivedBytes1 receivedBytes2

        set ns [Simulator instance]

	set time 0.9 ;#Set Sampling Time to 0.9 Sec

	set bw0 [$sink set bytes_]
        set bw1 [$sink2 set bytes_] 

        set bw4 [$sink set nlost_]
        set bw5 [$sink2 set nlost_] 

        set bw8 [$sink set lastPktTime_]
        set bw9 [$sink set npkts_]

        set bw10 [$sink2 set lastPktTime_]
        set bw11 [$sink2 set npkts_]

	set receivedBytes1 [expr ($receivedBytes1+$bw0)]
	set receivedBytes2 [expr ($receivedBytes2+$bw1)]

    set now [$ns now]

        # Record Received Bytes in Trace Files
	puts $f12 "$now $receivedBytes1"
	puts $f13 "$now $receivedBytes2" 

        # Record Bit Rate in Trace Files

        puts $f0 "$now [expr (($bw0+$holdrate1)*8)/(2*$time*1000000)]"
        puts $f1 "$now [expr (($bw1+$holdrate2)*8)/(2*$time*1000000)]" 

        # Record Packet Loss Rate in File

        puts $f4 "$now [expr $bw4/$time]"
        puts $f5 "$now [expr $bw5/$time]" 

        # Record Packet Delay in File

        if { $bw9 > $holdseq } {
                puts $f8 "$now [expr ($bw8 - $holdtime)/($bw9 - $holdseq)]"
        } else {
                puts $f8 "$now [expr ($bw9 - $holdseq)]"
        }

        if { $bw11 > $holdseq1 } {
                puts $f9 "$now [expr ($bw10 - $holdtime1)/($bw11 - $holdseq1)]"
        } else {
                puts $f9 "$now [expr ($bw11 - $holdseq1)]"
        }       

        # Reset Variables

        $sink set bytes_ 0
        $sink2 set bytes_ 0

        $sink set nlost_ 0
        $sink2 set nlost_ 0

        set holdtime $bw8
        set holdseq $bw9

        set  holdrate1 $bw0
        set  holdrate2 $bw1

    $ns at [expr $now+$time] "record"   ;# Schedule Record after $time interval sec

}

# Start Recording at Time 0

$ns_ at 0.0 "record"
$ns_ at 0.1 "$node_(0) make-hs-connection $node_(1)"
$ns_ at 0.1 "$node_(2) make-bnep-connection $node_(3) DH5 DH5 noqos $ifq"

$ns_ at 10.0 "$app1 start"                 ;# Start transmission at time t = 1.4 Sec
$ns_ at 10.0 "$app2 start"               ;# Start transmission at time t = 10 Sec
# Stop Simulation at Time 80 sec
$ns_ at 80.0 "stop"
# Reset Nodes at time 80 sec

#for {set i 0} {$i < $val(nn) } {incr i} {
#    $ns_ at 80.0 "$node_($i) reset";
#}

# Exit Simulatoion at Time 80.01 sec
$ns_ at 80.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
        global ns_ tracefd f0 f1 f4 f5 f8 f9 f12 f13
        # Close Trace Files
        close $f0 
        close $f1
        close $f4 
        close $f5
        close $f8
        close $f9
	close $f12
	close $f13
       # Plot Recorded Statistics
	exec xgraph data02.tr data12.tr -t "Data Recieved in Bytes" -geometry 800x400 &
        exec xgraph out02.tr out12.tr -t "Bit Rate" -geometry 800x400 &
        exec xgraph lost02.tr lost12.tr -t "Packet Loss Rate" -geometry 800x400 &
        exec xgraph delay02.tr delay12.tr -t "Packet Delay" -geometry 800x400 &       
        # Reset Trace File

        $ns_ flush-trace
        close $tracefd      
        exit 0

}

puts "Starting Simulation..."

$ns_ run