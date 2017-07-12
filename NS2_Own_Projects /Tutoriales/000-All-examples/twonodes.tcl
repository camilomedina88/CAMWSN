source emulate/ns-emulate.tcl
Agent/Tap set sport_ 0
Agent/Tap set dport_ 0
Agent/Null set sport_           0
Agent/Null set dport_           0

#$ns_ use-scheduler RealTime  ;# moved to ns-lib.tcl

# The hosts that will participate in the emulation:
set node1_ip "128.2.250.144" ;# farm7 
set node4_ip "128.2.250.51"  ;# farm2

# The ethernet card interface:
set ifname "xl0"

# How long to run the simulation:
set stoptime 60;

# Create a simulator:
set ns_ [new Simulator]

#$ns_ use-scheduler RealTime

# Create two nodes in our simulation:
set node1_ [$ns_ node]
set node4_ [$ns_ node]

# The parameters on the link between the two nodes:
set BWW 25Mb    ;# The bandwidth of the link
set owdelay 0   ;# The delay of the link

# Create a link in each direction.  If the queue overflows, 
# drop new packets first.
$ns_ simplex-link $node1_ $node4_ $BWW $owdelay DropTail
$ns_ simplex-link $node4_ $node1_ $BWW $owdelay DropTail

# Find out the ethernet hardware address of our card:
set arpagent [new ArpAgent]
$arpagent config $ifname
set myether [$arpagent set myether_]

#### tap and writers for node 1
set bpf1 [new Network/Pcap/Live]; #     used to read IP info
#$bpf1 set promisc_ true
set dev1 [$bpf1 open readonly $ifname]

set ipnet1 [new Network/IP];     #      used to write IP pkts
$ipnet1 open writeonly
$bpf1 filter "ip and ether dst $myether and ip src $node1_ip and ip dst $node4_ip"

set tapin1 [new Agent/Tap]
set ipout1 [new Agent/Tap]
$tapin1 network $bpf1
$ipout1 network $ipnet1

#####
set bpf4 [new Network/Pcap/Live]; #     used to read IP info
#$bpf4 set promisc_ true
set dev4 [$bpf4 open readonly $ifname]

set ipnet4 [new Network/IP];     #      used to write IP pkts
$ipnet4 open writeonly
$bpf4 filter "ip and ether dst $myether and ip src $node4_ip and ip dst $node1_ip"

set tapin4 [new Agent/Tap]
set ipout4 [new Agent/Tap]
$tapin4 network $bpf4
$ipout4 network $ipnet4

$ns_ attach-agent $node1_ $tapin1
$ns_ attach-agent $node1_ $ipout1

$ns_ attach-agent $node4_ $tapin4
$ns_ attach-agent $node4_ $ipout4

$ns_ connect $tapin1 $ipout4
$ns_ connect $tapin4 $ipout1

puts "starting emulation..."

$ns_ at $stoptime "puts \"exiting\"; $ns_  halt"
$ns_ run
