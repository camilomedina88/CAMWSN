#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/RAJARAMAN.default"
source "template/defaults/CONNECTOR.default"

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
	declareModule {Agent/RAJARAMAN} {Utility/CLUSTERING} {RAJARAMAN} {RAJARAMAN}
	declareModule {Agent/MYCONNECTOR} {Utility/BACKBONE} {CONNECTOR} {CONNECTOR}
start-simulation

