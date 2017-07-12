####################################################################
# init variable lists
####################################################################
set DelayTimer      {0.00}
set BER     {0.000100 0.000010  0.000001}
set PKT     {120 120 120}
set Frame   {1200 1200 1200}
#set Frame   {480 480 480}
set Frag    {120}
set nn      {60 70 80}
set x_axis  $nn


set fh_throughput "sta_voip_afr_throughput.txt"
set fh_a_delay    "sta_voip_afr_average_delay.txt"
set fh_p_delay    "sta_voip_afr_peak_delay.txt"
set fh_fairness   "sta_voip_afr_fairness.txt"
set fh_percentage   "sta_voip_afr_percentage.txt"


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
set fresult [open $fh_percentage "w"]
close $fresult  


####################################################################
# put an 'enter' at the end of a line
####################################################################
proc new_a_line args {
    global fh_throughput fh_a_delay fh_p_delay fh_fairness   fh_percentage
    
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
    set fresult [open $fh_percentage "a"]
    puts $fresult ""
    close $fresult 
}


####################################################################
# the first line
####################################################################
proc first_line args {
    global Frag DelayTimer fh_throughput fh_a_delay fh_p_delay fh_fairness fh_percentage
    
    
        for {set j 0} {$j < [llength "$args"] } {incr j} {
            #
            set fresult1 [open $fh_throughput "a"]
            set fresult2 [open $fh_a_delay "a"]
            set fresult3 [open $fh_p_delay "a"]
            set fresult4 [open $fh_fairness "a"]
            set fresult5 [open $fh_percentage "a"]
#
            puts -nonewline $fresult1 "[lindex $args $j]    "
            puts -nonewline $fresult2 "[lindex $args $j]    "
            puts -nonewline $fresult3 "[lindex $args $j]    "
            puts -nonewline $fresult4 "[lindex $args $j]    "
            puts -nonewline $fresult5 "[lindex $args $j]    "
#
            close $fresult1
            close $fresult2
            close $fresult3
            close $fresult4
            close $fresult5
}
}
first_line $x_axis
new_a_line



####################################################################
# run ns

for {set i 0} {$i < [llength $BER] } {incr i} {
    for {set j 0} {$j < [llength $nn] } {incr j} {
   	    exec ns sta_voip.tcl [lindex $BER $i] [lindex $PKT $i] [lindex $Frame $i] [lindex $Frag 0] [lindex $DelayTimer 0] [lindex $nn $j] >> "auto-result.txt" 2> /dev/null
    }
    new_a_line
}


