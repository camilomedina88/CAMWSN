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

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/MPR} {Utility/BACKBONE} {MPR} {MPR}
start-simulation

