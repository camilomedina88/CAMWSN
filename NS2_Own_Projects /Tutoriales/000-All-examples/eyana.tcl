#
# http://www.linuxquestions.org/questions/ubuntu-63/how-to-installing-lte-module-patch-in-ns2-33-a-857930/page3.html
#

set ns [new Simulator -multicast on]

set f [open out.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf

set number 10

set eNB [$ns node]
set aGW [$ns node]
set server [$ns node]

for { set i 0} {$i < $number} {incr i} {

set UE($i) [$ns node]
}


for { set i 0} {$i < $number} {incr i} {
$ns simplex-link $UE($i) $eNB 500Mb 2ms LTEQueue/ULAirQueue
$ns simplex-link $eNB $UE($i) 1Gb 2ms LTEQueue/DLAirQueue

}


$ns simplex-link $eNB $aGW 5Gb 10ms LTEQueue/ULS1Queue
$ns simplex-link $aGW $eNB 5Gb 10ms LTEQueue/DLS1Queue

$ns duplex-link $aGW $server 10Gb 100ms DropTail

set mproto DM
set mrthandle [$ns mrtproto $mproto {}]
set group [Node allocaddr]

for { set i 0 } { $i < $number } {incr i} {
set s0($i) [new Session/RTP]
set s1($i) [new Session/RTP]
$s0($i) session_bw 12.2kb/s
$s1($i) session_bw 12.2kb/s
$s0($i) attach-node $UE($i)
$s1($i) attach-node $server
$ns at 0.7 "$s0($i) join-group $group"
$ns at 0.8 "$s0($i) start"
$ns at 0.9 "$s0($i) transmit 12.2kb/s"
$ns at 1.0 "$s1($i) join-group $group"
$ns at 1.1 "$s1($i) start"
$ns at 1.2 "$s1($i) transmit 12.2kb/s"
}

for { set i 0} {$i < $number} {incr i} {
set udp($i) [new Agent/UDP]
$ns attach-agent $server $udp($i)
set null($i) [new Agent/Null]
$ns attach-agent $UE($i) $null($i)
$ns connect $udp($i) $null($i)
$udp($i) set class_ 1

set cbr($i) [new Application/Traffic/CBR]
$cbr($i) attach-agent $udp($i)
$cbr($i) set packetSize_ 1000
$cbr($i) set rate_ 0.01Mb
$cbr($i) set random_ false
$ns at 1.4 "$cbr($i) start"
}

# step 3.3 define the interactive traffic
$ns rtproto Session
set log [open "http.log" w]

# Care must be taken to make sure that every client sees the same set of pages as the servers to which they are attached.
set pgp [new PagePool/Math]
set tmp [new RandomVariable/Constant] ;# Size generator
$tmp set val_ 10240 ;# average page size
$pgp ranvar-size $tmp
set tmp [new RandomVariable/Exponential] ;# Age generator
$tmp set avg_ 4 ;# average page age
$pgp ranvar-age $tmp

set s [new Http/Server $ns $server]
$s set-page-generator $pgp
$s log $log

set cache [new Http/Cache $ns $aGW]
$cache log $log

for { set i 0} {$i<$number} {incr i} {
set c($i) [new Http/Client $ns $UE($i)]
set ctmp($i) [new RandomVariable/Exponential] ;# Poisson process
$ctmp($i) set avg_ 1 ;# average request interval
$c($i) set-interval-generator $ctmp($i)
$c($i) set-page-generator $pgp
$c($i) log $log
}

$ns at 0.4 "start-connection"
proc start-connection {} {
global ns s cache c number

$cache connect $s
for { set i 0} {$i<$number} {incr i} {
$c($i) connect $cache
$c($i) start-session $cache $s
}
}

for { set i 0} {$i < $number} {incr i} {
set tcp($i) [new Agent/TCP]
$ns attach-agent $server $tcp($i)
set sink($i) [new Agent/TCPSink]
$ns attach-agent $UE($i) $sink($i)
$ns connect $tcp($i) $sink($i)
$tcp($i) set class_ 3
$tcp($i) set packetSize_ 0.5M

set ftp($i) [new Application/FTP]
$ftp($i) attach-agent $tcp($i)
$ns at 3.4 "$ftp($i) start"
}

$ns at 30 "finish"
proc finish {} {
global ns f nf
$ns flush-trace
close $f
close $nf
exec nam out.nam &
exit 0
}

$ns run
