####################################################################
# init variable lists
####################################################################
set BER     {0.000100 0.000010 0.000001}
#set PKT     {512 512 512}
#set PKT     {1024 1024 1024}
set PKT     {2048 2048 2048}
set Frame   {2048 4096 8192 16384}
set DelayTimer      {0.0}
set Frag            {256 256 256 256 256}
set x_axis          $Frame

# set BER     {0.000100 0.000010 0.000001}
# #set PKT     {512 512 512}
# #set PKT     {1024 1024 1024}
# set PKT     {512 1024 2048}
# set Frame   {512 1024 2048}
# #set Frame   {1024 2048 4096 8192 16384}
# set DelayTimer      {0.0}
# set Frag            {256 256 256}
# #set Frag            {256 256 256 256 256}
# #set Frag            {1024}
# set x_axis          $Frame


set fh_throughput "frame_afr_throughput.txt"
set fh_a_delay    "frame_afr_average_delay.txt"
set fh_p_delay    "frame_afr_peak_delay.txt"
set fh_fairness   "frame_afr_fairness.txt"


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


####################################################################
# run ns
####################################################################

for {set i 0} {$i < [llength $BER] } {incr i} {
    for {set j 0} {$j < [llength $Frame] } {incr j} {
        exec ns frame_afr-david.tcl [lindex $BER $i] [lindex $PKT $i] [lindex $Frame $j] [lindex $Frag $j] [lindex $DelayTimer 0] >> "auto-result.txt" 2> /dev/null
#         exec ns frame_afr-david.tcl [lindex $BER $i] [lindex $PKT $i] [lindex $Frame $j] [lindex $Frag $j] [lindex $DelayTimer 0] >> "auto-result.txt" 2> /dev/null
}
    new_a_line
}


