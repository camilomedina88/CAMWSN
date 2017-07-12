#-------Event scheduler object creation--------#

set ns [new Simulator]

#--------creating nam----#

set nf [open drop1.nam w]
$ns namtrace-all $nf

set nt [open drop1.tr w]
$ns trace-all $nt

set proto rlm
$ns color 1 red
$ns color 2 cgyan

# --------- CREATING SENDER - RECEIVER - ROUTER NODES-----------#

set Client1 [$ns node]
set Client2 [$ns node]
set Router1 [$ns node]
set Router2 [$ns node]
set Endserver1 [$ns node]

# --------------CREATING DUPLEX LINK -----------------------#
                       
$ns duplex-link $Client1 $Router1 5Mb 50ms DropTail
$ns duplex-link $Client2 $Router1 5Mb 50ms DropTail
$ns duplex-link $Router1 $Router2 150Kb 50ms DropTail
$ns duplex-link $Router2 $Endserver1 300Kb 50ms DropTail

#-----------CREATING ORIENTATION -------------------------#

$ns duplex-link-op $Client1 $Router1 orient down-right
$ns duplex-link-op $Client2 $Router1 orient right
$ns duplex-link-op $Router1 $Router2 orient right
$ns duplex-link-op $Router2 $Endserver1 orient up

# --------------LABELLING -----------------------------#
$ns at 0.0 "$Client1 label Client1"
$ns at 0.0 "$Client2 label Client2"
$ns at 0.0 "$Router1 label Router1"
$ns at 0.0 "$Router2 label Router2"
$ns at 0.0 "$Endserver1 label Endserver1"

# --------------- CONFIGURING NODES -----------------#

$Endserver1 shape hexagon
$Router1 shape square
$Router2 shape square

# ----------------QUEUES POSITIONING AND ESTABLISHMENT -------------#

$ns duplex-link-op $Client1 $Router1 queuePos 0.1
$ns duplex-link-op $Client2 $Router1 queuePos 0.1
$ns duplex-link-op $Router1 $Router2 queuePos 0.5
$ns duplex-link-op $Router2 $Endserver1 queuePos 0.5

# ----------------ESTABLISHING COMMUNICATION -------------#
           
#--------------TCP CONNECTION BETWEEN NODES---------------#

set tcp0 [new Agent/TCP]
$tcp0 set maxcwnd_ 16
$tcp0 set fid_ 1
$ns attach-agent $Client1 $tcp0

set sink0 [new Agent/TCPSink]
$ns attach-agent $Endserver1 $sink0

$ns connect $tcp0 $sink0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

$ns add-agent-trace $tcp0 tcp
$tcp0 tracevar cwnd_

$ns at 0.5 "$ftp0 start"
$ns at 5.5 "$ftp0 stop"
#---------------------------------------#

set tcp1 [new Agent/TCP]
$tcp1 set maxcwnd_ 16
$tcp1 set fid_ 2
$ns attach-agent $Client2 $tcp1

set sink1 [new Agent/TCPSink]
$ns attach-agent $Endserver1 $sink1

$ns connect $tcp1 $sink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$ns add-agent-trace $tcp1 tcp
$tcp1 tracevar cwnd_

$ns at 0.5 "$ftp1 start"
$ns at 6.5 "$ftp1 stop"

#----------------------drop nodes---------------------------#

$ns rtmodel-at 2.88 down $Router1 $Router2
$ns rtmodel-at 3.52 up $Router2 $Endserver1

# ---------------- FINISH PROCEDURE -------------#

proc finish {} {
 
 global ns nf nt
 $ns flush-trace
 close $nf
 puts "running nam..."
 exec nam drop1.nam &
 exit 0
 }

#Calling finish procedure
$ns at 7.0 "finish"
$ns run
