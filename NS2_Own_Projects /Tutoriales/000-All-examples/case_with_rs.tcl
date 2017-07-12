#########################################################################
#
#    This file is part of LWX. 
#
#    LWX is the abbreviation of the Light WiMax simulation program which 
#    is a ns2 WiMAX network simulation module. LWX allows each user to 
#    apply his/her designed scheduling algorithm or other mechanism used 
#    in WiMAX network and generate the corresponding simulation results
#    for further analysis or other non-commercial purposes.
#
#    Copyright (C) 2008 Yen-Hung Cheng (pplong), NTUST in Taiwan, R.O.C.
#    E-Mail: lwx.ns2@gmail.com
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
##########################################################################


# ======================================================================
# Default Script Options
# ======================================================================
set opt(chan)        Channel/WirelessChannel    ;#Channel Type
set opt(prop)        Propagation/TwoRayGround   ;# radio-propagation model
set opt(netif)       Phy/WirelessPhy            ;# network interface type
set opt(mac)         Mac/LWX                    ;# MAC type
set opt(ifq)         Queue/DropTail/PriQueue    ;# interface queue type
set opt(ll)          LL                         ;# link layer type
set opt(ant)         Antenna/OmniAntenna        ;# antenna model
set opt(ifqlen)      50                         ;# max packet in ifq
set opt(nn)          3                          ;# number of mobilenodes
set opt(rp)          AODV                       ;# routing protocol. DSDV, DSR, AODV.
set opt(x)           250                        ;# Topology size
set opt(y)           250                        ;# Topology size
set opt(trace)       wireless_basic.tr          ;# trace file
#set opt(nam.tr)      wireless_basic.nam         ;# the nam trace file

# ======================================================================
# Initialize Global Variables
# ======================================================================

set ns		[new Simulator]

# This command should be called before the universal trace command $ns trace-all 
$ns use-newtrace                                   

#set namtrace [open $opt(nam.tr) w]                    ;# for nam
#$ns namtrace-all-wireless $namtrace $opt(x) $opt(y)   ;# for nam

set tracefd     [open $opt(trace) w]
$ns trace-all $tracefd

proc finish { } {                               ;# new a procedure finish
     global ns namtrace tracefd opt             ;# set global variable 
     $ns flush-trace
     #close $namtrace                           ;# for nam
     close $tracefd                             ;# close file 
     # exec nam $opt(nam.tr) &                  ;# for nam
     exit 0
}


# set up topography object
set topo       [new Topography]
$topo load_flatgrid $opt(x) $opt(y)

# Create God
create-god $opt(nn)

# Create channel
set chan_ [new $opt(chan)]

# Create node(0) and node(1)

# configure node, please note the change below.
$ns node-config -adhocRouting $opt(rp) \
		-llType $opt(ll) \
		-macType $opt(mac) \
		-ifqType $opt(ifq) \
		-ifqLen $opt(ifqlen) \
		-antType $opt(ant) \
		-propType $opt(prop) \
		-phyType $opt(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace OFF \
		-macTrace OFF \
		-movementTrace OFF \
		-channel $chan_


# ======================================================================
# Set Bandwidth Allocation Algorithm Type
# 0: test
# 1: Round Robin
# 2: Strict Priority
# 101: RR for Relay
# ======================================================================

Mac/LWX env BWA_Algorithm_Type   101

# ======================================================================
# adding nodes
# ======================================================================

set node_id(0)     0
set node(0)        [$ns node]
$node(0) random-motion 0
$ns initial_node_pos $node(0) 20
$node(0) set X_ 15.0
$node(0) set Y_ 15.0
$node(0) set Z_ 0.0
$node(0) nodeid $node_id(0)
Mac/LWX env add_bs node_id $node_id(0)

set node_id(1)     1
set node(1)        [$ns node]
$node(1) random-motion 0
$ns initial_node_pos $node(1) 20
$node(1) set X_ 16.0
$node(1) set Y_ 16.0
$node(1) set Z_ 0.0
$node(1) nodeid $node_id(1)
Mac/LWX env add_rs node_id $node_id(1) bs_node_id $node_id(0)

set node_id(2)     101
set node(2)        [$ns node]
$node(2) random-motion 0
$ns initial_node_pos $node(2) 20
$node(2) set X_ 17.0
$node(2) set Y_ 17.0
$node(2) set Z_ 0.0
$node(2) nodeid $node_id(2)
Mac/LWX env add_ss node_id $node_id(2) bs_node_id $node_id(0)

set node_id(3)     2
set node(3)        [$ns node]
$node(3) random-motion 0
$ns initial_node_pos $node(3) 20
$node(3) set X_ 18.0
$node(3) set Y_ 18.0
$node(3) set Z_ 0.0
$node(3) nodeid $node_id(3)
Mac/LWX env add_rs node_id $node_id(3) bs_node_id $node_id(0)

set node_id(4)     102
set node(4)        [$ns node]
$node(4) random-motion 0
$ns initial_node_pos $node(4) 20
$node(4) set X_ 17.0
$node(4) set Y_ 17.0
$node(4) set Z_ 0.0
$node(4) nodeid $node_id(4)
Mac/LWX env add_ss node_id $node_id(4) bs_node_id $node_id(0)

# ======================================================================
# adding downlink flows
# ======================================================================

#########################################
# UDP connections from node(0) to node(1)
######################################### 

# udp
set udp_(0) [new Agent/UDP]
$ns attach-agent  $node(0)  $udp_(0)
set null_(0)  [new Agent/Null]
$ns attach-agent  $node(2)  $null_(0)

# cbr
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 200
$cbr_(0) set rate_       5000000
$cbr_(0) set random_     0
$cbr_(0) attach-agent $udp_(0)
$ns connect $udp_(0) $null_(0)

# wimax
# bs->ss
# init env var
set flow_info     [$udp_(0) flow_info]
set src_nid       $node_id(0)
set from_nid      $node_id(0)
set to_nid        $node_id(2)

# add flow
# Mac/LWX env add_flow <type> $src_nid $from_nid $to_nid $flow_info
# type: bs_to_ss, ss_to_bs, rs_to_bs, rs_to_ss

Mac/LWX env add_flow bs_to_ss $src_nid $from_nid $to_nid $flow_info

# set flow attribute
# Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info <type> <value>
# type: rate(byte), QoS_Class (1~5), Rmin(bps), Rmax(bps), Lmax(ms), Jitter(ms)

Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info rate       2
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info QoS_Class  2
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Rmin       500000
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Rmax       6000000
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Lmax       60
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Jitter     45

# adding this flow's relay link
# Mac/LWX env set_relay <type> $src_nid $flow_info $rs_nid rate $relay_rate
Mac/LWX env set_relay bs_to_rs $src_nid $flow_info $node_id(1) rate 27


# adding relay link from rs to bs
# relay link 1
Mac/LWX env add_flow rs_to_ss_tp $src_nid $node_id(1) $to_nid $flow_info
Mac/LWX env set_flow $src_nid $node_id(1) $to_nid $flow_info rate       27
Mac/LWX env set_flow $src_nid $node_id(1) $to_nid $flow_info QoS_Class  2
Mac/LWX env set_flow $src_nid $node_id(1) $to_nid $flow_info Rmin       500000
Mac/LWX env set_flow $src_nid $node_id(1) $to_nid $flow_info Rmax       6000000
Mac/LWX env set_flow $src_nid $node_id(1) $to_nid $flow_info Lmax       60
Mac/LWX env set_flow $src_nid $node_id(1) $to_nid $flow_info Jitter     45


$ns at 0.50 "$cbr_(0) start"
$ns at 3.00 "$cbr_(0) stop"


# ======================================================================
# adding uplink flows
# ======================================================================


#########################################
# UDP connections from node(0) to node(1)
######################################### 

# udp
set udp_(1) [new Agent/UDP]
$ns attach-agent  $node(4)  $udp_(1)
set null_(1)  [new Agent/Null]
$ns attach-agent  $node(0)  $null_(1)

# cbr
set cbr_(1) [new Application/Traffic/CBR]
$cbr_(1) set packetSize_ 200
$cbr_(1) set rate_       4000000
$cbr_(1) set random_     0
$cbr_(1) attach-agent $udp_(1)
$ns connect $udp_(1) $null_(1)

# wimax
# bs->ss
# init env var
set flow_info     [$udp_(1) flow_info]
set src_nid       $node_id(4)
set from_nid      $node_id(4)
set to_nid        $node_id(0)

# add flow
# Mac/LWX env add_flow <type> $src_nid $from_nid $to_nid $flow_info
# type: bs_to_ss, ss_to_bs, rs_to_bs, rs_to_ss

Mac/LWX env add_flow ss_to_bs $src_nid $from_nid $to_nid $flow_info

# set flow attribute
# Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info <type> <value>
# type: rate(byte), QoS_Class (1~5), Rmin(bps), Rmax(bps), Lmax(ms), Jitter(ms)

Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info rate       2
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info QoS_Class  2
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Rmin       500000
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Rmax       5000000
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Lmax       60
Mac/LWX env set_flow $src_nid $from_nid $to_nid $flow_info Jitter     45

# adding this flow's relay link
# Mac/LWX env set_relay <type> $src_nid $flow_info $rs_nid rate $relay_rate
Mac/LWX env set_relay ss_to_rs_tp $src_nid $flow_info $node_id(3) rate 27


# adding relay link from rs to bs
# relay link 2
Mac/LWX env add_flow rs_to_bs $src_nid $node_id(3) $to_nid $flow_info
Mac/LWX env set_flow $src_nid $node_id(3) $to_nid $flow_info rate       27
Mac/LWX env set_flow $src_nid $node_id(3) $to_nid $flow_info QoS_Class  2
Mac/LWX env set_flow $src_nid $node_id(3) $to_nid $flow_info Rmin       500000
Mac/LWX env set_flow $src_nid $node_id(3) $to_nid $flow_info Rmax       5000000
Mac/LWX env set_flow $src_nid $node_id(3) $to_nid $flow_info Lmax       60
Mac/LWX env set_flow $src_nid $node_id(3) $to_nid $flow_info Jitter     45


$ns at 0.50 "$cbr_(1) start"
$ns at 3.00 "$cbr_(1) stop"


# ======================================================================
# commmend mac
# ======================================================================


puts [$udp_(0) flow_info]
puts [$udp_(1) flow_info]

#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $opt(nn) } {incr i} {
    $ns at 10.0 "$node($i) reset";
}
$ns at 10.0 "finish"
$ns at 10.01 "puts \"NS EXITING...\" ; $ns halt"

puts "Starting Simulation..."
$ns run
