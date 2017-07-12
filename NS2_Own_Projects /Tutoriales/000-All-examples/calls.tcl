source topology.tcl
source output.tcl
source registrations.tcl
source invite.tcl
source ua.tcl



# argomenti 

if {$argc != 2} { 
    puts [llength $argc]
    puts "Usage: ns calls  <m>  <seed>" 
    exit 1 
} 

set m [lindex $argv 0] 
set seed [lindex $argv 1] 
ns-random $seed




global n ns nr0 nr1 nr2 nr3 nr4 nr5 nr6 nr7 nr8



set ns [new Simulator]
$ns set-address-format hierarchical

set linkBneck 500Kb
set linkBW 55Mb
$ns clearMemTrace;

# Proxy servers
set nn(0) 1 
set nn(1) 101
set nn(2) 201
set nn(3) 301
set nn(4) 401
set nn(5) 501
set nn(6) 601
set nn(7) 701
set nn(8) 801
set nn(9) 901
set nn(10) 1001




create-hier-topology
set queue1_2 [$ns monitor-queue $n(1000) $n(1001) [$ns get-ns-traceall]]


for {set i 0} {$i < 11} {incr i 1} {
    
    set serveraddrPR($i) [$n($nn($i)) node-addr]
    set sipPR($i) [new Agent/SIPProxy proxy($i).com]
    $ns attach-agent $n($nn($i)) $sipPR($i)
    DNSGod register proxy proxy($i).com $serveraddrPR($i)
    $sipPR($i) set recordeRoute_ 1
}
define-UA

#$sipPR(10) set sipdelay_ 0.001
$sipPR(10) set send503_ 1

set FileRes [open data/queue-$m.dat w] 


$ns at 1.0 "REGISTRAZIONI"
$ns at 1.0 "REGISTRAZIONED11_1"
$ns at 10.0 "REGISTRAZIONED11_2"
$ns at 20.0 "REGISTRAZIONED11_3"
$ns at 30.0 "REGISTRAZIONED11_4"
$ns at 40.0 "REGISTRAZIONED11_5"
$ns at 50.0 "REGISTRAZIONED11_6"
$ns at 60.0 "REGISTRAZIONED11_7"
$ns at 70.0 "REGISTRAZIONED11_8"
$ns at 80.0 "REGISTRAZIONED11_9"
$ns at 90.0 "REGISTRAZIONED11_10"



$ns at 10.0 "stampa_coda 1"
$ns at 100.0 "INVITE_start0"
$ns at 5000.0 "INVITE_start1"
$ns at 5000.0 "INVITE_start2"
$ns at 5000.0 "INVITE_start3"
$ns at 5000.0 "INVITE_start4"
$ns at 5000.0 "INVITE_start5"
$ns at 5000.0 "INVITE_start6"
$ns at 5000.0 "INVITE_start7"
$ns at 5000.0 "INVITE_start8"
$ns at 5000.0 "INVITE_start9"

$ns at 30000.0 "finish"
$ns run








