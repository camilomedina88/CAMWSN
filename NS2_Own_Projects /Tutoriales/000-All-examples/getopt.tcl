#
# getopt.tcl
# inpired from http://www.45.free.net/~vitus/ice/works/tcl.html#getopt
#  
#
# Option parsing library for Tcl scripts
# Copyright (C) SoftWeyr, 1997
# Original Author V. Wagner <vitus@agropc.msk.su
# Extensive Modifications by Pedro Vale Estrela, pedro.estrela@gmail.com
# (tagus.inesc-id.pt/~pestrela/ns2)
#
# Distributed under GNU public license. (i.e. compiling into standalone
# executables or encrypting is prohibited, unless source is provided to users)
#



#
# "my_getopt" usage: 
#
# a) define opt(opt_conv) as in this example:
#
#	global opt
#	set opt(opt_conv) {
#		{ p protocol }
#		{ nam call_nam }
#		
#		{ tt generator_type }	{ tr pkt_rate }  
#		{ ts packet_size }		{ ti traffic_intradomain }
#		{ tb traffic_buffer }
#	}
#
# b) define the default options as in this example:
#	set opt(protocol) 		TIMIP
#	set opt(traffic_size)	100
#	set opt(call_nam)		0
#	set opt(generator_type)	CBR
#	...
#
# c) call "my_getopt $argv" in the beginning of the script
#
# d) the recognized parameters will replace the default options in the "opt" global array; 
# isolated parameters will get the value "1"
#
# USAGE EXAMPLES:
#	ns <your script>  
#  		(this will use the default options)
#
#	ns <your script> -- -p HAWAII -tt FTP -nam
#  		(this will replace the default opt(protocol) and opt(generator type) with the specified ones, and 
#		set the "opt(call_nam) flag. Note that the option's order can be interchanged at ease, eg
#		"ns <your script> -- -nam -tt FTP -p HAWAII"
#
#	ns <your script> -- -nam -p HAWAII -tt FTP -p CIP -p HMIP
#  		(same as above, but the protocol will be the last one specified , eg HMIP)
#
#
# HELP EXAMPLES:
#	ns <your script> -- -h
#		(shows the available options as a list)
#
#	ns <your script> -- -h 2
#		(shows the available options and their associated values)
#







#  
# getopt2 - recieves an array of possible options with default values
# and list of options with values, and modifies array according to supplied
# values
# ARGUMENTS: arrname - array in calling procedure, whose indices is names of
# options WITHOUT leading dash and values are default values.
# if element named "default" exists in array, all unrecognized options
# would concatenated there in same form, as they was in args
# args - argument list - can be passed either as one list argument or 
# sepatate arguments 
# RETURN VALUE: none
# SIDE EFFECTS: modifies passed array 
#
proc getopt2 {arrname args} {
	upvar $arrname opt
	if ![array exist opt] {
		return -code error "Array $arrname doesn't exist"
	}
	if {[llength $args]==1} {
		eval set args $args
	}
	
	if {![llength $args]} return
	
	#debug 1
	#if {[llength $args]%2!=0} {error "Odd count of opt. arguments"}

	for {set i 0} { $i < [expr [llength $args] - 1] } { incr i } {
		set a [lindex $args $i]
		set b [lindex $args [expr $i + 1]]
		

		if [string match -* $a] {
			set a [string trimleft $a -]
			
			
			if [string match -* $b] {
				## opção sem parametros. usa valor 1
				set b 1
				
				puts "$a -> boolean (==1); "
				set i [expr $i - 1]
			}
			
			## puts "$a -> $b "
			
			## ve se esta opção existe no array de shorthands			
			if { [info exists opt($a)] } {
				set opt($a) $b
				incr i
			} else {
				set msg "unknown option $a. Should be one of:"
				foreach j [array names opt] {append msg " -" $j}
				puts $msg
				
				exit 1
			}
		} else {
			puts "Ignoring Option $a"
		}

	}
	


	set a [lindex $args [expr [llength $args] - 1] ]
	
	if { [string match -* $a]} {
		set a [string trimleft $a -]
			
		set b 1 
		puts "$a -> boolean (==1); "

		## ve se esta opção existe no array de shorthands			
		if { [info exists opt($a)] } {
			set opt($a) $b
			incr i
		} else {
			set msg "unknown option $a. Should be one of:"
			foreach j [array names opt] {append msg " -" $j}
			puts $msg
			
			exit 1
		}
	}


	return
}


proc my_getopt { argv } {
	global opt
	#set args [lindex $argv 0]
	set args $argv
	#########

	set conv $opt(opt_conv)

	foreach op $conv {
		set a [ lindex $op 0 ]
		set b [ lindex $op 1 ]
		
		set opt_temp($a) ""
	}

	#debug 1	
	
	getopt2 opt_temp $args
	
	puts "********"


	foreach op $conv {
		set a [ lindex $op 0 ]
		set b [ lindex $op 1 ]
		set value $opt_temp($a)
		
		if { $value != "" } { 
			set opt($b) $value
			puts "$b:  $opt($b)"
		} else {
			# ignora opções que nao foram especificadas
		}
	}
	
	#debug 1
	return

}


#
# define opt(do_help) 1 for showing the available options as a list
# define opt(do_help) 2 for showing the available options and its current value
#
proc do_help { } {
	global opt 

	foreach op $opt(opt_conv) {
		set a [ lindex $op 0 ]
		set b [ lindex $op 1 ]
		
		set opt_temp($a) $opt($b)
		set opt_temp2($a) $b

	}
	
	
	if { $opt(do_help) >= 2 } {

		puts "\n Values in Use:"
		foreach j [lsort [array names opt_temp ]] {
			puts "-$j $opt_temp($j)    \t\t($opt_temp2($j))"
		}
	}
	
	if { $opt(do_help) >= 1 } {
		set msg "\n Available Options: \n"
		foreach j [array names opt_temp ] {append msg " -" $j}
		puts $msg
	}
		
	return
}


