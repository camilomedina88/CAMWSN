# Define the multicast mechanism 
set ns [new Simulator -multicast on] 
 
# Predefine tracing 
set f [open out-z.tr w] 
$ns trace-all $f 
set nf [open out-z.nam w] 
$ns namtrace-all $nf 
 
# Set the number of subscribers 
set numberClass0 0
set numberClass1 3 
set numberClass2 15 
set numberClass3 1 
set number [expr {$numberClass0 + $numberClass1 + $numberClass2 + $numberClass3}] 
# qos_ means whether classfication/scheduling mechanism is used 
Queue/LTEQueue set qos_ true 
#Queue/LTEQueue set qos_ false 
# flow_control_ is used in the model phase 
Queue/LTEQueue set flow_control_ false 
 
# Define the LTE topology 
# UE(i) <--> eNB <--> aGW <--> server 
 
 
# step 1: define the nodes, the order is fixed!! 
set eNB [$ns node];#node id is 0 
set aGW [$ns node];#node id is 1 
set server [$ns node];#node id is 2 
for { set i 0} {$i<$number} {incr i} { 
 set UE($i) [$ns node];#node id is > 2 
} 
 
# step 2: define the links to connect the nodes 
for { set i 0} {$i<$number} {incr i} { 
$ns simplex-link $UE($i) $eNB 10Mb 2ms LTEQueue/ULAirQueue 
$ns simplex-link $eNB $UE($i) 10Mb 2ms LTEQueue/DLAirQueue 
} 
 
$ns simplex-link $eNB $aGW 2Mb 2ms LTEQueue/ULS1Queue 
$ns simplex-link $aGW $eNB 2Mb 2ms LTEQueue/DLS1Queue 

 
# The bandwidth between aGW and server is not the bottleneck. 
$ns duplex-link $aGW $server 5000Mb 2ms DropTail 
#$ns simplex-link $server $aGW 5000Mb 2ms LTEQueue/DLQueue 
 
 
#--------manual set constant-------------((the best one until 17 Augus))-- 
# to change the RNG manually global defaultRNG 
#  to be changed manually from 1(default) to approximate value equal to 7.6x10^22 
$defaultRNG seed 10 
#---------------------------------------------- 
 
# step 3: define the traffic, based on  TR23.107 QoS concept and architecture 
#    class id class type simulation application
  
#    ------------------------------------------------- 
#    0:  Conversational: CBR/UdpAgent 
#    1:  Streaming:  CBR/UdpAgent 
#    2:  Interactive:  HTTP/TcpAgent (HTTP/Client, HTTP/Cache, HTTP/Server) 
#    3:  Background:  FTP/TcpAgent 
 
# step 3.1 define the conversational traffic 
for { set i 0} {$i < $numberClass0} {incr i} {
 set null($i) [new Agent/Null] 
 set nullS($i) [new Agent/Null] 
 $ns attach-agent $UE($i) $null($i) 
 $ns attach-agent $server $nullS($i) 
 set udp($i) [new Agent/UDP] 
 set udpUE($i) [new Agent/UDP] 
 $ns attach-agent $server $udp($i) 
 $ns attach-agent $UE($i) $udpUE($i) 
 $ns connect $null($i) $udp($i) 
 $ns connect $nullS($i) $udpUE($i) 
 $udp($i) set class_ 0 
 $udpUE($i) set class_ 0 
 set cbr($i) [new Application/Traffic/CBR] 
 set cbrS($i) [new Application/Traffic/CBR] 
 $cbr($i) attach-agent $udp($i) 
 $cbrS($i) attach-agent $udpUE($i) 
 $ns at 0.4 "$cbr($i) start" 
 $ns at 0.4 "$cbrS($i) start" 
 $ns at 40.0 "$cbr($i) stop" 
 $ns at 40.0 "$cbrS($i) stop" 93 
 } 
  
# step 3.2 define the streaming traffic 
for { set i $numberClass0} {$i< 
($numberClass0+$numberClass1)} {incr i} { 
 set null($i) [new Agent/Null] 
 $ns attach-agent $UE($i) $null($i) 
 set udp($i) [new Agent/UDP] 
 $ns attach-agent $server $udp($i) 
 $ns connect $null($i) $udp($i) 
 $udp($i) set class_ 1 
 set cbr($i) [new Application/Traffic/CBR] 
 $cbr($i) attach-agent $udp($i) 
 $ns at 0.4 "$cbr($i) start" 
 $ns at 40.0 "$cbr($i) stop" 
} 
 
 
# step 3.3 define the interactive traffic 
$ns rtproto Session 
set log [open "http.log-z" w] 
 
# Care must be taken to make sure that every client sees the same set of pages as the servers to which they are attached. 
set pgp [new PagePool/Math] 
set tmp [new RandomVariable/Constant] ;# Size generator 
$tmp set val_ 10240  ;# average page size 
$pgp ranvar-size $tmp 
set tmp [new RandomVariable/Exponential] ;# Age generator 
$tmp set avg_ 4 ;# average page age 
$pgp ranvar-age $tmp 
 
set s [new Http/Server $ns $server] 
$s set-page-generator $pgp 
$s log $log 
 
set cache [new Http/Cache $ns $aGW] 
$cache log $log 


for { set i [expr $numberClass0+$numberClass1]} {$i< 
($numberClass0+$numberClass1+$numberClass2)} {incr i} {   
 set c($i) [new Http/Client $ns $UE($i)] 
 set ctmp($i) [new RandomVariable/Exponential] ;# Poisson process 
 $ctmp($i) set avg_ 1 ;# average request interval 94 
 
 $c($i) set-interval-generator $ctmp($i) 
 $c($i) set-page-generator $pgp 
 $c($i) log $log 
}
 
$ns at 0.4 "start-connection" 
proc start-connection {} { 
        global ns s cache c number numberClass0 numberClass1 numberClass2 
         
 $cache connect $s 
 
 
for { set i [expr $numberClass0+$numberClass1]} {$i< 
($numberClass0+$numberClass1+$numberClass2)} {incr i} {  
         $c($i) connect $cache 
         $c($i) start-session $cache $s 
 } 
} 
 
 
# step 3.4 define the background traffic 
# no parameters to be configured by FTP 
# we can configue TCP and TCPSink parameters here. 



for { set i [expr $numberClass0+$numberClass1+$numberClass2]} {$i< 
($numberClass0+$numberClass1+$numberClass2+$numberClass3)} {incr i} {   

 set sink($i) [new Agent/TCPSink] 
 $ns attach-agent $UE($i) $sink($i) 
 set tcp($i) [new Agent/TCP] 
 $ns attach-agent $server $tcp($i) 
 $ns connect $sink($i) $tcp($i) 
 $tcp($i) set class_ 3 
 set ftp($i) [new Application/FTP] 
 $ftp($i) attach-agent $tcp($i) 
 $ns at 0.4 "$ftp($i) start" 
} 
 
# finish tracing 
$ns at 30 "finish" 
proc finish {} { 
 global ns f log 
 $ns flush-trace 
 flush $log 
 close $log 
 close $f 
 exit 0 
} 
 
# Finally, start the simulation. 
$ns run
