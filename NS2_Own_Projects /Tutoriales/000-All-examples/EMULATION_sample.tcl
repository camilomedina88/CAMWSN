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
# This script allows two nodes (one transmitter and one receiver) to communicate in the EMULATION setting. 
# The adopted hardware must be indicated by the user: run EMULATION_sample to display the parameter legend and corresponding usage.
# NOTE: Control the device connection ports (set in the "Tcl variable" section)!
#
# STACK adopted in this sample: UWCBR/UWUDP/UWstaticROUTING/UWIP/UWMLL/ALOHA/MODEM (MFSK_WHOI_MM or MS2C_EvoLogics)
# 
# In the case of the FSK WHOI MM we have the following: 
# Two nodes each with a MFSK_WHOI_MM: public UWMPhy_modem module for each node,
# i.e., a module that do UW network _EMULATION with the FSK WHOI micromodem as follows:
# 1) a- write a Packet* to a given diskfile as a SendDown() and send the corresponding line in the
#       payload of a NMEA minipacket ($CCMUC message); 
#    b- read the payload of an incoming NMEA minipacket ($CAMUA message), extract the indication of
#       the diskfile's line where to read the Packet* address and send this to the upper layers via 
#       SendUp().
#
#	+-----------------------+	                        +-----------------------+
#	|    7.  UWCBR  (tx)    |------------------------------>|      7. UWCBR(rx)     |
#	+-----------------------+	                        +-----------------------+
#	|       6. UWUDP        |                               |       6. UWUDP        |
#	+-----------------------+	                        +-----------------------+
#	|  5. UWstaticROUTING   |                               |  5. UWstaticROUTING   |
#	+-----------------------+	                        +-----------------------+
#	|       4. UWIP         |                               |       4. UWIP         |
#	+-----------------------+	                        +-----------------------+
#	|       3. UWMLL        |                               |       3. UWMLL        |
#	+-----------------------+                               +-----------------------+
#	|     2.   ALOHA        |                               |    2.    ALOHA        |
#	+-----------------------+	                        +-----------------------+
#	|  1. MFSK_WHOI_MM      |                               |  1. MFSK_WHOI_MM      |
#	+-----------------------+	                        +-----------------------+
#         |          ^        |                                   |       ^        |
#         v          |        |_____ real UW acoustic channel_____|       |        v    
#    disk_file1   disk_file2                                         diskfile1  diskfile2
#
#
# In the case of the S2C modem we have the following: 
# Two nodes each with a S2C_EvoLogics: public UWMPhy_modem module,
# i.e., a module that do UW network _EMULATION with the S2C EvoLogics acoustic modem as follows:
# 1) a- write a Packet* to the <data> field of an instant message (AT command: AT*SENDIM)
#    b- read the payload of an incoming instant message (AT message: RECVIM), extract the indication of the NS-miracle Packet* addres
#       and send this to the upper layers via SendUp().
#
#	+-----------------------+	                        +-----------------------+
#	|    7.  UWCBR  (tx)    |------------------------------>|      7. UWCBR(rx)     |
#	+-----------------------+	                        +-----------------------+
#	|       6. UWUDP        |                               |       6. UWUDP        |
#	+-----------------------+	                        +-----------------------+
#	|  5. UWstaticROUTING   |                               |  5. UWstaticROUTING   |
#	+-----------------------+	                        +-----------------------+
#	|       4. UWIP         |                               |       4. UWIP         |
#	+-----------------------+	                        +-----------------------+
#	|       3. UWMLL        |                               |       3. UWMLL        |
#	+-----------------------+                               +-----------------------+
#	|     2.   ALOHA        |                               |    2.    ALOHA        |
#	+-----------------------+	                        +-----------------------+
#	|  1. MS2C_EvoLogics    |                               |  1. MS2C_EvoLogics    |
#	+-----------------------+	                        +-----------------------+
#                             |                                   | 
#                             |_____ real UW acoustic channel_____|   
#
#
# Author: Riccardo Masiero
# Version: 1.0.0
# NOTE: tcl sample tested on Ubuntu 12.04, 64 bits OS
#
# NOTE: Concerning the PSK modem, this sample has not been tested because we was not equipped with the PSK hardware after the 
#       preparation of this script.
#       If you try it, your feedback would be much appreciated (you can write to Matteo Petrani - petranim@dei.unipd.it and/or 
#       to Riccardo Masiero - masieror@dei.unipd.it)    


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
if {$argc != 1} {
  puts "The exp1.tcl script wants 1 inputs to determine the hardware in use:"
  puts "- 1 for the FSK WHOI Micro-Modem "
  puts "- 2 for the PSK WHOI Micro-Modem "
  puts "- 3 for the S2C EvoLogics hydro-acoustic modem "
  puts "For example: ns EMULATION_sample.tcl 1"
  puts "Please try again."
  return
} else {
  set opt(start) 0
  set opt(stop) 15
  set opt(modem) [lindex $argv 0]
  set opt(tr_file_name) "EMULATION_test"
}

if {$opt(modem) != 1 && $opt(modem) != 3} {
   puts "WARNING: wrong input parameters. Modem unkown."
   return
}

#Serial Paths to be used
set serial_path(1) "/dev/ttyUSB0"
set serial_path(2) "/dev/ttyUSB1"
set serial_path(3) "/dev/ttyUSB2"

#Socket Ports to be used
set socket_port(1) "9200"
set socket_port(2) "9201"
set socket_port(3) "9202"

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
Module/UW/MPhy_modem/FSK_WHOI_MM set setting_ 0
Module/UW/MPhy_modem/FSK_WHOI_MM set stack_ 0
Module/UW/MPhy_modem/FSK_WHOI_MM set show_ 1
Module/UW/MPhy_modem/FSK_WHOI_MM set debug_ 0

# variables for the PSK WHOI modem's interface
Module/UW/MPhy_modem/PSK_WHOI_MM set period_ 1
Module/UW/MPhy_modem/PSK_WHOI_MM set setting_ 0
Module/UW/MPhy_modem/PSK_WHOI_MM set stack_ 0
Module/UW/MPhy_modem/PSK_WHOI_MM set show_ 1
Module/UW/MPhy_modem/PSK_WHOI_MM set packet_rate_ 4
Module/UW/MPhy_modem/PSK_WHOI_MM set debug_ 0

# variables for the S2C modem's interface
Module/UW/MPhy_modem/S2C set period_ 1
Module/UW/MPhy_modem/S2C set setting_ 0
Module/UW/MPhy_modem/S2C set stack_ 0
Module/UW/MPhy_modem/S2C set show_ 1
Module/UW/MPhy_modem/S2C set debug_ 0


################################
# Procedure(s) to create nodes #
################################
# Define here one or more procedures that allow you to create as many different kind of nodes
proc createNode { id } {
    
    # include all the global variable you are going to use inside this procedure
    global ns opt serial_path socket_port node_ app_ transport_ port_ routing_ ipif_ mll_ mac_ modem_
    
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
        set modem_($id) [new "Module/UW/MPhy_modem/FSK_WHOI_MM" $serial_path($id)]    
    } elseif {$opt(modem) == 2} {
        set modem_($id) [new "Module/UW/MPhy_modem/PSK_WHOI_MM" $serial_path($id)]    
    } else {
        set modem_($id) [new "Module/UW/MPhy_modem/S2C" $socket_port($id)]
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
createNode 2
puts "node 2 created!"

################################
# Inter-node module connection #
################################
# Put here all the commands required to connect nodes in the network (optional), namely, specify end to end connections, fill ARP tables, define routing settings

# connections at the application level
$app_(1) set destAddr_ [$ipif_(2) addr]
$app_(1) set destPort_ $port_(2)

# connections at the network layer
# addRoute (destination, mask, next hop)
$routing_(1) addRoute [$ipif_(2) addr-string] "255.255.255.255" [$ipif_(2) addr-string]

# connection at the data link layer
# $mll($id1) addentry [$ipif($id2) addr] [$mac($id2) addr]
$mll_(1) addentry [$ipif_(2) addr] [$mac_(2) addr]
$mll_(2) addentry [$ipif_(1) addr] [$mac_(1) addr]


#####################
# Start/Stop Timers #
#####################
# Set here the timers to start and/or stop modules (optional)
# e.g., 

$ns at 0 "$modem_(1) start"
$ns at 0 "$modem_(2) start"

$ns at $opt(start) "$app_(1) start"
$ns at $opt(stop) "$app_(1) stop"

$ns at $time_stop "$modem_(1) stop"
$ns at $time_stop "$modem_(2) stop"

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
