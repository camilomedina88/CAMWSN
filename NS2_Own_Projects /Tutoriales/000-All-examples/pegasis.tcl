####################################################################
#
# Protocol PEGASIS - pegasis.tcl
# 25.4.2012
# Tomas Takacs - FIIT STUBA
#
####################################################################


#source $env(uAMPS_LIBRARY)/ns-pegasis.tcl
source /home/tomas/ns-allinone-2.34/ns-2.34/mit/uAMPS/ns-pegasis.tcl

set opt(rcapp)        "Application/PEGASIS"     ;# Application type
set opt(tr)           "$opt(dirname)/pegasis.tr"   ;# Trace file
# Need to spread the data by k+1
set opt(spreading)    [expr $opt(num_clusters)+1]

set outf [open "$opt(dirname)/conditions.txt" w]
puts $outf "\nUSING PEGASIS:\n"
close $outf

source mit/uAMPS/sims/uamps.tcl

# Parameters for centralized control cluster formation algorithm
set opt(adv_info_time)    [TxTime [expr $opt(hdr_size) + 12]]
set opt(finish_adv)       [expr $opt(nn_) * $opt(adv_info_time)]
set opt(bs_setup_iters)   1000            ;# Num iters for sim. annealing alg.
set opt(bs_setup_max_eps) 10              ;# Max change for sim. annealing alg.

set outf [open "$opt(dirname)/conditions.txt" a]
puts $outf "Desired number of clusters = $opt(num_clusters)"
puts $outf "Spreading factor = $opt(spreading)"
puts $outf "Changing clusters every $opt(ch_change) seconds\n"
close $outf
