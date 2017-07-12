

# FIRST SCENARIO WITHOUT BUFFER
# Basic Mobile IPv6 example without using ns-topoman
# Needs proc defined in file proc-mipv6-config.tcl
Agent/MIPv6/MN set bs_forwarding_ 0 ; # 1 if forwarding from previous BS
################################################################
proc log-mn-movement_no_topo { } {
global logtimer ns
Class LogTimer -superclass Timer
LogTimer instproc timeout {} {
global mobile_
$mobile_ log-movement
$self sched 1
}
set logtimer [new LogTimer]
$logtimer sched 1
}
################################################################
# Create Topology
################################################################
proc create-my-topo {} {
global ns opt topo mobile_ cn_ mnn_nodes_
# Create and define topography
set topo [new Topography]
# set prop [new $opt(prop)]
# $prop topography $topo
$topo load_flatgrid 800 800
# god is a necessary object when wireless is used
# set to a value equal to the number of mobile nodes
create-god 5
# Call node-config
$ns node-config \
-addressType hierarchical \
-agentTrace On \
-routerTrace Off\
# Set NS Addressing
AddrParams set domain_num_ 2
AddrParams set cluster_num_ {1 3}
AddrParams set nodes_num_ {1 1 2 1}
# Create Nodes
set cn_ [create-router 0.0.0]
set router_ [create-router 1.0.0]
set bs1_ [create-base-station 1.1.0 1.0.0 100 100 0]
set bs2_ [create-base-station 1.2.0 1.0.0 100 550 0]
set mobile_ [create-mobile 1.1.1 1.1.0 230 100 0 0 0.01]
# Create Links
$ns simplex-link $cn_ $router_ 10Mb 2.0ms DropTail
$ns duplex-link $router_ $bs1_ 10Mb 2.0ms DropTail
$ns duplex-link $router_ $bs2_ 10Mb 2.0ms DropTail
display_ns_addr_domain
}
################################################################
# End of Simulation
################################################################
proc finish { } {
global tracef ns namf opt mobile_ cn_
puts "Simulation finished"
# Dump the Binding Update List of MN and Binding Cache of HA
[[$mobile_ set ha_] set regagent_] dump
[$cn_ set regagent_] dump
[$mobile_ set regagent_] dump
$ns flush-trace
flush $tracef
close $tracef
close $namf
puts "running nam with $opt(namfile) ... "
#exec nam $opt(namfile) &
exit 0
}
################################################################
# Main
################################################################
proc main { } {
global opt ns TOPOM namf n tracef mobile_ cn_
# Source Files
# source set-def-options.tcl

source /home/slim/Desktop/Work/ns-allinone-2.33/ns-2.33/tcl/lib/proc-mipv6-config.tcl
source /home/slim/Desktop/Work/ns-allinone-2.33/ns-2.33/tcl/lib/proc-tools.tcl
source /home/slim/Desktop/Work/ns-allinone-2.33/ns-2.33/tcl/lib/proc-topo.tcl
source /home/slim/Desktop/Work/ns-allinone-2.33/ns-2.33/tcl/lib/ns-topoman.tcl
source /home/slim/Desktop/Work/ns-allinone-2.33/ns-2.33/tcl/lib/proc-mobi-global.tcl
source /home/slim/Desktop/Work/ns-allinone-2.33/ns-2.33/tcl/lib/proc-mobi-config.tcl
source /home/slim/Desktop/Work/ns-allinone-2.33/ns-2.33/tcl/mobility/timer.tcl

set NAMF out.nam
set TRACEF out.tr
set INFOF out.info
set opt(mactrace) ON
set opt(NAM) 1
set opt(namfile) $NAMF
set opt(stop) 100
set opt(tracefile) $TRACEF
#>--------------- Extract options from command line ---------------<
#Getopt
; # Get option from the command line
#DisplayCommandLine
#>---------------------- Simulator Settings ----------------------<
set ns [new Simulator]
#>------------------------ Open trace files ----------------------<
exec rm -f $opt(tracefile)
set tracef [open $opt(tracefile) w]
#... dump the file
#set new trace file for wireless
$ns use-newtrace
$ns trace-all $tracef
set namf [open $opt(namfile) w]
$ns namtrace-all $namf
#>------------- Protocol and Topology Settings -------------------<
create-my-topo
log-mn-movement_no_topo
#############
set-cbr
# set-ping-int 0.1 $cn_ $mobile_ 10 $opt(stop)
#start movement to pos(x,y) with velocity v
#$ns at 10.0 "$mobile_ setdest 700 400 10"
#MN move again to BS2#####
$ns at 2.0 "$mobile_ setdest 230 500 10"
#>----------------------- Run Simulation -------------------------<
$ns at $opt(stop) "finish"
$ns run
$ns dump-topology $namf
close $namf
puts "running nam with $opt(namfile) ... "
exec nam $opt(namfile) &
}
proc set-cbr { } {
global ns cn_ mobile_
set udp [new Agent/UDP]
$ns attach-agent $cn_ $udp
set dst [new Agent/Null]
$ns attach-agent $mobile_ $dst
$ns connect $udp $dst
set src [new Application/Traffic/CBR]
$src set packetSize_ 160
$src set rate_ 64k
$src set interval_ 0.05
$src attach-agent $udp
$ns at 10.0 "$src start"
$ns at 15.0 "$src stop"
}
main

