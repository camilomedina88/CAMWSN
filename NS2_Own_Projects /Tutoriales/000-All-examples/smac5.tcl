if {$argc !=4} {

        puts "Usage: ns smac.tcl MacType msg-interval nodes time"
	puts "1=smac,2=teem,3=teem with ins,4 =ctsrtsnewteem ,5=smac with ins"
        puts "Example:ns smac.tcl 1/2/3/4 10 5 time"

        exit
}
 
set para1 [lindex $argv 0]
set para2 [lindex $argv 1]
set para3 [lindex $argv 2]
set para4 [lindex $argv 3]

set opt(chan)		Channel/WirelessChannel
set opt(prop)		Propagation/TwoRayGround
set opt(netif)		Phy/WirelessPhy
#set opt(mac)            Mac/802_11                   ;# MAC type
set opt(mac)            Mac/SMAC                   ;# MAC types
set opt(ifq)		Queue/DropTail/PriQueue
set opt(ll)		LL
set opt(ant)            Antenna/OmniAntenna

set opt(x)		2500	;# X dimension of the topography
set opt(y)		1000		;# Y dimension of the topography
set opt(cp)		"../mobility/scene/cbr-50-10-4-512"
set opt(sc)		"../mobility/scene/scen-670x670-50-600-20-0"

set opt(ifqlen)		50		;# max packet in ifq
#set opt(Ann)		5		;# number of nodes
#set opt(Snn)		10		;# number of nodes
set opt(Snn)		$para3		;# number of nodes
set opt(seed)		0.0
#set opt(stop)		250.0		;# simulation time
set opt(stop)		$para4		;# simulation time
set opt(tr)		"trace/trace-$para1-$para2-$para3-$para4.tr"	;# trace file
set opt(nam)		SMACTest.nam	;# animation file
#set opt(rp)             DumbAgent       ;# routing protocol script
set opt(adhocRouting)   NOAH		;
set opt(lm)             "off"           ;# log movement
set opt(agent)          Agent/DSDV
set opt(energymodel)    EnergyModel     ;
#set opt(energymodel)    RadioModel     ;
set opt(radiomodel)    	RadioModel     ;
set opt(initialenergy)  10            ;# Initial energy in Joules
#set opt(logenergy)      "on"           ;# log energy every 150 seconds
set val(incr_range)	250

Mac/SMAC set syncFlag_ 1
Mac/SMAC set dutyCycle_ 10
Mac/SMAC set selfConfigFlag_ 1 ;# disable user-configurable schedule
Mac/SMAC set MacType_ $para1
#1 smac
#2 teem
 #foreach cl [PacketHeader info subclass] {
  #              puts $cl
   #     }
 

#remove-all-packet-headers
#add-packet-header IP LL Mac

set ns_		[new Simulator]
set topo	[new Topography]
set tracefd	[open $opt(tr) w]
set namtrace    [open $opt(nam) w]
set prop	[new $opt(prop)]

$topo load_flatgrid $opt(x) $opt(y)
#ns-random 1  is same result everytime
#ns-random 0 is different result each time
ns-random 0
#$ns_ use-newtrace
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace 1000 1000  

#
# Create god
#

create-god $opt(Snn)

#global node setting

$ns_ node-config -adhocRouting $opt(adhocRouting) \
                         #-adhocRouting DumbAgent \
			 -llType $opt(ll) \
			 -macType $opt(mac) \
			 -ifqType $opt(ifq) \
			 -ifqLen $opt(ifqlen) \
			 -antType $opt(ant) \
			 -propType $opt(prop) \
			 -phyType $opt(netif) \
			 -channelType $opt(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON \
			 -phyTrace ON \
			 -energyModel $opt(energymodel) \
			 -idlePower 0.014 \
			 -rxPower 0.014 \
			 -txPower 0.036 \
          		 -sleepPower 0.000015 \
          		 -transitionPower 0.028 \
          		 -transitionTime 0.002 \
			 -initialEnergy $opt(initialenergy)
	
$ns_ set WirelessNewTrace_ ON

#set AgentTrace			ON
#set RouterTrace		OFF
#set MacTrace			ON

for {set i 0} {$i < $opt(Snn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
	#done my me to get reference of routing protocol in mac layaer
	#set Dumb($i) [$node_($i) get-ragent]
	#set temp_mac_ [$node_($i) get-mac 0]
	#$ns_ at 0.0 "$temp_mac_ set-rt $Dumb($i)"
}
	
#	$node_(1) set agentTrace ON	 
#	$node_(1) set macTrace ON
#	$node_(1) set routerTrace ON		 	
#	$node_(0) set macTrace ON
#	$node_(0) set agentTrace ON	 
#	$node_(0) set routerTrace ON

#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#
set Y 0
set X 0
set intver $val(incr_range)

for {set i 0} {$i < $opt(Snn)} {incr i} {
	set X [expr $X + $intver]

	if {$X < $val(incr_range)} {
		set Y [expr $Y + $val(incr_range)]
		set intver $val(incr_range)
		set X [expr $X + $intver]
		} 

	if {$X > $opt(x)} {
		set Y [expr $Y + $val(incr_range)]
		set intver "-$val(incr_range)"
		set X [expr $X + $intver]
		} 

	$node_($i) set X_ $X
	$node_($i) set Y_ $Y
	$node_($i) set Z_ 0.0

	puts "($i) $X, $Y"
}


# setup static routing for line of nodes
# NOAH static routing
for {set i 0} {$i < $opt(Snn) } {incr i} {
    set cmd "[$node_($i) set ragent_] routing $opt(Snn)"
    for {set to 0} {$to < $opt(Snn) } {incr to} {
	if {$to < $i} {
	    set hop [expr $i - 1]
	} elseif {$to > $i} {
	    set hop [expr $i + 1]
	} else {
	    set hop $i
	}
	set cmd "$cmd $to $hop"
    }
    eval $cmd
  # puts $cmd
}


#
# Now produce some simple node movements
# Node_(1) starts to move towards node_(0)
#
#$ns_ at 10.0 "$node_(1) setdest 25.0 20.0 15.0"
#$ns_ at 10.0 "$node_(0) setdest 5.0 2.0 1.0"

# Node_(1) then starts to move away from node_(0)
#$ns_ at 300.0 "$node_(1) setdest 490.0 480.0 15.0" 


set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(0) $udp_(0)

set null_(0) [new Agent/Null]
$ns_ attach-agent $node_([expr $opt(Snn) - 1]) $null_(0)

$ns_ connect $udp_(0) $null_(0)

set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 80
$cbr_(0) set interval_ $para2
#$cbr_(0) set rate_ 1mb
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 50	
	

$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)

#$ns_ at 100.00 "$cbr_(0) start"
$ns_ at 60.00 "$cbr_(0) start"

#$ns at 4.0 "$agent($i) produce 10"

# $ns_ at 177.000 "$node_(0) set ifqLen"

#
# Tell all the nodes when the simulation ends
#
for {set i 0} {$i < $opt(Snn) } {incr i} {
    $ns_ at $opt(stop) "$node_($i) reset";
}


#$ns_ at $opt(stop) "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).01 "stop"
$ns_ at $opt(stop).02 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd namtrace
      $ns_ flush-trace
      close $namtrace
    close $tracefd
}

#set b [$node_(0) set mac_(0)]
#set c [$b set freq_]
#set d [Mac/SMAC set syncFlag_]
#set e [$node_(0) set netif_(0)]
#set c [$e set L_]
set c [Mac/SMAC set dutyCycle_]

puts $tracefd "M 0.0 Snn $opt(Snn) x $opt(x) y $opt(y) rp $opt(adhocRouting)"
#puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp) seed $opt(seed)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"
#puts $tracefd "V $b : $c : $d :"
puts $tracefd "V $c :"

puts "Starting Simulation..."
puts "CBR interval = [$cbr_(0) set interval_]"

$ns_ run
