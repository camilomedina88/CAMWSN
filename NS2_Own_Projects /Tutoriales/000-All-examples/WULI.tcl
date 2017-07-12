#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/WULI.default"

Agent/WULI set degree							false
Agent/WULI set limit							-1
Agent/WULI set stojmenovic						false

set pathCompleto [lindex $argv 0]

if {[string compare [lindex $argv 1] ""] != 0} {
	Agent/WULI set limit [lindex $argv 1]
	begin-simulation $pathCompleto
		declareModule {Agent/WULI} {Utility/BACKBONE} "WULI([lindex $argv 1])" {WULI}
	start-simulation
} else {
	begin-simulation $pathCompleto
		declareModule {Agent/WULI} {Utility/BACKBONE} "WULI(n)" {WULI}
	start-simulation
}


