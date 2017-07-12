#------------------------------------------------------------------------------
# Tmac - The Tcl Macro Package
# 
#   Copyright (C) 2003, Roy Terry
#   Version 1.0 December 2003
#------------------------------------------------------------------------------

if {[catch {package require Tcl 8.4}]} {
    error "Tmac requires Tcl 8.4 or higher"
}

namespace eval tmac {
    variable macs
    variable lmacs
    variable config
}

proc tmac::tmsetcomments {c1 c2} {
    variable config
    set config(comstart) $c1
    set config(comend) $c2
    set config(comRE) [_tmREEscape $c1].*[_tmREEscape $c2]
}
proc tmac::tmsetdelims {d1 d2} {
    variable config
    set config(macstart) $d1
    set config(macend) $d2
    set config(macRE) [_tmREEscape $d1]|[_tmREEscape $d2]
}
proc tmac::_tmREEscape {re} {
    variable config
    # Escape RE chars that may be also used as delimiters
    # Probably a source of bugs...
    set RECALC {([^\\]??)([][()+|?*.{}^$])}
    regsub -all $RECALC $re {\1\\\2} out
    return $out
}
proc tmac::tmeval {s} {
    return [uplevel 1 [tmfindexpand $s] ]
}
proc tmac::xtmsource {file} {
    # Simulate the normal source command but first read 
    # embedded macro definitions and expand invocations.
    # MYSTERY: This version seems to work but leads to tcltest
    # not removing the files
    set tmsch [open $file r]
    # set data [read $ch]
    # close $ch
    # set newdat [tmfindexpand $data]

    # BEWARE: errors are passed right on up!
    # string2File $newdat tmsource.out
    uplevel 1 [tmfindexpand [read $tmsch]]
    # puts "HI MOM $tmsch"
    close $tmsch
}
proc tmac::tmsource {file} {
    # Simulate the normal source command but first read 
    # embedded macro definitions and expand invocations.
    set ch [open $file r]
    set data [read $ch]
    close $ch
    set newdat [tmfindexpand $data]

    # BEWARE: errors are passed right on up!
    # string2File $newdat tmsource.out
    uplevel 1 $newdat
}
proc tmac::tmfileio {in out} {
    # process infile for defs and expansions. Put result in out
    set chin [open $in r]
    set chout [open $out w]
    puts -nonewline $chout [tmfindexpand [read $chin]]
    close $chin
    close $chout
}

proc tmac::tmproc {args} {
    # macro process a procedure body before defining it.
    # At moment we only handle global procs.

    foreach {a b} $args {break}

    # Currently only 1 possible arg pair
    # -lifetime local|global

    set life local ;# DEFAULT value
    if {$a eq "-lifetime"} {
        # TODO - warn if unknown value supplied
        set life $b
        set offset 2
    } else {
        set offset 0
    }
    
    if {[llength $args] - $offset != 3} {
        error "wrong number of args for tmproc\
            \nshould be: ?-lifetime global|local? procName procArgs procBody"
    }
    set deflist ""
    proc ::[lindex $args $offset] \
           [lindex $args [incr offset]] \
           [tmfindexpand  [lindex $args [incr offset]] deflist]

    # Local lifetime dictates that we destroy the just created
    # macros. (the proc body has no further use for them)
    
    if {$life eq "local"} {
        variable macs

        # 05Mar03RT - deflist includes index sublist too
        # foreach def $deflist {array unset macs $def,* }
        foreach defset $deflist {
            foreach {def ipair} $defset {}
            array unset macs $def,* 
        }

    }
}

proc tmac::tmmac-block {args} { tmfind [concat MAC-BLOCK $args] }
proc tmac::tmmac-filter {args } { tmfind [concat MAC-FILTER $args] }

proc tmac::tm-delete {name} {
    # delete only global macros for now
    variable macs
    array unset macs $name,*
}
proc tmac::tmfindexpand {s {deflistOUT ""}} {
    if {$deflistOUT ne ""} {upvar $deflistOUT deflist}
    return [tmexpand [tmfind $s deflist]]
}

proc tmac::tmfind {s {deflistOUT ""}} {
    # Find and record macros in the string. Return string w macrodefs
    # removed. Set optional passed var list of macro names defined.

    # 27Feb03RT redo looping to avoid visiting every line of input

    # TODO: refine the requirements so that broken macro defs are
    # more easily discovered. Possibilities: 1) fail on a MAC-XXX while
    # try to find end of another macro, 2) Force closing brace to be
    # last non-white char on last line of mac def. 

    variable config
    variable macs
    variable lmacs
    # puts "tmfind,s: |$s|"


    # Keep live local contexts (non-nested) separate
    # To do this we must distinguish - use numbers for this
    # expand *MUST* increment this variable in "syncrony"!
    set config(lserial) 0 

    # Also set the scope back to global
    set config(mactable) global


    # Caller can optionally learn all the defs we processed
    if {$deflistOUT ne ""} {upvar $deflistOUT deflist}

    # Optional multi-line "comment" feature
    # beware of trying to use mac delims as comments chars
    if {$config(comments)} {
        # bye bye ...
        set s [regsub -all $config(comRE) $s "" ]
    }

    # Look for macro defs by lines
    # 1. Find a mac def of some kind
    # 2. Parse mac name and args
    
    # This is "old reliable"
    set reMAC {\s*MAC-(BLOCK|FILTER|BEGINLOCALS|ENDLOCALS|DUMP)}
    append reMACget $reMAC {\s([^\s]+)\s+(.*)}

    set INMAC 0
    set mac ""
    set out ""
    set noni 0
    # foreach l [split $s \n] {}
    foreach {maini typei} [regexp -all -indices -inline $reMAC $s] {

        foreach {si ei} $maini {}
        
        # Copy over non matching and reset step
        append out [string range $s $noni [expr {$si-1}] ]
        set noni [expr {$ei+1}]

        # Find extent of macro, working by line
        set mac ""
        set breakout 0
        while {1} {
            # Tack on lines until it's in form of a complete command
            set lend [string first \n $s $ei]
            if {$lend == -1} {
                if {$breakout == 0} {
                    set lend [string length $s]
                    incr breakout
                } else {
                    error "string ([string range $mac 0 50]..) ended\
                           with open macro definition"
                }
            }
            set mac [string range $s $si [expr {$lend-1}] ]
            if {[info complete $mac]} {
                # First try to honor backslash continuations usefully
                # THIS IS EXPERIMENTAL AND NOT IN TESTS (01Mar03RT)
                # Wouldn't need this except that
                #     info complete x y z \
                # returns *true*
                # 
                if {[string index $mac end] eq "\\"} {
                    set theBS [expr {$lend-1}]
                    set s [string replace $s $theBS $theBS " "]
                } else {
                    break
                }
            }
            # puts "NOT COMPLETE: $mac"
            set ei [expr {$lend+1}]
        }
        # if {$breakout > 1} break
        set noni $lend
        set range [list [expr {$si+1}]  [expr {$lend-1}] ]
        
        # puts "mac: $mac"

        # Process the macro in $mac

        # puts stderr "COMPLETE |$mac|"
        # puts stderr "MAC $mac"
        # Get optional args
        if {[regexp $reMACget $mac x mactype name rest]} {
            # Check for all possible option pairs
            # -parse xx -redefine yyy -lifetime zzz
            # No abbreviations honored here (for the moment)
            # 15May03RT add -proc for FILTER macros
            #           it must come last and it's parsing is split between
            #           options loop and ,def area below
            # 19Nov03RT add -1line optional parameter - rm's \n from body
            #           and does not take a value 
            # Defaults:
            set parse keepwrap
            set lifetime $config(mactable) 
            set redefine $config(redefine)
            set proc ""
            set oneline 0
            set eat 0
            foreach {op n1 opval n2} [scan $rest %s%n%s%n%s%n%s%n%s%n%s%n] {
                switch -glob -- $op {
                    -parse -
                    -lifetime -
                    -redefine {
                        if {[lsearch $config(opvals,$op) $opval] < 0} {
                            # bail out on unknown option value
                            error "bad option value \"$opval\" for $op in\
                            macro definition \"$name\". Should be one of:\
                            $config(opvals,$op)"
                        }
                        set [string range $op 1 end] $opval
                        set eat $n2
                    }
                    -proc {
                        if {$mactype ne "FILTER"} {
                            error "Only filter macro accepts -proc option"
                        }
                        set [string range $op 1 end] $opval
                        set eat $n1
                        # -proc must be the last option
                        break
                    }
                    -oneline -
                    -1line {
                        if {$mactype ne "BLOCK"} {
                            error "Only filter macro accepts -proc option"
                        }
                        set oneline 1
                        set eat $n1; break
                    }

                    -- {set eat $n1; break}
                    -* {
                        error "bad option name \"$op\" in\
                        macro definition \"$name\". Should be one of:\
                        $config(opnames)"
                    }
                    default break
                }
            }
            # consume parsed options
            set rest [string range $rest $eat end]

            # Set local or global residency for the macro def
            if {$lifetime eq "global"} {
                upvar 0 macs MACS 
                set SUF ""
            } else {
                upvar 0 lmacs MACS 
                set SUF ,$config(lserial)
            }

            # Enforce redefinition policy
            # The policy applies *within* local/global - not
            # across.
            # QUESTION: shall macros *store* their redefine
            # setting. - currently not. So we are testing the 
            # value from global/-option w -option taking precedence
            # if {$name eq "redef3"} {parray config}
            if {[info exists MACS($name,def$SUF)]} {
                switch $redefine {
                    ok {}
                    disallow {
                        # puts "REDEF $name disallowed"
                        continue
                    }
                    warn {puts stderr "warning: redefining macro \"$name\"" }
                    error { error "attempt to redefine macro \"$name\"" } 
                    default { error "bad redefine option value at \"$name\"" } 
                }
            }

            set MACS($name,parse$SUF) $parse
            set MACS($name,type$SUF) $mactype

            if {[catch { 
                if {$mactype eq "FILTER"} {
                    if {$proc ne ""} {
                        set prest [eval list $rest ]
                        set proc [lindex $prest 0]
                        # Define the proc
                        proc ::[string trimleft $proc :] \
                                [lindex $prest 1] [lindex $prest 2]
                        set MACS($name,def$SUF) $proc
                    } else {
                        set MACS($name,def$SUF) [eval list $rest ]
                    }
                } else {
                    set MACS($name,plist$SUF) [lrange $rest 0 end-1]
                    if {$oneline} {
                        # 19Nov03RT - oneline processing applies only
                        # to block macros
                        set MACS($name,def$SUF) \
                            [string map [list \n " "] [lindex $rest end] ]
                    } else {
                        set MACS($name,def$SUF) [lindex $rest end]
                    }
                }
                       } msg]} {
               # Probably "can't happen" due to use of
               # info complete above
                error "macro $name has bad format in formal parameter list" $msg
            }
            lappend deflist [list $name $range]
        } else {
            # Is it a macro directive form?
            # During find phase, previous to expansion, 
            # each new locals area increments the serial num
            switch -exact -- [scan $mac %s] {
                MAC-BEGINLOCALS {
                    # Begin defining locals
                    incr config(lserial)
                    set config(mactable) local
                    # Enter an expand-time directive
                    append out \
                      $config(macstart)BEGINLOCALS$config(macend)\n
                }
                MAC-ENDLOCALS {
                    # Stop defining to local table
                    set config(mactable) global
                    # Enter an expand-time directive
                    append out \
                      $config(macstart)ENDLOCALS$config(macend)\n
                }
                MAC-DUMP {
                    puts stderr "MACRO DUMP"
                    catch {parray macs}
                    catch {parray lmacs}
                    parray config
                }
                default {
                    error "macro \"$mac\" could\
                        not find end of definition"
                }
            }
        }
    }
    append out [string range $s $noni end]

    return $out
}

proc tmac::_tmexpandsingle {s} {
    # s is the macro in <:dkjf adsljf ladfkj :> form
    # RETURN the macro expansion value
    variable config
    variable macs
    variable lmacs
    set DBG 0

    set mac [string range $s \
        [string length $config(macstart)] \
        end-[string length $config(macend)] ]

    set name "" 
    set nameconsume 0 ;# 14Apr03RT - bug fix incase of empty delims like ''
    scan $mac %s%n name nameconsume

    # Built-in macros are directives
    if {$name eq "BEGINLOCALS"} {
        incr config(lserial)
        # puts "<:BEGINLOCALS:> lserial=$config(lserial)"
        set config(mactable) local
        return ""
    } elseif {$name eq "ENDLOCALS"} {
        set config(mactable) global
        return ""
    }

    set rest [string range $mac $nameconsume end]

    # puts stderr " mac: |$name|"
    # puts stderr "   s: |$s|"
    # puts stderr "rest: |$rest|"
    
    # Existence test must respect both local and global versions
    if {$config(mactable) eq "local" } {
        set SUF ,$config(lserial)
        set isloc 1
    } else {
        set SUF ""
        set isloc 0
    }

    # DEBUG
    if { 0 && $name eq "local2"} {
        puts "local2 table=$config(mactable) SUF=$SUF"
        catch {parray lmacs local2*}
    }

    if {$isloc && [info exists lmacs($name,def$SUF) ]} {
        # puts stderr USELOCAL
        upvar 0 lmacs MACS  ;# use local
    } elseif {[info exists macs($name,def) ]} {
        upvar 0 macs MACS   ;# use global
        set SUF "" ;# "back-tracking"
    } else {
        # No such macro defined - behave according to config setting
        switch -- $config(notfound) {
            eat      {return ""}
            passtrick {
                    # 15Apr03RT 
                    # Special trick in a case where single char delims
                    # in effect are "escaped" if presented as an empty
                    # macro: ''  ==> '
                    # If not empty then behaves as passthrough
                    if {[string length $s] == 2} {
                        return [string index $s 0]
                    } else {
                        return $s  ;# same as passthru
                    }
            }
            passthrough -
            passthru   {return $s}
            passinside   {return $mac}
            error    {
                  # puts SUF=$SUF
                  # catch {parray macs for*}
                  # catch {parray lmacs}
                  # parray config
                error "no definition found for macro call \"$name\""
            }

             default { error "unknown tmac::config(notfound) value \
                                $config(notfound) on expand failure"
             }
        }
    }
    
    if {$MACS($name,type$SUF) eq "BLOCK"} {
        # puts stderr "M var CAll $mac"
        # set mcall [eval list $mac]
        # set mcall [concat $mac]
        set mcall $mac
        # puts stderr "mcall: |$mcall|"
        
        # Parse the supplied params by setting
        switch -exact -- $MACS($name,parse$SUF) {
            keepwrap {
                set argvals \
                    [_tmparse $name $rest [llength $MACS($name,plist$SUF)]]
            }
            simple {
                # final arg of 0 is added
                set argvals \
                    [_tmparse $name $rest [llength $MACS($name,plist$SUF)] 0]
            }
            tcl {
                if {[catch {
                    set argvals [eval list $rest]
                    } msg]} {
                        error "macro $name bad parameter list" \
                                "bad list: $rest"
                }
            }
        }
        set acnt 0
        set map ""
        set map3 ""
        foreach val $argvals sym $MACS($name,plist$SUF) {
            incr acnt
            # TODO: doc behavior if list lengths mis-match
            # Do special if symbol is marked with *
            # 02Dec03RT - bug fix: test val too,
            #             if val empty, refrain from wrapping call
            if {[string match {\**} $sym]} {
                set sym [string range $sym 1 end] 
                if {$val ne ""} {
                    set val [_tmpwrapexpr $val]
                }
            }
            # lappend map @$sym $val
            lappend map3 [list [string length $sym] $sym $val]
        }
        # Sort symbols so longest are substituted first
        foreach x3 [lsort -decreasing -index 0 -integer $map3] {
            foreach {len sym val} $x3 {}
            lappend map @$sym $val
        }
        # puts stderr "MAP: $map"
        # Do parameter substition on body
        if {$acnt} {
            set res [string map $map $MACS($name,def$SUF)]
        } else {
            set res $MACS($name,def$SUF)
        }

        # RECURSIVE expansion for BLOCK Macs
        # 2nd argument tells it about recursion
        set res  [tmexpand $res 1]

    } elseif {$MACS($name,type$SUF) eq "FILTER"} {
        # TODO: let filter types have option to wrap their
        # args automatically: -wrapquote, -wrapbrace
        # puts stderr "FILTER:  $MACS($name,def) [string range $mac $nameconsume end]"
        # 18Mar03RT - make non eval the default for filter macs by wrapping
        # in list
        # puts stderr "Parse setting of $name is $MACS($name,parse$SUF) "
        # puts stderr "rest of $name is $rest"
        if 0 {
        if {[catch {
            set res [eval \
                $MACS($name,def$SUF) [string range $mac $nameconsume end] ]
                } msg]} {
            error "expansion of filter $name failed ($msg) \
                [string range \
                    "$MACS($name,def$SUF) [string range $mac $nameconsume end]" \
                    0 100]"
            }
        } elseif {0} {
            # Get a bunch - EXPERIMENTAL (18Mar03RT)
            # ISSUE/TODO should we know the expected arg count of FILTER mac
            # at least optionally?
            set argvals \
                [_tmparse $name $rest 100 0]
            # puts stderr "filter argvals for $name $argvals"
            if {[catch {
                set res [eval \
                    $MACS($name,def$SUF) $argvals ]
                    } msg]} {
                error "expansion of filter $name failed ($msg) \
                    [string range \
                        "$MACS($name,def$SUF) $argvals" \
                        0 100]"
                }
            
        } else {
            # Notice nominal limit of 100 args (hoping to limit run-away
            # behavior in error situations)
            set ptype  $MACS($name,parse$SUF)
            global errorInfo
            switch -exact -- $ptype {
                simple   -
                keepwrap { 
                    set argvals \
                     [_tmparse $name $rest 100 [expr {$ptype eq "keepwrap"}] ]
                        if {[catch {
                            set res [eval \
                                $MACS($name,def$SUF) $argvals ]
                                } msg]} {
                            append msg \n[string range $errorInfo 0 500]//
                            error "expansion of filter $name failed ($msg) \
                                    [string range \
                                    "$MACS($name,def$SUF) $argvals" \
                                    0 100]"
                        }
                }
                tcl {
                    # The scariest, least useful, and hardest to use...
                    if {[catch {
                        set res [eval \
                            $MACS($name,def$SUF) [string range $mac $nameconsume end] ]
                            } msg]} {
                        error "expansion of filter $name failed ($msg) \
                            [string range \
                                "$MACS($name,def$SUF) [string range $mac $nameconsume end]" \
                                0 100]"
                        }
                }
            }
        }
    } else {
        error "macro $name has no valid type ($MACS($name,type$SUF))"
    }
    if {0 && $name eq "local2"} { puts stderr "---\n MACRO: $mac" }
    if {0 && $name eq "local2"} { puts stderr      "RESULT: $res" }
    return $res
}

proc tmac::_tmparse {name s cnt {keep 1}} {
    # Simple minded parsing of quote and brace delimiters is
    # not the way tcl does it. Ignores backslashes.
    # RETURNS a list of params no longer than cnt
    # The main motivation is to implement the "keepwrap" option
    # so that the params will *include* their delimiters, if any.
    # IOW, sourounding "double quotes" or {braces} will be both respected
    # and kept.
    # 19Feb03RT - add keep param as an optional
    # 23Feb03RT - handled nested levels of braces,
    #       brace-in-quote & quote-in-brace & quote/brace inside word
    # 11May03RT - resolve defects with nested delimiters of all kinds and
    #             properly passing them thru; Added diagCODE
    set out [list]
    set inquote 0
    set inbrace 0
    set inword 0
    set word ""
    set diag 0
    if {$diag} {
        set diagCODE \
          {puts stderr "$X [string repeat "*" $inbrace]\
                 c=$c inword=$inword inquote=$inquote w=$word"}
        puts stderr "_tmparse: keep=$keep \nSTR:\n|$s|"
    } else {
        set diagCODE ""
    }
    foreach c [split $s ""] {
        if {[llength $out] >= $cnt} break
        if {$c eq "\"" } {
            # QUOTES
            if {$inquote} {
                set inquote 0
                if {$keep} {append word \"}
                set X Qe; eval $diagCODE
                lappend out $word
                set word ""
                set inword 0
                continue
            } elseif {$inword} {
                # a plain or braced word treats quotes as ordinary
                append word $c
                set X Qi; eval $diagCODE
            } else {
                set inquote 1
                if {$keep} {set word \"} {set word ""}
                set inword 1
                set X Qs; eval $diagCODE
                continue
            }
        } elseif {$c eq "\}" || $c eq "\{"} {
            # BRACES
            # 22Mar03RT - fix detects with nested and not contiguous
            # braces
            if {$inword && !$inbrace} {
                # a plain or quoted word treats braces as ordinary
                set X Bi; eval $diagCODE
                append word $c
                continue
            }
            if { ! $inword && $c eq "\}"} {
                error "macro \"$name\" parameter word cannot begin with \}"
            }
            if { ! $inword} {
                # An open brace begins a word
                set inword 1
                set inbrace 1
                if {$keep} {set word \{ } {set word ""}
                # puts stderr "inbrace: $inbrace c=$c inword=$inword"
                set X Bb; eval $diagCODE
                continue
            }

            # we are in a word and in braces
            if {$c eq "\}" } {
                incr inbrace -1
                if {$inbrace == 0} {
                    if {$keep} {append word \}}
                    lappend out $word
                    set X Be; eval $diagCODE
                    set word ""
                    set inword 0
                } else {
                    # 02May03RT - bug fix pass inner braces on thru!
                    # 11May03RT - but only in "else case
                    append word \}
                    set X Ba; eval $diagCODE
                }
                # puts stderr "inbrace: $inbrace c=$c inword=$inword"

                continue
            } else {
                # An opening nested brace
                incr inbrace 1
                # puts stderr "inbrace: $inbrace c=$c inword=$inword"

                # 02May03RT - bug fix pass inner braces on thru!
                append word \{
                set X B1; eval $diagCODE

                continue
            }
            # puts stderr "inbrace: $inbrace c=$c inword=$inword"

        } elseif {!$inquote && !$inbrace } {
            if {[string is space $c]} {
                if {$inword} {
                    set inword 0
                    lappend out $word
                    set X Si; eval $diagCODE
                    # puts stderr "word:$word"
                    set word ""
                    continue
                } else {
                    # puts "white eat"
                    set X So; eval $diagCODE
                    continue ;# eat extra white space
                }
            } else {
                # 11May03RT - restruct and add this missing clause!
                set inword 1
                append word $c
                set X SX; eval $diagCODE
                # puts stderr "nQ inner char: $c (word=$word)"
            }

        } else {
            set inword 1
            append word $c
            set X Sz; eval $diagCODE
            # puts stderr "Q inner char: $c"
        }

    }
    # puts stderr "s=$s cnt=$cnt c=$c outlen=[llength $out] \
        # outend=|[lindex $out end]| out=$out"
    if {$inword} {
        # unclosed words are an error
        if {$inbrace} {
            error "macro \"$name\" parameter missed closing brace"
        } elseif {$inquote} {
            error "macro \"$name\" parameter missed closing quote"
        }
        lappend out $word
    }
    return $out
}

proc tmac::_tmpwrapexpr {val} {
    variable config
    set val [string trim $val]
    if {$config(killoctal)} {
        # Make any constant values that could be interp'd 
        # as octal lose their leading zeros.
        # See tmac.test for examples
        # puts stderr "KILL OCTAL: $val"
        regsub -all {(([^\da-zA-Z_])|^)0+(\d+([^.]|$))} $val {\2\3} val
    }
    set exprPRE ""
    if {[string match \{*\} $val]} {
        # honor brace quoting by just removing it and doing nothing else
        set val [string range $val 1 end-1]
    } elseif {[string is integer -strict $val] ||
        [regexp {^end(-\d+)*$} $val]} {
        # puts stderr "skipping val: $val"
        # Ignore plain ints or the special built in
        # just let it pass thru to the command
    } elseif {$val ne "end" && [regexp {^[[:alpha:]_]\w*$} $val]} {
        # If value seems obviously a single simple var name then just add
        # $ and be done (16May03RT)
        return $\{$val\}
    } else {
        # auto embed an expr call with expanded var
        # names too
        # find all the var names
        # PROBLEM with array refs, how to 
        # interpret: {$a(BIG) *$x}
        # Strategy: ignore any string var bordered by matching parens
       
        set vlist ""

        # 20Mar03RT allow expr following keyword end-
        if [regexp {^end-(.+)} $val => val] {
            # puts stderr "new val is subexpr: $val"
            set exprPRE end-
        }

        foreach vpair [regexp -indices -all -inline {[[:alpha:]_]\w*} $val] {
            foreach {vsi vei} $vpair {}
            # puts stderr "val:$val vsi:$vsi vei:$vei"
            if {$vsi > 0} {
                set vprev [string index $val [expr {$vsi-1}]]
                if {$vprev eq "$"} continue
                if {$vprev eq "("
                && [string index $val [expr {$vei+1}]] eq ")"} {
                    # ignore (string) as a likely array index
                    continue
                }
            }
            # 20Mar03RT - skip expr function names
            if {[lsearch -exact $config(exprfuncs) \
                  [scan [string range $val $vsi $vei] {%[a-z0-9]}] ] >= 0} {
                continue
            }
            # build list backward (as string)
            set vlist "$vsi $vei $vlist"
        }
        # Now add $ to what we think are vars but
        # go backwards so indexes stay valid
        foreach {vsi vei} $vlist {
            # puts stderr "val:$val vsi:$vsi vei:$vei"
            set vv [string range $val $vsi $vei]
            set val [string replace $val $vsi $vei $$vv]
        }
        if {0 && $config(killoctal)} {
            # EXPERIMENTAL and not active (29Mar03RT)
            # If used, will be mutually exclusive with killoctal
            # code at top of this proc.
            # Make any *substituted* values that could be interp'd 
            # as octal lose their leading zeros.
            # See tmac.test for examples
            # regsub -all {(([^\da-zA-Z_])|^)0+(\d+([^.]|$))} $val {\2\3} val
            set    x {[regsub -all {(([^\da-zA-Z_])|^)0+(\d+([^.]|$))} }
            append x "\[subst [list $val]]" 
            append x " " {{\2\3}} \]
            set xval "\[expr \{$x\}\]"
            # puts stderr "xval: $xval"
        }
        set val "\[expr \{$val\}\]"
        # puts stderr "*val is $val"
    }
    return $exprPRE$val
}

proc tmac::tmexpand {s {recursive 0} } {

    # Expand all defined macros in the string.
    # Unknown macros are passed thru unchanged as is plain text

    variable macs
    variable lmacs
    variable config

    # IMPORTANT - must sync increments with tmfind!
    # as we stepping thru local contexts
    # In particular, don't reset lserial on recursive calls
    if { ! $recursive}  {
        set config(lserial) 0 
        set config(mactable) global ;# sync 
    }

    # First do a global evaluation of the string to ensure that
    # start/end markers match and nest properly.
    
    set mrkList [regexp -inline -indices -all -- $config(macRE) $s]
    # puts stderr "tmexpand: mrkList: $mrkList"
    if {[llength $mrkList] == 0} {
        # Nothing to bother expanding
        return $s
    }

    set nestlev 0
    set tree ""
    set i0 0  ;# initial potential plain text (level 0) index
    set ei 0

    # If delimiters are same char nesting makes no sense
    if {$config(macstart) eq $config(macend)} {
        set nonest 1
    } else {
        set nonest 0
    }
    set oddeven 0
    foreach e $mrkList {
        incr oddeven
        foreach {si ei} $e {}
        # 28Feb03RT - support nonest <==> start/end are same string
        if {($nonest && ($oddeven & 1)) 
            || ($nonest==0 && [string range $s $si $ei] eq $config(macstart))} {
            if {$nestlev == 0} {
                # Capture any passed-over plain text
                if {$si > $i0} {
                    lappend tree "+0 $i0" "-0 [expr {$si-1}]"
                }
            }
            incr nestlev +1
            lappend tree "+$nestlev $si"
        } else {
            lappend tree "-$nestlev $ei"
            incr nestlev -1
            if {$nestlev == 0} {
                # mark potential beginning of plain text
                set i0 [expr {$ei+1}]
            }
        }
        # puts "NEWLEV $nestlev"
        if {$nestlev < 0} {
            # puts stderr "Mis-matched markers at string index $si"
            error "Mis-matched markers at string index $si \
                [string range $s [expr {$si-100}] [expr {$si+100}]]"

            return ""
        }
    }
    if {$nestlev == 0} {
        # puts "string good"
        # Catch any final portion of plain text
        if {$ei == 0} {
            # it was all plain text
            lappend tree "+0 0" "-0 [string length $s]"
        } elseif {$ei +1 < [string length $s]} {
            # There is trailing plain text
            lappend tree "+0 $i0" "-0 [string length $s]"
        }
        # plist $tree

        # Diag feature
        if {$recursive == 0} {
            set config(tree) $tree
        }

        return [_tmexpandtree $tree $s]
    }
    # puts stderr "bad macro invocations: ended at level $nestlev (should be 0)"
    error "bad macro invocations: ended at level $nestlev (should be 0)"\
                [string range $s [expr {$si-100}] [expr {$si+100}]]
    return ""
}
proc tmac::_tmexpandtree {tree s} {
    set DBG 0
    set fulltree $tree

    # if {$DBG} {puts stderr "ENTRY tree: $tree  s: $s"}
    if {[string length $tree] == 0} {return ""}
    if {[string length $s] == 0} {return ""}

    # Process everything in string from end-to-end
    while {[llength $tree] > 0} {
        scan [lindex $tree 0] %s%s dirlev idx
        scan [lindex $tree 1] %s%s dirlev2 idx2
        set indent [string repeat "  " [scan $dirlev %d] ]
        if {$DBG} {puts stderr "${indent}TOP $dirlev  tree:$tree"}

        if {$dirlev eq "+0"} {
            # plain text
            set simple [string range $s $idx $idx2]
            if {$DBG} {puts stderr "$indent  PLAIN $simple"}
            append chunks $simple
            set tree [lrange $tree 2 end]
            continue
        }

        # If this is a simple (non-containing) macro then consume it
        if {$dirlev + $dirlev2 == 0} {
            append chunks [_tmexpandsingle [string range $s $idx $idx2] ]
            set tree [lrange $tree 2 end]
            continue
        }
        # It's more complicated...
        # We are looking at "<:...<:..."
        # IOW: +x i, +(x+1) j =>VALIDATE
        if { ! ($dirlev +1) == $dirlev2} {
            error "bad expansion" "Broken nesting assertion 1"
        }
        # Scan forward to matching marker
        # and expand the 1st sublevel (as many as there are)
        for {set i 1} {$i < [llength $tree]} {incr i} {
            # We know 1st iteration will get a hit below
            if {[lindex $tree $i 0] eq $dirlev2} {
                set ileft $i
                incr i
                while {$i < 1000} {
                    # find it's match
                    if {[lindex $tree $i 0] + $dirlev2 == 0} {
                        # Each entry in sublevs is 
                        # Record its *relative* substitution range &
                        # the substitution text
                        lappend sublevs [list \
                            [expr {[lindex $tree $ileft 1] - $idx} ]\
                            [expr {[lindex $tree $i 1] - $idx} ]\
                            [_tmexpandtree [lrange $tree $ileft $i] $s ] ]
                        break
                    }
                    incr i
                }
            }
            # done when hit our match
            if {$dirlev + [lindex $tree $i 0] == 0} {
                set idxEnd [lindex $tree $i 1]
                set tree [lrange $tree [expr {$i+1}] end]
                break
            }
        }
        if {$DBG} {puts stderr "$indent loop DONE: i=$i ileft=$ileft sublevs:$sublevs"}
        # Substitute sublevel results and then expand the
        # immediate level
        # Go backwards to keep indexes valid
        set growth 0
        set ss [string range $s $idx $idxEnd]
        if {$DBG} {puts stderr "$indent ss IN |$ss|"}
        for {set i [expr {[llength $sublevs] -1} ]} {$i >= 0} {incr i -1} {
            foreach {si ei text} [lindex $sublevs $i] {}
            if {$DBG} {puts stderr "$indent NEW vars si=$si ei=$ei text=|$text|" }
            incr growth [expr {[string length $text] - ($ei - $si) -1 } ]
            if {$DBG} {puts stderr "$indent REPLACE |[string range $ss $si $ei]| with\
                |$text| growth=$growth"}
            set ss [string replace $ss $si $ei $text]
            if {$DBG} {puts stderr "$indent NEW ss |$ss|" }
        }
        if {$DBG} {puts stderr "$indent ss OUT |$ss|"}
        
        append chunks [_tmexpandsingle $ss]
        set sublevs [list]
    }
    if {$DBG} {puts stderr "$indent  BOT |$chunks|"}
    return $chunks
}
namespace eval tmac {

    namespace export tm*
    ## Tmac default configuration
    set config(mactable) global
    set config(opvals,-parse) [list tcl simple keepwrap]
    set config(opvals,-lifetime) [list global local]
    set config(opvals,-redefine) [list error warn disallowed ok]
    set config(opnames) [list -parse -lifetime -redefine -oneline]

    set config(redefine) ok
    set config(killoctal) 1

    # notfound behaviors: error, eat, passthrough passinside, passtrick
    set config(notfound) error

    # The "big gulp" comment delimiter strings are
    # disabled by default
    set config(comments)   0
    set config(comRE) [tmsetcomments <* *>]

    # We want to avoid wrongly putting $ in front of expr functions
    set config(exprfuncs) [list abs cosh log sqrt acos double log10 \
                            srand asin exp pow tan atan floor rand \
                            tanh atan2 fmod round ceil hypot sin \
                            cos int sinh]

    # The default macro invocation strings
    tmsetdelims <: :>
}
package provide tmac 1.0
package provide Tmac 1.0
package provide TMac 1.0
