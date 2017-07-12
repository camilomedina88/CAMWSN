# Create 7 sinks in a single node
# ====================================================================
# Define Node Configuration paramaters
#====================================================================
set val(mac)            Mac/BNEP                 ;# MAC type
set val(nn)             8                        ;# number of mobilenodes
set val(numberOfMACs)   16                        ;# total number of MACs
set val(palType) PAL/802_11
set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model
set val(chan)   Channel/WirelessChannel    ;# channel type

set val(x)              50                        ;# X dimension of the topography
set val(y)              50                          ;# Y dimension of the topography

#=====================================================================
# Initialize trace file desctiptors
#=====================================================================

# *** Throughput Trace ***

set out1 [open out1.tr w]
set out2 [open out2.tr w]
set out3 [open out3.tr w]
set out4 [open out4.tr w]
set out5 [open out5.tr w]
set out6 [open out6.tr w]
set out7 [open out7.tr w]

# *** Packet Loss Trace ***

set lost1 [open lost1.tr w]
set lost2 [open lost2.tr w]
set lost3 [open lost3.tr w]
set lost4 [open lost4.tr w]
set lost5 [open lost5.tr w]
set lost6 [open lost6.tr w]
set lost7 [open lost7.tr w]

# *** Packet Delay Trace ***

set delay1 [open delay1.tr w]
set delay2 [open delay2.tr w]
set delay3 [open delay3.tr w]
set delay4 [open delay4.tr w]
set delay5 [open delay5.tr w]
set delay6 [open delay6.tr w]
set delay7 [open delay7.tr w]

# *** Bytes Received Trace ***

set data1 [open data1.tr w]
set data2 [open data2.tr w]
set data3 [open data3.tr w]
set data4 [open data4.tr w]
set data5 [open data5.tr w]
set data6 [open data6.tr w]
set data7 [open data7.tr w]

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

        for {set i 0} {$i < $val(nn) } {incr i} {
	############# Add 802.11 PAL #####################
        $node_($i) add-PAL $val(palType) $topo $chan $val(prop)
	}
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
$agent1 set packetSize_ 1500
set sink1 [new Agent/LossMonitor]  ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(1) $agent1     ;# Attach Agent to source node
$ns_ attach-agent $node_(0) $sink1 ;# Attach Agent to sink node
$ns_ connect $agent1 $sink1            ;# Connect the nodes
set app1 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app1 set packetSize_ 1480               ;# Set Packet Size to 512 bytes
#$app1 set rate_ 6000Kb                    ;# Set CBR rate to 200 Kbits/sec
$app1 set interval_ 0.01		;##### frange( 0.001, 0.05, 0.0005 ) 
$app1 attach-agent $agent1             ;# Attach Application to agent

 
set agent2 [new Agent/UDP]             ;# Create UDP Agent
$agent2 set prio_ 1                   ;# Set Its priority to 1
$agent2 set packetSize_ 1500
set sink2 [new Agent/LossMonitor]         ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(3) $agent2     ;# Attach Agent to source node
$ns_ attach-agent $node_(2) $sink2        ;# Attach Agent to sink node
$ns_ connect $agent2 $sink2                  ;# Connect the nodes

set app2 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app2 set packetSize_ 1480               ;# Set Packet Size to 512 bytes
#$app2 set rate_ 6000Kb                    ;# Set CBR rate to 200 Kbits/sec
$app2 set interval_ 0.01		;##### frange( 0.001, 0.05, 0.0005 ) 
$app2 attach-agent $agent2             ;# Attach Application to agent
 


set agent3 [new Agent/UDP]             ;# Create UDP Agent
$agent3 set prio_ 1                   ;# Set Its priority to 1
$agent3 set packetSize_ 1500
set sink3 [new Agent/LossMonitor]         ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(5) $agent3     ;# Attach Agent to source node
$ns_ attach-agent $node_(4) $sink3        ;# Attach Agent to sink node
$ns_ connect $agent3 $sink3                  ;# Connect the nodes

set app3 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app3 set packetSize_ 1480               ;# Set Packet Size to 512 bytes
#$app2 set rate_ 6000Kb                    ;# Set CBR rate to 200 Kbits/sec
$app3 set interval_ 0.01		;##### frange( 0.001, 0.05, 0.0005 ) 
$app3 attach-agent $agent3             ;# Attach Application to agent


set agent4 [new Agent/UDP]             ;# Create UDP Agent
$agent4 set prio_ 1                   ;# Set Its priority to 1
$agent4 set packetSize_ 1500
set sink4 [new Agent/LossMonitor]         ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(7) $agent4     ;# Attach Agent to source node
$ns_ attach-agent $node_(6) $sink4        ;# Attach Agent to sink node
$ns_ connect $agent4 $sink4                  ;# Connect the nodes

set app4 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app4 set packetSize_ 1480               ;# Set Packet Size to 512 bytes
#$app2 set rate_ 6000Kb                    ;# Set CBR rate to 200 Kbits/sec
$app4 set interval_ 0.01		;##### frange( 0.001, 0.05, 0.0005 ) 
$app4 attach-agent $agent4             ;# Attach Application to agent


set agent5 [new Agent/UDP]             ;# Create UDP Agent
$agent5 set prio_ 1                   ;# Set Its priority to 1
$agent5 set packetSize_ 1500
set sink5 [new Agent/LossMonitor]         ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(0) $agent5     ;# Attach Agent to source node
$ns_ attach-agent $node_(1) $sink5        ;# Attach Agent to sink node
$ns_ connect $agent5 $sink5                  ;# Connect the nodes

set app5 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app5 set packetSize_ 1480               ;# Set Packet Size to 512 bytes
#$app2 set rate_ 6000Kb                    ;# Set CBR rate to 200 Kbits/sec
$app5 set interval_ 0.01		;##### frange( 0.001, 0.05, 0.0005 ) 
$app5 attach-agent $agent5             ;# Attach Application to agent


set agent6 [new Agent/UDP]             ;# Create UDP Agent
$agent6 set prio_ 1                   ;# Set Its priority to 1
$agent6 set packetSize_ 1500
set sink6 [new Agent/LossMonitor]         ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(2) $agent6     ;# Attach Agent to source node
$ns_ attach-agent $node_(3) $sink6        ;# Attach Agent to sink node
$ns_ connect $agent6 $sink6                  ;# Connect the nodes

set app6 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app6 set packetSize_ 1480               ;# Set Packet Size to 512 bytes
#$app2 set rate_ 6000Kb                    ;# Set CBR rate to 200 Kbits/sec
$app6 set interval_ 0.01		;##### frange( 0.001, 0.05, 0.0005 ) 
$app6 attach-agent $agent6             ;# Attach Application to agent


set agent7 [new Agent/UDP]             ;# Create UDP Agent
$agent7 set prio_ 1                   ;# Set Its priority to 1
$agent7 set packetSize_ 1500
set sink7 [new Agent/LossMonitor]         ;# Create Loss Monitor Sink in order to be able to trace the number obytes received
$ns_ attach-agent $node_(4) $agent7     ;# Attach Agent to source node
$ns_ attach-agent $node_(5) $sink7        ;# Attach Agent to sink node
$ns_ connect $agent7 $sink7                  ;# Connect the nodes

set app7 [new Application/Traffic/CBR]  ;# Create Constant Bit Rate application
$app7 set packetSize_ 1480               ;# Set Packet Size to 512 bytes
#$app2 set rate_ 6000Kb                    ;# Set CBR rate to 200 Kbits/sec
$app7 set interval_ 0.01		;##### frange( 0.001, 0.05, 0.0005 ) 
$app7 attach-agent $agent7             ;# Attach Application to agent
# defines the node size in Network Animator
#for {set i 0} {$i < $val(nn)} {incr i} {
#    $ns_ initial_node_pos $node_($i) 20
#}

 

# Initialize Flags

set holdtime1 0
set holdseq1 0

set holdtime2 0
set holdseq2 0

set holdtime3 0
set holdseq3 0

set holdtime4 0
set holdseq4 0

set holdtime5 0
set holdseq5 0

set holdtime6 0
set holdseq6 0

set holdtime7 0
set holdseq7 0

set holdrate1 0
set holdrate2 0
set holdrate3 0
set holdrate4 0
set holdrate5 0
set holdrate6 0
set holdrate7 0

set receivedBytes1 0
set receivedBytes2 0
set receivedBytes3 0
set receivedBytes4 0
set receivedBytes5 0
set receivedBytes6 0
set receivedBytes7 0

# Function To record Statistcis (Bit Rate, Delay, Drop)

 

proc record {} {

        global sink1 sink2 sink3 sink4 sink5 sink6 sink7 holdtime1 holdtime2 holdtime3 holdtime4 holdtime5 holdtime6 holdtime7 holdseq1 holdseq2 holdseq3 holdseq4 holdseq5 holdseq6 holdseq7 holdrate1 holdrate2 holdrate3 holdrate4 holdrate5 holdrate6 holdrate7 receivedBytes1 receivedBytes2 receivedBytes3 receivedBytes4 receivedBytes5 receivedBytes6 receivedBytes7 out1 out2 out3 out4 out5 out6 out7 lost1 lost2 lost3 lost4 lost5 lost6 lost7 delay1 delay2 delay3 delay4 delay5 delay6 delay7 data1 data2 data3 data4 data5 data6 data7

        set ns [Simulator instance]

	set time 0.9 ;#Set Sampling Time to 0.9 Sec

	set b1 [$sink1 set bytes_]
	set b2 [$sink2 set bytes_]
	set b3 [$sink3 set bytes_]
	set b4 [$sink4 set bytes_]
	set b5 [$sink5 set bytes_]
	set b6 [$sink6 set bytes_]
	set b7 [$sink7 set bytes_]

	set l1 [$sink1 set nlost_]
	set l2 [$sink2 set nlost_]
	set l3 [$sink3 set nlost_]
	set l4 [$sink4 set nlost_]
	set l5 [$sink5 set nlost_]
	set l6 [$sink6 set nlost_]
	set l7 [$sink7 set nlost_]
        
        set d11 [$sink1 set lastPktTime_]
        set d12 [$sink1 set npkts_]
        set d21 [$sink2 set lastPktTime_]
        set d22 [$sink2 set npkts_]
        set d31 [$sink3 set lastPktTime_]
        set d32 [$sink3 set npkts_]
        set d41 [$sink4 set lastPktTime_]
        set d42 [$sink4 set npkts_]
        set d51 [$sink5 set lastPktTime_]
        set d52 [$sink5 set npkts_]
        set d61 [$sink6 set lastPktTime_]
        set d62 [$sink6 set npkts_]
        set d71 [$sink7 set lastPktTime_]
        set d72 [$sink7 set npkts_]


	set receivedBytes1 [expr ($receivedBytes1+$b1)]
	set receivedBytes2 [expr ($receivedBytes2+$b2)]
	set receivedBytes3 [expr ($receivedBytes3+$b3)]
	set receivedBytes4 [expr ($receivedBytes4+$b4)]
	set receivedBytes5 [expr ($receivedBytes5+$b5)]
	set receivedBytes6 [expr ($receivedBytes6+$b6)]
	set receivedBytes7 [expr ($receivedBytes7+$b7)]

    set now [$ns now]

        # Record Received Bytes in Trace Files
	puts $data1 "$now $receivedBytes1"
	puts $data2 "$now $receivedBytes2"
	puts $data3 "$now $receivedBytes3"
	puts $data4 "$now $receivedBytes4"
	puts $data5 "$now $receivedBytes5"
	puts $data6 "$now $receivedBytes6"
	puts $data7 "$now $receivedBytes7"

        # Record Bit Rate in Trace Files

        puts $out1 "$now [expr (($b1+$holdrate1)*8)/(2*$time*1000000)]"
	puts $out2 "$now [expr (($b2+$holdrate2)*8)/(2*$time*1000000)]"
	puts $out3 "$now [expr (($b3+$holdrate3)*8)/(2*$time*1000000)]"
	puts $out4 "$now [expr (($b4+$holdrate4)*8)/(2*$time*1000000)]"
	puts $out5 "$now [expr (($b5+$holdrate5)*8)/(2*$time*1000000)]"
	puts $out6 "$now [expr (($b6+$holdrate6)*8)/(2*$time*1000000)]"
	puts $out7 "$now [expr (($b7+$holdrate7)*8)/(2*$time*1000000)]"

        # Record Packet Loss Rate in File

        puts $lost1 "$now [expr $l1/$time]"
	puts $lost2 "$now [expr $l2/$time]"
	puts $lost3 "$now [expr $l3/$time]"
	puts $lost4 "$now [expr $l4/$time]"
	puts $lost5 "$now [expr $l5/$time]"
	puts $lost6 "$now [expr $l6/$time]"
	puts $lost7 "$now [expr $l7/$time]"

        # Record Packet Delay in File

        if { $d12 > $holdseq1 } {
                puts $delay1 "$now [expr ($d11 - $holdtime1)/($d12 - $holdseq1)]"
        } else {
                puts $delay1 "$now [expr ($d12 - $holdseq1)]"
        }

        if { $d22 > $holdseq2 } {
                puts $delay2 "$now [expr ($d21 - $holdtime2)/($d22 - $holdseq2)]"
        } else {
                puts $delay2 "$now [expr ($d22 - $holdseq2)]"
        }

        if { $d32 > $holdseq3 } {
                puts $delay3 "$now [expr ($d31 - $holdtime3)/($d32 - $holdseq3)]"
        } else {
                puts $delay3 "$now [expr ($d32 - $holdseq3)]"
        }

        if { $d42 > $holdseq4 } {
                puts $delay4 "$now [expr ($d41 - $holdtime4)/($d42 - $holdseq4)]"
        } else {
                puts $delay4 "$now [expr ($d42 - $holdseq4)]"
        }

        if { $d52 > $holdseq5 } {
                puts $delay5 "$now [expr ($d51 - $holdtime5)/($d52 - $holdseq5)]"
        } else {
                puts $delay5 "$now [expr ($d52 - $holdseq5)]"
        }

        if { $d62 > $holdseq6 } {
                puts $delay6 "$now [expr ($d61 - $holdtime6)/($d62 - $holdseq6)]"
        } else {
                puts $delay6 "$now [expr ($d62 - $holdseq6)]"
        }

        if { $d72 > $holdseq7 } {
                puts $delay7 "$now [expr ($d71 - $holdtime7)/($d72 - $holdseq7)]"
        } else {
                puts $delay7 "$now [expr ($d72 - $holdseq7)]"
        }


        # Reset Variables

        $sink1 set bytes_ 0
        $sink2 set bytes_ 0
        $sink3 set bytes_ 0
        $sink4 set bytes_ 0
        $sink5 set bytes_ 0
        $sink6 set bytes_ 0
        $sink7 set bytes_ 0

        $sink1 set nlost_ 0
        $sink2 set nlost_ 0
        $sink3 set nlost_ 0
        $sink4 set nlost_ 0
        $sink5 set nlost_ 0
        $sink6 set nlost_ 0
        $sink7 set nlost_ 0

        set holdtime1 $d11
	set holdtime2 $d21
	set holdtime3 $d31
	set holdtime4 $d41
	set holdtime5 $d51
	set holdtime6 $d61
	set holdtime7 $d71

        set holdseq1 $d12
        set holdseq2 $d22
        set holdseq3 $d32
        set holdseq4 $d42
        set holdseq5 $d52
        set holdseq6 $d62
        set holdseq7 $d72

        set  holdrate1 $b1
        set  holdrate2 $b2
	set  holdrate3 $b3
	set  holdrate4 $b4
	set  holdrate5 $b5
	set  holdrate6 $b6
	set  holdrate7 $b7

    $ns at [expr $now+$time] "record"   ;# Schedule Record after $time interval sec

}

# Start Recording at Time 0

$ns_ at 0.0 "record"
$ns_ at 0.1 "$node_(0) make-hs-connection $node_(1)"
$ns_ at 0.1 "$node_(2) make-hs-connection $node_(3)"
$ns_ at 0.1 "$node_(4) make-hs-connection $node_(5)"
$ns_ at 0.1 "$node_(7) make-hs-connection $node_(6)"
#$ns_ at 0.1 "$node_(1) make-hs-connection $node_(0)"
#$ns_ at 0.1 "$node_(2) make-hs-connection $node_(3)"
#$ns_ at 0.1 "$node_(3) make-hs-connection $node_(5)"
#$ns_ at 0.1 "$node_(0) make-bnep-connection $node_(1) DH5 DH5 noqos $ifq"
#$ns_ at 0.1 "$node_(0) make-bnep-connection $node_(2) DH5 DH5 noqos $ifq"
#$ns_ at 0.1 "$node_(0) make-bnep-connection $node_(3) DH5 DH5 noqos $ifq"
#$ns_ at 0.1 "$node_(0) make-bnep-connection $node_(4) DH5 DH5 noqos $ifq"
#$ns_ at 0.1 "$node_(0) make-bnep-connection $node_(5) DH5 DH5 noqos $ifq"
#$ns_ at 0.1 "$node_(0) make-bnep-connection $node_(6) DH5 DH5 noqos $ifq"
#$ns_ at 0.1 "$node_(0) make-bnep-connection $node_(7) DH5 DH5 noqos $ifq"

$ns_ at 5.0 "$app1 start"                 ;# Start transmission at time t = 1.4 Sec
$ns_ at 5.0 "$app2 start"               ;# Start transmission at time t = 10 Sec
$ns_ at 5.0 "$app3 start"               ;# Start transmission at time t = 10 Sec
$ns_ at 5.0 "$app4 start"               ;# Start transmission at time t = 10 Sec
$ns_ at 5.0 "$app5 start"               ;# Start transmission at time t = 10 Sec
$ns_ at 5.0 "$app6 start"               ;# Start transmission at time t = 10 Sec
$ns_ at 5.0 "$app7 start"               ;# Start transmission at time t = 10 Sec
# Stop Simulation at Time 80 sec
$ns_ at 12.0 "stop"
# Reset Nodes at time 80 sec

#for {set i 0} {$i < $val(nn) } {incr i} {
#    $ns_ at 15.0 "$node_($i) reset";
#}

# Exit Simulatoion at Time 80.01 sec
$ns_ at 15.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
        global ns_ tracefd out1 out2 out3 out4 out5 out6 out7 lost1 lost2 lost3 lost4 lost5 lost6 lost7 delay1 delay2 delay3 delay4 delay5 delay6 delay7 data1 data2 data3 data4 data5 data6 data7
        # Close Trace Files
        close $out1 
        close $out2 
        close $out3 
        close $out4 
        close $out5 
        close $out6 
        close $out7 

        close $lost1 
        close $lost2
        close $lost3
        close $lost4
        close $lost5
        close $lost6
        close $lost7

        close $delay1
        close $delay2
        close $delay3
        close $delay4
        close $delay5
        close $delay6
        close $delay7

        close $data1
        close $data2
        close $data3
        close $data4
        close $data5
        close $data6
        close $data7

       # Plot Recorded Statistics
	exec xgraph data1.tr data2.tr data3.tr data4.tr data5.tr data6.tr data7.tr -t "Data Recieved in Bytes" -geometry 800x400 &
        exec xgraph out1.tr out2.tr out3.tr out4.tr out5.tr out6.tr out7.tr -t "Bit Rate" -geometry 800x400 &
        exec xgraph lost1.tr lost2.tr lost3.tr lost4.tr lost5.tr lost6.tr lost7.tr -t "Packet Loss Rate" -geometry 800x400 &
        exec xgraph delay1.tr delay2.tr delay3.tr delay4.tr delay5.tr delay6.tr delay7.tr -t "Packet Delay" -geometry 800x400 &       
        # Reset Trace File

        $ns_ flush-trace
        close $tracefd      
        exit 0

}

puts "Starting Simulation..."

$ns_ run
