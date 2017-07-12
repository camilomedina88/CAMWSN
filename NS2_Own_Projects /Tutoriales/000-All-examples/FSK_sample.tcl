#
# Copyright (c) 2012 Regents of the SIGNET lab, University of Padova.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the University of Padova (SIGNET lab) nor the 
#    names of its contributors may be used to endorse or promote products 
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# This script allows one host to command a single FSK WHOI MM exploiting the mFSK_WHOI_MM: public UWMPhy_modem module, in the TESTBED setting. 
# Each node can act as a transmitter/receiver or just as a rely (set input parameter accordingly: run FSK_sample to display the parameter legend and corresponding usage).
# STACKS that can be tested with this script (set the simulation option flags "stack", "" accordingly):
# 1- UWCBR+UWVBR/UWUDP/UWstaticROUTING/UWIP/UWMLL/UWALOHA
# 2- UWCBR+UWVBR/UWUDP/UWstaticROUTING/UWIP/UWMLL/UWALOHA-CSMA
# Among the possible network configuration that can be realized running this script in (up to three) independent hosts, there are:
# TX (source) -> RX (sink)
# TX (source) -> RELAY -> RX (sink)
# TX (CBR source) -> RX (sink) <- TX (VBR source)
# use main_sample.sh to quick run them (with third input parameter "FSK")
#
# Author: Riccardo Masiero
# Version: 1.0.0
# NOTE: tcl sample tested on Ubuntu 12.04, 64 bits OS
#
######################
# Simulation Options #
######################
# Put here flags to enable or disable high level options for the simulation setup (optional)
set opt(stack)    1

if {$opt(stack) < 1 || $opt(stack) > 2} {
   puts "WARNING: stack must be in the set {1,2,3,4}. Legend: "
   puts "-1: UWCBR+UWVBR/UWUDP/UWstaticROUTING/UWIP/UWMLL/UWALOHA"
   puts "-2: UWCBR+UWVBR/UWUDP/UWstaticROUTING/UWIP/UWMLL/UWALOHA-CSMA"
   return
}

#####################
# Library Loading   #
#####################
# Load here all the NS-Miracle libraries you need
# e.g.,
load libMiracle.so
load libmphy.so
load libuwip.so
load libuwmll.so
load libuwstaticrouting.so
load libuwaloha.so
load libuwcsmaaloha.so
load libuwudp.so
load libuwcbr.so
load libuwvbr.so
load libuwcbrtracer.so
load libuwmphy_modem.so
load libmfsk_whoi_mm.so

#############################
# NS-Miracle initialization #
#############################
# You always need the following two lines to use the NS-Miracle simulator
set ns [new Simulator]
$ns use-Miracle

#Declare the use of a Real Time Schedule (necessary for the interfacing with real hardware)
$ns use-scheduler RealTime

##################
# Tcl variables  #
##################
# Put here all the tcl variables you need for simulation management (optional), namely, values for the binded variables, location parameters, module configuration's parameters, ...

# Terminal's parameter check
if {$argc != 9} {
  puts "The exp1.tcl script wants 9 inputs to determine the node's role in the network:"
  puts "- 0: node (1, 2 or 3. WARNING: This parameter determines also the serial port). See the Tcl varible serial_path. "
  puts "- 1: transmitter (1-2), relay (3), receiver (4 or default) "
  puts "- 2: start (sec)"
  puts "- 3: stop  (sec)"
  puts "- 5: connect to node (0, 1, 2, 3. Cannot be equal to node)"
  puts "- 6: port associated with the first connection (1, 2)"
  puts "- 7: connect to node (0, 1, 2, 3. Cannot be equal to node)"
  puts "- 8: port associated with the second connection (1, 2)"
  puts "- 9: name of the file where to save traces"
  puts "For example: ns FSK_sample.tcl 1 1 0 8 2 1 0 1 FSK_sample-test"
  puts "Please try again."
  return
} else {
  set opt(node) [lindex $argv 0]
  set opt(role) [lindex $argv 1]
  set opt(start) [lindex $argv 2]
  set opt(stop) [lindex $argv 3]
  set opt(conn1) [lindex $argv 4]
  set opt(port1) [lindex $argv 5]
  set opt(conn2) [lindex $argv 6]
  set opt(port2) [lindex $argv 7]
  set opt(tr_file_name) [lindex $argv 8]
}

if {$opt(node) < 1 || $opt(node) > 3} {
   puts "WARNING: Node ID must be in the set {1,2,3}."
   return
}

if {$opt(conn1) < 0 || $opt(conn2) < 0 || $opt(conn1) > 3 || $opt(conn2) > 3} {
   puts "WARNING: Node ID must be in the set {1,2,3}. Problem with the ID specification of the node to get connected."
   return
}


if {$opt(conn1) == $opt(node) || $opt(conn2) == $opt(node)} {
   puts "WARNING: wrong input parameters. Node cannot transmit to itself."
   return
}

if {$opt(port1) < 1 || $opt(port2) < 1 || $opt(port1) > 2 || $opt(port2) > 2} {
   puts "WARNING: Port must be in the set {1,2}."
   return
}

#Serial Paths to be used
set serial_path(1) "/dev/ttyUSB0"
set serial_path(2) "/dev/ttyUSB1"
set serial_path(3) "/dev/ttyUSB2"

#Procedures to convert IP addresses (credits to: Maksym Komar, EvoLogics)
proc ip2int {str} {
   binary scan [binary format c4 [split $str .]] I ip
   return $ip
}

proc int2ip {ip} {
   binary scan [binary format I $ip] c4 ip
   return [join $ip .]
}

#IP addresses of interest
set adrIP1 [ip2int 1.0.0.1]
set adrIP2 [ip2int 1.0.0.2]
set adrIP3 [ip2int 1.0.0.3]

#MAC addresses of interest
set adrMAC1 1
set adrMAC2 2
set adrMAC3 3

# time when actually to stop the simulation
set time_stop [expr "$opt(stop)+15"]

#Trace file name
set tf_name "${opt(tr_file_name)}.tr"

#Open a file for writing the trace data
set tf [open $tf_name w]
$ns trace-all $tf

#########################
# Module Configuration  #
#########################
# Put here all the commands to set globally the initialization values of the binded variables (optional)

# variables for the CBR module
Module/UW/CBR set packetSize_          13
Module/UW/CBR set period_              4
Module/UW/CBR set PoissonTraffic_      0

# variables for the VBR module
Module/UW/VBR set packetSize_          13
Module/UW/VBR set period1_             4
Module/UW/VBR set period2_             8
Module/UW/VBR set timer_switch_1_      30
Module/UW/VBR set timer_switch_2_      60
Module/UW/VBR set PoissonTraffic_      0

# variables for the ALOHA-CSMA module
Module/UW/ALOHA set debug_          0

# variables for the ALOHA-CSMA module
Module/UW/CSMA_ALOHA set debug_        0
Module/UW/CSMA_ALOHA set listen_time_  1

# variables for the  FSK WHOI modem's interface
Module/UW/MPhy_modem/FSK_WHOI_MM set period_ 1
Module/UW/MPhy_modem/FSK_WHOI_MM set setting_ 1
Module/UW/MPhy_modem/FSK_WHOI_MM set stack_ 1
Module/UW/MPhy_modem/FSK_WHOI_MM set show_ 1
Module/UW/MPhy_modem/FSK_WHOI_MM set debug_ 0

################################
# Procedure(s) to create nodes #
################################
# Define here one or more procedures that allow you to create as many different kind of nodes
proc createNode { id } {
    
    # include all the global variable you are going to use inside this procedure
    global ns opt serial_path node_ app_ transport_ port_ routing_ ipif_ mll_ mac_ modem_
    
    # build the NS-Miracle node
    set node_($id) [$ns create-M_Node]

    # define the module(s) you want to put in the node
    # APPLICATION LAYER
    set app_(1) [new Module/UW/CBR]
    set app_(2) [new Module/UW/VBR]
    
    # TRANSPORT LAYER
    set transport_($id) [new Module/UW/UDP]

    # NETWORK LAYER
    # Static Routing
    set routing_($id) [new Module/UW/StaticRouting]
	
    # IP interface
    set ipif_($id) [new Module/UW/IP]
	
    # DATA LINK LAYER - MEDIA LINK LAYER
    set mll_($id) [new Module/UW/MLL]
    
    # DATA LINK LAYER - MAC LAYER
    if {$opt(stack) == 1} {
       set mac_($id) [new Module/UW/ALOHA]
     } else {
       set mac_($id) [new Module/UW/CSMA_ALOHA]
    }

    # PHY LAYER
    set modem_($id) [new "Module/UW/MPhy_modem/FSK_WHOI_MM" $serial_path($id)]    
    
    # insert the module(s) into the node
    $node_($id) addModule 7 $app_(1) 1 "CBR"
    $node_($id) addModule 7 $app_(2) 1 "VBR"
    $node_($id) addModule 6 $transport_($id) 1 "UDP"
    $node_($id) addModule 5 $routing_($id) 1 "IPR"
    $node_($id) addModule 4 $ipif_($id) 1 "IPIF"
    $node_($id) addModule 3 $mll_($id) 1 "ARP TABLES"
    if {$opt(stack) == 1} {
        $node_($id) addModule 2 $mac_($id) 1 "ALOHA"
    } else {
        $node_($id) addModule 2 $mac_($id) 1 "ALOHA-CSMA"
        
    }
    $node_($id) addModule 1 $modem_($id) 1 "FSK MODEM" 
    
    # intra-node module connections (if needed)
    $node_($id) setConnection $app_(1) $transport_($id) trace
    $node_($id) setConnection $app_(2) $transport_($id) trace
    $node_($id) setConnection $transport_($id) $routing_($id) trace
    $node_($id) setConnection $routing_($id) $ipif_($id) trace
    $node_($id) setConnection $ipif_($id) $mll_($id) trace
    $node_($id) setConnection $mll_($id) $mac_($id) trace
    $node_($id) setConnection $mac_($id) $modem_($id) trace
    
    # set module and node parameters (optional)
    
    # assign a port number to the application considered (CBR or VBR)
    set port_(1) [$transport_($id) assignPort $app_(1)]
    set port_(2) [$transport_($id) assignPort $app_(2)]
    # set IP, MAC and modem ID
    $ipif_($id) addr "1.0.0.${id}"
    $mac_($id) setMacAddr $id
    $mac_($id) setNoAckMode
    $modem_($id) set ID_ $id

    # initialize node's modules (if needed)
    
    # add node positions (optional)  
}

#################
# Node Creation #
#################
# Create here all the nodes you want to network together
createNode $opt(node)

puts "node $opt(node) created!"
puts "CBR - port1: $port_(1)"
puts "VBR - port2: $port_(2)"
puts  "IP address: [$ipif_($opt(node)) addr-string] equals to [$ipif_($opt(node)) addr]"
puts  "MAC address: [$mac_($opt(node)) addr]"

################################
# Inter-node module connection #
################################
# Put here all the commands required to connect nodes in the network (optional), namely, specify end to end connections, fill ARP tables, define routing settings

# connections at the application level
if {$opt(conn1) > 0} {
    $app_(1) set destAddr_ [ip2int 1.0.0.$opt(conn1)] 
    $app_(1) set destPort_ $opt(port1)
}

if {$opt(conn2) > 0} {
   $app_(2) set destAddr_ [ip2int 1.0.0.$opt(conn2)] 
   $app_(2) set destPort_ $opt(port2)   
}

# connections at the network layer
# addRoute (destination, mask, next hop)
if {$opt(role) == 2} { 
# transmitter with relay
  $routing_($opt(node)) addRoute "1.0.0.1" "255.255.255.255" "1.0.0.2"
  $routing_($opt(node)) addRoute "1.0.0.3" "255.255.255.255" "1.0.0.2"
} elseif {$opt(role) != 4} {
# all to all communication available
   $routing_($opt(node)) addRoute "1.0.0.1" "255.255.255.255" "1.0.0.1"
   $routing_($opt(node)) addRoute "1.0.0.2" "255.255.255.255" "1.0.0.2"
   $routing_($opt(node)) addRoute "1.0.0.3" "255.255.255.255" "1.0.0.3"
}

# connection at the data link layer
# $mll($id1) addentry [$ipif($id2) addr] [$mac($id2) addr]
$mll_($opt(node)) addentry $adrIP1 $adrMAC1
$mll_($opt(node)) addentry $adrIP2 $adrMAC2
$mll_($opt(node)) addentry $adrIP3 $adrMAC3


#####################
# Start/Stop Timers #
#####################
# Set here the timers to start and/or stop modules (optional)
# e.g., 

$ns at 0 "$modem_($opt(node)) start"
      
    if {$opt(role) == 1 || $opt(role) == 2} {
        if {$opt(conn1) > 0} {
           $ns at $opt(start) "$app_(1) start"
           $ns at $opt(stop) "$app_(1) stop"
        }
        if {$opt(conn2) > 0} {
           $ns at $opt(start) "$app_(2) start"        
           $ns at $opt(stop) "$app_(2) stop"
        }
    }

$ns at $time_stop "$modem_($opt(node)) stop"

###################
# Final Procedure #
###################
# Define here the procedure to call at the end of the simulation
proc finish {} {
   
   global ns tf tf_name	
   # computation of the statics

   # display messages
   puts "done!"
   puts "tracefile: $tf_name"

   # save traces
   $ns flush-trace
   
   # close files
   close $tf
}

##################
# Run simulation #
##################
# Specify the time at which to call the finish procedure and halt ns
$ns at $time_stop "finish; $ns halt"

# You always need the following line to run the NS-Miracle simulator
$ns run
