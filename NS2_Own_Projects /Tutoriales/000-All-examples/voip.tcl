# vim: syntax=tcl
#
#  Copyright (C) 2007 Dip. Ing. dell'Informazione, University of Pisa, Italy
#  http://info.iet.unipi.it/~cng/ns2voip/
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA, USA
#
#

##############################################################################
#                       CONFIGURATION OF PARAMETERS                          #
##############################################################################

#
# Simulation environment
#
set opt(run)        0         ;# replic ID
set opt(duration)   180.0     ;# run duration, in seconds
set opt(warm)       36.0 ;# run duration, in seconds
set opt(out)        "out"     ;# statistics output file
set opt(debug)      ""        ;# debug configuration file, "" = no debug
set opt(startdebug) 21550.0     ;# start time of debug output

set opt(aggregate) 1
set opt(tagrand)   "constant"
set opt(tagmean)    0.10
set opt(tagvar)     0.01
set opt(tagper)     0.00

set opt(codec)     "GSM.AMR" ;# G.711, G.723.1, G.729A, GSM.EFR, GSM.AMR, 
set opt(initialDelay) 0.060 

##############################################################################
#                       DEFINITION OF PROCEDURES                             #
##############################################################################

#
# parse command-line options and store values into the $opt(.) hash
#
proc getopt {argc argv} {
        global opt

        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue

                set name [string range $arg 1 end]
                set opt($name) [lindex $argv [expr $i+1]]
        }
}

#
# print out options
#
proc printopt { } {
        global opt

        foreach x [lsort [array names opt]] {
                puts "$x = $opt($x)"
        }
}

#
# die function
#
proc die { x } {
        puts $x
        exit 1
}

#
# alive function
#
proc alive { } {
        global ns opt

        if { [$ns now] != 0 } {
                puts -nonewline \
                 [format "elapsed %.0f s (remaining %.0f s) completed %.f%%" \
                 [$ns now] \
                 [expr $opt(duration) - [$ns now]] \
                 [expr 100 * [$ns now] / $opt(duration)]]
                if { [$ns now] >= $opt(warm) } {
                        puts " stat collection ON"
                } else {
                        puts ""
                }
        }
        $ns at [expr [$ns now] + $opt(duration) / 10.0] "alive"
}

#
# collect statistics at the end of the simulation
#
proc finish {} {
        global ns simtime

        # print statistics to output file
        $ns stat print

        # print out the simulation time
        set simtime [expr [clock seconds] - $simtime]
        puts "run duration: $simtime s"

        exit 0
}

#
# initialize simulation
#
proc init {} {
        global opt defaultRNG ns simtime

        # create the simulator instance
        set ns [new Simulator]  ;# create a new simulator instance
        $defaultRNG seed 1

        # initialize statistics collection
        $ns run-identifier $opt(run)
        $ns stat file "$opt(out)"
        $ns at $opt(warm) "$ns stat on"
        $ns at $opt(duration) "finish"

        # add default probes
        $ns stat add e2e_owd_a    avg discrete
        $ns stat add e2e_tpt      avg rate
        $ns stat add e2e_owpl     avg rate
        #$ns stat add tcp_cwnd_a   avg continuous
        #$ns stat add tcp_dupacks  avg continuous
        #$ns stat add tcp_ssthresh avg continuous
        #$ns stat add tcp_rtt      avg continuous
        #$ns stat add tcp_srtt     avg continuous

        #$ns stat add tcp_cwnd_d   dst continuous 0 128 128
        $ns stat add e2e_owd_d    dst discrete 0.0 1.0 1000
        #$ns stat add e2e_ipdv_d   dst discrete 0.0 5.0 100 

        $ns stat add voip_frame_delay avg discrete
        $ns stat add voip_frame_sent avg counter
        $ns stat add voip_frame_rcvd avg counter
        $ns stat add voip_mos_talkspurt avg discrete
        $ns stat add voip_none_frame_sent avg counter
        $ns stat add voip_none_frame_rcvd avg counter
        $ns stat add voip_none_mos_talkspurt avg discrete
        $ns stat add voip_end_mos avg discrete
        $ns stat add voip_end_per avg discrete
        $ns stat add voip_end_cell_outage avg discrete
	$ns stat add voip_buffer_overflow_drop avg counter
	$ns stat add voip_buffer_out_of_time_drop avg counter
	$ns stat add voip_%_of_bad_talkspurts avg discrete

	$ns stat add Weibull_ON avg discrete
	$ns stat add Weibull_OFF avg discrete

        # open trace files
        set opt(trace) [open "/dev/null" w]

        set simtime [clock seconds]

        $ns trace-all $opt(trace)
}

##############################################################################
#                       SCENARIO CONFIGURATION                               #
##############################################################################

proc scenario {} {
        global ns opt

        set n0 [$ns node]
        set n1 [$ns node]
        $ns duplex-link $n0 $n1 8Mb 10ms DropTail

		  for { set i 0 } { $i < 1 } { incr i } {
			  set source($i) [new VoipSource]
			  #$source($i) model exponential 1 1
			  $source($i) model one-to-one
			  $ns at 0.0 "$source($i) start"
			  #$ns at 100.0 "$source($i) stop"

			  set encoder($i) [new Application/VoipEncoder]
			  $encoder($i) codec $opt(codec)

			  $source($i) encoder $encoder($i)

			  set decoder($i) [new Application/VoipDecoder]
			  set decoder($i) [new Application/VoipDecoderStatic]
			  set decoder($i) [new Application/VoipDecoderOptimal]
			  $decoder($i) id $i
			  $decoder($i) cell-id 0
			  $decoder($i) emodel $opt(codec)

			  #Only for static decoder
			  #$decoder($i) buffer-size 20      ;# in number of VoIP frames
			  #$decoder($i) initial-delay $opt(initialDelay) ;# in ms

			  set agtsrc($i) [new Agent/UDP]
			  set agtdst($i) [new Agent/UDP]
			  $agtsrc($i) set fid_ 1
			  $ns attach-agent $n0 $agtsrc($i)
			  $ns attach-agent $n1 $agtdst($i)
			  $ns connect $agtsrc($i) $agtdst($i)
			  $encoder($i) attach-agent $agtsrc($i)
			  $decoder($i) attach-agent $agtdst($i)

			  set aggregate($i) [new Application/VoipAggregate]
			  #$aggregate($i) size 200
			  $aggregate($i) nframes $opt(aggregate)
			  $aggregate($i) attach-agent $agtsrc($i)
			  #$encoder($i) aggregate $aggregate($i)

			  #set header($i) [new Application/VoipHeader]
			  #$header($i) nocompression
			  #$header($i) attach-agent $agtsrc($i)
			  #$encoder($i) header $header($i)
			  #$aggregate($i) header $header($i)

			  $ns at $opt(startdebug) "$source($i) debug"
			  $ns at $opt(startdebug) "$encoder($i) debug"
			  $ns at $opt(startdebug) "$decoder($i) debug"
			  $ns at $opt(startdebug) "$aggregate($i) debug"

			  # end-to-end modules statistics collection
			  set tag [new e2et]
			  set mon [new e2em]

			  if { $opt(tagrand) == "uniform" } {
				  set tag_ranvar [new RandomVariable/Uniform]
				  $tag_ranvar set min_ 0
				  $tag_ranvar set max_ [expr $opt(tagmean) / 2]
			  } elseif { $opt(tagrand) == "exponential" } {
				  set tag_ranvar [new RandomVariable/Exponential]
				  $tag_ranvar set avg_ $opt(tagmean)
			  } elseif { $opt(tagrand) == "normal" } {
				  set tag_ranvar [new RandomVariable/Normal]
				  $tag_ranvar set avg_ $opt(tagmean)
				  $tag_ranvar set std_ [expr $opt(tagvar) / 2]
			  } elseif { $opt(tagrand) == "weibull" } {
				  set tag_ranvar [new RandomVariable/Weibull]
				  $tag_ranvar set shape_ 2
				  $tag_ranvar set scale_ [expr $opt(tagmean) / 0.88623]
			  } elseif { $opt(tagrand) == "constant" } {
			      set tag_ranvar [new RandomVariable/Constant]
				  $tag_ranvar set val_ $opt(tagmean)
			  } else {
				  puts "Unknown distribution '%s'"
				  exit 0
			  }

			  if { $opt(tagrand) != "none" } {
				  $tag ranvar $tag_ranvar
			  }

			  $tag per $opt(tagper)
			  $agtsrc($i) attach-e2et $tag
			  $agtdst($i) attach-e2em $mon
			  $mon index $i
			  $mon start-log

			  #$ns stat trace voip_frame_delay $i delay.$i
		  }

		  #set bidirectional [new VoipBidirectional]
		  #$bidirectional source $source(0)
		  #$bidirectional source $source(1)
		  #$source(0) bidirectional $bidirectional
		  #$source(1) bidirectional $bidirectional
		  #$ns at $opt(startdebug) "$bidirectional debug"
}

##############################################################################
#                            MAIN BODY                                       #
##############################################################################

getopt $argc $argv
init
scenario
if { $opt(debug) != "" } {
        printopt
}
alive

$ns run
