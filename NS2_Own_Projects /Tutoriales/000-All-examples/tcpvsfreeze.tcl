# Simple TCP vs. Freeze-TCP (with disconnections) NS-2 script
# Olivier Mehani <olivier.mehani@nicta.com.au>

# Load the NsDccp module _before_ instanciating the simulator
set system_type [exec uname -s]
# Libraries have different names in some operating systems
if {[string match "CYGWIN*" "$system_type"] == 1} {    
	load ../src/.libs/cygnsfreezetcp-0.dll
    } else {    
	load ../src/.libs/libnsfreezetcp.so
} 

set ns_ [new Simulator]

set tracefile_ [open out.tr w]
$ns_ trace-all $tracefile_

set n0_ [$ns_ node]
set n1_ [$ns_ node]
$ns_ duplex-link $n0_ $n1_ 100Mb 2ms DropTail

if { $argc == 1 && [lindex $argv 0] == "freeze" } {
	puts "Using Freeze-TCP..."
	set tcp_ [new Agent/TCP/Freeze]
	set sink_ [new Agent/TCPSink/Freeze]
	source samplepredict.tcl
} else {
	puts "Using regular TCP (Reno)..."
	set tcp_ [new Agent/TCP]
	set sink_ [new Agent/TCPSink]
}

$ns_ attach-agent $n0_ $tcp_
$ns_ attach-agent $n1_ $sink_

source samplelink.tcl

set ftp_ [new Application/FTP] 
$ftp_ attach-agent $tcp_

$sink_ listen
$ns_ connect $tcp_ $sink_
$ns_ at 0.1 "$ftp_ start"

proc finish {} {
	global ns_ tracefile_
	$ns_ flush-trace
	close $tracefile_
	
	exit 0
}
$ns_ at 1500. "finish"

$ns_ run
