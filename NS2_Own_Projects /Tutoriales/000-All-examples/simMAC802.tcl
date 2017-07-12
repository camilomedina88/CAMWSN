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
    }
}

set topoFile "./topoDir/new-scen-$numNodes-$maxX-$maxY"

source "wirelessOpt.tcl"

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
    -macTrace OFF \
    -channel $chan

source "multiHopTopoGen.tcl"

$ns_ run
