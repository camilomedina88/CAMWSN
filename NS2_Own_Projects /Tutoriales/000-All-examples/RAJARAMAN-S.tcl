#============================
# Load Library.
#============================
source "template/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/RAJARAMAN.default"
source "template/defaults/CONNECTOR.default"
source "template/defaults/SHIVA.default"

Agent/RAJARAMAN set fraction		false
Agent/SHIVA set max-length			3	

set level 3

set pathCompleto "";
set index -1;
set nodes -1;

proc usage {} {
	puts "usage: ns RAJARAMAN-S.tcl \[options\]";
	puts "options:";
	puts "* -t TopologyMainDirectory\tSet Topology Main Directory (contains subdir for nodes)";
	puts "* -N nodes\t\t\tNumber of nodes of topology";
	puts "* -I index\t\t\tIndex for topology";
	puts "  -f\t\t\t\tFraction Version";
	puts "  -c length\t\t\tCycles Length";
	puts "  -l level\t\t\tStop Algoritmo at selected level";
	puts "Default is Rajaraman + Shiva (cycles length 3)";
}

set pos 0;
while {[string compare [lindex $argv $pos] ""] != 0} {
	if {[string compare [lindex $argv $pos] "-f"] == 0} {
		Agent/RAJARAMAN set fraction true;
	} elseif {[string compare [lindex $argv $pos] "-l"] == 0} {
		set pos [expr $pos + 1];
		if {[string compare [lindex $argv $pos] ""] != 0} {
			set level [lindex $argv $pos];
		}
	} elseif {[string compare [lindex $argv $pos] "-c"] == 0} {
		set pos [expr $pos + 1];
		if {[string compare [lindex $argv $pos] ""] != 0} {
			Agent/SHIVA set max-length [lindex $argv $pos];
		}
	} elseif {[string compare [lindex $argv $pos] "-I"] == 0} {
		set pos [expr $pos + 1];
		if {[string compare [lindex $argv $pos] ""] != 0} {
			set index [lindex $argv $pos];
		}
	} elseif {[string compare [lindex $argv $pos] "-N"] == 0} {
		set pos [expr $pos + 1];
		if {[string compare [lindex $argv $pos] ""] != 0} {
			set nodes [lindex $argv $pos];
		}
	} elseif {[string compare [lindex $argv $pos] "-h"] == 0} {
		usage;
		exit 0;
	} elseif {[string compare [lindex $argv $pos] "-t"] == 0} {
		set pos [expr $pos + 1];
		set pathCompleto [lindex $argv $pos];
	}
	set pos [expr $pos + 1];
}

set error false;

if {[string compare $pathCompleto ""] == 0} {
	error "Set name of topology with -t TopologyFile";
	set error true;
}

if {[Agent/SHIVA set max-length] < 3} {
	error "Cycles must be length >= 3";
	set error true;
}

if {$nodes == -1} {
	error "Specify number of nodes: -N nodes";
	set error true;
}

if {$index == -1} {
	error "Specify index: -I index";
	set error true;
}

if {$level < 1 || $level > 3} {
	error "Level can be 1, 2 or 3";
	set error true;
}

if {$error} {
	puts "--------------------------------"
	usage;
	exit 1;
}

set rajaramanAlgo "RAJARAMAN";
if {[Agent/RAJARAMAN set fraction]} {
	set rajaramanAlgo "${rajaramanAlgo}(F)";
}

if {[Agent/SHIVA set max-length] == 3 ||
	[Agent/SHIVA set max-length] == 4} {
	Agent/SHIVA set timeout-destruction				1.5
} elseif {[Agent/SHIVA set max-length] == 5 ||
		[Agent/SHIVA set max-length] == 6} {
	Agent/SHIVA set timeout-destruction				5.0
}

begin-simulation "$pathCompleto/" "${index}" "${nodes}"
declareModule {Agent/RAJARAMAN} {Utility/RAJARAMAN} "$rajaramanAlgo" {RAJARAMAN}
if {$level > 1} {
	declareModule {Agent/MYCONNECTOR} {Utility/CONNECTOR} {CONNECTOR} {CONNECTOR}
	if {$level > 2} {
		declareModule {Agent/SHIVA} {Utility/SHIVA} "SHIVA([Agent/SHIVA set max-length])" {SHIVA}
	}
}
start-simulation

