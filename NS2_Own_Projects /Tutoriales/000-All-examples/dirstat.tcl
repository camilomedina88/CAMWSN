###########################################################################
# 
# Tmac - Tcl Macros: Sample usage script #1
#
# Part of: 
# Tmac version 0.2 Copyright (c) 2003 Roy E. Terry
# 
# The Tmac package and the software in this file are licensed similarly
# to Tcl/Tk.  Please see "tmac.license" in this directory for details.
# 
#===========================================================================
#
# INTRODUCTION TO SAMPLE SCRIPT #1
#
#  This script only intended to show examples of some possible
#  ways of using Tmac. These examples are contrived and aren't intended
#  as any sort of design suggestions. 
# 
# The purpose is to expose in detail how some macros can be defined and
# invoked. Notice that only block macros are demonstrated here. For
# examples of filter macros see the controls.tmac
#
#
#===========================================================================

if {[string match wish* [file tail [info nameofexecutable] ] ]
     && [info proc tkcon_puts] eq ""} {
    wm withdraw .
    console show
}



puts "\n***** Tmac Sample program #1 - \"dirstats\" *****\n"


# Expect sample to be in same dir as packace provider script
lappend auto_path [file dirname [info script]]

package require tmac


# The rest of this file is macro-enhanced Tcl code. So it must be
# pre-processed before the Tcl interpreter sees it. "tmac::tmeval" is
# used here to accomplish pre-processing. Other methods would be
# "tmsource" - called from a separate file, or "tmproc" (provided the
# code was wrapped in Tcl procs).


tmac::tmeval {

    # Sample application showing modes use of tmac.
    # Computes and displays statistics about current or given directory

    # Interpret argv and apply glob to get file name list
    if {[info exists argv] && $argv ne ""} {
        set files [eval glob -nocomplain $argv]
        # if we got a single dir name then take its contents
        if {[llength $files] == 1 && [file isdirectory [lindex $files 0]]} {
            set files [glob [file join [lindex $files 0] *] ]
        }
    } else {
        set files [glob *]
        set argv *
    }
    set files [lsort -dictionary $files]



    # Build a list of attributes for each file
    set stats(numfiles) 0
    set stats(numbytes) 0
    foreach f $files {
        file stat $f a
        lappend flist [list $f $a(size) $a(type) $a(mtime) \
                    [file readable $f] [file writable $f] [file executable $f] \
                    [file extension $f] ]
        incr stats(numfiles)
        incr stats(numbytes) $a(size)
    }

    puts -nonewline " =Dirstats for \"[join $argv]\" includes: "
    puts "$stats(numfiles) files totaling $stats(numbytes) bytes= \n"
    puts " =STAT=   ==DATA=========================================="

    # Macros to access file properties are an example of named constants
    MAC-BLOCK name   0
    MAC-BLOCK size   1
    MAC-BLOCK type   2
    MAC-BLOCK mtime  3
    MAC-BLOCK read   4
    MAC-BLOCK write  5
    MAC-BLOCK exec   6
    MAC-BLOCK ext    7

    # Calc size stats

    # MACROS that build in some logic some vars and some data structure
    # "-parse simple" means that double quotes at invocation will define 
    # parameters and then be discarded (-parse keepwrap would preserve "")

    # minmax => mix
    MAC-BLOCK mixSTAT -parse simple tag val {
        if {$stats(@tag,max,val) <= @val} {
            set stats(@tag,max,val) @val
            set stats(@tag,max,rec) $fp
        } 
        if {$stats(@tag,min,val) >= @val} {
            set stats(@tag,min,val) @val
            set stats(@tag,min,rec) $fp
        } 
    }

    set stats(size,max,val) 0
    set stats(mtime,max,val)  0
    set stats(size,min,val) 2147483648
    set stats(mtime,min,val)  [clock seconds]

    foreach fp $flist {
        # Illustrates ability to nest macro invocations.
        <:mixSTAT size "[lindex $fp <:size:>]" :>
        <:mixSTAT mtime "[lindex $fp <:mtime:>]" :>
    }

    # Experimental use of backslash in macro definition
    MAC-BLOCK mixPROP mix propIN propOUT \
    {[lindex $stats(@propIN,@mix,rec) @propOUT]}


    # Format an incoming value by type
    MAC-BLOCK mixFMT v typ { [switch @typ num "subst @v" date {clock format @v -format %Y.%m.%d,%T}] }

    # Output a min/max pair of values in variable formats
    # Notice there is a macro call inside this definition. The nested 
    # call will be expanded after the enclosing call is expanded (not when
    # the enclosing call is defined.)
    MAC-BLOCK mixOUT h1 h2 p typ {
        puts "[format %8s @h1:] [format %20s <:mixFMT $stats(@p,max,val) @typ :>]\
              - <:mixPROP max @p <:name:>:>"
        puts "[format %8s @h2:] [format %20s <:mixFMT $stats(@p,min,val) @typ :>]\
              - <:mixPROP min @p <:name:>:>"
    }

    <:mixOUT Large Small size num :>
    <:mixOUT Newest Oldest mtime date :>
    puts ""


    # Do some accumulating of discrete categories
    # Translates 1/0 to YES/NO
    # This method of empty list enties is fastest alternative 
    # from Tcl Wiki page http://mini.net/tcl/676
    MAC-BLOCK tallyPROPCATS p {
        set _v [lindex $fp <:@p:>]
        switch $_v {
            "" {set _v (NONE)}
            1 {set _v YES}
            0 {set _v NO}
        }
        
        lappend _pc(@p,$_v) {}
        set _pcnames(@p) 1
   }

    foreach fp $flist {
        <:tallyPROPCATS ext:>
        <:tallyPROPCATS exec:>
        <:tallyPROPCATS type:>
        <:tallyPROPCATS read:>
        <:tallyPROPCATS write:>
    }

    # Make initial substring go away - works on var names
    MAC-BLOCK TRIMPRE vs vpre {[string range $@vs [expr {[string length $@vpre]+1}] end]}

    # Put out a fixed width field
    # Notice how 's' at the end of width is not a factor in param expansion
    MAC-BLOCK FF -parse simple width str {[format %@widths @str]}

    foreach p [lsort [array names _pcnames]] {
        puts -nonewline <:FF 8 "[string toupper $p]:" :>
        set line "  "
        set lim 60
        foreach k [lsort [array names _pc $p,*]] {
            set slot <: TRIMPRE k p :>
            append line " <:FF 6.6 $slot:>[format %3d [llength $_pc($k)]] files|"

            # Do explicit line wrapping aligning with preceeding line
            if {[string length $line] > $lim} {
                append line "\n [string repeat " " 9]"
                incr lim 62
            }
        }
        puts $line
    }
}
# End of Tmac Sample Application #1
