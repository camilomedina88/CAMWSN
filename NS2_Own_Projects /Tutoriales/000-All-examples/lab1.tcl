# ****** Lab1 ******
#        s1                    s4
#          \                  /
#  1Mb,10ms \   0.2Mb,10ms   / 1Mb,10ms
#            r1 ---------- r2
#  1Mb,10ms /                \ 1Mb,10ms
#          /                  \
#        s2                    s3

set ns [new Simulator]

#******tracing******
set f [open lab1.tr w]
$ns trace-all $f
set nf [open lab1.nam w]
$ns namtrace-all $nf
#******colors*******
$ns color 1 Blue
$ns color 2 Red

set s1 [$ns node]
set s2 [$ns node]
set s3 [$ns node]
set s4 [$ns node]

set r1 [$ns node]
set r2 [$ns node]

$ns duplex-link $s1 $r1 1Mb 10ms DropTail
$ns duplex-link $s2 $r1 1Mb 10ms DropTail
set L [$ns duplex-link $r1 $r2 200Kb 10ms SFQ]
$ns duplex-link $r2 $s4 1Mb 10ms DropTail
$ns duplex-link $r2 $s3 1Mb 10ms DropTail

#$ns queue-limit $r1 $r2 2     ;# ne rabotaet s SFQ
#[$L queue] set maxqueue_ 2    ;# nikak ne rabotaet
set qmon1 [$ns monitor-queue $r1 $r2 0]
set qmon2 [$ns monitor-queue $r2 $s3 0]
set qmon3 [$ns monitor-queue $r2 $s4 0]

#******animation******
$ns duplex-link-op $s1 $r1 orient right-down
$ns duplex-link-op $s2 $r1 orient right-up
$ns duplex-link-op $r1 $r2 orient right
$ns duplex-link-op $r2 $s4 orient right-up
$ns duplex-link-op $r2 $s3 orient right-down

$ns duplex-link-op $r1 $r2 queuePos 0.5

#tcp params
set window 15
set packet_size 555

#******TCP Tahoe connection s1-s3******
set tcp1 [new Agent/TCP]
$ns attach-agent $s1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $s3 $sink1
$ns connect $tcp1 $sink1

$tcp1 set fid_ 1
$tcp1 set window_ $window
$tcp1 set packetSize_ $packet_size

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

#******TCP Reno connection s2-s4******
set tcp2 [new Agent/TCP/Reno]
$ns attach-agent $s2 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $s4 $sink2
$ns connect $tcp2 $sink2

$tcp2 set fid_ 2
$tcp2 set window_ $window
$tcp2 set packetSize_ $packet_size

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

#******Schedule******
$ns at 0.0 "$ftp1 start"
$ns at 0.0 "$ftp2 start"
$ns at 5.0 "finish"

proc finish {} {
  global ns f nf qmon1 qmon2 qmon3
  $ns flush-trace
  close $f
  close $nf

  puts "r1 drops = [$qmon1 set pdrops_]"
  puts "r1 arrivals = [$qmon1 set parrivals_]"
  puts "s3(tahoe) arrivals = [$qmon2 set parrivals_]"
  puts "s4(reno ) arrivals = [$qmon3 set parrivals_]"

  exec nam lab1.nam &
  exit 0
}

$ns run









































