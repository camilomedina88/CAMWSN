# srnode.tcl
# $Id: dsdvnode.tcl,v 1.2 1998/02/22 17:02:24 dmaltz Exp $

# ARGH! this is broken in the presence of multiple links...
# the forwarder needs to figure out what the right target is
#  since there could be multiple targets.  the source route itself
#  must also encode which inf the packet should be sent out.

Class DSDVNode -superclass MobileNode

DSDVNode instproc init {args} {
    eval $self next $args	;# parent class constructor

    $self mobile_ 1
    $self forwarding_ 1
}

DSDVNode instproc add-if { channel pmodel		\
				{ file "" }		\
				{ lltype  LL }		\
				{ mactype Mac }		\
				{ iftype  NetIf/WaveLAN } } {
    global ns_
    $self instvar classifier_ forwarder_ num_ifs_

    eval $self next $channel $pmodel $file $lltype $mactype $iftype

    set forwarder_ [new Agent/DSDV]

    if {$num_ifs_ > 1} {
	puts "WARNING: more than one if"
    }
# WARNING: assumption of only 1 interface made here... XXX -dam 1/20/98
    $self attach-router $forwarder_
    $forwarder_ target [$self get-queue 0]
    $classifier_ defaulttarget $forwarder_

#    set tracefd [lindex $args 2];
#    if {$tracefd != ""} {
#	set T [new Trace/Generic]
#	$T target [$ns_ set nullAgent_]
#	$T attach $tracefd
#	$T set src_ [$self id]
#
#	$forwarder_ tracetarget $T
#    }
}

DSDVNode instproc start-dsdv {} {
#    $self start
# If you uncomment that line, you will be SCREWED!
    $self instvar forwarder_
    $forwarder_ start
}

#DSDVNode instproc attach agent {
#    eval $self next $agent
#    
#    set addsr [new Connector/AddSR]
#    $addsr target [$agent target]
#    $agent target $addsr
#}
