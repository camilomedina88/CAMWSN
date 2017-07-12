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
# This script allows us to create a transmitter node for the TESTBED setting. 
# The adopted hardware and connection port must be indicated by the user: run TESTBED_n1_sample to display the parameter legend and corresponding usage.
#
# STACK adopted in this sample: UWCBR/UWUDP/UWstaticROUTING/UWIP/UWMLL/ALOHA/MODEM (MFSK_WHOI_MM, MPSK_WHOI_MM or MS2C_EvoLogics)
# 
#
#	+-----------------------+	                        
#	|    7.  UWCBR  (tx)    |------------------------------>                               
#	+-----------------------+	                        
#	|       6. UWUDP        |                               
#	+-----------------------+	                        
#	|  5. UWstaticROUTING   |                               
#	+-----------------------+	                        
#	|       4. UWIP         |                               
#	+-----------------------+	                        
#	|       3. UWMLL        |                               
#	+-----------------------+                               
#	|     2.   ALOHA        |                               
#	+-----------------------+	                       	
#	|       1. MODEM        |                               
#	+-----------------------+	                       	
#               |                                 
#               +----real UW acoustic channel--->
#
#
#
# Author: Riccardo Masiero
# Version: 1.0.0
# NOTE: tcl sample tested on Ubuntu 12.04, 64 bits OS
#
# NOTE: Concerning the PSK modem, this sample has not been tested because we was not equipped with the PSK hardware after the 
#       preparation of this script.
#       If you try it, your feedback would be much appreciated (you can write to Matteo Petrani - petranim@dei.unipd.it and/or 
#       to Masiero Riccardo - masieror@dei.unipd.it)    

######################
# Simulation Options #
######################
# Put here flags to enable or disable high level options for the simulation setup (optional)

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
load libuwudp.so
load libuwcbr.so
load libuwvbr.so
load libuwcbrtracer.so
load libuwmphy_modem.so
load libmfsk_whoi_mm.so
load libmpsk_whoi_mm.so
load libmstwoc_evologics.so

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
if {$argc != 2} {
  puts "The exp1.tcl script wants 2 inputs to determine the hardware in use:"
  puts "- Arg 1: modem:"
  puts "       - 1 for the FSK WHOI Micro-Modem "
  puts "       - 2 for the PSK WHOI Micro-Modem "
  puts "       - 3 for the S2C EvoLogics hydro-acoustic modem "

  puts "- Arg 2: path to the device "
  puts ""
  puts "For example: ns TESTBED_n1_sample.tcl 1 /dev/ttyUSB0"
  puts "Please try again."
  return
} else {
  set opt(start) 0
  set opt(stop) 15
  set opt(modem) [lindex $argv 0]
  set opt(path_to_dev) [lindex $argv 1]
  set opt(tr_file_name) "TESTBED_n1_test"
}

if {$opt(modem) != 1 && $opt(modem) != 2 && $opt(modem) != 3} {
   puts "WARNING: wrong input parameters. Modem unkown."
   return
}

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

#MAC addresses of interest
set adrMAC1 1
set adrMAC2 2

#Connection port (NOTE: since the receiver as a single application, its port is equal to 1)
set RXport 1

# time when actually to stop the simulation
set time_stop [expr "$opt(stop)+5"]

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
Module/UW/CBR set period_              4
Module/UW/CBR set PoissonTraffic_      0

# variables for the FSK WHOI modem's interface
Module/UW/MPhy_modem/FSK_WHOI_MM set period_ 1
Module/UW/MPhy_modem/FSK_WHOI_MM set setting_ 1
Module/UW/MPhy_modem/FSK_WHOI_MM set stack_ 1
Module/UW/MPhy_modem/FSK_WHOI_MM set show_ 1
Module/UW/MPhy_modem/FSK_WHOI_MM set debug_ 0

# variables for the PSK WHOI modem's interface
Module/UW/MPhy_modem/PSK_WHOI_MM set period_ 1
Module/UW/MPhy_modem/PSK_WHOI_MM set setting_ 0
Module/UW/MPhy_modem/PSK_WHOI_MM set stack_ 0
Module/UW/MPhy_modem/PSK_WHOI_MM set show_ 1
Module/UW/MPhy_modem/PSK_WHOI_MM set packet_rate_ 0
Module/UW/MPhy_modem/PSK_WHOI_MM set debug_ 0


# variables for the S2C modem's interface
Module/UW/MPhy_modem/S2C set period_ 1
Module/UW/MPhy_modem/S2C set setting_ 1
Module/UW/MPhy_modem/S2C set stack_ 1
Module/UW/MPhy_modem/S2C set show_ 1
Module/UW/MPhy_modem/S2C set debug_ 0


################################
# Procedure(s) to create nodes #
################################
# Define here one or more procedures that allow you to create as many different kind of nodes
proc createNode { id } {
    
    # include all the global variable you are going to use inside this procedure
    global ns opt node_ app_ transport_ port_ routing_ ipif_ mll_ mac_ modem_
    
    # build the NS-Miracle node
    set node_($id) [$ns create-M_Node]

    # define the module(s) you want to put in the node
    # APPLICATION LAYER
    set app_($id) [new Module/UW/CBR]
    
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
    set mac_($id) [new Module/UW/ALOHA]

    # PHY LAYER
    if {$opt(modem) == 1} {
        set modem_($id) [new "Module/UW/MPhy_modem/FSK_WHOI_MM" $opt(path_to_dev)]    
    } elseif {$opt(modem) == 2} {
        set modem_($id) [new "Module/UW/MPhy_modem/PSK_WHOI_MM" $opt(path_to_dev)]    
    } else {
        set modem_($id) [new "Module/UW/MPhy_modem/S2C" $opt(path_to_dev)]
    }
    
    # insert the module(s) into the node
    $node_($id) addModule 7 $app_($id) 1 "CBR"
    $node_($id) addModule 6 $transport_($id) 1 "UDP"
    $node_($id) addModule 5 $routing_($id) 1 "IPR"
    $node_($id) addModule 4 $ipif_($id) 1 "IPIF"
    $node_($id) addModule 3 $mll_($id) 1 "ARP TABLES"
    $node_($id) addModule 2 $mac_($id) 1 "ALOHA"
    if {$opt(modem) == 1} {
        $node_($id) addModule 1 $modem_($id) 1 "FSK MODEM" 
    } else {
        $node_($id) addModule 1 $modem_($id) 1 "S2C MODEM"
    } 
    
    # intra-node module connections (if needed)
    $node_($id) setConnection $app_($id) $transport_($id) trace
    $node_($id) setConnection $transport_($id) $routing_($id) trace
    $node_($id) setConnection $routing_($id) $ipif_($id) trace
    $node_($id) setConnection $ipif_($id) $mll_($id) trace
    $node_($id) setConnection $mll_($id) $mac_($id) trace
    $node_($id) setConnection $mac_($id) $modem_($id) trace
    
    # set module and node parameters (optional)
    
    # assign a port number to the application considered (CBR or VBR)
    set port_($id) [$transport_($id) assignPort $app_($id)]

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
createNode 1
puts "node 1 created!"
puts  "IP address: [$ipif_(1) addr-string] equals to [$ipif_(1) addr]"
puts  "MAC address: [$mac_(1) addr]"


################################
# Inter-node module connection #
################################
# Put here all the commands required to connect nodes in the network (optional), namely, specify end to end connections, fill ARP tables, define routing settings

# connections at the application level
$app_(1) set destAddr_ [ip2int 1.0.0.2]
$app_(1) set destPort_ $RXport

# connections at the network layer
# addRoute (destination, mask, next hop)
$routing_(1) addRoute "1.0.0.2" "255.255.255.255" "1.0.0.2"

# connection at the data link layer
# $mll($id1) addentry [$ipif($id2) addr] [$mac($id2) addr]
$mll_(1) addentry $adrIP2 $adrMAC2

#####################
# Start/Stop Timers #
#####################
# Set here the timers to start and/or stop modules (optional)
# e.g., 

$ns at 0 "$modem_(1) start"
     
$ns at $opt(start) "$app_(1) start"
$ns at $opt(stop) "$app_(1) stop"

$ns at $time_stop "$modem_(1) stop"

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
