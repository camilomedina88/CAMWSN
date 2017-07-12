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


WOSS/Utilities set debug 0


WOSS/Definitions/Handler set debug 0

WOSS/Definitions/TransducerHandler set debug 0


WOSS/Creator/Database/NetCDF/Bathymetry/GEBCO set debug           0
WOSS/Creator/Database/NetCDF/Bathymetry/GEBCO set woss_db_debug   0

WOSS/Creator/Database/NetCDF/Sediment/DECK41 set debug            0
WOSS/Creator/Database/NetCDF/Sediment/DECK41 set woss_db_debug    0

WOSS/Creator/Database/NetCDF/SSP/WOA2005/MonthlyAverage set debug          0
WOSS/Creator/Database/NetCDF/SSP/WOA2005/MonthlyAverage set woss_db_debug  0

WOSS/Creator/Database/Textual/Results/TimeArr set debug           0
WOSS/Creator/Database/Textual/Results/TimeArr set woss_db_debug   0
WOSS/Creator/Database/Textual/Results/TimeArr set space_sampling  0

WOSS/Creator/Database/Textual/Results/Pressure set debug          0
WOSS/Creator/Database/Textual/Results/Pressure set woss_db_debug  0
WOSS/Creator/Database/Textual/Results/Pressure set space_sampling 0


WOSS/Database/Manager set debug 0


WOSS/Creator/Bellhop set debug                        0.0
WOSS/Creator/Bellhop set woss_debug                   0.0
WOSS/Creator/Bellhop set woss_clean_workdir           0.0
WOSS/Creator/Bellhop set max_time_values              10
WOSS/Creator/Bellhop set total_runs                   1
WOSS/Creator/Bellhop set frequency_step               0.0
WOSS/Creator/Bellhop set total_range_steps            1.0
WOSS/Creator/Bellhop set tx_min_depth_offset          0.0
WOSS/Creator/Bellhop set tx_max_depth_offset          0.0
WOSS/Creator/Bellhop set total_transmitters           1
WOSS/Creator/Bellhop set total_rx_depths              1
WOSS/Creator/Bellhop set rx_min_depth_offset          0.0
WOSS/Creator/Bellhop set rx_max_depth_offset          0.0
WOSS/Creator/Bellhop set total_rx_ranges              1
WOSS/Creator/Bellhop set rx_min_range_offset          0.0
WOSS/Creator/Bellhop set rx_max_range_offset          0.0
WOSS/Creator/Bellhop set total_rays                   0.0
WOSS/Creator/Bellhop set min_angle                    -10.0
WOSS/Creator/Bellhop set max_angle                    10.0
WOSS/Creator/Bellhop set ssp_depth_precision          1.0e-6
WOSS/Creator/Bellhop set normalized_ssp_depth_steps   20


WOSS/Manager/Simple set debug             0.0
WOSS/Manager/Simple set space_sampling    0.0


WOSS/Controller set debug 0.0


WOSS/Definitions/RandomGenerator/C set seed_ 1

# WOSS/Manager/Simple/MultiThread set max_thread_number 9
# WOSS/Manager/Simple/MultiThread set debug 0.0
# WOSS/Manager/Simple/MultiThread set space_sampling 0.0
