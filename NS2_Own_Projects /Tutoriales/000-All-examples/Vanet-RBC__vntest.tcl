#
#    http://read.pudn.com/downloads155/sourcecode/comm/wireless/689495/vanetrbc-ns229/vntest.tcl__.htm
#
# -------------------------------------------------------------------
# Vehicular Ad Hoc Networks: Regular Broadcasting of messages.
# Skeleton for VANET-protocols. This should be considered as an
# example to create other VANET protocols!
# Apart from channel load, the "protocol" as it is now does not do
# anything useful.
#
# Dan Jungels (daniel.jungels@epfl.ch)
# LCA - EPFL
#
#
# Simulation script
# Originally written for ns2.29
#
# 2005-12-15: release of first version (dj)
# 2005-12-23: update and cleanup, public release (dj)
# -------------------------------------------------------------------

#=================================================
#                     Init.
#=================================================

set scriptStart [clock seconds]         ;# start time of the simulation

set maxTripTime -1                      ;# 2 variables for storing the
set maxTripTimeNode -1                  ;#      maximum trip-time and node

#=================================================
#          Parse command-line parameters
#=================================================
# the following is not necessary right now, but it may help you
# "getting started" if you want to make a large number of simulations
# later in a batch-run

#set clpars [split $argv " "]
#set par1 [lindex $clpars 0]
#set par2 [lindex $clpars 1]

#=================================================
#                     Options
#=================================================

set val(chan)       Channel/WirelessChannel     ;# channel type
set val(prop)       Propagation/FreeSpace       ;# radio-propagation model
set val(ant)        Antenna/OmniAntenna         ;# antenna type
set val(ll)         LL                          ;# link layer type
set val(ifq)        Queue/DropTail/PriQueue     ;# interface queue type
set val(ifqlen)     50                          ;# max packet in ifq
set val(netif)      Phy/WirelessPhy             ;# network interface type
set val(mac)        Mac/802_11                  ;# MAC type
set val(rp)         DumbAgent                   ;# routing (none)

# for the tracedir, you may use a local /tmp/ instead of your /home/
# if you have problems with your quota...
set opt(tracedir)   out_files/
set opt(outdir)     out_files/

set opt(filename)   $opt(tracedir)out           ;# base filename for traces
set opt(vnfilen)    $opt(filename)-vanet.tr     ;# vanet tracelog

# example scenario (loaded later in the Events section)
set opt(nn)         50                          ;# number of mobilenodes
set opt(x)          2400
set opt(y)          2400
set opt(sc)         scenario/univ-50.tcl

# second example with more nodes
#set opt(nn)         150                         ;# number of mobilenodes
#set opt(x)          2400
#set opt(y)          2400
#set opt(sc)         scenario/univ-150.tcl

set opt(stop)       80          ;# simulation end time
set opt(cbrinterv)  0.3         ;# the interval for sending RBC messages (also
                                ;# necessary for calculating the start times)

#=================================================
#                      MAC
#=================================================

# this should be more or less 802.11a
Mac/802_11 set dataRate_            6.0e6
Mac/802_11 set basicRate_           6.0e6
Mac/802_11 set CCATime              0.000004
Mac/802_11 set CWMax_               1023
Mac/802_11 set CWMin_               15
Mac/802_11 set PLCPDataRate_        6.0e6
Mac/802_11 set PLCPHeaderLength_    50
Mac/802_11 set PreambleLength_      16
Mac/802_11 set SIFS_                0.000016
Mac/802_11 set SlotTime_            0.000009

# 300m, default power, freq, etc... These can be calculated with
# the tool in ns-allinone-2.29/ns-2.29/indep-utils/propagation/
Phy/WirelessPhy set RXThresh_   6.72923e-11     ;# 300m at 5.15e9 GHz
Phy/WirelessPhy set freq_       5.15e9
Phy/WirelessPhy set Pt_         0.281838        ;# value for the 300m case..

#=================================================
# define a 'finish' procedure
#=================================================
# (executed at the end of the simulation to parse results, etc).
proc finish {} {
    global ns_ tracefd
    global ns_ vanettracefd
    global ns_ namfd
    global opt
    global scriptStart
    global maxTripTime
    global maxTripTimeNode
    
    # first erase all old Xgraph-files (if necessary)
#    eval exec rm [glob $opt(outdir)*.xgr]
    
    $ns_ flush-trace
    close $tracefd
    close $vanettracefd
    
    # NAM
    close $namfd
    exec nam $opt(filename).nam &
    
    # traffic on the channel: TX
    exec awk -f awk_files/tx.awk $opt(filename).tr > $opt(outdir)tx.xgr
    # RX at different nodes
    exec awk -f awk_files/rx01.awk $opt(filename).tr > $opt(outdir)rx01.xgr
    exec awk -f awk_files/rx05.awk $opt(filename).tr > $opt(outdir)rx05.xgr
    # create your own awk-files to filter other data...
    
    exec xgraph -x "time (sec)" -y "bw usage (bits/s)" $opt(outdir)tx.xgr \
                                $opt(outdir)rx01.xgr $opt(outdir)rx05.xgr &
    
    # here you could also parse your vanet-logtarget, if there is some
    # interesting data in it...
    
    # display the maximal trip time that we encountered during the sim.
    puts "maxTripTime: $maxTripTime ms, measured by $maxTripTimeNode"
    
    # erase files not needed anymore
    # (if you are sure that you don't want to have a look at them, you can
    # erase them to free up some disk space)
#    exec rm -f $opt(filename).tr
#    exec rm -f $opt(vnfilen)
#    exec rm -f $opt(filename).nam
    
    set scriptEnd [clock seconds]           ;# end-time of the simulation
    # display some statistics.. nice for very long simulations
    puts "Finishing ns.. Execution time: [expr $scriptEnd - $scriptStart] \
        seconds (End: [clock format $scriptEnd -format {%d.%m.%y %H:%M:%S}])"
    
    exit 0                                  ;# ... and we're done
}

#=================================================
# Define a 'recv' function for the class 'Agent/VanetRBC'
#=================================================
Agent/VanetRBC instproc recv {from tt} {        ;# (called from the C++ part)
    global maxTripTime
    global maxTripTimeNode
    
    $self instvar node_
    # display a message (if necessary, you may comment this out for debugging)
#    puts "node [$node_ id] received VANET msg from $from (trip-time $tt ms)."
    
    # store the longest trip time, to display it at the end of the simulation
    if {$maxTripTime < $tt} {
        set maxTripTime [expr {$tt}]                ;# one way trip time 'tt'
        set maxTripTimeNode [expr {[$node_ id]}]    ;# received by node 'id'
    }
}

#=================================================
#                     Nodes
#=================================================

set ns_ [new Simulator]                         ;# simulator object

set tracefd [open $opt(filename).tr w]         ;# set up trace file
$ns_ trace-all $tracefd

# for "real" simulations, you may comment this (nam-related stuff) out
# everywhere in this TCL file, since it fills up your disk drive
set namfd [open $opt(filename).nam w]           ;# set up nam trace file
$ns_ namtrace-all-wireless $namfd $opt(x) $opt(y)

# set up log-trace file (where the agents will dump their tables, etc)
set vanettracefd [open $opt(vnfilen) w]
set VanetTrace [new Trace/Generic]
$VanetTrace attach $vanettracefd

set topo   [new Topography]                     ;# create the topology
$topo load_flatgrid $opt(x) $opt(y)
create-god  $opt(nn)

# configure nodes with previously defined options
$ns_ node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -channel [new $val(chan)] \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace OFF \
    -macTrace OFF \
    -movementTrace OFF


Agent set debug_ true       ;# to get displayed the debug()-messages... if you
                            ;# make a batch of simulations, comment this out!

# create some nodes
for {set i 0} {$i < $opt(nn)} {incr i} {
    set node($i) [ $ns_ node $i ]
}

# create some agents and attach them to the nodes
for {set i 0} {$i < $opt(nn)} {incr i} {
    set p($i) [new Agent/VanetRBC $i]
    $ns_ attach-agent $node($i) $p($i)
    # set the logtarget for every agent
    $p($i) log-target $VanetTrace
}

# set some parameters for all agents
for {set i 0} {$i < $opt(nn)} {incr i} {
    $p($i) set interval_ $opt(cbrinterv)
    $p($i) set jitterFactor_ 0.001
    # for example (ECC): sig-delay (0.003255) + 2*verif-delay (0.00762)
    $p($i) set crypto_delay_ 0.018495
}

#=================================================
#                     Events
#=================================================

source $opt(sc)                     ;# load the scenario, defined previously

# let the nodes start to send messages.
for {set i 0} {$i < $opt(nn)} {incr i} {
    # they should not start all at the very same moment
    set sttime [expr {5 + $opt(cbrinterv)*$i/$opt(nn)}]
    $ns_ at $sttime "$p($i) start-regbc"
}

# and later, they should also stop
for {set i 0} {$i < $opt(nn)} {incr i} {
    $ns_ at 70 "$p($i) stop-regbc"
}

# only an example, to get some information from them...
$ns_ at 75.1 "$p(10) lookup 8"          ;# example of a command with parameter
$ns_ at 75.2 "$p(10) lookup 42"
$ns_ at 76 "$p(10) dump-rxdb"           ;# example of a command w/o parameter


# stop the simulation at the previously defined time
$ns_ at $opt(stop) "finish"

# run the simulation
$ns_ run
