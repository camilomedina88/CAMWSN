#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/MPR.default"

Agent/MPR set degree							false
Agent/MPR set enhanced-2						true

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/MPR} {Utility/BACKBONE} {MPR(E2)} {MPR}
start-simulation

