### command line processing
set count 0

while {$count < $argc} {
    set arg [lindex $argv $count]
    incr count 2
    switch -exact '$arg' {
        '-numsources' {
            set numsources [lindex $argv [expr $count-1]]
            continue
        }
        '-zmacMode' {
            set zmacMode [lindex $argv [expr $count-1]]
            continue
        }
        '-interval' {
            set interval [lindex $argv [expr $count-1]]
            continue
        }
        '-valuefile' {
            set valuefile [lindex $argv [expr $count-1]]
            continue
        }
        '-sinknode' {
            set sinknode [lindex $argv [expr $count-1]]
            continue
        }
        '-maxX' {
            set maxX [lindex $argv [expr $count-1]]
            continue
        }
        '-maxY' {
            set maxY [lindex $argv [expr $count-1]]
            continue
        }
        '-nn' {
            set numNodes [lindex $argv [expr $count-1]]
            continue
        }
        '-ack' {
            set ack [lindex $argv [expr $count-1]]
            continue
        }
        '-to' {
            set to [lindex $argv [expr $count-1]]
            continue
        }
        '-tno' {
            set tno [lindex $argv [expr $count-1]]
            continue
        }
        '-a' {
            set ptdmaA [lindex $argv [expr $count-1]]
            continue
        }
        '-timeSyncErrorFlag' {
            set timeSyncErrorFlag [lindex $argv [expr $count-1]]
            continue
        }
        '-timeSyncErrorValue' {
            set timeSyncErrorValue [lindex $argv [expr $count-1]]
            continue
        }
    }
}

set topoFile "./topoDir/new-scen-$numNodes-$maxX-$maxY"
set slotFile "$topoFile.drand"
set maxColorFile "$topoFile.maxcolor"

source "wirelessOpt.tcl"
source "zmacParameters.tcl"
source $maxColorFile

set ns_		[new Simulator] 
set topo	[new Topography]

set tracefd	[open $traceFile w]
$ns_ trace-all $tracefd
$ns_ use-newtrace
$topo load_flatgrid $maxX $maxY
set god_ [create-god $numNodes]
set chan [new $val(chan)]

$ns_ node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -topoInstance $topo \
    -agentTrace OFF \
    -routerTrace OFF \
    -macTrace ON \
    -channel $chan

source "multiHopTopoGen.tcl"
source $slotFile

$ns_ run
