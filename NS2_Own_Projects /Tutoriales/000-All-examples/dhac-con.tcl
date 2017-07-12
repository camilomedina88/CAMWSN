############################################################################
# by zcj 2007
#   This code was developed from the code of LEACH. (June, 2000)
#   Developed as part of the WSNs project at Carleton University.
#
############################################################################

source dhac/ns-dhac-con.tcl

set opt(rcapp)        "Application/DHAC-CON"        ;# Application type
set opt(tr)           "out.tr"            ;# Trace file
# Can have more than k clusters in LEACH ==> need more than k spreading
set opt(minimum_cluster_size) [expr ceil([expr $opt(nn) * $opt(minimum_cluster)])]
set opt(merge_steps)   0
set outf [open "$opt(dirname)/conditions.txt" w]
puts $outf "\nDHAC algorithm using information: CONNECTIVITY\n"
puts $outf "Coefficient algorithm method:     $opt(coeff_method)"
puts $outf "DHAC algorithm method:            $opt(hac_method)"
puts $outf "Cluster Head choose method:       $opt(ch_method)"
puts $outf "Merge minimum cluster method:     $opt(merge_method)"
puts $outf "\n#=====================================================#\n"
close $outf

source dhac/tools/setting.tcl

# Parameters for distrbuted cluster formation algorithm
#zcj added ==================================================================
                                          ;# RA Time (s) for HELLO
set opt(ra_hello)     [TxTime [expr $opt(hdr_size) + 4]]
                                          ;# RA Time (s) for CH INVITE
set opt(ra_invite)    [TxTime [expr $opt(hdr_size) + 4]]
                                          ;# RA Time (s) for CH CONFIRM
set opt(ra_confirm)   [TxTime [expr $opt(hdr_size) + 200]]
                                          ;# RA Time (s) for CH SCHEDULE
set opt(ra_shedule)   [TxTime [expr $opt(hdr_size) + 20]]

#zcj added ==================================================================
                                          ;# RA Time (s) for CH ADVs
set opt(ra_adv)       [TxTime [expr $opt(hdr_size) + 20]]
                                          ;# Total time (s) for CH ADVs
                                          ;# Assume max 4(nn*%) CHs
set opt(ra_adv_total) [expr $opt(ra_adv)*($opt(num_clusters)*4 + 1)]
                                          ;# RA Time (s) for nodes' join reqs
set opt(ra_join)      [expr 0.01 * $opt(nn_)]
                                          ;# Buffer time for join req xmittal
set opt(ra_delay)     [TxTime [expr $opt(hdr_size) + 4]]
                                          ;# Maximum time required to transmit 
                                          ;# a schedule (n nodes in 1 cluster)
set opt(xmit_sch)     [expr 0.005 + [TxTime [expr $opt(nn_)*4+$opt(hdr_size)]]]
                                          ;# Overhead time for cluster set-up
set opt(start_xmit)   [expr $opt(ra_adv_total) + $opt(ra_join) + $opt(xmit_sch)]


set outf [open "$opt(dirname)/conditions.txt" a]

puts $outf "#=====================================================#\n"
puts $outf "Network: $opt(topo)\n"

if {$opt(eq_energy) == 1} {
  puts $outf "Set nodes have equally initial energy."
} else {
  puts $outf "Set nodes have different initial energy."
}
puts $outf "Transmission range         =  $opt(trans_range)"
puts $outf "Desired number of clusters =  $opt(num_clusters)"
puts $outf "Minimum cluster size       =  $opt(minimum_cluster_size)"
puts $outf "\n#=====================================================#\n\n"
close $outf

