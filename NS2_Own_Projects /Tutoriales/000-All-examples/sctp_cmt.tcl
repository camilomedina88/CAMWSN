#      http://blog.163.com/xjtshua@126/blog/static/10195470201112510136559/

set lrate1 "0.0100"
set lrate2 "0.0100"

Trace set show_sctphdr_ 1

set ns [new Simulator]
set nf [open sctp.nam w]
$ns namtrace-all $nf

set allchan [open all.tr w]
set rnd   [open rnd.tr w]
$ns trace-all $allchan

proc finish {} {
    global ns nf allchan

    set PERL "/usr/bin/perl"
    set NSHOME "/home/fan/ns-allinone-2.34"
    #set XGRAPH "$NSHOME/bin/xgraph"
    set SETFID "$NSHOME/ns-2.34/bin/set_flow_id"
    set RAW2XG_SCTP "$NSHOME/ns-2.34/bin/raw2xg-sctp"
    set GETRC "$NSHOME/ns-2.34/bin/getrc"

    $ns flush-trace
    close $nf
    close $allchan


    
    exec nam sctp.nam &

    exit 0
}





set host0_core [$ns node]
set host0_if0 [$ns node]
set host0_if1 [$ns node]

$host0_core color Red
$host0_if0 color Red
$host0_if1 color Red

$ns multihome-add-interface $host0_core $host0_if0
$ns multihome-add-interface $host0_core $host0_if1

set host1_core [$ns node]
set host1_if0 [$ns node]
set host1_if1 [$ns node]

$host1_core color Blue
$host1_if0 color Blue
$host1_if1 color Blue

set loss_module [new ErrorModel]
$loss_module set rate_ $lrate1
$loss_module ranvar [new RandomVariable/Uniform]
set loss_module1 [new ErrorModel]
$loss_module1 set rate_ $lrate2
$loss_module1 ranvar [new RandomVariable/Uniform]

$ns multihome-add-interface $host1_core $host1_if0
$ns multihome-add-interface $host1_core $host1_if1

$ns duplex-link $host0_if0 $host1_if0 10Mb 45ms DropTail
[[$ns link $host0_if0 $host1_if0] queue] set limit_ 20
$ns duplex-link $host0_if1 $host1_if1 50Mb 55ms DropTail
[[$ns link $host0_if1 $host1_if1] queue] set limit_ 50

$ns lossmodel $loss_module $host0_if0 $host1_if0
$ns lossmodel $loss_module1 $host0_if1 $host1_if1



set sctp0 [new Agent/SCTP/CMT]
$ns multihome-attach-agent $host0_core $sctp0
$sctp0 set fid_ 0
$sctp0 set debugMask_ -1
$sctp0 set debugFileIndex_ 0
$sctp0 set mtu_ 1500
$sctp0 set dataChunkSize_ 1468
$sctp0 set numOutStreams_ 1
$sctp0 set useCmtReordering_ 1    # turn on Reordering algo.
$sctp0 set useCmtCwnd_ 1          # turn on CUC algo.
$sctp0 set useCmtDelAck_ 1        # turn on DAC algo.
$sctp0 set eCmtRtxPolicy_ 0     # rtx. policy : RTX_CWND
$sctp0 set useCmtPF_ 1              # turn on CMT-PF
$sctp0 set cmtPFCwnd_ 2           # cwnd=2*MTU after HB-ACK

set trace_ch [open trace.sctp w]
$sctp0 set trace_all_ 1           # trace them all on one line
$sctp0 trace cwnd_
$sctp0 trace rto_



$sctp0 attach $trace_ch

set sctp1 [new Agent/SCTP/CMT]
$ns multihome-attach-agent $host1_core $sctp1
$sctp1 set debugMask_ -1
$sctp1 set debugFileIndex_ 1
$sctp1 set mtu_ 1500
$sctp1 set initialRwnd_ 131072
$sctp1 set useDelayedSacks_ 1
$sctp1 set useCmtDelAck_ 1

$ns color 0 Red
$ns color 1 Blue

$ns connect $sctp0 $sctp1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $sctp0

# set primary before association starts
$sctp0 set-primary-destination $host1_if0

proc record {} {
  global ns sctp0 rnd
  set now [$ns now]
  puts $rnd "$now [$sctp0 set cwnd_]"
  $ns at [expr $now+0.01] "record"
}


$ns at 0.5 "$ftp0 start"
#$ns at 0.5 "record"
$ns at 30.0 "finish"

$ns run 
