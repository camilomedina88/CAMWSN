# This function repeatedly calls the the given check command
# at the specified intervals.  The first time that the check_command
# returns 1, the finish_command will be called.
#
#  For example:
# 
#     set fc [new FinishCheck]
#     $fc set check_commad_ "check"
#     $fc set interval_ .01
#     $fc set finish_command_ "finish"
#
#     $fc sched .01
#
# This will schedule the commad "check" to be run every .01
# seconds starting at time .01.  The first time that "check"
# returns 1, "finish" will be called.
#

Class FinishCheck -superclass NewTimer
FinishCheck instproc init {} {
    
    $self instvar check_command_ interval_ finish_command_ timeout_

    $self next
    set check_command_ ""
    set interval_ ""
    set finish_command_ ""
}

FinishCheck instproc timeout {} {
    global ns_ ns

    set ns $ns_
    $self instvar interval_ check_command_ finish_command_ timeout_
    
    set finished [$check_command_]
	  set current_time [$ns_ now]

    if {$finished == 1} {
	# We're done!
	puts "\n !!!!!!!!!We're done at time $current_time!!!!!!!!"
	$finish_command_
    } else {
	# reschedule the timer
	$self sched $interval_
    }

    return
}

# rca_check_wants_empty
#
# This check function will check to see whether the
# "wants" list of every node is empty.  The following
# global variables are assumed to be defined.
#
# rca -- an array of rca apps
# num_nodes -- the number of nodes in rc

proc rca_check_wants_empty {} {
    global ns_ opt node_

    set finished 1

    rca_gather_stats

    for {set id 0} {($id < $opt(nn)) && ($finished == 1)} {incr id} {
	
	set app [$node_($id) set rca_app_]
	set wants [$app set wants_]
	
	if {![$wants emptyset?]} {
	    set current_time [$ns_ now]
	    puts "\n Node $id still not finished at time $current_time"
	    $wants pp "Wants list"
	    set finished 0
	}
    }

    return $finished
}

# rca_finish
#
# This finish function will print out the
# final wants and has lists of all the rca
# agents.  The following global variables are
# assumed to be defined (this is messy, but so
# is tcl).
#
# ns  -- a simulator
# rca -- an array of rca apps
# nsf -- the ns trace file
# num_nodes -- the number of nodes in rc
# namf -- the name file

proc rca_finish {} {

    global ns_ opt node_

    # Print out the has and wants list for all the nodes
    for {set id 0} {$id < $opt(nn)} {incr id} {

	set rca [$node_($id) set rca_app_]
	set wants [$rca set wants_]

	set wants [$rca set wants_]
	set has [$rca set has_]
	set stats [$rca set stats_]
	set er [$rca getER]

	puts "\n Final data for node $id"
	$wants pp "Wants list"
	$has pp "Has list"
#	$er pp 

	puts "\n Final statistics for node $id"
	$stats pp

    }
    rca_gather_stats

#    rca_close_stats
	exit 0
}
