source dynlibutils.tcl

dynlibload aodvetx     ../src/.libs

set val(chan)           Channel/WirelessChannel    ;# Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(rp)             AODVETX                    ;# routing protocol
set val(rtAgentFunction) create-aodvetx-agent
set val(distance)       200                        ;# distance between nodes (m)
set val(stop)           450
set val(tracefile)      "wireless-sim-aodv-grd.tr"
set val(namfile)        "wireless-sim-aodv-grd.nam"

set opt(n)                      0               ;# number of nodes
set opt(x)              0
set opt(y)              0
set opt(d)              0
set opt(seed)               0.0
set opt(stop)               0.0         ;# simulation time
set opt(tr)             ""

# ======================================================================
proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}


proc usage { argv0 }  {
        puts "Usage: $argv0"
        puts "\tmandatory arguments:"
        puts "\t\t\[-n NODES PER ROW\] \[-x MAXX\] \[-y MAXY\]"
        puts "\toptional arguments:"
        puts "\t\t\[-d distance\] \[-seed seed\] \[-stop sec\] \[-tr tracefile\]\n"
}


proc getopt {argc argv} {
        global opt
        lappend optlist seed sc stop tr x y

        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue

                set name [string range $arg 1 end]
                set opt($name) [lindex $argv [expr $i+1]]
        }
}

proc recordStats {} {
    global val ns_ sink1

    # How many bytes have been received by the traffic sinks?
    set sinkBytes [$sink1 set bytes_]
    # Get the current time
    set now [$ns_ now]
    # Calculate the bandwidth (in MBit/s) and write it to the files

    set bandwidth [format "%.5f" [expr $sinkBytes/4.0*8]]

    puts "$now BANDWIDTH $bandwidth"

    # Reset the bytes_ values on the traffic sinks
    $sink1 set bytes_ 0

    # Re-schedule the procedure
    $ns_ at [expr $now + 4.0] "recordStats"
}

# ======================================================================
# Main Program
# ======================================================================
getopt $argc $argv

if { $opt(n) == 0 || $opt(x) == 0 || $opt(y) == 0 } {
        usage $argv0
        exit 1
}

set val(nn) [expr $opt(n) * $opt(n)]

if {$opt(d) > 0} {
        puts "Setting distance between nodes to $opt(d)\n"
        set $val(distance) $opt(d)
}

if {$opt(seed) > 0} {
        puts "Seeding Random number generator with $opt(seed)\n"
        ns-random $opt(seed)
}

if {$opt(stop) > 0} {
        puts "Setting simulation duration to $opt(seed) seconds\n"
        $val(stop) = $opt(stop)
}

if {$opt(tr) != ""} {
        puts "Setting tracefile name to opt(tr)\n"
        $val(tr) = $opt(tr)
}

# Initialize Global Variables
set ns_         [new Simulator]
set tracefd     [open $val(tracefile) w]
$ns_ trace-all  $tracefd

set namtrace    [open $val(namfile) w]
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# set up topography object
set topo [new Topography]

$topo load_flatgrid $opt(x) $opt(y)

# Create God
create-god $val(nn)

# Create channel
set chan_ [new $val(chan)]

# Create node(0) "attached" to channel #1

# configure node, please note the change below.
$ns_ node-config -rtAgentFunction $val(rtAgentFunction) \
                -adhocRouting $val(rp) \
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
                -macTrace ON \
                -movementTrace OFF \
                -channel $chan_

for {set i 0} {$i < $opt(n)} {incr i} {
    for {set j 0} {$j < $opt(n)} {incr j} {
        set id [expr $i * $opt(n) + $j]
       
        set node_($id) [$ns_ node]
       
        $node_($id) random-motion 0
       
        $node_($id) set X_ [expr $val(distance) * $j]
        $node_($id) set Y_ [expr $val(distance) * $i]
        $node_($id) set Z_ 0.00
    }
}

for {set i 0} {$i < $val(nn)} {incr i} {    
        $ns_ initial_node_pos $node_($i) 20
}

# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)

set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $node_(7) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at 3.0 "$ftp1 start"
set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp2
$ns_ attach-agent $node_(8) $sink2
$ns_ connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns_ at 5.0 "$ftp2 start"

#
# Tell nodes when the simulation ends
#
$ns_ at 6.0 "recordStats"

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}

$ns_ at $val(stop) "stop"
$ns_ at $val(stop).01 "puts \"NS EXITING...\" ; $ns_ halt"

puts "Starting Simulation..."
$ns_ run
