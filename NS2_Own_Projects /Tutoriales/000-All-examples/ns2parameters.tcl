# Copyright (c) 2009 Rice University.
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
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE UNIVERSITY OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# Scripts for RI-MAC simulation. Created by Yanjun in the Monarch group 
# of Rice University, 2009
#

# default system pamaters
set opt(radioBW)	2.5e5 ; # 250 kbps
Agent/UDP set packetSize_ 2000;				# prevent fragmentation in CBR

set opt(RTSThreshold) 		2000
set opt(CSThresh) 			[Phy/WirelessPhy set CSThresh_]
set opt(RXThresh) 			[Phy/WirelessPhy set RXThresh_]
set opt(CWMin) 				31 ;# 7; 2^3-1 802.15.4 spec
set opt(SlotTime) 			0.000320 ;# 20 symbols @ 62.5 ksymbol rate
set opt(SIFS) 				0.000192 ;# turnaround time; 192us 12 symbols @ 62.5 ks; we also use this as T_ack (interval between DATA and ACK) though in the standard it's a random number between aTurnaroundTime and (aTurnaroundTime + aUnitBackoffPeriod)
set opt(PreambleLength) 	40 ;# 32 bit; SHR header
set opt(PLCPHeaderLength) 	8 ;# 8 bits; length field

Mac/802_11 set RTSThreshold_		$opt(RTSThreshold) 
Mac/802_11 set CSThresh_			$opt(CSThresh)
Mac/802_11 set DutyCycleLength_		$opt(DutyCycleLength) 
Mac/802_11 set CWMin_				$opt(CWMin)
Mac/802_11 set SlotTime_			$opt(SlotTime)
Mac/802_11 set SIFS_				$opt(SIFS)
Mac/802_11 set PreambleLength_		$opt(PreambleLength)
Mac/802_11 set PLCPHeaderLength_	$opt(PLCPHeaderLength)
Mac/802_11 set PLCPDataRate_		$opt(radioBW)    
Mac/802_11 set LongRetryLimit_		0; # no retransmission in orig XMAC
Mac/802_11 set ShortRetryLimit_		0; # no retransmission in orig XMAC
Mac/802_11 set dataRate_			$opt(radioBW); 
Mac/802_11 set basicRate_			$opt(radioBW);

Mac/RIMAC set RTSThreshold_			$opt(RTSThreshold) 
Mac/RIMAC set CSThresh_				$opt(CSThresh)
Mac/RIMAC set RXThresh_				$opt(RXThresh)
Mac/RIMAC set DutyCycleLength_		$opt(DutyCycleLength) 
Mac/RIMAC set CWMin_				$opt(CWMin)
Mac/RIMAC set SlotTime_				$opt(SlotTime)
Mac/RIMAC set SIFS_					$opt(SIFS)
Mac/RIMAC set PreambleLength_		$opt(PreambleLength)
Mac/RIMAC set PLCPHeaderLength_		$opt(PLCPHeaderLength)
Mac/RIMAC set PLCPDataRate_			$opt(radioBW)    
Mac/RIMAC set LongRetryLimit_		5; # 5 retrans by default
Mac/RIMAC set ShortRetryLimit_		5; # 5 retrans by default
Mac/RIMAC set dataRate_				$opt(radioBW); 
Mac/RIMAC set basicRate_			$opt(radioBW);
Mac/RIMAC set base_beacon_frame_length	12	; # preamble(6) + FC(2) + src (2) [+ seq(1) + dst(2) + bw(1)] + crc(2)

Agent/MyNull set nlost_ 0
Agent/MyNull set npkts_ 0
Agent/MyNull set bytes_ 0
Agent/MyNull set lastPktTime_ 0
Agent/MyNull set expected_ 0
Agent/MyNull set packetSize_ 2000;			# max size for segmentation

set opt(transmitpower) 	 	0.0312 ;# Transmitting Power
set opt(receivepower)   	0.0222 ;# Receiving Power
set opt(idlepower)      	0.0222 ;# Idle Power
set opt(sleeppower)			0.000003 ;# Sleep Power
set opt(transitionpower) 	0.0312
set opt(transitiontime) 	0.00247

# 0 to enable random behavor
#set myseed [ns-random  0] 
#puts "seed is $myseed"
ns-random $opt(nsseed)


set RoutingProto "DSR"; # DSR or AODV
set addBroadcastAgent "OFF"

#  ---------- below are supporting code ------------------
set val(mac)  "Mac/RIMAC" 
Mac/802_11 set CWMin_			31	; # not used
Mac/RIMAC set  CWMax_			255; 
puts "MAC type is RIMAC"

if { $RoutingProto == "DSR" } {
#	set val(ifq)             CMUPriQueue                ;# pri-queue for DSR
	set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
	set val(rp)            DSR                       ;# routing protocol
} elseif { $RoutingProto == "AODV" } {
	set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
	set val(rp)            AODV                      ;# routing protocol
} else {
	puts "INVALID Routing Protocol: $RoutingProto, exiting..."
	exit;
}

proc add-my-trace { ttype atype node target} {
	set ns [Simulator instance]
	set tracefd [$ns get-ns-traceall]
	if { $tracefd == "" } {
		puts "Warning: add-my-trace: You have not defined you tracefile yet!"
		puts "Please use trace-all command to define it."
		exit
	}
	set T [new CMUTrace/$ttype $atype]
	$T newtrace ON
	$T tagged OFF
	#$T target [$ns nullagent]
	$T target $target
	$T attach $tracefd
	$T set src_ [$node id]
	#puts "preparing trace for node [$node id]"
	$T node $node
	return $T
}
