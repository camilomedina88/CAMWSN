#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/LEADER.default"

# Agent/LEADER set debug true

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/LEADER} {Utility/LEADER} {LEADER} {LEADER}
start-simulation
