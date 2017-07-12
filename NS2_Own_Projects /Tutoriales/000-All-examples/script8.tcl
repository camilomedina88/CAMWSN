# Tarcisio Coutinho
# Centro de Informática - UFPE
# 
# Redes de Computadores - 2011.2


set ns [new Simulator]


set f [open out.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf

$ns color 1 Blue
$ns color 2 Red


proc finish {} {
  global ns f nf qmon1 qmon2 qmon3
  $ns flush-trace
  close $f
  close $nf

  puts "r1 drops = [$qmon1 set pdrops_]"
  puts "r1 arrivals = [$qmon1 set parrivals_]"
  puts "s3(tahoe) arrivals = [$qmon2 set parrivals_]"
  puts "s4(reno ) arrivals = [$qmon3 set parrivals_]"

  exec nam out.nam &
  exit 0
}

# ******  ******
#        s1                    s4
#          \                  /
#  1Mb,10ms \   0.2Mb,10ms   / 1Mb,10ms
#            r1 ---------- r2
#  1Mb,10ms /                \ 1Mb,10ms
#          /                  \
#        s2                    s3


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

set window 15
set packet_size 555


set tcp1 [new Agent/TCP/Reno]
$ns attach-agent $s1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $s3 $sink1
$ns connect $tcp1 $sink1

$tcp1 set fid_ 1
$tcp1 set window_ $window
$tcp1 set packetSize_ $packet_size

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

set tcp2 [new Agent/TCP]
$ns attach-agent $s2 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $s4 $sink2
$ns connect $tcp2 $sink2

$tcp2 set fid_ 2
$tcp2 set window_ $window
$tcp2 set packetSize_ $packet_size

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

$ns at 0.0 "$ftp1 start"
$ns at 0.0 "$ftp2 start"
$ns at 10.0 "finish"

$ns run