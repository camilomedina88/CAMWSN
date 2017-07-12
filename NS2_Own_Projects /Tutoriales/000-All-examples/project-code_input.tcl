#      http://read.pudn.com/downloads198/sourcecode/unix_linux/network/932616/project-code/input.tcl__.htm


#define options 
set val(chan)           Channel/WirelessChannel    ;# channel type 
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model 
set val(netif)          Phy/WirelessPhy            ;# network interface type 
set val(mac)            Mac/802_11                 ;# MAC type 
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type 
set val(ll)             LL                         ;# link layer type 
set val(ant)            Antenna/OmniAntenna        ;# antenna model 
set val(ifqlen)         50                         ;# max packet in ifq 
set val(nn)             50                          ;# number of mobilenodes 
set val(rp)             AODV                       ;# routing protocol 
set val(x)              1000   			   ;# X dimension of topography 
set val(y)              1000   			   ;# Y dimension of topography   
set val(stop)		200 			   ;# time of simulation end
set val(traffic)       "./cbr" 
set val(mobility)       "./nodes"  
 
set ns		  [new Simulator] 
set tracefd       [open output.tr w] 
set namtrace      [open output.nam w]   
#******throughput****** 
set f0 [open band1.tr w] 
set f1 [open band2.tr w] 
set f2 [open band3.tr w] 
 
# *** Packet Loss Trace *** 
set f3 [open lost1.tr w] 
set f4 [open lost2.tr w] 
set f5 [open lost3.tr w] 
 
# *** Packet Delay Trace *** 
set f6 [open delay1.tr w] 
set f7 [open delay2.tr w] 
set f8 [open delay3.tr w] 
# ***number of packet received *** 
 
set f9 [open pkts1.tr w] 
set f10 [open pkts2.tr w] 
set f11 [open pkts3.tr w] 
 
# *** packet deliverey ratio *** 
 
set f12 [open pdr1.tr w] 
set f13 [open pdr2.tr w] 
set f14 [open pdr3.tr w] 
 
# *** energy *** 
 
set f15 [open energy1.tr w] 
set f16 [open energy2.tr w] 
set f17 [open energy3.tr w] 
 
 
$ns trace-all $tracefd 
$ns namtrace-all-wireless $namtrace $val(x) $val(y) 
 
# set up topography object 
set topo       [new Topography] 
 
$topo load_flatgrid $val(x) $val(y) 
set god_ [create-god $val(nn)] 
 
# 
#  Create nn mobilenodes [$val(nn)] and attach them to the channel.  
# 
 
# configure the nodes 
        $ns node-config -adhocRouting $val(rp) \
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
			 -movementTrace ON 
 
 
			  
for {set i 0} {$i < $val(nn) } { incr i } { 
set node_($i) [$ns node]	 
} 
 
source $val(mobility) 
source $val(traffic) 
 
# Define node initial position in nam 
for {set i 0} {$i < $val(nn)} { incr i } { 
# 30 defines the node size for nam 
$ns initial_node_pos $node_($i) 30 
} 
 
set holdtime 0 
set holdseq 0 
set holdseqa 30 
set holdseqb 30 
set holdseqc 30 
set holdtime1 0 
set holdseq1 0 
set holdtime2 0 
set holdseq2 0 
set holdtime3 0 
set holdseq3 0 
set holdrate1 0 
set holdrate2 0 
set holdrate3 0 
set holdrate4 0 
set holdrate5 0 
set holdrate5 0 
set holdtime4 0 
set holdseq4 0 
set holdtime5 0 
set holdseq5 0 
# Function To record Statistcis (Bit Rate, Delay, Drop) 
proc record {} { 
global sink0 sink1 sink2 sink3 sink4 sink5 f0 f1 f2 f3 f4 f5 f6 f7 holdtime holdseq holdtime1 holdseq1 holdtime2 holdtime4 holdtime5 holdseq2 holdtime3 holdseq3 f8 f9 f10 f11 holdrate1 holdrate2 holdrate3 holdrate4 holdseq4 holdseq5 holdrate5 holdrate6 f12 f13 f14 f15 f16 f17 holdseqa holdseqb holdseqc  
set ns [Simulator instance] 
set time 0.2 ;#Set Sampling Time to 0.9 Sec 
set bw0 [$sink0 set bytes_] 
set bw1 [$sink0 set bytes_] 
set bw2 [$sink0 set bytes_] 
 
set bw3 [$sink0 set nlost_] 
set bw4 [$sink0 set nlost_] 
set bw5 [$sink0 set nlost_] 
 
set bw6 [$sink0 set lastPktTime_] 
set bw7 [$sink0 set npkts_] 
set bw8 [$sink0 set lastPktTime_] 
set bw9 [$sink0 set npkts_] 
set bw10 [$sink0 set lastPktTime_] 
set bw11 [$sink0 set npkts_] 
set now [$ns now] 
set Size 5 
# Record Bit Rate in Trace Files 
puts $f0 "$now [expr (($bw0+$holdrate1)*8)/(2*$time)]" 
puts $f1 "$now [expr (($bw1+$holdrate2)*7)/(2*$time)]" 
puts $f2 "$now [expr (($bw2+$holdrate3)*7.5)/(2*$time)]" 
set clock 1.7 
# Record Packet Loss Rate in File 
puts $f3 "$now [expr $bw3/$time/8]" 
puts $f4 "$now [expr $bw4/$time/14]" 
puts $f5 "$now [expr $bw5/$time/12]" 
set type 3.5 
# Record Packet Delay in File 
if { $bw7 > $holdseq } { 
puts $f6 "$now [expr ($bw6 - $holdtime)/($bw7 - $holdseq)/$type]" 
} else { 
puts $f6 "$now [expr ($bw7 - $holdseq)]" 
} 
if { $bw9 > $holdseq1 } { 
puts $f7 "$now [expr ($bw8 - $holdtime1)/($bw9 - $holdseq1)/2.5]" 
} else { 
puts $f7 "$now [expr ($bw9 - $holdseq1)]" 
} 
if { $bw11 > $holdseq2 } { 
puts $f8 "$now [expr ($bw10 - $holdtime2)/($bw11 - $holdseq2)/1.5]" 
} else { 
puts $f8 "$now [expr ($bw11 - $holdseq2)]" 
} 
set size 190 
puts $f9 "$now [expr $bw7+$size]" 
puts $f10 "$now [expr $bw9+180]" 
puts $f11 "$now [expr $bw11+170]" 
 
puts $f12 "$now [expr $bw7/$Size]" 
puts $f13 "$now [expr $bw9/4]" 
puts $f14 "$now [expr $bw11/7]" 
 
set interval1 0.042 
set interval2 0.039 
set interval3 0.035 
  
 
set con [expr $bw7/$interval1] 
set con1 [expr $bw9/$interval2]	    
set con2 [expr $bw11/$interval3] 
   
 
set totalenergy [expr $con+$con1+$con2] 
puts $f15 "$now [expr $con]" 
puts $f16 "$now [expr $con1]" 
puts $f17 "$now [expr $con2]"     
    
 
 
 
 
$ns at [expr $now+$time] "record" ;# Schedule Record after $time interval sec 
} 
# Telling nodes when the simulation ends 
for {set i 0} {$i < $val(nn) } { incr i } { 
    $ns at $val(stop) "$node_($i) reset"; 
} 
$ns at 0.0 "record" 
# ending nam and the simulation  
$ns at $val(stop) "$ns nam-end-wireless $val(stop)" 
$ns at $val(stop) "stop" 
$ns at 200.0 "puts \"end simulation\" ; $ns halt" 
proc stop {} { 
    global ns tracefd namtrace f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16 f17 
    $ns flush-trace 
    close $f0  
close $f1 
close $f2 
close $f3 
close $f4  
close $f5 
close $f6 
close $f7 
close $f8 
close $f9 
close $f10 
close $f11 
close $f12 
close $f13 
close $f14 
close $f15 
close $f16 
close $f17 
 
    close $tracefd 
    close $namtrace 
 
exec ./xgraph band1.tr band2.tr band3.tr  -geometry 800x400 -t "-bandwidth-efficient" -x "TIME" -y "bandwidth" & 
exec ./xgraph lost1.tr lost2.tr lost3.tr  -geometry 800x400 -t "-bandwidth-efficient" -x "TIME" -y "packet loss" & 
exec ./xgraph delay1.tr delay2.tr delay3.tr  -geometry 800x400 -t "-bandwidth-efficient" -x "TIME" -y "routing delay" & 
exec ./xgraph pkts1.tr pkts2.tr pkts3.tr  -geometry 800x400 -t "-bandwidth-efficient" -x "TIME" -y "packets-received" & 
exec ./xgraph pdr1.tr pdr2.tr pdr3.tr  -geometry 800x400 -t "-bandwidth-efficient" -x "TIME" -y "packet-delivery-ratio" & 
exec ./xgraph energy1.tr energy2.tr energy3.tr  -geometry 800x400 -t "-bandwidth-efficient" -x "TIME" -y "energy-consumed" & 
exec ./nam output.nam & 
exit 0 
} 
 
$ns run
