#     http://naveenshanmugam.blogspot.dk/


proc my-duplex-link {ns n1 n2 bw delay queue_method queue_length} {
$ns optical-duplex-link $n1 $n2 $bw $delay $queue_method
$ns queue-limit $n1 $n2 $queue_length
$ns queue-limit $n2 $n1 $queue_length
}


proc my-duplex-link2 {ns n1 n2 bw delay queue_method queue_length} {
$ns optical-simplex-link $n1 $n2 $bw $delay $queue_method
$ns simplex-link $n2 $n1 $bw $delay DropTail
$ns queue-limit $n1 $n2 $queue_length
$ns queue-limit $n2 $n1 $queue_length
}


#Create a simulator object
set ns [new Simulator] 

#Variable Simulation settings: max burst size [50,100,200,300,400,500], timeout = [1:1:10] msec, simulation time: 200 sec, buffer = 2*500*1040 bytes, receive window = 500 packets.
set settings [new OpticalDefaults] 
$settings set MAX_PACKET_NUM 20
$settings set TIMEOUT 7ms
$settings set MAX_FLOW_QUEUE 5
# The following are the default values for settings, only the above have been changed.
#OpticalDefaults set MAX_PACKET_NUM 500;
#OpticalDefaults set HOP_DELAY 0.00001;
#OpticalDefaults set TIMEOUT 0.005;
#OpticalDefaults set MAX_LAMBDA 1;
#OpticalDefaults set LINKSPEED 1Gb;
#OpticalDefaults set SWITCHTIME 0.000005;
#OpticalDefaults set LIFETIME 0.1;
#OpticalDefaults set DEBUG 3;
#OpticalDefaults set MAX_DEST 40;
#OpticalDefaults set BURST_HEADER 40;
#OpticalDefaults set MAX_DELAYED_BURST 2;
#OpticalDefaults set MAX_FLOW_QUEUE 1;
$settings set MAX_DELAYED_BURST 5


$ns color 12 Red
$ns color 13 Yellow
$ns color 14 Green
$ns color 15 Purple
$ns color 16 Black
$ns color 17 Magenta
$ns color 18 Brown
$ns color 19 Orange
$ns color 20 Red
$ns color 21 Blue

#Open the win size file
set winfile [open windows.txt w]
set goodfile [open goodput.txt w]


#Open the nam trace file
set nf [open out-O.nam w]
$ns namtrace-all $nf

# enable source routing

$ns op_src_rting 1



#Open the nam trace file
set nf [open out.tr w]
$ns trace-all $nf
set f [open out.nam w]
$ns namtrace-all $f

#Start from zero when numbering the nodes. 

#Create 2 optical nodes
for {set i 0} {$i < 2} {incr i} {
            set n($i) [$ns OpNode]
   #define optical nodes
   set temp [$n($i) set src_agent_]
   $temp optic_nodes 0 1
   $temp set nodetype_ 0
   $temp set conversiontype_ 1
   $temp create
   #whether acks are burstified
   $temp set ackdontburst 1

   set temp [$n($i) set burst_agent_]
   $temp optic_nodes 0 1
   #whether acks are burstified
   $temp set ackdontburst 1

   set temp [$n($i) set classifier_]
   $temp optic_nodes 0 1

}



#Create 20 electronic nodes
for {set i 2} {$i < 22} {incr i} {
            set n($i) [$ns node]
   
   #define optical nodes
   set temp [$n($i) set src_agent_]
   $temp optic_nodes 0 1
   

   
   set temp [$n($i) set classifier_]
   $temp optic_nodes 0 1
   
}

set queue_length 100000

#Create links between the nodes
 my-duplex-link2 $ns $n(0) $n(1) 1000Mb 10ms OpQueue $queue_length

#creating the error model
set loss_module [new ErrorModel]
$loss_module set rate_ 0.01
$loss_module unit pkt
$loss_module ranvar [new RandomVariable/Uniform]
$loss_module drop-target [new ONA]
#set whether burst or control packet will be dropped
$loss_module set opticaldrop_ 2
#Inserting Error Module
$ns lossmodel $loss_module $n(0) $n(1)
for {set i 2} {$i < 12} {incr i} {
$ns duplex-link $n($i) $n(0) 155Mb 1ms DropTail
$ns queue-limit $n($i) $n(0) $queue_length
$ns queue-limit $n(0) $n($i) $queue_length
}


for {set i 12} {$i < 22} {incr i} { 
$ns duplex-link $n($i) $n(1) 155Mb 1ms DropTail
$ns queue-limit $n($i) $n(1) $queue_length
$ns queue-limit $n(1) $n($i) $queue_length
}




 set flow 0

 for {set i 2} {$i < 12} {incr i} {

  set d [expr $i + 10]

  #Create a TCP agent and attach it to node n0
set cbr($i) [new Agent/TCP/Reno]
$ns attach-agent $n($i) $cbr($i)
$cbr($i) set fid_ $d
$cbr($i) set fid2_ $flow
$cbr($i) set window_ 10000

$cbr($i) target [$n($i) set src_agent_]

set ftp($i) [$cbr($i) attach-source FTP]


set null($i) [new Agent/TCPSink]
$ns attach-agent $n($d) $null($i)
#$null($i) set fid_ $s  #This part is not working. Hard coded in tcp sink.cc
$null($i) set fid2_ $flow

$null($i) target [$n($d) set src_agent_]

$ns connect $cbr($i) $null($i)

incr flow


  set temp [$n($i) set src_agent_]
$temp install_connection $d         $i $d   $i 0 1 $d
set temp [$n($d) set src_agent_]
$temp install_connection $i         $d $i   $d 1 0 $i

 $ns at [expr $i] "$ftp($i) start" 

 }
  set temp [$n(0) set src_agent_]
$temp install_connection 1         0 1   0 1 
set temp [$n(1) set src_agent_]
$temp install_connection 0         1 0   1 0



proc plotWindow {file} {
global goodfile
global ns
global cbr
set time 0.01
set now [$ns now]
puts -nonewline $file "$now"
puts -nonewline $goodfile "$now"
for {set i 2} {$i < 12} {incr i} {
set cwnd($i) [$cbr($i) set cwnd_]
puts -nonewline $file " $cwnd($i)"
puts -nonewline $goodfile " "
puts -nonewline  $goodfile [$cbr($i) set ack_]
#puts -nonewline  $goodfile [expr  [$cbr($i) set ack_]/[expr $now-$i]]
}
puts $file ""
puts $goodfile ""
$ns at [expr $now+$time] "plotWindow $file"
}

proc finish {} {
        #global ns nf
#global f
global winfile
global goodfile
        #$ns flush-trace
#Close the trace file
        #close $f
close $winfile
#Execute nam on the trace file
        #exec ./nam out.nam 
close $goodfile
        exit 0
}


#$ns at 1 "plotWindow $winfile"
$ns at 10 "finish"
$ns run
 
