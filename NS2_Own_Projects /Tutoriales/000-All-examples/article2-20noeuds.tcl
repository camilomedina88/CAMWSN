#    #26 http://www.linuxquestions.org/questions/linux-software-2/implementing-new-protocol-in-ns2-35-a-4175456332/page2.html



set val(chan)   Channel/WirelessChannel    ;# channel type

set val(prop)   Propagation/TwoRayGround   ;# radio-propagation model

set val(netif)  Phy/WirelessPhy            ;# network interface type

set val(mac)    Mac/802_11                 ;# MAC type

set val(ifq)    Queue/DropTail/PriQueue    ;# interface queue type

set val(ll)     LL                         ;# link layer type

set val(ant)    Antenna/OmniAntenna        ;# antenna model

set val(ifqlen) 250                         ;# max packet in ifq

set val(nn)     20                          ;# number of mobilenodes

set val(rp)     OAODV                       ;# routing protocol

set val(x)      500                      ;# X dimension of topography

set val(y)      500                      ;# Y dimension of topography



#CMUTrace set newtrace_  1

#set RouterTrace         ON

#set MacTrace            ON

Phy/WirelessPhy set CPThresh_ 10.0

Phy/WirelessPhy set CSThresh_ 1.559e-11

Phy/WirelessPhy set RXThresh_ 3.652e-10

Phy/WirelessPhy set bandwidth_ 2e6

Phy/WirelessPhy set Pt_ 0.2818

Phy/WirelessPhy set freq_ 914e+6

Phy/WirelessPhy set L_ 1.0



set ns [new Simulator]

set f [open output.tr w]

$ns trace-all $f

set namtrace [open AODV10.nam w]

$ns namtrace-all-wireless $namtrace $val(x) $val(y)

$ns use-newtrace

set f0 [open throughput1.tr w]

set f1 [open throughput2.tr w]

set f2 [open throughput3.tr w]

set f3 [open packetdrop1.tr w]

set f4 [open packetdrop2.tr w]

set f5 [open packetdrop3.tr w]

set f6 [open delay1.tr w]

set f7 [open delay2.tr w]

set f8 [open delay3.tr w]



set topo [new Topography]

$topo load_flatgrid 1000 1000



create-god $val(nn)



$ns node-config  -adhocRouting $val(rp) \
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
-macTrace ON \
-movementTrace OFF \

       proc finish {} {

        global ns f f0 f1 f2 f3 f4 f5 f6 f7 f8 namtrace

              $ns flush-trace

        close $namtrace

        close $f0

        close $f1

        close $f2

        close $f3

        close $f4

        close $f5

close $f6

close $f7

close $f8

      # exec xgraph throughput1.tr throughput2.tr throughput3.tr -geometry 800x400 -t "AODV Throughput" -x "Time" -y "No.of Packets" -bg white &

      # exec ./xgraph packetdrop1.tr packetdrop2.tr packetdrop3.tr -geometry 800x400 -t "AODV Packet Drop" -x "Time" -y "No.of Packets" -bg white &

      # exec ./xgraph delay1.tr delay2.tr delay3.tr -geometry 800x400 -t "AODV Delay Level" -x "Time" -y "No.of Packets" -bg white &

      # exec ./nam AODV10.nam &


        exec xgraph throughput1.tr throughput2.tr throughput3.tr -geometry 800x400  &
        exec xgraph packetdrop1.tr packetdrop2.tr packetdrop3.tr -geometry 800x400   &
         exec xgraph delay1.tr delay2.tr delay3.tr -geometry 800x400    &
                                     # proj_out2.tr proj_out3.tr 
        exec nam -r 5m 1_out.nam &
	exit 0
}


       for {set i 0} {$i < $val(nn)} {incr i} {
           
        set n($i) [$ns node] 
            }





for {set i 0} {$i < $val(nn)} {incr i} {

            $ns initial_node_pos $n($i) 30+i*100

            $n($i) set X_ [expr ($i+1)*150]
            #$n($i) set X_ 0.0
            $n($i) set Y_  0.0
            $n($i) set Z_ 10.0 

}



$ns at 0.0 "$n(0) setdest 100.0 100.0 3.0"

$ns at 0.0 "$n(1) setdest 200.0 200.0 3.0"

$ns at 0.0 "$n(2) setdest 300.0 200.0 3.0"

$ns at 0.0 "$n(3) setdest 400.0 300.0 3.0"

$ns at 0.0 "$n(4) setdest 500.0 300.0 3.0"

$ns at 0.0 "$n(5) setdest 600.0 400.0 3.0"

$ns at 0.0 "$n(6) setdest 550.0 30.0 3.0"

$ns at 0.0 "$n(7) setdest 150.0 350.0 3.0"

$ns at 0.0 "$n(8) setdest 600.0 340.0 3.0"

$ns at 0.0 "$n(9) setdest 165.0 240.0 3.0"

$ns at 0.0 "$n(10) setdest 134.0 180.0 3.0"

$ns at 0.0 "$n(11) setdest 520.0 400.0 3.0"

$ns at 0.0 "$n(12) setdest 160.0 740.0 3.0"

$ns at 0.0 "$n(13) setdest 350.0 200.0 3.0"

$ns at 0.0 "$n(14) setdest 280.0 400.0 3.0"

$ns at 0.0 "$n(15) setdest 420.868 84.518 3.0"

$ns at 0.0 "$n(16) setdest 170.566 106.349 3.0"

$ns at 0.0 "$n(17) setdest 160.0 740.0 3.0"

$ns at 0.0 "$n(18) setdest 351.0 200.0 3.0"

$ns at 0.0 "$n(19) setdest 330.0 400.0 3.0"

$n(0) color blues

$ns at 1.0 "$n(0) color blue"

$n(7) color blue

$ns at 1.0 "$n(7) color blue"

$ns at 1.0 "$n(0) label Source1"

$ns at 1.0 "$n(7) label Destination1"

$n(2) color brown

$ns at 1.0 "$n(2) color brown"

$ns at 1.0 "$n(2) label source2"

$n(5) color brown

$ns at 1.0 "$n(5) color brown"

$ns at 1.0 "$n(5) label Destination2"

$n(3) color darkgreen

$ns at 1.0 "$n(3) color darkgreen"

$ns at 1.0 "$n(3) label source3"

$n(8) color darkgreen

$ns at 1.0 "$n(8) color darkgreen"

$ns at 1.0 "$n(8) label Destination3"



# CONFIGURE AND SET UP A FLOW

proc record {} {

        global sink5 sink0 sink1 sink2 sink3 f0 f1 f2 f3 f4 f5 f6 f7 f8



    set ns [Simulator instance]



    set time 0.05
#1.5

    set bw0 [$sink0 set bytes_]

    set bw1 [$sink1 set bytes_]

    set bw2 [$sink2 set bytes_]

    set bw3 [$sink0 set nlost_]

    set bw4 [$sink1 set nlost_]

    set bw5 [$sink2 set nlost_]

    set bw6 [$sink0 set lastPktTime_]

    set bw7 [$sink0 set npkts_]

    set bw8 [$sink1 set lastPktTime_]

    set bw9 [$sink1 set npkts_]

    set bw10 [$sink2 set lastPktTime_]

    set bw11 [$sink2 set npkts_]

    set now [$ns now]
 # Record Bit Rate in Trace Files

  # puts $f0 "$now [expr (($bw0+$holdrate1)*8)/(2*$time*1000000)]"
 puts $f0 "$now [expr (($bw0)*8)]"

 puts $f1 "$now [expr (($bw1)*8)]"

 puts $f2 "$now [expr (($bw2)*8)]"

 # Record Packet Loss Rate in File

        puts $f3 "$now [expr $bw3]"

        puts $f4 "$now [expr $bw4]"

        puts $f5 "$now [expr $bw5]"

#record the packet delay in file

        if { $bw7 > 0} {

                puts $f6 "$now [expr ($bw6)/($bw7)]"

        } else {

                puts $f6 "$now [expr ($bw7)]"

        }

        if { $bw9 > 0 } {

          puts $f7 "$now [expr ($bw8)/($bw9)]"

        } else {

                puts $f7 "$now [expr ($bw9)]"

        }

        if { $bw11 > 0 } {

            puts $f8 "$now [expr ($bw10)/($bw11)]"

        } else {

                puts $f8 "$now [expr ($bw11)]"

        }


  $ns at [expr $now+$time] "record"    ;# Schedule Record after $time
}

proc PerHopTime {} {

puts"time delay $now [expr ($n(0)+$time)]"
}

set sink0 [new Agent/LossMonitor]

set sink1 [new Agent/LossMonitor]

set sink2 [new Agent/LossMonitor]

set sink3 [new Agent/LossMonitor]

set sink4 [new Agent/LossMonitor]

set sink5 [new Agent/LossMonitor]

set sink6 [new Agent/LossMonitor]

set sink7 [new Agent/LossMonitor]

set sink8 [new Agent/LossMonitor]

set sink9 [new Agent/LossMonitor]

set sink10 [new Agent/LossMonitor]

set sink11 [new Agent/LossMonitor]

set sink12 [new Agent/LossMonitor]

set sink13 [new Agent/LossMonitor]

set sink14 [new Agent/LossMonitor]

set sink15 [new Agent/LossMonitor]

set sink16 [new Agent/LossMonitor]

set sink17 [new Agent/LossMonitor]

set sink18 [new Agent/LossMonitor]

set sink19 [new Agent/LossMonitor]


$ns attach-agent $n(0) $sink0

$ns attach-agent $n(1) $sink1

$ns attach-agent $n(2) $sink2

$ns attach-agent $n(3) $sink3

$ns attach-agent $n(4) $sink4

$ns attach-agent $n(5) $sink5

$ns attach-agent $n(6) $sink6

$ns attach-agent $n(7) $sink7

$ns attach-agent $n(8) $sink8

$ns attach-agent $n(9) $sink9

$ns attach-agent $n(10) $sink10

$ns attach-agent $n(11) $sink11

$ns attach-agent $n(12) $sink12

$ns attach-agent $n(13) $sink13

$ns attach-agent $n(14) $sink14

$ns attach-agent $n(15) $sink15

$ns attach-agent $n(16) $sink16

$ns attach-agent $n(17) $sink17

$ns attach-agent $n(18) $sink18

$ns attach-agent $n(19) $sink19


set tcp0 [new Agent/TCP]

$tcp0 set prio_ 1

$ns attach-agent $n(0) $tcp0

set tcp1 [new Agent/TCP]

$tcp1 set prio_ 2

$ns attach-agent $n(1) $tcp1

set tcp2 [new Agent/TCP]

$tcp2 set prio_ 3

$ns attach-agent $n(2) $tcp2

set tcp3 [new Agent/TCP]

$tcp3 set prio_ 4

$ns attach-agent $n(3) $tcp3

set tcp4 [new Agent/TCP]

$tcp4 set prio_ 5

$ns attach-agent $n(4) $tcp4

set tcp5 [new Agent/TCP]

$tcp5 set prio_ 6

$ns attach-agent $n(5) $tcp5

set tcp6 [new Agent/TCP]

$tcp6 set prio_ 7

$ns attach-agent $n(6) $tcp6

set tcp7 [new Agent/TCP]

$tcp7 set prio_ 8

$ns attach-agent $n(7) $tcp7

set tcp8 [new Agent/TCP]

$tcp8 set prio_ 9

$ns attach-agent $n(8) $tcp8

set tcp9 [new Agent/TCP]

$tcp9 set prio_ 10

$ns attach-agent $n(9) $tcp9

set tcp10 [new Agent/TCP]

$tcp10 set prio_ 11

$ns attach-agent $n(10) $tcp10

set tcp11 [new Agent/TCP]

$tcp11 set prio_ 12

$ns attach-agent $n(11) $tcp11

set tcp12 [new Agent/TCP]

$tcp12 set prio_ 13

$ns attach-agent $n(12) $tcp12

set tcp13 [new Agent/TCP]

$tcp7 set prio_ 14

$ns attach-agent $n(13) $tcp13

set tcp14 [new Agent/TCP]

$tcp14 set prio_ 15

$ns attach-agent $n(14) $tcp14

set tcp15 [new Agent/TCP]

$tcp15 set prio_ 16

$ns attach-agent $n(15) $tcp15

set tcp16 [new Agent/TCP]

$tcp16 set prio_ 17

$ns attach-agent $n(16) $tcp16

set tcp17 [new Agent/TCP]

$tcp17 set prio_ 18

$ns attach-agent $n(17) $tcp17

set tcp18 [new Agent/TCP]

$tcp15 set prio_ 19

$ns attach-agent $n(18) $tcp18

set tcp19 [new Agent/TCP]

$tcp19 set prio_ 20

$ns attach-agent $n(19) $tcp19


proc attach-CBR-traffic { node sink size interval } {

   #Get an instance of the simulator

   set ns [Simulator instance]

   #Create a CBR sink14 agent and attach it to the node

   set cbr [new Agent/CBR]

   $ns attach-agent $node $cbr

   $cbr set packetSize_ $size

   $cbr set interval_ $interval

   #Attach CBR source to sink;

   $ns connect $cbr $sink

   return $cbr

  }
set cbr0 [attach-CBR-traffic $n(3) $sink0 512 .0515]
#0.015
set cbr1 [attach-CBR-traffic $n(4) $sink1 512 .0415]
#0.041
set cbr2 [attach-CBR-traffic $n(5) $sink2 512 .0315]

set cbr3 [attach-CBR-traffic $n(7) $sink0 512 .0415]

set cbr4 [attach-CBR-traffic $n(1) $sink5 512 .0415]
#0.042
set cbr5 [attach-CBR-traffic $n(6) $sink2 512 .0415]
#0.041
set cbr6 [attach-CBR-traffic $n(19) $sink5 512 .0415]

set cbr7 [attach-CBR-traffic $n(18) $sink1 512 .0415]

set cbr8 [attach-CBR-traffic $n(7) $sink2 512 .0415]

set cbr9 [attach-CBR-traffic $n(12) $sink1 512 .0415]

#set cbr10 [attach-CBR-traffic $n(13) $sink2 512 .0041]

#set cbr11 [attach-CBR-traffic $n(10) $sink11 512 .0041]

#set cbr12 [attach-CBR-traffic $n(5) $sink12 512 .0041]

$ns at 0.0 "record"
$ns at 0.0 "[$n(8) set ragent_] hacker"
#$ns at 2.0 "[$n(7) set ragent_] hacker"
#$ns at 0.0 "[$n(6) set ragent_] hacker"
#$ns at 0.0 "[$n(9) set ragent_] hacker"
#$ns at 0.0 "[$n(19) set ragent_] hacker"
#$ns at 1.5 "[$n(10) set ragent_] hacker"
#$ns at 0.0 "[$n(11) set ragent_] hacker"
#$ns at 0.0 "[$n(12) set ragent_] hacker"
#$ns at 0.0 "[$n(13) set ragent_] hacker"
#$ns at 1.5 "[$n(14) set ragent_] hacker"
#$ns at 0.0 "[$n(15) set ragent_] hacker"
#$ns at 0.0 "[$n(16) set ragent_] hacker"
#$ns at 0.0 "[$n(17) set ragent_] hacker"
#$ns at 1.5 "[$n(18) set ragent_] hacker"
#$ns at 3.0 "[$n(8) set ragent_] hacker"
#$ns at 1.5 "[$n(10) set ragent_] hacker"

$ns at 0.5 "$cbr0 start"
$ns at 15.0 "$cbr0 stop"

$ns at 1.0 "$cbr1 start"
#$ns at 2.0 "$cbr1 stop"

$ns at 2.0 "$cbr2 start"
#$ns at 2.5 "$cbr2 stop"

$ns at 2.0 "$cbr3 start"
#$ns at 4.0 "$cbr3 stop"

$ns at 3.0 "$cbr4 start"
#$ns at 5.0 "$cbr4 stop"

#$ns at 3.5 "$cbr5 start"
#$ns at 5.0 "$cbr5 stop"

#$ns at 4.0 "$cbr6 start"
#$ns at 5.0 "$cbr7 start"
#$ns at 6.0 "$cbr8 start"
#$ns at 7.0 "$cbr9 start"

#$ns at 0.5 "$cbr0 start"
#$ns at 1.0 "$cbr0 stop"

#$ns at 1.5 "$cbr1 start"
#$ns at 2.0 "$cbr1 stop"

#$ns at 3.0 "$cbr2 start"
#$ns at 3.0 "$cbr2 stop"

#$ns at 4.5 "$cbr3 start"
#$ns at 4.0 "$cbr3 stop"

#$ns at 4.0 "$cbr4 start"
#$ns at 5.0 "$cbr4 stop"

#$ns at 6.5.0 "$cbr5 start"
#$ns at 5.0 "$cbr5 stop"

#$ns at 7.0 "$cbr6 start"
#$ns at 8.5 "$cbr7 start"
#$ns at 9.0 "$cbr8 start"
#$ns at 10.5 "$cbr9 start"

$ns at 100.0 "finish"

puts "Start of simulation.."

$ns run 
