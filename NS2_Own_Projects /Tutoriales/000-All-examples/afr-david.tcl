# ======================================================================
# 		afr-david.tcl
# 	TCL script for the AFR scheme 
# 
# ======================================================================

# ======================================================================
# Author: 		Tianji Li
# Date:   		11/04/2005
# Organization:   	Hamilton Institute, NUIM, Ireland
# ======================================================================


# ======================================================================
# Define options
# ======================================================================
source default_options.tcl

#-------------------------------------------------------------------------------- 
set val(nn)             10
set val(ifqlen)         10                          ;# max packet in ifq
set val(Sq_LIMIT)       20000
set val(run)            10.0

# set val(basicRate)      1.0Mb
# set val(dataRate)       6.0Mb
# set val(CBRrate)        .2Mb

set val(basicRate)      6.0Mb
set val(dataRate)       54.0Mb
set val(CBRrate)        5Mb

# set val(basicRate)      54.0Mb
# set val(dataRate)       216.0Mb
# set val(CBRrate)        4Mb


#-----------------------------------------------------------------------
set val(BER)            [lindex $argv 0]
set val(PktSize)        [lindex $argv 1]
set val(FRAMELEN)       [lindex $argv 2]
set val(fgLEN)          [lindex $argv 3]
set val(DELAY)          [lindex $argv 4] ;# duration of delay timer
#-----------------------------------------------------------------------







#-------------------------------------------------------------------------------- 
Mac/802_11 		        set fgLEN_      $val(fgLEN)
Mac/802_11 		        set BER_        $val(BER)
Mac/802_11              set Sq_LIMIT_   $val(Sq_LIMIT)   ;# number of fragments
Mac/802_11 		        set PktSize_        $val(PktSize)
Mac/802_11              set peakDelay_      0.0 
#Mac/802_11 		        set PLCPDataRate_	 $val(PLCPRate)
set val(avoidARP)	    0.0
set val(stop)		    [expr $val(start)+$val(avoidARP)+$val(run)]


#-------------------------------------------------------------------------------- 
puts "----------------------------------------------------------------"
puts "BER       Rate   Pkt     Frame    Frag    STA    Sq     D_Timer  Run"
puts "$val(BER)  $val(CBRrate)    $val(PktSize)    $val(FRAMELEN)     $val(fgLEN)    $val(nn)    $val(Sq_LIMIT)   $val(DELAY)   $val(run)"
puts "----------------------------------------------------------------"
#-------------------------------------------------------------------------------- 


#-------------------------------------------------------------------------------- 
# PHY MIB
#-------------------------------------------------------------------------------- 
Phy/WirelessPhy 	set CPThresh_ 	20000.0		;#capture threshold (db)
Phy/WirelessPhy 	set Pt_ 	0.2818 		;#for 250m range

#-------------------------------------------------------------------------------- 
# MAC MIB
#-------------------------------------------------------------------------------- 
Mac/802_11 		set basicRate_ 		$val(basicRate)
Mac/802_11 		set dataRate_ 		$val(dataRate)
Mac/802_11 		set CWMin_ 		$val(CWmin)
Mac/802_11 		set CWMax_ 		$val(CWmax)
Mac/802_11 		set SlotTime_ 		$val(SlotTime)
Mac/802_11 		set SIFS_ 		$val(SIFS)
Mac/802_11 		set RTSThreshold_ 	$val(RTSThreshold)
Mac/802_11 		set ShortRetryLimit_ 	$val(ShortRetryLimit)
Mac/802_11 		set LongRetryLimit_ 	$val(LongRetryLimit)
Mac/802_11 		set STANUM_ 		$val(nn)
Mac/802_11      set THRind_         0.0
Mac/802_11      set AverageFrameSize_ 0.0
Mac/802_11 		set totalDelay_		0.0
Mac/802_11 		set recvNumber_		0
Mac/802_11 		set DELAY_ 		    $val(DELAY)
Mac/802_11 		set FRAMELEN_ 		$val(FRAMELEN)


#-------------------------------------------------------------------------------- 
# Antenna settings
#-------------------------------------------------------------------------------- 

# unity gain, omni-directional antennas
# set up the antennas to be centered in the node and 1.5 meters above it
Antenna/OmniAntenna set X_ 1
Antenna/OmniAntenna set Y_ 1
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0
 

#   Application	Characteristics		 
Agent/CBR set sport_ 0
Agent/CBR set dport_ 0
Application/Traffic/CBR set rate_ $val(CBRrate)	
Application/Traffic/CBR set packetSize_ $val(PktSize)	;#bytes
Agent/UDP set packetSize_ $val(UPDpacketsize)			;#bytes
Agent/Null set sport_ 0
Agent/Null set dport_ 0

# LL 	
LL set mindelay_                0us
LL set delay_                   0us
LL set bandwidth_               0       ;# not used
LL set off_prune_               0       ;# not used
LL set off_CtrMcast_            0       ;# not used
LL set debug_ false


# ======================================================================
# Global Procedures
# ======================================================================
#remove-all-packet-headers
remove-packet-header AODV ARP IMEP IPinIP IVS LDP MPLS MIP Ping PGM PGM_SPM PGM_NAK NV Smac Pushback TORA TFRC_ACK TFRC 
#add-packet-header Common IP Mac TCP LL CtrMcast

#
# Initialize Global Variables
#
#Simulator set AgentTrace_ "OFF"
#Simulator set RouterTrace_ "OFF"
#Simulator set MacTrace_ "OFF"
#Simulator set EotTrace_ "OFF"

set ns_		[new Simulator]
$ns_ use-newtrace

#
# CMU trace format
#
set tracefd     [open $val(tr).cmu.all w]
$ns_ trace-all $tracefd


ns-random 0

#
# set up topography object
#
set topo       [new Topography]
$topo load_flatgrid $val(X) $val(Y)

#
# Create God
#
create-god $val(nn)

# ---------------------------------------------------------------------------------
$ns_ node-config -adhocRouting $val(rp) \
	 -llType $val(ll) \
	 -macType $val(mac) \
	 -ifqType $val(ifq) \
	 -ifqLen $val(ifqlen) \
	 -antType $val(ant) \
	 -propType $val(prop) \
	 -phyType $val(netif) \
	 -channelType $val(chan) \
	 -topoInstance $topo \
	 -agentTrace OFF \
	 -routerTrace OFF \
	 -macTrace OFF \
	 -movementTrace OFF 
 
# ---------------------------------------------------------------------------------
# 					Create node(s)			 
# ---------------------------------------------------------------------------------
for {set i 0} {$i < $val(nn) } {incr i} {
	# assign dst address in TCL because I do not use ARP pkts
#    LL set macDA_ [expr [expr $i+1] % $val(nn)]
    LL set dataDA_ [expr [expr $i+1] % $val(nn)]
    if { $i == 0 } {
      LL set tcpAckDA_ [expr $val(nn) - 1 ]
    } else {
      LL set tcpAckDA_ [expr $i-1]
    }
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
	#$node_($i) set SlotTime_
}


# ---------------------------------------------------------------------------------
# source scenario file			 
# ---------------------------------------------------------------------------------
source scenario.tcl

# ---------------------------------------------------------------------------------
# Tell nodes when the simulation ends
# ---------------------------------------------------------------------------------
$ns_ at $val(stop) "stop"
#$ns_ at $val(stop)+1 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $val(stop)+1 "$ns_ halt"




proc stop {} {
    global ns_ tracefd val node_ temp_delay
#    $ns_ flush-trace
	set sum 0.0
	set squaresum 0.0
    set peakDelay 0.0
    
    set f_throughput [open "afr_throughput.txt" "a"]
    set f_a_delay [open "afr_average_delay.txt" "a"]
    set f_p_delay [open "afr_peak_delay.txt" "a"]
    set f_fairness [open "afr_fairness.txt" "a"]
	
    
	for {set i 0} {$i < $val(nn) } {incr i} {
		set mac [$node_($i) getMac 0]

        set throughput($i)  [$mac set THRind_]
		set totalDelay      [$mac set totalDelay_]
		set recvNumber      [$mac set recvNumber_]
		set temp_delay      [$mac set peakDelay_]
        set AverageFrameSize  [$mac set AverageFrameSize_]
        #puts "SizeOfAllFrame of $i=$SizeOfAllFrame($i)"

        set peakDelay	[expr $peakDelay + $temp_delay]	
		
		set sum [expr $sum + $throughput($i)]
		set squaresum [expr $squaresum+[expr $throughput($i)*$throughput($i)]]
	}
	
#	puts "--------------------------------------------------------"
	puts "The system throughput = [expr $sum/$val(stop)]"
    puts -nonewline $f_throughput "[string range [expr $sum/$val(stop)] 0 6] "
	
	set nominator [expr $sum*$sum]
	set denominator [expr $val(nn)*$squaresum]
	set fairness [expr $nominator/$denominator]
	
#	puts "The total Delay=$totalDelay"
    puts "The average delay     = [expr $totalDelay/$recvNumber]"
    puts "The average frame     = $AverageFrameSize bytes"
  	puts "The peak delay        = [expr $peakDelay/$val(nn)]"
	puts "The fairness          = $fairness"
    puts -nonewline $f_a_delay "[string range [expr $totalDelay/$recvNumber] 0 6] "
    puts -nonewline $f_p_delay "[string range [expr $peakDelay/$val(nn)] 0 6] "
    puts -nonewline $f_fairness "[string range $fairness 0 6] "

    close $f_throughput
    close $f_a_delay
    close $f_p_delay
    close $f_fairness
}


# ---------------------------------------------------------------------------------
# 	Run ns...
# ---------------------------------------------------------------------------------
#puts "Starting Simulation..."
$ns_ run

