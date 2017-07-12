#============================
# Load Library.
#============================
source "template/config/lib.tcl"

#============================
# Load Algorithms's Defaults.
#============================
source "template/defaults/sensors.default"
source "template/defaults/DCA.default"
source "template/defaults/CONNECTOR.default"

Agent/DCA set degree								true

set pathCompleto [lindex $argv 0]
begin-simulation $pathCompleto
declareModule {Agent/DCA} {Utility/CLUSTERING} {DCA(D)} {DCA}
declareModule {Agent/MYCONNECTOR} {Utility/BACKBONE} {CONNECTOR} {CONNECTOR}
start-simulation
