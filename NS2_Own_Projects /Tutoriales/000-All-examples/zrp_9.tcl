# ======================================================================
# Define options
# ======================================================================
Mac/802_11 set dataRate_ 11Mb              ;#Rate for Data Frames
 set val(chan)         Channel/WirelessChannel  ;# channel type
 set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
 set val(ant)          Antenna/OmniAntenna      ;# Antenna type
 set val(ll)           LL                       ;# Link layer type
 set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
 set val(ifqlen)       50                       ;# max packet in ifq
 set val(netif)        Phy/WirelessPhy          ;# network interface type
 set val(mac)          Mac/802_11               ;# MAC type
 set val(nn)           100                       ;# number of mobilenodes
 set val(rp)	       ZRP                    ;# routing protocol
 set val(x)            10000
 set val(y)            10000
 set val(stop)	       10 ;
Agent/ZRP set radius_ 9 ;
set ns [new Simulator]
#ns-random 0

set tracefd [open zrp_9.tr w]
#set windowVsTime2 [open win.tr w] 
set namtrace [open zrp_9.nam w]
$ns use-newtrace
$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

#set f0 [open So_Goi_Da_Gui.tr w]
#set f1 [open So_Goi_Mat.tr w]
#set f2 [open proj_out2.tr w]
#set f3 [open proj_out3.tr w]


set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)


set chan_1 [new $val(chan)]

# CONFIGURE AND CREATE NODES

$ns node-config  -adhocRouting $val(rp) \
 		 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 #-channelType $val(chan) \
                 -topoInstance $topo \
                 -agentTrace OFF \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace OFF \
                 -channel $chan_1  # \


proc finish {} {
	global ns f f0 f1 f2 f3 namtrace
	$ns flush-trace
        close $namtrace   

        exec nam -r 5m zrp_9 &
	exit 0
}

proc record {} {
  global sink0 sink1 sink2 sink3 sink4 sink5 sink6 sink7 sink8 sink9 f0 f1 f2 f3
   #Get An Instance Of The Simulator
   set ns [Simulator instance]
   
   #Set The Time After Which The Procedure Should Be Called Again
   set time 0.05
   #How Many Bytes Have Been Received By The Traffic Sinks?
   set bw0 [$sink9 set npkts_]
   set bw1 [$sink9 set nlost_]

   #set bw2 [$sink2 set npkts_]
   #set bw3 [$sink3 set npkts_]
   
   #Get The Current Time
   set now [$ns now]
   
   #Save Data To The Files
   puts $f0 "$now [expr $bw0]"
   puts $f1 "$now [expr $bw1]"
   #puts $f2 "$now [expr $bw2]"
   #puts $f3 "$now [expr $bw3]"

   #Re-Schedule The Procedure
   $ns at [expr $now+$time] "record"
  }
 
for {set i 0} {$i < $val(nn)} {incr i} {
set n_($i) [$ns node]
#$n_($i) random-motion 0
$ns initial_node_pos $n_($i) 20
}


for {set i 0} {[expr $i < $val(nn)/10]} {incr i} {
for {set j 0} {$j < 10} {incr j} {
set id [expr $i*10 + $j]
$n_($id) set X_ [expr $j*100+120]
$n_($id) set Y_ [expr $i*100+120]
$n_($id) set Z_ 0.0
}
}

for {set i 0} {$i < $val(nn)} {incr i} {
if {$i%3 == 0} {
$ns at 0.0 "$n_($i) setdest [expr $i%7*1040+20] [expr $i%3*3000+20] 5.0"
}

if {$i%3 == 1} {
$ns at 0.0 "$n_($i) setdest [expr $i%6+20] [expr $i%3*3000+20] 5.0"
}

if {$i%3 == 2} {
$ns at 0.0 "$n_($i) setdest [expr $i%7*1040+20] [expr $i%3+10] 5.0"
}
}

# CONFIGURE AND SET UP A FLOW

for {set i 0} {$i < $val(nn)} {incr i} {
set sink_($i) [new Agent/LossMonitor]
$ns attach-agent $n_($i) $sink_($i)

set tcp_($i) [new Agent/TCP]
$ns attach-agent $n_(0) $tcp_($i)
}




proc attach-CBR-traffic { node sink size interval } {
   #Get an instance of the simulator
   set ns [Simulator instance]
   #Create a CBR  agent and attach it to the node
   set cbr [new Agent/CBR]
   $ns attach-agent $node $cbr
   $cbr set packetSize_ $size
   $cbr set interval_ $interval

   #Attach CBR source to sink;
   $ns connect $cbr $sink
   return $cbr
  }



set cbr0 [attach-CBR-traffic $n_(0) $sink_([expr $val(nn)-1]) 512 0.25]
set cbr1 [attach-CBR-traffic $n_(1) $sink_([expr $val(nn)-1]) 512 0.25]




$ns at 0.0 "$cbr0 start"
$ns at $val(stop) "$cbr0 stop"

$ns at 0.0 "$cbr1 start"
$ns at $val(stop) "$cbr1 stop"


$ns at $val(stop) "finish"

puts "Start of simulation.."
$ns run
