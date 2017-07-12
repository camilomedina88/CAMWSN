## *** CVS Info: ******************************************************
##  $Header: /home/pmsrve/.cvsroot/ns_cims/tcl/lib/ns2_shared_procs.tcl,v 1.19 2006/09/25 13:41:01 pmsrve Exp $
##  $Date: 2006/09/25 13:41:01 $
##  $Revision: 1.19 $
## ********************************************************************
##
##  Pedro Estrela, pedro.estrela@inesc.pt
##  web page:  http://inesc-0.tagus.ist.utl.pt/~pmsrve/ns2/
##
##  This file contains TCL code fragments useful for debbuging ns2 and otcl
##  It should be used inside procs, instprocs, and for intereactive debugging inside tcl-debug ("debug 1")
##
##  Please send comments, bug fixes and improvements to pedro.estrela@inesc.pt
##
##  "Index":
##    - tcl's "Exit" related functions 
##    - tcl proc fragments (static, incr, etc (from XXXX))
##    - tcl proc fragments (check_list_length, etc)
##
##    - otcl debug code fragments (dputs, dputsl, show,  etc)
##    - otcl class helper code fragments (instaces, vars, exists_var  etc)
##
##    - tracegraph debug code fragments (dump_.tr.ip)
##    - NAM animator debug code fragments (trace-annotate-time, set-animation-rate )
##
##    - Nodes IDs, Hierarquical addresses, iaddrs helper functions (id2haddr, handle2iaddr, etc)
##    - RouteLogic Dumping Functions, Hierarchical addresses debugging  
##    - AddrParams Helper Functions  
##
##    - TCL simple lists statistics (stddev, avg, N, min, ...)
##


# This variable controls the default destination of the debug messages (stdout, sdterr)
set CHANNEL stdout

###################################################################
####  Exit Functions
####


#
# this code disables the "exit" proc behaviour to "none"
#
set OPT_DISABLE_EXIT 1

# check option  existence and value
if { [info exists OPT_DISABLE_EXIT] && [expr $OPT_DISABLE_EXIT] } {

	# only once 
	if { ![info exists OPT_DISABLE_EXIT_FLAG] } {
		set OPT_DISABLE_EXIT_FLAG 1

		# check tkcon console existence
		if { [info exists ::tkcon::OPT] } {
			rename exit exit_ORIGINAL

			proc exit { {a 1} }  {
				#debug 1
			}

			proc quit { {a 1} }  {
				exit_ORIGINAL
			}

		}
	}
}


###################################################################
###################################################################
###################################################################
##  tcl proc fragments 
##
##  Note: fragments taken from http://slwww.epfl.ch/SIC/SL/logiciels/TclTk/tcl/Fragments.html
##


#
## I saw this on the Net and grabbed it without recording who initially created it ( my Apologies to the author). It gives Tcl static variables within procs ( cf static in C ) and works by using a global array for the procname indexed by the variableName desired to hold the variable and mapping that onto the desired variableName within the proc. 
## proc 
#
# 
proc static {varname {initval 0}} {

    # determine the name of the proc that invoked us:
    set procname [lindex [info level -1] 0]
    global $procname

    # initialize only if the variable doesn't already exist:
    
    if ![info exists [set procname]($varname)] {
	set [set procname]($varname) $initval
    }

    # make the global variable accessible from within the invoking proc
    # and return its current value:
    
    uplevel upvar #0 [set procname]($varname) $varname
    return [set [set procname]($varname)]
}



#
##Dumping the Keys and values of a TclX keyed list
#
proc pkeyl { keylnm } {
    upvar $keylnm keyl
    puts stderr "$keylnm :"
    set l [ keylkeys keyl ]
    foreach i $l {
        set v [ keylget keyl $i ]
        puts stderr [format "%20s = %-s" $i $v]
    }
}

#
## Dumping the value of an arbitrary Tcl variable
## Taken from tkinspect, posted by jhobbs@cs.uoregon.edu, 
# Print out the value of a variable (array or simple) by 
# just passing it the variable  name
proc dumpvar var {
	upvar $var v
	if {[set ix [array names v]] != ""} {
		foreach i $ix {append res [list set $var\($i) $v($i)]\n}
	} elseif [info exists v] {
		if [catch {list set $var $v} res] {set res "No known variable [list $var]"}
	} else {
		set res "No known variable [list $var]"
	}
	return $res
}

#
## Ascii and integer conversions
# convert integer to ascii char
proc asc i { 
	if { $i<0 || $i>255 } { error "asc:Integer out of range 0-255" } 
	return [format %c $i ] 
}

proc chr c { 
	if {[string length $c] > 1 } { error "chr: arg should be a single char"}
#   set c [ string range $c 0 1] 
	set v 0; 
	scan $c %c v; return $v
}

#
## An incr proc resistant to nonexistant variables 
## An incr fn that doesn't croak if varname given does not already exist 
#
proc incr { name {value 1 } } {
upvar $name var

	if { [ info exists var ] }  {
		set var [ expr $var + $value ]
	} else {
		set var $value 
	}
}


#
# returns the sum of all elements of an list
#
proc lsum { l } {
        for {set i 0} {$i < [llength $l]} {incr i} {
		incr s [lindex $l $i]
	}
	return $s
}


###################################################################
###################################################################
### tcl proc fragments


#
# check if list has exactly c elements; show error "st" if not
#
proc check_list_length { l c st } {
	set n [llength $l]

	if { [expr $n > $c] } {
		puts "Warning: defined more $st ($n) than required ($c)"
	} elseif { [expr $n < $c] } {
		puts "Error: defined less $st ($n) than required ($c)"
		exit 1
	} else {
		#OK
	}
}


#
# check if list has exactly c elements, EXCLUDING first element "0"; show error "st" if not
#
proc check_0_list_length { l c st } {
	set n		[llength $l]
	set first	[lindex $l 0]
	set c 		[expr $c + 1]		;# ignore first (0) element of 0-list 

	if { $first != "_DUMMY_" } {
		puts "Warning: first 0-list element is not _DUMMY_, but $first "
	}

	if { [expr $n > $c] } {
		puts "Warning: defined more $st ($n) than required ($c)"
	} elseif { [expr $n < $c] } {
		puts "Error: defined less $st ($n) than required ($c)"
		exit 1
	} else {
		#OK
	}
}



###################################################################
###################################################################
### otcl debug code fragments



#
# Simple debug puts for usage in otcl instprocs
# Besides the message arguments, it also shows the Object, Class & Method of the Caller instproc
#
# Note: these functions should be protected with "catch" always!!!
#
proc dputs args {
	global CHANNEL 

	global opt
	

	if { [info exists opt(debug_level)] && [expr $opt(debug_level) == 0 ] } {
		return;
	}

	set obj				[lindex [info level -1] 1]
	set actual_class	[lindex [info level -1] 2]
	set actual_instproc	[lindex [info level -1] 3]

	catch {

		set my_class [$obj info class]

		set now [format "%7.7f: " [[Simulator instance] now]]
		puts -nonewline $CHANNEL  "$now $obj ($my_class)(@ ${actual_class}::${actual_instproc}) "
	
		foreach i $args {
			puts -nonewline $CHANNEL "$i "
		}

		puts $CHANNEL ""
	}
}

#
# Long debug puts, that also shows the caller's arguments
#
proc dputsl args {
	global CHANNEL 

	global opt
	if { [info exists opt(debug_level)] && [expr $opt(debug_level) == 0 ] } {
		return;
	}


	set obj				[lindex [info level -1] 1]
	set actual_class	[lindex [info level -1] 2]
	set actual_instproc	[lindex [info level -1] 3]
	#catch { [$obj info class] } my_class

	catch {

		set my_class [$obj info class]

		set now [format "%7.7f: " [[Simulator instance] now]]
		puts -nonewline $CHANNEL  "$now  $obj ($my_class)(@ ${actual_class}::${actual_instproc}) "
	
		# show arguments for this functions	
		foreach i $args {
			puts -nonewline $CHANNEL "$i "
		}
	
		####################################

		# show caller's arguments 
		set callers_args [$actual_class info instargs $actual_instproc]
	
		if { [llength $callers_args] } {
			puts -nonewline $CHANNEL "<<ARGS: "
		
			foreach i $callers_args {
				upvar $i x
				puts -nonewline $CHANNEL "$i: $x  "
			}
		
			puts -nonewline $CHANNEL ">>"
		}
	}
	
	puts $CHANNEL ""
}

#
# proc show: dputsl + body of current instproc
#
proc show args {
	global CHANNEL 

	#puts $CHANNEL ""
	puts $CHANNEL "----------------------"


	uplevel { dputsl }

	set obj			[lindex [info level -1] 1]
	set actual_class	[lindex [info level -1] 2]
	set actual_instproc	[lindex [info level -1] 3]

	puts -nonewline $CHANNEL [list [$actual_class info instbody $actual_instproc]]" 
	puts $CHANNEL "----------------------"
	#	puts $CHANNEL ""
}


#
# proc W: shows where we are in otcl
#
proc W args {
	global CHANNEL 

	uplevel { dputsl }
}



#
# shows all acessible vars of the current class
#
proc v args {
	global CHANNEL 

	set obj				[lindex [info level -1] 1]
	set actual_class	[lindex [info level -1] 2]
	set actual_instproc	[lindex [info level -1] 3]
	catch [$obj info class] my_class


	puts -nonewline $CHANNEL  " DEBUG: "
	puts -nonewline $CHANNEL  " obj $obj ($my_class) (@ ${actual_class}::${actual_instproc})  "


	# show arguments for this functions	(debug string)
	foreach i $args {
		puts -nonewline $CHANNEL "$i "
	}

	######################################
	# show acessible vars
	set callers_vars [$obj info vars]
	puts $callers_vars
}



#
# shows all acessible procs of the current class
#
proc p { { arg_level 0 }} {
	global CHANNEL 

	set obj				[lindex [info level -1] 1]
	set actual_class	[lindex [info level -1] 2]
	set actual_instproc	[lindex [info level -1] 3]
	catch [$obj info class] my_class

	puts -nonewline $CHANNEL  " DEBUG: "
	puts -nonewline $CHANNEL  " obj $obj ($my_class) (@ ${actual_class}::${actual_instproc})  "
	puts $CHANNEL ""



	set level $arg_level

	if { [expr $level >= 0] } {

		######################################
		# show acessibel vars
		puts -nonewline $CHANNEL "$my_class:    "
		
		puts -nonewline $CHANNEL [$my_class info instprocs]
	
		puts $CHANNEL ""

		if { [expr $level >= 1] } {
			
			foreach i [$my_class info heritage] {
	
				if { [expr $level >= 1] } {
	
					puts -nonewline $CHANNEL "$i:    "
					puts -nonewline $CHANNEL [$i info instprocs]
					puts $CHANNEL ""
					
					set level [expr $level - 1]
				}
			}
		}
	}
		
	#puts $CHANNEL ""
}



###################################################################
###################################################################
### otcl CLASS helper code fragments


#
# The following instproc returns a list of all direct and indirect instances of a class
# (taken from ftp://ftp.tns.lcs.mit.edu/pub/otcl/doc/class.html)
#
# note that "<Class> info instances" only gives you the direct instances of that class; this proc is more generic
# by retrieving also the indirect (eg, heritaged) instances.
#
# This proc works by: 
#	a) generating all instances of the class "Class"  (eg, the names of all existing classes)
#	b) for each class of a), check if THAT class is a subclass of THIS class 
#		(note that "$self info subclass" gives the DIRECT subclasses of this class only, and "$self info subclass $i" checks if $i is a DIRECT or INDIRECT subclass of $self
#	c) if yes, collect the classes's instances in a list
# 	d) in the end, return the collected list
#
#
# Supporting Notes:
# ----------------
# Object info subclass     <- gives you the DIRECT subclasses of Object (eg, 1st level)
# Object info subclass XXX <- returns 1 if XXX is a DIRECT or INDIRECT subclasses of Object
# Class info instances     <- gives you ALL existing classes
#
Class instproc instances {} {
	set il {}
	foreach i [Class info instances] {
		if {[$self info subclass $i]} then {
			eval lappend il [$i info instances]
		}	
	}
	return $il
}



#
# The following instproc returns a list of all direct and indirect subclasses of a class
# (based from ftp://ftp.tns.lcs.mit.edu/pub/otcl/doc/class.html)
#
# Note that "class info subclass" only gives you the DIRECT subclasses of that class 
# (altough the second usage form is able to check if it an INDIRECT subclass, it doesn't return the names of it)
#
Class instproc subclass {} {
	set il {}
	foreach i [Class info instances] {
		if {[$self info subclass $i]} then {
			eval lappend il $i
		}	
	}
	return $il
}



#
# The following instproc returns a list of all DIRECT and INDIRECT variables of a class
# (based from ftp://ftp.tns.lcs.mit.edu/pub/otcl/doc/class.html)
#
# note that "Object info vars" only gives you the direct variables of that class; this proc is more generic
# by retrieving also the indirect (eg, heritaged) variables.
#
Class instproc vars {} {
	set il {}
	foreach i [Class info instances] {
		if {[$self info subclass $i]} then {
			eval lappend il [$i info vars]
		}	
	}
	return $il
}



#
# checks if a given variable exists in the current class
#
Class instproc exists_var { var } {
	set il {}
	
	foreach i [Class info vars] {
		if {[$i == $var]} then {
			return 1
		}	
	}
	return 0
}




#
# creates a new instproc p2 exactly equal to a given p1
#
Class instproc clone_instproc { p1 p2 } {

	#
	# retreive code of the instproc p1, but change the name to p2: 
	# (inspired and adapted from http://bmrc.berkeley.edu/research/cmt/cmtdoc/otcl/object.html)
	#

	set txt [list $self instproc $p2]
	set al [$self info instargs $p1]
	set dft {}
	for {set i 0} {$i < [llength $al]} {incr i} {
		set av [lindex $al $i]

		#
		# default argument handling - warning! not tested!
		#
		if {[$self info instdefault $p1 $av dft]} then {
			set al [lreplace $al $i $i [list $av $dft]]
		}
	}
	lappend txt $al
	lappend txt [$self info instbody $p1]
   
	#
	# eval the code, to add instproc with the new name
	#
	#puts $txt
	eval $txt 
}

#
# example usage: renames Simulator::node instproc into "node_previous", replaces with our own wrapper 
#  that calls the original one, and does aditional operations
# NOTE: The same functionality of this example could be acheived equally with "Node instances" (see above)
# 
#Simulator clone_instproc node node_previous
#set global_node_list {}
#
#Simulator instproc node args {
#	global global_node_list
#	
#	puts "inside my version of instproc node"
#	puts "calling previous node version"
#	
#	set node [$self node_previous $args]
#
#	puts "previous node version returned $node"
#
#	lappend global_node_list $node
#	return $node	
#}
#




###################################################################
###################################################################
###  tracegraph debug code fragments 


##
## this function dumps IP information file for tracegraph
## usage:  dump_.tr.ip <name of tracefile (without .tr)> <0/1 (optional argument, dumps the generated .tr.ip file to the screen)>
##
## The function automatically generates conversions for old or new wireless traces. (thanks to Przemek Machan, przemek.machan@wp.pl)
## Previously, the funtion depended on a trivial patch to /tcl/lib/ns-lib.tcl. That is not needed anymore
## If using MOBIWAN, check the alternative conversion below (thanks to Przemek Machan, przemek.machan@wp.pl)
##

## BUG REPORT: TraceGraph simply converts the integer addressess like "2048" via a simple 
## string substitution. This causes ooccourences of this string to be substituted, namely packet sizes, 
## sequence numbers and time values that match the i32 addresses of the nodes. However, this conversion is required, as
## these ip addresses without port information appear in the traces on some (all?) forwarding nodes.
##
## This bug has been reported to the TG author (Jaroslaw Malek), but mainly for copyright reasons it's 
## still not possible to fix it properly (eg, to modifiy TG conversion process to perform string substitutions 
## on the IP addresses fields only).
##
## There are several workarounds that may be used until this bug is solved:
##  - use (much?) higher node addresses, like 10.0.0, that by correponding to much interger higher values, will (hopefully) 
##  not appear on the trace file
##  - modify the code below, marked as "HACK", to generate conversions with port separator for the lowest addresses, and normal for the high ones
##  using this hack, there exists the possibility that low addresses, without port, may be needed by TG. 
##  - code your own file IP address converter that respects IP fields. 
##



#
# Examples of desired conversions, by wireless trace format:
#  old wireless format traces - node:port format. 
#  new wireless trace format - node.port format (eg, with a period instead of a colon!)
#
#
# old wireless trace format:
# --------------------------
# 3.2.1.255   -> 3:255
# 4194305     -> 6
# 4194305:2   -> 6:2
#
# thus: 
#   <hnode>.<port>  ->  <node>:<port>
#   <inode>:<port>  ->  <node>:<port>
#   <inode>         ->  <node>               (note: this case fully encompasses the above one)
#
# thus, it is generated these conversions for all existing nodes: 
#   <hnode>.  <node>:
#   <inode>   <node>                         (note: this case triggers a known bug on the TG conversion process - see below)
#
#
#
# new wireless trace format:
# --------------------------
#
# 3.2.1.255   -> 3.255
# 4194305     -> 6
# 4194305.2   -> 6.2
#
# thus: 
#   <hnode>.<port>  ->  <node>.<port>
#   <inode>.<port>  ->  <node>.<port>
#   <inode>         ->  <node>               (note: again, this case fully encompasses the above one)
#
# thus, it is generated these conversions for all existing nodes: 
#   <hnode>.  <node>.
#   <inode>   <node>                         (note: this case triggers a known bug on the TG conversion process - see below)
#
#
#
# merging the two cases:
#   <hnode>.  <node>$port_separator
#   <inode>   <node>
#


Simulator instproc use-newtrace? {} { 
	$self instvar WirelessNewTrace_
	
	return $WirelessNewTrace_ 
} 


proc dump_.tr.ip { tracename { print_convertion_file 0 } } {
	set ns_ [ Simulator instance ]
	set filename "$tracename.tr.ip"
	set warning 0

	puts stderr "==> dump_.tr.ip"

	puts stderr	"creating IP conversion file $filename"
	set convfd [open $filename w]

	if {[$ns_ use-newtrace?] == 1} {
		puts stderr	"using NEW trace format"
        set separator "."
	} else {
		puts stderr	"using OLD trace format"
        set separator ":"
	}


	#step 1: haddr format to simple nodes conversion
	foreach node_ [Node instances] {
		set id    [handle2id $node_]
		set haddr [handle2haddr $node_]
		
		puts $convfd "$haddr. $id$separator"
	}

	#step 2: iaddr format to simple nodes conversion
	foreach node_ [Node instances] {
		set id    [handle2id $node_]
		set haddr [handle2haddr $node_]
		set iaddr [handle2iaddr $node_]
		puts $convfd "$iaddr $id"

		if { [ expr $iaddr < 4194304 ] } {
			#puts stderr	 "Warning: node $node_  has a very low address number (id $id, haddr $haddr, iaddr $iaddr)."
			set warning 1
		}

		###########
		### HACK 
		##  to use, comment the code above, and uncomment this one.
		#
		# set MAX_TR.IP 2048		;# ajust case-by-case for each simulation
		##
		#if { [ expr $iaddr <= ${MAX_TR.IP} ] } {
		#	puts $convfd "$iaddr$separator $i$separator"
		#} else {
		#	puts $convfd "$iaddr $i"
		#}
	}

	if { $warning } {
		puts stderr	"You SHOULD use high number addresses (eg, 2.X.X and above) to AVOID a known TG conversion bug"
		puts stderr	"check the dump.tr.ip comment, and http://inesc-0.tagus.ist.utl.pt/~pmsrve/ns2/tracegraph.html for more info"
	}

	close $convfd

	#####
	if { $print_convertion_file == 1 } {

		;# shows the generated convertion file

		puts stderr "-------"
		puts stderr "Content of generated $filename:"
		
		set chan [open "$filename"]
		while {[gets $chan line] >= 0} {
		    puts stderr "$line"
		}
		close $chan
	}
	
	puts stderr "<== dump_.tr.ip"
}




##############################################################################
##############################################################################
##############################################################################
##
## dump_.tr.ip MOBIWAN VERSION (contributed by Przemek Machan, przemek.machan@wp.pl)
##

# The procedure calculates mobile node (mnode) COA for BS address (addr)
proc coa_get { addr mnode } {
        set addr_list [split $addr "."]
        set prefix_list [lrange $addr_list 0 [expr [llength $addr_list] -2] ]
        set prefix_string [join $prefix_list "."]
        set suffix [expr [$mnode set id_] % 128]
        return $prefix_string.$suffix
}

# The procedure dumps all possible COAs for the mobile node (mnode)
proc coa_dump { ns mnode ipfile sep haddr} {
        global warning
        # Iterate the list of base stations
        for {set j [expr [Node set nn_] - 1]} { $j >= 0 } { set j [ expr $j - 1]} {
                if {[$ns node_exists $j] == 1} {
                        set n [$ns set Node_($j)]
                        if {[$n node-type] == "BS"} {
                                # Calculate mobile node COA assigned by this BS
                                set coa [coa_get [$n set address_] $mnode]
                                if {$haddr == 1} {
                                        puts $ipfile "$coa. [$mnode set id_]$sep"
                                } else {
                                        set addressObj [[$ns get-AllocAddrBits ""] get-Address]
                                        set iaddr [$addressObj str2addr $coa]
                                        if { [ expr $iaddr < 4194304 ] } {
                                                puts stderr      "Warning: node ([$mnode set address_]) has a very low COA ($iaddr) at BS ([$n set address_])."
                                                set warning 1
                                        }
                                        puts $ipfile "$iaddr [$mnode set id_]"
                                }
                        }
                }
        }
}



Simulator instproc node_exists { i } {
        $self instvar Node_
        return [info exists  Node_($i)]
}



proc dump_.tr.ip_MOBIWAN { tracename } {
        set ns_ [ Simulator instance ]
        set filename "$tracename.tr.ip"
		global warning
        set warning 0


        puts stderr "==> dump_.tr.ip_MOBIWAN"
        puts stderr     "creating IP conversion file $filename"

        set convfd [open $filename w]


        if {[$ns_ use-newtrace?] == 1} {
                puts stderr     "using NEW trace format"
                set separator "."
        } else {
                puts stderr     "using OLD trace format"
                set separator ":"
        }

        #step 1: haddr format to simple nodes conversion
        for {set i [expr [Node set nn_] - 1]} { $i >= 0 } { set i [ expr $i - 1]} {
                if {[$ns_ node_exists $i] == 1} {
                        set node_ [$ns_ set Node_($i)]

                } else {
                        # assume that the node is in the MNode_() table
                        set node_ [$ns_ set MNode_($i)]
                        # dump all possible COAs for the current node
                        coa_dump $ns_ $node_ $convfd $separator 1
                }
                puts $convfd "[$node_ set address_]. $i$separator"        }

        #step 2: iaddr format to simple nodes conversion
        for {set i [expr [Node set nn_] - 1]} { $i >= 0 } { set i [ expr $i - 1]} {
                if {[$ns_ node_exists $i] == 1} {
                        set node_ [$ns_ set Node_($i)]
                } else {
                        # assume that the node is in the MNode_() table
                        set node_ [$ns_ set MNode_($i)]
                        # dump all possible COAs for the current node
                        coa_dump $ns_ $node_ $convfd $separator 0                 }
                set iaddr [$node_ address?]

                if { [ expr $iaddr < 4194304 ] } {
                        puts stderr      "Warning: node $node_  has a very low address number ($iaddr)."
                        set warning 1
                }

                puts $convfd "$iaddr $i"

        }
        close $convfd

        if { $warning } {
                puts stderr     "You SHOULD use high number addresses (eg, 2.X.X and above) to AVOID a known TG conversion bug"
                puts stderr     "check the dump.tr.ip comment, and http://inesc-0.tagus.ist.utl.pt/~pmsrve/ns2/tracegraph.html for more info"
        }


        #####
        set print_convertion_file 0
        if { $print_convertion_file == 1 } {

                ;# shows the generated convertion file

                puts stderr "-------"
                puts stderr "Content of generated $filename:"

                set chan [open "$filename"]
                while {[gets $chan line] >= 0} {
                    puts stderr "$line"
                }
                close $chan
        }

        puts stderr "<== dump_.tr.ip_MOBIWAN"

}



###################################################################
###################################################################
### NAM animator debug code fragments


#
# Annotate NAM trace file with TIME information
#
proc trace_annotate_time_at { tempo str } {
	set ns_ [Simulator instance]

	$ns_ at $tempo  "trace_annotate_time [list $str] "
}



proc format_fp { fp } {
	set ret [format %7.7f $fp]
}



#
# Annotate NAM trace file with TIME information
#
proc trace_annotate_time { str { doprint 1 } } {
	set ns_ [Simulator instance]

	set st [format "%7.7f: %s" [$ns_ now] $str]

	$ns_ trace-annotate $st

	if { $doprint == 1 } {
		puts $st
	}
}



# rate's unit is second
Simulator instproc set-animation-rate { rate } {
	set r [time_parse $rate]
	$self puts-nam-config "v -t [$self now] -e set_rate_ext $r 1"
}




###################################################################
###################################################################
### Nodes, Int addresses Hierarquical addresses helper functions 


##
## In NS2, a node can be uniquevely identified by several forms
##
##  the "handle" is the otcl name; it refers to an object of the form "_oXXX", and 
##      because of this, it is the only form can be used to directly call internal 
##      instprocs and variables.
##  the "haddr" is the Hierarquical address, on the form "X.Y.Z" 
##  the "iaddr" is the INTEGER hieralquical address, where the haddr string is simply
##      ENCODED in a 32 bit integer.
##  the "id" is the sequential Node ID of the simulator.
##
## The proposed variable names and contents are outlined in the following table. 
## For unknown nodes or in error conditions, the value "-1" is generally used. 
##   (however 
##
##
## Type                   |  VarNames   |  C++ type |  TCL           | Example     | Error / UNK
## -----------------------|-------------|-----------|----------------|-------------|--------------
## Node's handle          |  N_handle   |  char *   | string         | "_o89"      | "-1"
## String HierAddress     |  N_haddr    |  char *   | string         | "1.2.3"     | "-1"
## 32 bit Address         |  N_iaddr    |  int      | int in string  | 6144        | -1
## Sequential ID          |  N_id       |  int      | int in string  | 4           | -1
##


#
# Conversion functions that take account the UNK/ERROR values (eg, "-1")
# <FIXME> - these convertion procs requires that all nodes are contained in the Simulator::Node array, which may 
# not be the case for Mobile Nodes
#


# Given the node handle, return the haddr, iaddr or ID
proc handle2iaddr { handle } {

	if { $handle == "-1" } {
		return "-1"
	}

	set iaddr [$handle address?]
	return $iaddr
}



proc handle2haddr { handle } {
	if { $handle == "-1" } {
		return "-1"
	}

	set haddr [$handle set address_]
	return $haddr
}

proc handle2id { handle } {
	if { $handle == "-1" } {
		return "-1"
	}

	set id [$handle id]
	return $id
}

#
# Given the node's address in haddr, iaddr or ID, search and return the handle
# (TODO:) create an array at creation to store these pairs for faster lookup
#
proc iaddr2handle { node_iaddr } {
	if { $node_iaddr == "-1" } {
		return "-1"
	}

	set ns_ [Simulator instance]

	for {set i 0} { $i < [Node set nn_]} {incr i} {
		set node_handle [$ns_ set Node_($i)]
		
		if {[string compare [handle2iaddr $node_handle] $node_iaddr] == 0} {
			return $node_handle
		}
	}
	
	return "-1"
}


proc haddr2handle { node_haddr } {
	if { $node_haddr == "-1" } {
		return "-1"
	}

	set ns_ [Simulator instance]

	for {set i 0} { $i < [Node set nn_]} {incr i} {
		set node_handle [$ns_ set Node_($i)]
		
		if {[string compare [handle2haddr $node_handle] $node_haddr] == 0} {
			return $node_handle
		}
	}
	
	return "-1"
}


proc id2handle { node_id } {
	if { $node_id == "-1" } {
		return "-1"
	}

	set ns_ [Simulator instance]

	#
	#note: simple "set nh_handle [$ns_ set Node_($id)]" would fail in an unkownn ID!
	#
	for {set i 0} { $i < [Node set nn_]} {incr i} {
		set node_handle [$ns_ set Node_($i)]
		
		if {[string compare [handle2id $node_handle] $node_id] == 0} {
			return $node_handle
		}
	}
	
	return "-1"
}


# remaining conversion procs 
# note that more efficient possibilities DO exist; this code aims for simplicity only
proc id2iaddr { id } {

	return [handle2iaddr [id2handle $id]] 
}

proc id2haddr { id } {

	return [handle2haddr [id2handle $id]] 
}


proc iaddr2id { iaddr } {

	return [handle2id [iaddr2handle $iaddr]] 
}

proc iaddr2haddr { iaddr } {

	return [handle2haddr [iaddr2handle $iaddr]] 
}



proc haddr2id { haddr } {

	return [handle2id [haddr2handle $haddr]] 
}

proc haddr2iaddr { haddr } {

	return [handle2iaddr [haddr2handle $haddr]] 
}


#######################

proc test_conversion_procs { }  {
	set ns_ [Simulator instance]

	puts "==> test_conversion_procs()"

	# part 1 - existing nodes
	for {set id 0} { $id < [Node set nn_]} {incr id} {
		set handle [id2handle $id]
		set haddr  [id2haddr  $id]
		set iaddr  [id2iaddr  $id]

		# perform conversions
		set id_from_handle [handle2id $handle]
		set id_from_haddr  [haddr2id $haddr]
		set id_from_iaddr  [iaddr2id $iaddr]

		#debug 1
		# check conversions
		assert ( $id == $id_from_handle )
		assert ( $id == $id_from_haddr )
		assert ( $id == $id_from_iaddr )


		# confirm that no error values were generated 
		assert " $id != \"-1\"  "

		## be verbose
		dump_node_info $handle
	}

	# part 2 - error values

	assert " [haddr2iaddr NOTHING] == -1" 
	assert " [iaddr2id   NOTHING] == -1"

	puts "<== test_conversion_procs: OK "
}



proc dump_node_info { handle } {
	set node_id [handle2id $handle]
	set node_haddr [handle2haddr $handle]
	set node_iaddr [handle2iaddr $handle]

	puts "ID: $node_id\t haddr: $node_haddr\tHandle: $handle\tiaddr: $node_iaddr "
}

#######
# Simulator instproc wrappers 

Simulator instproc handle2iaddr { handle } {
	return [handle2iaddr $handle ]
}

Simulator instproc handle2haddr { handle } {
	return [handle2haddr $handle ]
}

Simulator instproc handle2id { handle } {
	return [handle2id $handle ]
}

Simulator instproc iaddr2handle { node_iaddr } {
	return [iaddr2handle $node_iaddr ]
}

Simulator instproc haddr2handle { node_haddr } {
	return [haddr2handle $node_haddr ]
}

Simulator instproc id2handle { node_id } {
	return [id2handle $node_id ]
}

Simulator instproc id2iaddr { id } {
	return [id2iaddr $id ]
}

Simulator instproc id2haddr { id } {
	return [id2haddr $id ]
}

Simulator instproc iaddr2id { iaddr } {
	return [iaddr2id $iaddr ]
}

Simulator instproc iaddr2haddr { iaddr } {
	return [iaddr2haddr $iaddr ]
}

Simulator instproc haddr2id { haddr } {
	return [haddr2id $haddr ]
}

Simulator instproc haddr2iaddr { haddr } {
	return [haddr2iaddr $haddr ]
}


#
# Equivelences to original functions scatered in the NS2 codebase
#
# id2handle		-> Simulator::get-node-by-id 
# handle2haddr	-> Node::node-addr 
# haddr2handle	-> Simulator::get-node-id-by-addr 
#
	



###################################################################
###################################################################
### RouteLogic Dumping Functions, Hierarchical addresses debugging  


#
# debugging method to dump table (see route.cc for C++ methods)
#
# pmsrve: my own version of the debug proc present in tcl/lib/ns-route.tcl 
#  This proc shows how each nodes reach all other nodes (eg, what is the next hop )
#
#
RouteLogic instproc dump { { nn 999}  } {
	
	# limit to the maximum existing nodes
	if { $nn > [Node set nn_] } {
		set nn [Node set nn_]
	}

	set i 0
	while { $i < $nn } {
		set j 0
		while { $j < $nn } {
			set ns_ [Simulator instance]
			puts "$i -> $j via [$self lookup $i $j]"
		    incr j
		}
		incr i
	}
}



#
# Debug proc: Shows which routes are being used to reach all nodes, up to node nn (optional)
# Returns:  Number of unreachable pairs
#
RouteLogic instproc check_unreachable_nodes { { nn 999}  } {

	set ns_ [Simulator instance]
	
	# limit to the maximum existing nodes
	if { $nn > [Node set nn_] } {
		set nn [Node set nn_]
	}
	set count 0

	puts "*******************************"
	puts "==> check_unreachable_nodes(till $nn) ([$ns_ now]) "

	set i 0
	while { $i < $nn } {
		set j 0
		while { $j < $nn } {
		
			## vê se os nós existem mesmo antes de os usar
			if { [expr [$ns_ node_exists $i] & [$ns_ node_exists $j] ] } {
				set via [$self lookup $i $j]
				
				if { $via == -1 } {
					puts "$i -> $j via $via (UNREACHABLE)"
					incr count
				}
			}
		    incr j
		}
		incr i
	}

	puts "<== check_unreachable_nodes()  ([$ns_ now])  ($count unrechable)"
	puts "*******************************"
	
	return $count
}


#
# Debug proc: Shows which routes are being used to reach a certain node N
# Returns:  Number of nodes that can't reach N
#
RouteLogic instproc routes_to { j } {

	set ns_ [Simulator instance]

	set nn [Node set nn_]
	puts "*******************************"
	puts "==> All Routes TO Node $j"

	set i 0
	while { $i < $nn } {

		set via [$self lookup $i $j]
				
		if { $via == -1 } {
			puts "$i -> $j via $via (UNREACHABLE)"
			incr count
		} else {
			puts "$i -> $j via $via"
		}

		incr i
	}

	puts "<== Routes_to Node $j   ($count unrechable)"
	puts "*******************************"
	return $count
}



#
# Debug proc: Shows which routes are being used to reach a certain node N
# Returns:  Number of nodes not reachable by N
#
RouteLogic instproc routes_from { i } {

	set ns_ [Simulator instance]

	set nn [Node set nn_]
	puts "*******************************"
	puts "==> All Routes FROM Node $i"

	set j 0
	while { $j < $nn } {

		set via [$self lookup $i $j]
				
		if { $via == -1 } {
			puts "$i -> $j via $via (UNREACHABLE)"
			incr count
		} else {
			puts "$i -> $j via $via"
		}

		incr j
	}

	puts "<== Routes_from Node $i   ($count unrechable)"
	puts "*******************************"
	return $count
}


#
# Imporant Hierarquical addresses explanations from NS manual and Marc Greis tutorial
#
# NS Manual:
#
#   "Instead, for hierarchical routing, a given node needs to know about its neighbours in its own cluster, 
# about the all clusters in its domain and about all the domains. This saves on memory consumption as 
# well as run-time for the simulations using several thousands of nodes in their topology."
#
#
# Tutorial Marc Greis:
#
# AddrParams set domain_num_ 3           ;# number of domains
# lappend cluster_num 2 1 1              ;# number of clusters in each domain
# AddrParams set cluster_num_ $cluster_num
# lappend eilastlevel 1 1 2 1            ;# number of nodes in each cluster 
# AddrParams set nodes_num_ $eilastlevel ;# of each domain
#
#    So in this topology we have one wired domain (denoted by 0) and 2 wireless domains 
# (denoted by 1 & 2 respectively). Hence as described in section X.1, the wired node 
# addresses remain the same, 0.0.0 and 0.1.0. In the first wireless domain (domain 1)
# we have base-station, HA and mobilenode, MH, in the same single cluster. 
#    Their addresses are 1.0.0 and 1.0.1 respectively. For the second wireless domain 
# (domain 2) we have a base-station, FA with an address of 2.0.0.
# However in the course of the simulation, the MH will move into the domain of FA
# and we shall see how pkts originating from a wired domain and destined to MH 
# will reach it as a result of the MobileIP protocol. 
#



###################################################################
###################################################################
### AddrParams Helper Functions  

#
# This function will apply the chosen parameters for Domains, clusters and number of nodes
# basic validity checks are performed
#
proc apply_hier_parameters { domain_num cluster_num eilastlevel } {
	set ns_ [Simulator instance]
	$ns_ node-config -addressType hierarchical

	puts ""
	puts "***** hierarchical settings *******"
	puts "domain_num: $domain_num"
	puts "cluster_num: $cluster_num"
	puts "eilastlevel: $eilastlevel"

	# basic safety checks
	assert ( [llength $cluster_num] == $domain_num )
	assert ( [llength $eilastlevel] == [expr [lsum $cluster_num] ])

	AddrParams set domain_num_ $domain_num
	AddrParams set cluster_num_ $cluster_num
	AddrParams set nodes_num_ $eilastlevel
}

#
# This function will generate and apply some simple hier_parameters, based only on number of domains, 
# clusters and nodes. However, greater memory savings are acheived by calling directly 
# apply_hier_parameters() with more specific parameters
#
proc choose_simple_hier_parameters { { domains 5 } { clusters 5 } { nodes 10 } } {

	# DOMAINS
	set domain_num $domains

	# CLUSTERS
	set cluster_num ""
	for {set i 0} {$i < $domains } {incr i} {
		lappend cluster_num $clusters
	}
	
	# LAST_LEVEL
	set eilastlevel ""
	for {set i 0} {$i < [expr [lsum $cluster_num] ] } {incr i} {
		lappend eilastlevel $nodes
	}
	
	apply_hier_parameters $domain_num $cluster_num $eilastlevel 
}









###################################################################
###################################################################
### TCL List simple stats

proc list_calc_n { l } {
	set n 0 
	foreach i $l {
		incr n	
	}

	return $n
}


proc list_calc_avg { l } {


	set n [list_calc_n $l]
	set sum 0 

	foreach i $l {
		set sum [expr $sum + $i + 0.0 ]
	}

	set avg [expr $sum / $n ]
	return $avg
}


proc list_calc_stddev { l } {

#
#In other words, the standard deviation of a discrete uniform random variable X can be calculated as follows:
#
#- Calculate the average (mean) value . 
#- For each value xi calculate the difference  between xi and the average value . 
#- Calculate the squares of these differences. 
#- Find the average of the squared differences. This quantity is the variance s2. 
#- Take the square root of the variance. 
#

	set n [list_calc_n $l]
	set avg [list_calc_avg $l]
	set var_sum 0.0
	
	foreach i $l {
		set dif  [expr $i - $avg + 0.0 ]
		set dif2 [expr $dif * $dif + 0.0 ]
	
		set var_sum [expr $var_sum + $dif2 + 0.0 ]
	}

	set var [expr $var_sum / $n + 0.0 ]
	set dev [expr sqrt($var) ]
	return $dev
}


proc list_calc_min { l } {

	set min 99999999.0 

	foreach i $l {
		if { $i < $min } {
			set min [expr $i + 0.0 ]
		}
	}
	return $min
}



proc list_calc_max { l } {

	set max 0.0 

	foreach i $l {
		if { $i > $max } {
			set max $i
		}
	}
	return $max
}


proc list_calc_dump_all { l } {
	puts "lista_dump: N [format_fp [list_calc_n $l]]  AVG [format_fp [list_calc_avg $l]] \
  STDDEV [format_fp [list_calc_stddev $l]]  MIN [format_fp [list_calc_min $l]] \
  MAX [format_fp [list_calc_max $l]]"

	#puts " $l"
}


proc list_calc_dump_avg_min_max { l } {
	puts "[list_calc_avg $l]\t [list_calc_min $l]\t [list_calc_max $l]"
}


proc list_get2 { l } {
	set r {}
	
	foreach { a b } $l {
		set r [lappend r $b]
	}

	return $r
}


# ARRAYS vs LISTAS:
#array set A {city Hamilton state TX zip 34567} 
#set L [array get A] 
