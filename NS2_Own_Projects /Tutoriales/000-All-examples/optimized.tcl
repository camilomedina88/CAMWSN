#Create a new simulator object
set ns [new Simulator]
#create tracefiles
set na [open fully_local.tr w]
set nf [open fully_local.nam w]
$ns trace-all $na
$ns namtrace-all $nf
set f0 [open fully_local-bw.tr w]
set fs [open fully_local-seq.tr w]
# Set the colors for the different packets
$ns color 0 brown
$ns color 100 blue
proc finish {} {
global ns na nf f0 fs
$ns flush-trace
close $na
close $nf
close $f0
close $fs
exec nam fully_local.nam &
exec xgraph -m fully_local-bw.tr -geometry 800x400 &
exit 0
}
proc attach-expoo-traffic {node sink size burst idle rate} {
global ns
set source [new Agent/CBR/UDP]
$ns attach-agent $node $source
set traffic [new Traffic/Expoo]
$traffic set packet-size $size
$traffic set burst-time $burst
$traffic set idle-time $idle
$traffic set rate $rate

$source attach-traffic $traffic
$ns connect $source $sink
return $source
}
# Define a procedure which periodically records the bandwidth received by the
# traffic sink sink0 and writes it to the file f0.
set totalpkt 0
proc record {} {
global sink0 f0 totalpkt
set ns [Simulator instance]
#Set the time after which the procedure should be called again
set time 0.065
#How many bytes have been received by the traffic sink?
set bw0 [$sink0 set bytes_]
#Get the current time
set now [$ns now]
#Calculate the bandwidth (in MBit/s) and write it to the file
puts $f0 "$now [expr $bw0/$time*8/1000000]"
#Reset the bytes_ values on the traffic sink
$sink0 set bytes_ 0
#Re-schedule the procedure
$ns at [expr $now+$time] "record"
set bw0 [expr $bw0 / 200]
set totalpkt [expr $totalpkt + $bw0]
}
proc recv-pkts {} {
global totalpkt seqerrnb prvseqnb
puts "The Number of Total sent packages are $prvseqnb"
puts "The Number of Total received packages are $totalpkt"
puts "The number of dropped packages are [expr $prvseqnb - $totalpkt]"
puts "The Number of Total recieved unordered packages are $seqerrnb"
}
set prvseqnb -1

proc seq-record {size rate ftime} {
global prvseqnb seqerrnb sink0 fs
set ns [Simulator instance]
#Set the time after which the procedure should be called again
set tsize [parse-bw $size]
set rate [parse-bw $rate]
set time [expr double($tsize)/double($trate)/8.0]
#Get the current time
set now [$ns now]
# seek the sequence number of packet.
set revseqnb [$sink0 set expected_]
if {$prvseqnb > $revseqnb} {
incr seqerrnb 1
}
# write the sequence number of packet to the file
if {$prvseqnb != $revseqnb} {
puts $fs "$now [$sink0 set expected_]"
set prvseqnb $revseqnb
}
#Re-schedule the procedure
if { [expr $now+$time] < $ftime } {
$ns at [expr $now+$time] "seq-record $size $rate $ftime"
}
}
# routing protocol Distance Vector
$ns rtproto DV
#
# make nodes & MPLSnodes
#
set n0 [$ns node]
set n1 [$ns mpls-node]
set n2 [$ns mpls-node]
set n3 [$ns mpls-node]

set n4 [$ns mpls-node]
set n5 [$ns mpls-node]
set n6 [$ns mpls-node]
set n7 [$ns mpls-node]
# add variables for mpls modules
set LSRmpls1 [eval $n1 get-module "MPLS"]
set LSRmpls2 [eval $n2 get-module "MPLS"]
set LSRmpls3 [eval $n3 get-module "MPLS"]
set LSRmpls4 [eval $n4 get-module "MPLS"]
set LSRmpls5 [eval $n5 get-module "MPLS"]
set LSRmpls6 [eval $n6 get-module "MPLS"]
set LSRmpls7 [eval $n7 get-module "MPLS"]
# make links
$ns duplex-mpls-link $n0 $n1 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n1 $n3 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n3 $n5 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n5 $n6 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n7 $n7 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n1 $n2 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n2 $n4 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n4 $n6 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n1 $n2 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n3 $n4 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n5 $n6 10Mb 1ms 0.99 1000 10000 Param Null
$ns duplex-mpls-link $n7 $n5 10Mb 1ms 0.99 1000 10000 param Null
# Create a traffic sink and attach it to the node node7
set sink0 [new Agent/LossMonitor]
$ns attach-agent $n10 $sink0
$sink0 clear
# Create a traffic source
set src0 [attach-expoo-traffic $n0 $sink0 200 0 0 5000k]
$src0 set fid_ 100
# Enable upcalls on all nodes
Agent/RSVP set noisy_ 255
# Set re-route option to drop
$ns enable-reroute drop
# Start recording
$ns at 0.0 "record"
$ns at 0.3 "seq-record 200 5000k 2.0"
# The setup of working LSP
$ns at 0.0 "$LSRmpls1 create-crlsp $n0 $n7 0 100 1000 +400000 5000 32 1_3_5_7_"
# setup of the local recovery paths
$ns at 0.2 "$LSRmpls1 create-erlsp $n0 $n5 1 100 2000 1_2_4_6_5_"
$ns at 0.3 "$LSRmpls3 create-erlsp $n0 $n7 1 100 3000 3_4_6_7_"
$ns at 0.4 "$LSRmpls5 create-erlsp $n0 $n7 2 100 4000 5_6_"
$ns at 0.5 "$LSRmpls7 create-erlsp $n0 $n7 1 100 5000 6_7_"
# bind a flow to working LSP
$ns at 0.4 "$LSRmpls1 bind-flow-erlsp 10 100 1000"
#bind backup path to lsp
$ns at 0.7 "$LSRmpls1 reroute-lsp-binding 1000 2000"
$ns at 0.7 "$LSRmpls3 reroute-lsp-binding 1000 3000"
$ns at 0.7 "$LSRmpls5 reroute-lsp-binding 1000 4000"
$ns at 0.7 "$LSRmpls7 reroute-lsp-binding 1000 5000"
#start to send
$ns at 0.5 "$src0 start"
#break link
$ns rtmodel-at 0.8 down $n5 $n7
#stop sending
$ns at 1.8 "$src0 stop"
#finish simulation
$ns at 2.0 "recv-pkts"
$ns at 2.0 "record"
$ns at 2.0 "finish"
$ns run
