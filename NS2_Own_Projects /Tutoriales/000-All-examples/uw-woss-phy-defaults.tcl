# WOSS - World Ocean Simulation System -
# 
# Copyright (C) 2009 Regents of Patavina Technologies 
# 
# Author: Federico Guerra - federico@guerra-tlc.com
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANATBILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses>/.

# This software has been developed by Patavina Technologies, s.r.l., 
# in collaboration with the NATO Undersea Research Centre 
# (http://www.nurc.nato.int; E-mail: pao@nurc.nato.int), 
# whose support is gratefully acknowledged.


PacketHeaderManager set tab_(PacketHeader/WOSS/FH-BFSK) 1

PacketHeaderManager set tab_(PacketHeader/WOSS)    1


#### MaxTxSPL_dB_ was previously named MaxTxPower_dB_
#### MinTxSPL_dB_ was previously named MinTxPower_dB_
#### TxSPLMargin_dB_ was previously named TxPowerMargin_dB_
WOSS/Module/MPhy/BPSK set MaxTxSPL_dB_              190
WOSS/Module/MPhy/BPSK set MinTxSPL_dB_              10
WOSS/Module/MPhy/BPSK set RxSnrPenalty_dB_  	      -10
WOSS/Module/MPhy/BPSK set TxSPLMargin_dB_ 	        10
WOSS/Module/MPhy/BPSK set ConsumedEnergy_ 	        0
WOSS/Module/MPhy/BPSK set debug_	                  0
WOSS/Module/MPhy/BPSK set SPLOptimization_          0
WOSS/Module/MPhy/BPSK set CentralFreqOptimization_  0
WOSS/Module/MPhy/BPSK set BandwidthOptimization_    0
WOSS/Module/MPhy/BPSK set MaxTxRange_           10000
WOSS/Module/MPhy/BPSK set PER_target_            0.01


WOSS/Module/Channel set channel_time_resolution_  -1.0
WOSS/Module/Channel set debug_                    0.0

WOSS/ChannelEstimator set debug_           0.0
WOSS/ChannelEstimator set space_sampling_  0.0
WOSS/ChannelEstimator set avg_coeff_       0.5

WOSS/PlugIn/ChannelEstimator set debug_    0.0

WOSS/Position set compDistance_                0.0
WOSS/Position set verticalOrientation_         0.0
WOSS/Position set minVerticalOrientation_    -90.0
WOSS/Position set maxVerticalOrientation_     90.0


WOSS/Position/WayPoint set time_threshold_             1e-5


