# scen file ... :

# 802.11p default parameters

Phy/WirelessPhyExt set CSThresh_                3.9810717055349694e-13	;# -94 dBm wireless interface sensitivity
Phy/WirelessPhyExt set Pt_                      0.1			;# equals 20dBm when considering antenna gains of 1.0
Phy/WirelessPhyExt set freq_                    5.9e+9
Phy/WirelessPhyExt set noise_floor_             1.26e-13    		;# -99 dBm for 10MHz bandwidth
Phy/WirelessPhyExt set L_                       1.0         		;# default radio circuit gain/loss
Phy/WirelessPhyExt set PowerMonitorThresh_      3.981071705534985e-18   ;# -174 dBm power monitor sensitivity (=level of gaussian noise)
Phy/WirelessPhyExt set HeaderDuration_          0.000040    		;# 40 us
Phy/WirelessPhyExt set BasicModulationScheme_   0
Phy/WirelessPhyExt set PreambleCaptureSwitch_   1
Phy/WirelessPhyExt set DataCaptureSwitch_       1
Phy/WirelessPhyExt set SINR_PreambleCapture_    3.1623;     		;# 5 dB
Phy/WirelessPhyExt set SINR_DataCapture_        10.0;      		;# 10 dB
Phy/WirelessPhyExt set trace_dist_              1e6         		;# PHY trace until distance of 1 Mio. km ("infinity")
Phy/WirelessPhyExt set PHY_DBG_                 0

Mac/802_11Ext set CWMin_                        15
Mac/802_11Ext set CWMax_                        1023
Mac/802_11Ext set SlotTime_                     0.000013
Mac/802_11Ext set SIFS_                         0.000032
Mac/802_11Ext set ShortRetryLimit_              7
Mac/802_11Ext set LongRetryLimit_               4
Mac/802_11Ext set HeaderDuration_               0.000040
Mac/802_11Ext set SymbolDuration_               0.000008
Mac/802_11Ext set BasicModulationScheme_        0
Mac/802_11Ext set use_802_11a_flag_             true
Mac/802_11Ext set RTSThreshold_                 2346
Mac/802_11Ext set MAC_DBG                       0


