#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/DCA.default"

Agent/DCA set degree								false

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/DCA} {Utility/CLUSTERING} {DCA} {DCA}
start-simulation

