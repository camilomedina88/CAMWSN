#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/ALZOUBI.default"
source "template/defaults/LEADER.default"

if {[string compare [lindex $argv 1] ""] != 0} {
	Agent/LEADER set fake-leader [lindex $argv 1]
}

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/LEADER} {Utility/LEADER} {LEADER} {LEADER}
	declareModule {Agent/ALZOUBI} {Utility/BACKBONE} {ALZOUBI} {ALZOUBI}
start-simulation
