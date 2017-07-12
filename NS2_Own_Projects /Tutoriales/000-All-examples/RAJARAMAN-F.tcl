#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/RAJARAMAN.default"

Agent/RAJARAMAN set fraction				true

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/RAJARAMAN} {Utility/CLUSTERING} {RAJARAMAN(F)} {RAJARAMAN}
start-simulation

