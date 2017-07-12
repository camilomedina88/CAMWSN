#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/WULI.default"

Agent/WULI set degree							true
Agent/WULI set limit							2
Agent/WULI set stojmenovic						true
Agent/WULI set debug							true

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/WULI} {Utility/BACKBONE} {STOJMENOVIC} {WULI}
start-simulation

