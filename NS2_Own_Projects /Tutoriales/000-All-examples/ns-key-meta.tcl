Class KeyMetaData -superclass Set/KeySet

KeyMetaData instproc metatostring {} {
    
    return [$self settolist]
}

KeyMetaData instproc stringtometa {l} {
    
    $self addlist $l
}

KeyMetaData instproc maptosize {} {

    # By default, the size of the data is 500 times the number
    # of elements of meta-data
    set els [$self numelements]

    return [expr $els * 500]
}

Class ListMetaData -superclass KeyMetaData

ListMetaData instproc getkey {element} {
    
    return [lindex $element 0]
}



