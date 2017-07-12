


#======================================================================
# Define options
#======================================================================
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(rp) DumbAgent ;# routing protocol
set val(start) 0.0
set val(tr) "trace"
set val(X) 100
set val(Y) 100T
set val(UPDpacketsize) 65536
set val(RTSThreshold) 65536
set val(ShortRetryLimit) 4
set val(LongRetryLimit) 4
set val(CWmin) 16
set val(CWmax) 1024
set val(SlotTime) 0.000009
set val(SIFS) 0.000016
set rng [new RNG]
set val(nn) 0
$rng seed 0
set ss [$rng next-random]
puts "random number for ns is: $ss"
set opt(seed) $ss
#the cbr_scenario.tcl defines the traffic flows and the stations’ positions
# Get default options
#source phyrate_cbr-default_options.tcl
#Ken Chan Advisor: Prof Melody MohCS298 Report, Spring 2009 May 03, 2009 39
# Station position
puts "---------------------------------------------------------------------"
for {set i 1} {$i < $val(nn)+1 } {incr i 1} {
$node_([expr $i-1]) set X_ [expr $val(X)-$i]
$node_([expr $i-1]) set Y_ [expr $val(Y)-$i]
$node_([expr $i-1]) set Z_ 0.0
}
puts "---------------------------------------------------------------------"
# Flow from this station to all the others
puts "---------------------------------------------------------------------"
set flowid 0

# only one flow
set i 0
set udp($flowid) [new Agent/UDP]
set null($flowid) [new Agent/Null]
#$ns_ attach-agent $node_($i) $udp($flowid)
#$ns_ attach-agent $node_([expr ($i+1) % $val(nn)]) $null($flowid)
#$ns_ connect $udp($flowid) $null($flowid)
set cbr($flowid) [new Application/Traffic/CBR]
$cbr($flowid) attach-agent $udp($flowid)
#$ns_ at [expr $val(start)+[expr $i / 1000]] "$cbr($flowid) start"
#$ns_ at [expr $val(start)+ $i]] "$cbr($flowid) start"
set flowid [expr $flowid + 1]
# multi flows
for {set i 0} {$i < $val(nn) } {incr i 1} {
set udp($flowid) [new Agent/UDP]
set null($flowid) [new Agent/Null]
$ns_ attach-agent $node_($i) $udp($flowid)
$ns_ attach-agent $node_([expr ($i+1) % $val(nn)]) $null($flowid)
$ns_ connect $udp($flowid) $null($flowid)
set cbr($flowid) [new Application/Traffic/CBR]
$cbr($flowid) attach-agent $udp($flowid)
$ns_ at [expr $val(start)+[expr $i / 1000]] "$cbr($flowid) start"
$ns_ at [expr $val(start)+ $i]] "$cbr($flowid) start"
$ns_ at $val(start) "$cbr($flowid) start"
set flowid [expr $flowid + 1]
}
puts "---------------------------------------------------------------------"
# the cbr.tcl defines the core of the cbr simulations and the record of nam graphand .tr trace file, following are parts of the files and explanations Ken Chan #CS298 Report, Spring 2009 May 03, 2009 40
#======================================================================
# Define options
#======================================================================
#source phyrate_cbr-default_options.tcl
#----------------------------------------------------------------------------
set val(nn) 10 ;##fixed node number for testing CBR traffic
set val(ifqlen) 10 ;# max packet in ifq
set val(Sq_LIMIT) 10
set val(run) 5.0
#-----------------------------------------------------------------------
set val(BER) 0
set val(PktSize) 1024
set val(FRAMELEN) 65535
set val(fgLEN) 8192
set val(DELAY) 0.0 ;# duration of delay timer, change to 0.0 instead of using argument 4
set val(temp) 144 ;# datarate
set val(appFERReq) 0.10
set val(trafficload) 0.5
set val(turnOnAFS) 1
set val(dataRate) $val(temp)Mb
set val(basicRate) 6.0Mb ;#changed to 6.0MB
set val(CBRrate) {expr [$val(temp)/$val(nn)*$val(trafficload)]}
puts "CBRrate for each station = $val(CBRrate)"
#-----------------------------------------------------------------------
set val(percentage) 0.03 ;#for calculating the percentage with more than 30ms
set val(OrigPktSize) 1024
#----------------------------------------------------------------------------
Mac/802_11 set fgLEN_ $val(fgLEN)
Mac/802_11 set BER_ $val(BER)
Mac/802_11 set Sq_LIMIT_ $val(Sq_LIMIT) ;# number of fragments
Mac/802_11 set peakDelay_ 0.0
Mac/802_11 set percentage_ $val(percentage)
Mac/802_11 set appFERReq_ $val(appFERReq) ;#for setting applicationFERRequirement
#Mac/802_11 set PLCPDataRate_ $val(PLCPRate)
set val(avoidARP) 0.0
set val(stop) [expr $val(start)+$val(avoidARP)+$val(run)]
#-------------------------------------------------------------------------------- Ken Chan Advisor: Prof Melody Moh CS298 Report, Spring 2009 May 03, 2009 41$val(fgLEN)//////////////////////////
puts "----------------------------------------------------------------"
puts "BER PktSize AMPDU_Frame_Size AMSDU_Frame_Size DataRate(Mbps) App_FER_Req Trafficload TurnOnAFS"
puts "$val(BER) $val(PktSize) $val(FRAMELEN) $val(dataRate) $val(appFERReq) $val(trafficload) $val(turnOnAFS)"
puts "----------------------------------------------------------------"

#--------------------------------------------------------------------------------
# PHY MIB
#--------------------------------------------------------------------------------
Phy/WirelessPhy set CPThresh_ 20000.0 ;#capture threshold (db)
Phy/WirelessPhy set Pt_ 0.2818 ;#for 250m range
#--------------------------------------------------------------------------------
# MAC MIB
#--------------------------------------------------------------------------------
Mac/802_11 set PktSize_ $val(PktSize)
Mac/802_11 set basicRate_ $val(basicRate)
Mac/802_11 set dataRate_ $val(dataRate)
Mac/802_11 set CWMin_ $val(CWmin)
Mac/802_11 set CWMax_ $val(CWmax)
Mac/802_11 set SlotTime_ $val(SlotTime)
Mac/802_11 set SIFS_ $val(SIFS)
Mac/802_11 set RTSThreshold_ $val(RTSThreshold)
Mac/802_11 set ShortRetryLimit_ $val(ShortRetryLimit)
Mac/802_11 set LongRetryLimit_ $val(LongRetryLimit)
Mac/802_11 set STANUM_ $val(nn)
Mac/802_11 set THRind_ 0.0
Mac/802_11 set SizeOfAllFrame_ 0
Mac/802_11 set totalDelay_ 0.0
Mac/802_11 set percentageDelay_ 0.0
Mac/802_11 set recvNumber_ 0
Mac/802_11 set DELAY_ $val(DELAY)
Mac/802_11 set FRAMELEN_ $val(FRAMELEN)
Mac/802_11 set turnOnAFS_ $val(turnOnAFS)
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

# Application Characteristics
Agent/CBR set sport_ 0
Agent/CBR set dport_ 0
Application/Traffic/CBR set rate_ $val(CBRrate)
Application/Traffic/CBR set packetSize_ $val(PktSize) ;#bytes
Agent/UDP set packetSize_ $val(UPDpacketsize) ;#bytes
Agent/Null set sport_ 0
Agent/Null set dport_ 0
# LL
LL set mindelay_ 0us
LL set delay_ 0us
LL set bandwidth_ 0 ;# not used
LL set off_prune_ 0 ;# not used
LL set off_CtrMcast_ 0 ;# not used
LL set debug_ false
#======================================================================
# Global Procedures
#======================================================================
#remove-all-packet-headers
#remove-packet-header AODV ARP IMEP IPinIP IVS LDP MPLS MIP Ping PGM PGM_SPM PGM_NAK NV Smac Pushback TORA TFRC_ACK TFRC ;# original

#remove-packet-header IMEP IPinIP IVS LDP MPLS MIP Ping PGM PGM_SPMPGM_NAK NV Smac Pushback TORA TFRC_ACK TFRC
#add-packet-header Common IP Mac TCP LL CtrMcast
# new ns
#------------------------------------------------------------------------
remove-all-packet-headers
add-packet-header Common IP Mac LL CtrMcast
set ns_ [new Simulator]
$ns_ use-newtrace ;# change to use another trace
# CMU trace format, trace if needed
set tracefd [open $val(tr).cmu.all w]
$ns_ trace-all $tracefd
puts "second times"
proc hello {} {
puts "hello"
}
# open the tr trace file and the nam graph Ken Chan Advisor: Prof Melody Moh
set f [open final_out.tr w]
#$ns trace-all $f
## set nam trace for graph generation
##/////enable namtrace if needed
set namtrace [open phyrate_cbr.nam w]
$ns_ namtrace-all-wireless $namtrace $val(X) $val(Y)
set f0 [open bandwidth_node1.tr w]
set f1 [open npkts_node1.tr w]
## open throughput, average delay and peak delay and fairness or percentage delay if needed here
set f_throughput [open throughput_dcf.tr w]
set f_averagedelay [open averagedelay__dcf.tr w]
set f_peakdelay [open peakdelay_dcf.tr w]
set f_data [open phyrate_cbr_data_$val(temp).tr a]
ns-random 0 ;# may not be useful
# set up topography object
set topo [new Topography]
$topo load_flatgrid $val(X) $val(Y)
# Create God
create-god $val(nn)
## need to get the wireless channel value first
set wirelesschan [new $val(chan)]
#------------------------------------------------------------------------
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
-agentTrace ON \
-routerTrace ON \
-macTrace ON \
-movementTrace ON
#-channel $val(chan) ;# wireless channel
#-agentTrace OFF \ ;# should be set to ON for nam trace Ken Chan Advisor: Prof
#-routerTrace OFF \
#-macTrace OFF \
#-movementTrace OFF
#------------------------------------------------------------------------
##Need to do sth here .........
# Create node
#------------------------------------------------------------------------
for {set i 0} {$i < $val(nn) } {incr i} {
# assign dst address in TCL because I do not use ARP pkts
LL set macDA_ [expr [expr $i+1] % $val(nn)]
LL set dataDA_ [expr [expr $i+1] % $val(nn)]
if { $i == 0 } {
LL set tcpAckDA_ [expr $val(nn) - 1 ]
} else {
LL set tcpAckDA_ [expr $i-1]
}

set node_($i) [$ns_ node]
$node_($i) random-motion 0 ;# disable random motion
$ns_ initial_node_pos $node_($i) 30 ;# define the initial position of bility
#$node_($i) set SlotTime_
}

#---------------------------------------------------------------------
#source phyrate_cbr-scenario.tcl
# Station position
# Station position
#set phydatarate $var(dataRate)
#put "$var(dataRate)"
###for setting the first line
proc stop {} { global ns_ val node_ temp_delay tracefd f_data
#namtrace
#f_throughput f_averagedelay f_peakdelay
$ns_ flush-trace ; #flush the trace file

#exec xgraph cwnd_tcp1.tr
#exec xgraph pkt_received_at_node1.tr
#set sum 0.0
#set squaresum 0.0
#set peakDelay 0.0

set f_throughput [open "phyrate_cbr_throughput_ampdu.tr" "a"]
#Ken Chan Advisor:
set f_a_delay [open "phyrate_cbr_average_delay_ampdu.tr" "a"]
set f_p_delay [open "phyrate_cbr_peak_delay_ampdu.tr" "a"]
set f_fairness [open "phyrate_cbr_fairness_ampdu.tr" "a"]
set f_percentage_delay [open "phyrate_cbr_percentage_delay_ampdu.tr" "a"]
#omit BER and TrafficLoad, put $val(dataRate) in the front of file, to get result for BER and TL $val(BER) $val(PktSize) $val(FRAMELEN) $val(fgLEN) $val(dataRate) $val(appFERReq) $val(trafficload) $val(turnOnAFS)
set f_data [open phyrate_cbr_data_$val(dataRate)_$val(PktSize)_$val(FRAMELEN)_$val(fgLEN)_$val( appFERReq)_$val(turnOnAFS).tr a]
set f_data [open phyrate_cbr_data_Optimal_vs_Adaptive.tr a]
set f_data [open phyrate_cbr_data_BER_vs_AMSDUSize.tr a]
set f_data [open phyrate_cbr_data_test.tr a]

for {set i 0} {$i < $val(nn) } {incr i} {
set mac [$node_($i) getMac 0] ;## get the current mac instance
set throughput($i) [$mac set THRind_]
set totalDelay [$mac set totalDelay_]
set recvNumber [$mac set recvNumber_]
set temp_delay [$mac set peakDelay_]
set totalBER [$mac set totalBER_] ;## for caluculating actual BER increase with TL
set totalBERCounter [$mac set totalBERCounter_]
set averageActualFER [$mac set averageActualFER_]
set averageActualBER [$mac set averageActualBER_]
set peakDelay [expr $peakDelay + $temp_delay]
set percentageDelay [$mac set percentageDelay_] ;## for caluculating percentage delay, percentage is set to MAC previously
set numExceed30ms [$mac set numExceed30ms_]
puts "peak Delay=$temp_delay"

set sum [expr $sum + $throughput($i)]
set squaresum [expr $squaresum+[expr $throughput($i)*$throughput($i)]]
}
##need to move forward
set nominator [expr $sum*$sum]
set denominator [expr $val(nn)*$squaresum]
set fairness [expr $nominator/$denominator]
##for tracing performance in .tr file
set systhroughput [expr $sum/$val(stop)]
set a_delay [expr $totalDelay/$recvNumber]
set a_actual_BER [expr $totalBER/$totalBERCounter] ;## for calculating the average actual BER.
set p_delay [expr $peakDelay/$val(nn)]
set percentageDelay [expr $percentageDelay]


puts "numExceed30ms/recvNumber = $numExceed30ms/$recvNumber"
puts $f_throughput "$val(temp) $systhroughput" ;## temp is data rate
puts $f_a_delay "$val(temp) $a_delay"
puts $f_p_delay "$val(temp) $p_delay"
puts $f_fairness "$val(temp) $fairness"
puts $f_percentage_delay "$val(temp) $percentageDelay $val(percentage)"
# for calculating the actual BER with increase of Traffic Load.
# should remove column 3 $a_actual_BER
puts $f_data "$systhroughput $a_delay $a_actual_BER $p_delay
$percentageDelay $averageActualBER $averageActualFER $val(BER)
$val(OrigPktSize) $val(FRAMELEN) $val(fgLEN) $val(dataRate)
$val(appFERReq) $val(trafficload) $val(turnOnAFS)
$val(percentage)"


puts "The system throughput = [expr $sum/$val(stop)]"
puts -nonewline $f_throughput "[string range [expr $sum/$val(stop)] 0 6] "
puts "The average delay = [expr $totalDelay/$recvNumber]"
puts "The peak delay = [expr $peakDelay/$val(nn)]"
puts "The Percentage delay of $val(percentage) = $percentageDelay"
puts "The fairness = $fairness"
puts "The average actual BER = $averageActualBER"
puts "The average actual FER = $averageActualFER "

close $f_data
close $tracefd
puts -nonewline $f_a_delay "[string range [expr $totalDelay/$recvNumber] 0 6] "
puts -nonewline $f_p_delay "[string range [expr $peakDelay/$val(nn)] 0 6] "
puts -nonewline $f_fairness "[string range $fairness 0 6] "
close $f_throughput
close $f_a_delay
close $f_p_delay
close $f_fairness

close $namtrace

close $f_throughput
close $f_averagedelay
close $f_peakdelay
##exec nam graph
exec nam -r 5m phyrate_cbr.nam &
exit 0
}
# Tell nodes when the simulation ends
#-----------------------------------------------------------------------
$ns_ at $val(stop) "stop"
$ns_ at $val(stop)+1 "$ns_ halt"

# Run ns...
#-----------------------------------------------------------------------
$ns_ run 
