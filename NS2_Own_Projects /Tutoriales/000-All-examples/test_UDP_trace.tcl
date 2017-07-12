set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagationmodel
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         1000                       ;# max packet in ifq
set val(nn)             5                          ;# number of mobilenodes
set val(rp)             DSDV                       ;# routing protocol
 
Mac/802_11 set RTSThreshold_          3000             ;# bytes
Mac/802_11 set ShortRetryLimit_       7               ;# retransmittions
Mac/802_11 set LongRetryLimit_        4               ;# retransmissions
Mac/802_11 set PreambleLength_        144             ;# 144 bit
Mac/802_11 set PLCPHeaderLength_      48              ;# 48 bits
Mac/802_11 set PLCPDataRate_  1Mb                         ;# 1Mbps
Mac/802_11 set dataRate_      1Mb
Mac/802_11 set basicRate_     1Mb
Mac/802_11 set CWMin_         31
Mac/802_11 set CWMax_         1023
Mac/802_11 set SlotTime_      0.000020        ;# 20us
Mac/802_11 set SIFS_          0.000010        ;# 10us
 
set ns_              [new Simulator]
 
set tracefd     [open simple.tr w]
$ns_ trace-all $tracefd
 
set nf [open out.nam w]
$ns_ namtrace-all-wireless $nf 300 300
 
set topo       [new Topography]
 
$topo load_flatgrid 300 300
 
create-god $val(nn)
set chan_1_ [new $val(chan)]
 
        $ns_ node-config -adhocRouting $val(rp) \
                         -llType $val(ll) \
                         -macType $val(mac) \
                         -ifqType $val(ifq) \
                         -ifqLen $val(ifqlen) \
                         -antType $val(ant) \
                         -propType $val(prop) \
                         -phyType $val(netif) \
                         -channel $chan_1_ \
                         -topoInstance $topo \
                         -agentTrace ON \
                         -routerTrace OFF \
                         -macTrace OFF \
                         -movementTrace OFF                   
       
        for {set i 0} {$i < $val(nn) } {incr i} {
                set node_($i) [$ns_ node]
                $node_($i) random-motion 0            ;# disable random motion
        }
      
set  rng  [new RNG]
$rng seed 1
set  rand1  [new RandomVariable/Uniform]
 
for {set i 0} {$i < $val(nn) } {incr i} {
    puts "wireless node $i created ..."
    set x [expr 150+[$rand1 value]*4]
    set y [expr 150+[$rand1 value]*1]
    $node_($i) set X_ $x
    $node_($i) set Y_ $y
    $node_($i) set Z_ 0.0
    puts "X_:$x Y_:$y"
}
 
for {set i 0} {$i < $val(nn) } {incr i} {
    set udp_($i) [new Agent/UDP]
    $ns_ attach-agent $node_($i) $udp_($i)
    set null_($i) [new Agent/LossMonitor]
    $ns_ attach-agent $node_($i) $null_($i)
}
 
for {set i 0} {$i < $val(nn) } {incr i} {
    if {$i == ($val(nn)-1)} {
            $ns_ connect $udp_($i) $null_(0)
    } else {
            set j [expr $i+1]
            $ns_ connect $udp_($i) $null_($j)
    }
   
    set cbr_($i) [new Application/Traffic/CBR]
    $cbr_($i) attach-agent $udp_($i)
    $cbr_($i) set type_ CBR
    $cbr_($i) set packet_size_ 1000
    $cbr_($i) set rate_ 500kb
    $cbr_($i) set random_ false
}
 
for {set i 0} {$i < $val(nn) } {incr i} {   
    $ns_ at 1.0  "$cbr_($i) start"
    $ns_ at 50.0 "$cbr_($i) stop"
}
 
# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 100.0 "$node_($i) reset";
}
 
$ns_ at 100.0 "stop"
$ns_ at 100.01 "puts \"NS EXITING...\" ; $ns_ halt"
 
$ns_ at 45.0 "record"
 
proc record {} {
        global ns_ null_ val
       set sum 0
            for {set i 0} {$i < $val(nn) } {incr i} {
                    set th 0
                    set a [$null_($i) set bytes_]
                    set b [$null_($i) set lastPktTime_]
                    set c [$null_($i) set firstPktTime_]
                    set d [$null_($i) set npkts_]
                    if {$b>$c} {
                           set th [expr ($a-$d*20)*8/($b-$c)]
                           puts "flow $i has $th bps"
            }
            set sum [expr $sum+$th]
    }
    puts "total throughput:$sum bps"
}
 
proc stop {} {
    global ns_  tracefd
    $ns_ flush-trace
    close $tracefd
}
 
puts "Starting Simulation..."
$ns_ run 
