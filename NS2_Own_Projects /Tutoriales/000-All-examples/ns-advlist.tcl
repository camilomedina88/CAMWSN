Class Advlist -superclass Set/KeySet

Advlist instproc add {key element} {

    if {[$self member $key] == 1} {
	set el [$self findelement $key]
	$el union $ element
    } else {
	$self next $key $element
    }

    return
}

Advlist instproc pp {args} {

    set desc "Set"
    if {[llength $args] == 1} {
	set desc [lindex $args 0]
    }
    
    set list [$self settolist]
    set n [$self numelements]

    puts -nonewline "$desc has $n elements. ( "
    foreach el $list {
	set key [lindex $el 0]
	set meta [lindex $el 1]
	set metastring [$meta metatostring]
	puts -nonewline "($key : $metastring) "
    }
    puts ")"
}

Advlist instproc addADV {sender meta} {
    
    $self add $sender [$meta copy]
}

Advlist instproc findADV {sender} {

    return [$self findelement $sender]
}
