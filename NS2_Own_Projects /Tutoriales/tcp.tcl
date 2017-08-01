# usage: ns <scriptfile> <err_rate> <num_rtx>
SimpleLink instproc link-arq { limit } {


    $self instvar link_ link_errmodule_ queue_ drophead_ 
    $self instvar tARQ_ acker_ nacker_  
    set tARQ_ [new ARQTx]
    set acker_ [new ARQAcker]
    set nacker_ [new ARQNacker]
    $tARQ_ set retry_limit_ $limit
    $acker_ attach-ARQTx $tARQ_
    $nacker_ attach-ARQTx $tARQ_
    $tARQ_ target [$queue_ target] 
    $tARQ_ drop-target $drophead_
    $queue_ target $tARQ_
    $acker_ target [$link_errmodule_ target]
    $link_errmodule_ target $acker_
    $link_errmodule_ drop-target $nacker_
}

Simulator instproc link-arq {limit from to} {
    set link [$self link $from $to]
    $link link-arq $limit
}

proc show_tcp_seqno {} {
    global tcp ns x
    puts "At [$ns now], The tcp sequence number is [$tcp set t_seqno_]"
}

#=== Create the Simulator, Nodes, and Links ===
set ns [new Simulator]

set f [open out.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf



set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
$ns duplex-link $n1 $n2 5M 2ms DropTail
$ns duplex-link $n2 $n3 5M 2ms DropTail
$ns duplex-link $n1 $n3 5M 2ms DropTail

#=== Create error and ARQ module ===
set em [new ErrorModel]
$em set rate_ 0.5

$em set enable_ 1
$em unit pkt
$em set bandwidth_ 5M
$em ranvar [new RandomVariable/Uniform]
$em drop-target [new Agent/Null]

$ns link-lossmodel $em $n1 $n3

set num_rtx 2

$ns link-arq $num_rtx $n1 $n3

#=== Set up a TCP connection ===
set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
set ftp [new Application/FTP]
$ns attach-agent $n1 $tcp
$ns attach-agent $n3 $sink
$ftp attach-agent $tcp
$ns connect $tcp $sink

$ns at 10.0 "$ftp start"
$ns at 25.0 show_tcp_seqno
#$ns at 100.1 "exit 0"

$ns at 30.0 "finish"
proc finish {} {
global ns f nf
$ns flush-trace
close $f
close $nf
puts "running nam..."
exec nam out.nam &
exit 0
}

$ns run