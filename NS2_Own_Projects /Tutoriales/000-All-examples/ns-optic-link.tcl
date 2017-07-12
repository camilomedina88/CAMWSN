 #   Copyright (c) University of Maryland, Baltimore County, 2003.
#    Original Authors: Ramakrishna Shenai, Sunil Gowda and Krishna Sivalingam.
  
#    This software is developed at the University of Maryland, Baltimore County under
#    grants from Cisco Systems Inc and the University of Maryland, Baltimore County.
  
#    Permission to use, copy, modify, and distribute this software and its
#    documentation in source and binary forms for non-commercial purposes
#    and without fee is hereby granted, provided that the above copyright
#    notice appear in all copies and that both the copyright notice and
#    this permission notice appear in supporting documentation. and that
#    any documentation, advertising materials, and other materials related
#    to such distribution and use acknowledge that the software was
#    developed by the University of Maryland, Baltimore County.  The name of
#    the University may not be used to endorse or promote products derived from
#    this software without specific prior written permission.
  
#    Copyright (C) 2000-2003 Washington State University. All rights reserved.
#    This software was originally developed at Alcatel USA and subsequently modified
#    at Washington State University, Pullman, WA  through research work which was
#    supported by Alcatel USA, Inc and Cisco Systems Inc.

#    The  following notice is in adherence to the Washington State University
#    copyright policy follows.
  
#    License is granted to copy, to use, and to make and to use derivative
#    works for research and evaluation purposes, provided that Washington
#    State University is acknowledged in all documentation pertaining to any such
#    copy or derivative work. Washington State University grants no other
#    licenses expressed or implied. The Washington State University name
#    should not be used in any advertising without its written permission.
  
#    WASHINGTON STATE UNIVERSITY MAKES NO REPRESENTATIONS CONCERNING EITHER
#    THE MERCHANTABILITY OF THIS SOFTWARE OR THE SUITABILITY OF THIS SOFTWARE
#    FOR ANY PARTICULAR PURPOSE.  The software is provided "as is"
#     without express or implied warranty of any kind. These notices must
#    be retained in any copies of any part of this software.
  

OBSFiberDelayLink set bandwidth_ 1.5Mb
OBSFiberDelayLink set delay_ 100ms
OBSFiberDelayLink set wvlen_num_ 8
OBSFiberDelayLink set debug_ 0

#GMG -- inserted these dummy functions - needed for tracing because the
# Connector object has replaced the queue object.
# Dummy function for all the queues that don't implement attach-traces
#
Connector instproc attach-traces {src dst file {op ""}} {
	#Do nothing here
}

Connector instproc attach-nam-traces {src dst file {op ""}} {
	#Do nothing here
}

Simulator instproc duplex-link-of-interfaces { n1 n2 bw delay linktype args } {
        eval $self obs_duplex-FiberLink $n1 $n2 $bw $delay $linktype 8 $args
}

# create a duplex link with the provided nodes delay bw and linktype
Simulator instproc obs_duplex-FiberLink { n1 n2 bw delay linktype nlambda args } {
        $self instvar link_
        set i1 [$n1 id]
        set i2 [$n2 id]

        if [info exists link_($i1:$i2)] {
                $self remove-nam-linkconfig $i1 $i2
        }

        eval $self obs_simplex-FiberLink $n1 $n2 $bw $delay $linktype $nlambda $args
        eval $self obs_simplex-FiberLink $n2 $n1 $bw $delay $linktype $nlambda $args
}

Simulator instproc obs_simplex-FiberLink { n1 n2 bw delay linktype nlambda args } {
	$self instvar link_ 

	#
	# create the common simple-link between nodes
	#
        #eval $self simplex-link $n1 $n2 $bw $delay $linktype $args

        set sid [$n1 id]
        set did [$n2 id]
 
	# use connector to replace queue, in OWNS
	if { $linktype == "ErrorModule" } {
		if { [llength $args] > 0 } {
                	set q [eval new $linktype $args]
                } else {
                        set q [new $linktype Fid]
                }                             
	} else {
        	set q [new Connector]
	}


	# create fiber link
        set link_($sid:$did) [new obs_SimpleFiberLink $n1 $n2 $bw $delay $q]

	# set fiber delay link's wvlen_num_
	[$link_($sid:$did) set link_] set wvlen_num_ $nlambda

        $n1 add-neighbor $n2
 
#GMG - uncommented the tracing
	# trace and nam trace
         set tracefile [$self get-ns-traceall]
         if {$tracefile != ""} {
                 $self trace-queue $n1 $n2 $tracefile
         }
         set namtracefile [$self get-nam-traceall]
         if {$namtracefile != ""} {
                 $self namtrace-queue $n1 $n2 $namtracefile
         }
 
        # Register this simplex link in nam link list. Treat it as
        # a duplex link in nam                                                

        $self register-nam-linkconfig $link_($sid:$did)              
	
	#
	# Store wavelength information
	#
	set wbw [expr [$self bw_parse $bw] / $nlambda]

	# call C++ to register wavelength information - not reqd for OBS
	#[$self get-wassign-logic] register-wvlen $sid $did $nlambda $wbw

        #
        # set trace on lightpath classifier of nodes
        #
        # GMG commented out the lines below, as they are inserted above
        # set tracefile [$self get-ns-traceall]
        # set namtracefile [$self get-nam-traceall]

	#
	# direct dropped packets from classifiers to link queue's drophead
	# drop-target is in C++ command
	#

 	set classifier [$n1 set classifier_] 
 	set droptarget [$classifier drop-target] 

	#
	# Sigh, there might have more than one
	# link queue which help drop packets,
	# but we only select the first one.
	#
	# In nam, it does not make difference, 
	# but in trace file, there might be confused with
	# the normal dropped packets.
	#
 	if { $droptarget == "" } {
 		set drophead [$link_($sid:$did) set drophead_]
 		eval $classifier drop-target $drophead
 	}
        
}

Class obs_SimpleFiberLink -superclass SimpleLink
 
obs_SimpleFiberLink instproc init { src dst bw delay q {lltype "OBSFiberDelayLink"} } {      
	$self next $src $dst $bw $delay $q $lltype
}




