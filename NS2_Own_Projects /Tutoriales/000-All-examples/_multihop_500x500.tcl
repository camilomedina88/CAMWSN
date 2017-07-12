#
#        http://bbs.chinaunix.net/thread-1637093-1-1.html
#
# TCL脚本的代码：
set val(simDur) 85.0         ;#simulation duration
set val(basename)  multi-hop ;#basename for this project or scenario
set val(statIntvl) 0.1 ;#statistics collection interval
set val(statStart) 0.5 ;
set val(trafStart) 0.5 ;#CBR start time
set val(cbrIntvl) 1.0  ;#CBR traffic interval
set val(chan)  [new Channel/WirelessChannel]    ;# channel model
set val(prop)  Propagation/TwoRayGround   ;# radio-propagation model
set val(netif) Phy/WirelessPhy            ;# network interface type
set val(mac)   Mac/802_11                 ;# MAC type
set val(ifq)   Queue/DropTail/PriQueue    ;# interface queue type
set val(ifqlen) 50                         ;# max packet in ifq
set val(ll)     LL                         ;# link layer type
set val(ant)    Antenna/OmniAntenna        ;# antenna model
set val(nn)     3                          ;# number of mobilenodes
set val(rp)             AODV                  ;# routing protocol
set val(topo_x_dim)     500
set val(topo_y_dim)     500
#Initialize and create output files
#Create a simulator instance
set ns [new Simulator]
#Crate a trace file and animation record
set tracefd [open $val(basename).tr w]
$ns trace-all $tracefd
set namtracefd [open $val(basename).nam w]
$ns namtrace-all-wireless $namtracefd $val(topo_x_dim) $val(topo_y_dim)
set outfd [open $val(basename).out w]
#Create Topology
# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(topo_x_dim) $val(topo_y_dim)
# Create God
#
create-god $val(nn)
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel.

# configure node
$ns node-config -adhocRouting $val(rp) \
   -llType $val(ll) \
   -macType $val(mac) \
   -ifqType $val(ifq) \
   -ifqLen $val(ifqlen) \
   -antType $val(ant) \
   -propType $val(prop) \
   -phyType $val(netif) \
   -topoInstance $topo \
   -agentTrace ON \
   -routerTrace ON \
   -macTrace OFF \
   -movementTrace OFF \
   -channel $val(chan)
for {set i 0} {$i 
}

