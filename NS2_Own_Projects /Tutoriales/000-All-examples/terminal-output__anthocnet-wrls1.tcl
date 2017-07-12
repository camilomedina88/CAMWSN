
[knudfl@localhost test-tcl]$ ns234-anthocnet anthocnet-wrls1.tcl


num_nodes is set 300
warning: Please use -channel as shown in tcl/ex/wireless-mitf.tcl
INITIALIZE THE LIST xListHead
channel.cc:sendUp - Calc highestAntennaZ_ and distCST_
highestAntennaZ_ = 1.5,  distCST_ = 550.0
SORTING LISTS ...DONE!
ns: _o428 setdest 735.0 0.0 3.0: 
    (_o428 cmd line 1)
    invoked from within
"_o428 cmd setdest 735.0 0.0 3.0"
    invoked from within
"catch "$self cmd $args" ret"
    invoked from within
"if [catch "$self cmd $args" ret] {
set cls [$self info class]
global errorInfo
set savedInfo $errorInfo
error "error when calling class $cls: $args" $..."
    (procedure "_o428" line 2)
    (SplitObject unknown line 2)
    invoked from within
"_o428 setdest 735.0 0.0 3.0"


$ ns234-anthocnet anthocnet-wrls1.tcl :
The files complex-ant.tr 103MB, complex-wrls.nam 55MB, win-complex-ant.tr 106kB
... are created. ( And the empty file rtable.txt ).  

$ ns234-anthocnet Edited-anthocnet-wrls1.tcl :
complex-ant.tr 264MB, complex-wrls.nam 138MB, win-complex-ant.tr 284kB
( And the empty file rtable.txt ). 

 

