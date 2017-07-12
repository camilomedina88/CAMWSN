#
# simple-codeldt.tcl - simulates application traffic where upstream link is
#   under CoDel-DT active queue management.
#
# Description
#   The nodes n0 and n1 represent a cable modem and a CMTS respectively.
#   The upstream link (n0->n1) uses CoDel-DT to manage the queue.
#
#   A mix of two appliation types run over the n0-n1 link: FTP upload and
#   low speed CBR (a la VoIP), to evaluate the benefit of CoDel-DT such as
#   latency and TCP throughput.
#
# See Also
#   DOCSIS Cable Modem - http://www.cablelabs.com/cablemodem/
#
############################################################################
#
# Copyright (c) 2012-2013 Cable Television Laboratories, Inc.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions, and the following disclaimer,
#    without modification.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The names of the authors may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# Alternatively, provided that this notice is retained in full, this
# software may be distributed under the terms of the GNU General
# Public License ("GPL") version 2, in which case the provisions of the
# GPL apply INSTEAD OF those given above.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Authors
#   Greg White <g.white@cablelabs.com>
#   Joey Padden <j.padden@cablelabs.com>
#   Takashi Hayakawa <t.hayakawa@cablelabs.com>
#
############################################################################


################
# Configuration

set num_ftps 3                          ;# Number of FTP sessions
set num_cbrs 2                          ;# Number of CBR sessions
set bottleneck_bw 3000000               ;# Bottleneck bandwidth, between CM-CMTS
set dynamic_bw {0.1 0.01 0.5 0.01 1.0}  ;# Link bandwidth changes during simulation


####

set ns [new Simulator]

set stopTime 300

set packet_size 1500
if { $bottleneck_bw < 1000000 } { set packet_size 500 }

set nominal_rtt [delay_parse 100ms]
set access_delay 20
set bottleneck_delay 10
set realrtt [expr 2 * (2 * $access_delay + $bottleneck_delay)]
set link_bw [expr $bottleneck_bw * 10]

# BDP in packets, based on the nominal RTT
set bdp [expr round($bottleneck_bw * $nominal_rtt / (8 * $packet_size))]

set bufsize1 [expr $bdp]
set bufsize2 [expr $bdp * 10]

puts [format "access_delay=%d(ms) bottleneck_delay=%d(ms) realrtt=%d(ms) bottleneck_bw=%.2f(Mbps)" \
          $access_delay $bottleneck_delay $realrtt [expr $bottleneck_bw / 1000000]]

global defaultRNG
$defaultRNG seed 0
ns-random 0

Trace set show_tcphdr_ 1

Agent/TCP set window_ [expr $bdp * 16]
Agent/TCP set segsize_ [expr $packet_size - 40]
Agent/TCP set packetSize_ [expr $packet_size - 40]
Agent/TCP set windowInit_ 4
Agent/TCP set segsperack_ 1
Agent/TCP set timestamps_ true
Agent/TCP set interval_ 0.4

Queue/CoDelDt set target_ [delay_parse 5ms]
Queue/CoDelDt set interval_ [delay_parse 100ms]


################
# Procedures

proc finish {} {
    global ns
    $ns halt
    $ns flush-trace
    exit 0
}

proc connect_endpoints {server client bw bufsize delay_server delay_client} {
    global ns n0 n1
    $ns duplex-link $server $n0 $bw ${delay_server}ms DropTail
    $ns queue-limit $server $n0 $bufsize
    $ns queue-limit $n0 $server $bufsize
    $ns duplex-link $n1 $client $bw ${delay_client}ms DropTail
    $ns queue-limit $n1 $client $bufsize
    $ns queue-limit $client $n1 $bufsize
}

proc random_uniform {a b} {
    expr $a + (($b - $a) * ([ns-random] * 1.0 / 0x7fffffff))
}


################
# Build the topology

set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 $bottleneck_bw ${bottleneck_delay}ms CoDelDt
$ns queue-limit $n0 $n1 $bufsize1
$ns queue-limit $n1 $n0 $bufsize1

# FTP sessions
for {set k 1} {$k <= $num_ftps} {incr k} {
    set server [$ns node]
    set client [$ns node]
    set dly [expr $access_delay + $k]
    set flow_id [$client id]

    connect_endpoints $server $client $link_bw $bufsize2 $access_delay $dly
    set ctcp [$ns create-connection TCP/Linux $server TCPSink/Sack1 $client $flow_id]
    $ctcp select_ca cubic

    set ftp [$ctcp attach-app FTP]
    $ftp set enableResume_ true
    $ftp set type_ FTP

    puts [format "FTP: s=%s c=%s bw=%.2f(Mbps) bs=%d d1=%d(ms) d2=%d(ms) flow_id=%s" \
              [$server id] [$client id] [expr $link_bw / 1000000] $bufsize2 \
              $access_delay $dly $flow_id]

    set t0 0
    set t1 $stopTime
    $ns at $t0 "$ftp start"
    $ns at $t1 "$ftp stop"
}

# CBR sessions
for {set k 1} {$k <= $num_cbrs} {incr k} {
    set server [$ns node]
    set client [$ns node]
    connect_endpoints $server $client $link_bw $bufsize2 $access_delay $access_delay

    set flow_id [$client id]
    puts [format "CBR: server=%s client=%s flow_id=%s" \
              [$server id] [$client id] $flow_id]
    set udp [$ns create-connection UDP $server LossMonitor $client $flow_id]
    set cbr [new Application/Traffic/CBR]
    $cbr attach-agent $udp
    # change these for different types of CBRs
    $cbr set packetSize_ 100
    $cbr set rate_ 0.064Mb

    set t0 [expr ($k - 1) * [random_uniform 0.0 2.0]]
    set t1 $stopTime
    $ns at $t0 "$cbr start"
    $ns at $t1 "$cbr stop"
}


################
# Change link bandwidth dynamicaly

proc change_bottleneck {bw} {
    global ns n0 n1
    [[$ns link $n0 $n1] link] set bandwidth_ $bw
    [[$ns link $n1 $n0] link] set bandwidth_ $bw
    puts [format "change_bottleneck: now=%.3f bw=%.2f(Mbps)" [$ns now] [expr $bw / 1000000]]
}

for {set k 0} {$k < [llength $dynamic_bw]} {incr k} {
    set changeTime [expr ($k + 1) * $stopTime / ([llength $dynamic_bw] + 1)]
    set f [lindex $dynamic_bw $k]
    set newBW [expr $f * $bottleneck_bw]
    $ns at $changeTime "change_bottleneck $newBW"
}


################
# Prepare trace files

set trace_file_main tmp-main.tr
set trace_file_codeldt tmp-codeldt.tr

$ns trace-queue $n0 $n1 [open $trace_file_main w]
set codeldt [[$ns link $n0 $n1] queue]
$codeldt trace curq_
$codeldt trace d_exp_
$codeldt attach [open $trace_file_codeldt w]


################
# Run it

puts ""
puts "Starting simulation"
puts "Trace files are '$trace_file_main' and '$trace_file_codeldt'"
puts ""

$ns at $stopTime "finish"
$ns run
exit 0
