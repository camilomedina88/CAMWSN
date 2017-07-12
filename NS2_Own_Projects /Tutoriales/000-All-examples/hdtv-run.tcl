####################################################################
# init variable lists
####################################################################
set BER     {0.000100 0.000010 0.000001}
set DelayTimer      {0.0}
set PKT     {1500 1500 1500}
set Frame   {9000 9000 9000}
set Frag    {750}
set nn      {2 3 4 5 6 7 8 9 10}
set x_axis  $nn

set fh_throughput "hdtv_afr_throughput.txt"
set fh_a_delay    "hdtv_afr_average_delay.txt"
set fh_p_delay    "hdtv_afr_peak_delay.txt"
set fh_fairness   "hdtv_afr_fairness.txt"


####################################################################
# clear result files
####################################################################
set fresult [open $fh_throughput "w"]
close $fresult 	
set fresult [open $fh_a_delay "w"]
close $fresult 	
set fresult [open $fh_p_delay "w"]
close $fresult 	
set fresult [open $fh_fairness "w"]
close $fresult 	


####################################################################
# put an 'enter' at the end of a line
####################################################################
proc new_a_line args {
    global fh_throughput fh_a_delay fh_p_delay fh_fairness
    
    set fresult [open $fh_throughput "a"]
    puts $fresult ""
    close $fresult 	
    set fresult [open $fh_a_delay "a"]
    puts $fresult ""
    close $fresult 	
    set fresult [open $fh_p_delay "a"]
    puts $fresult ""
    close $fresult 
    set fresult [open $fh_fairness "a"]
    puts $fresult ""
    close $fresult 
}


####################################################################
# the first line
####################################################################
proc first_line args {
    global Frag DelayTimer fh_throughput fh_a_delay fh_p_delay fh_fairness
    
    
        for {set j 0} {$j < [llength "$args"] } {incr j} {
            #
            set fresult1 [open $fh_throughput "a"]
            set fresult2 [open $fh_a_delay "a"]
            set fresult3 [open $fh_p_delay "a"]
            set fresult4 [open $fh_fairness "a"]
            #
            puts -nonewline $fresult1 "[lindex $args $j]    "
            puts -nonewline $fresult2 "[lindex $args $j]    "
            puts -nonewline $fresult3 "[lindex $args $j]    "
            puts -nonewline $fresult4 "[lindex $args $j]    "
            #
            close $fresult1
            close $fresult2
            close $fresult3
            close $fresult4
        }
}
first_line $x_axis
new_a_line

for {set i 0} {$i < [llength $BER] } {incr i} {
    for {set j 0} {$j < [llength $Frag] } {incr j} {
        for {set k 0} {$k < [llength $nn] } {incr k} {
            
    	    exec ns hdtv-afr-david.tcl [lindex $BER $i] [lindex $PKT $i] [lindex $Frame $i] [lindex $Frag $j] [lindex $DelayTimer 0]  [lindex $nn $k] >> "auto-result.txt" 2> /dev/null
        }
    }
    new_a_line
}


