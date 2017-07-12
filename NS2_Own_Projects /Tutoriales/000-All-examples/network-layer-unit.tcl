# Copyright (c) 2009 Q2S NTNU, Trondheim, Norway
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation;
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# Author: Laurent Paquereau <laurent.paquereau@q2s.ntnu.no>
#

NetworkLayerUnit instproc init args  {
    eval $self next $args
    if {[NetworkLayerUnit set queue-type_]!=""} {
	if {[lsearch [\
		[NetworkLayerUnit set queue-type_] info heritage] Queue]==-1} {
	    puts stderr "NetworkLayerUnit: Error invalid queue type"
	    exit 1
	}
	set queue [new [NetworkLayerUnit set queue-type_]]
        $queue set limit_ [NetworkLayerUnit set queue-limit_]
	set packet_queue [new NetworkLayerUnitPacketQueue $self $queue]
	$queue target $packet_queue
	$packet_queue set-service-time-routing \
	    [NetworkLayerUnit set service-time-routing_]
	$packet_queue set-service-time-data \
	    [NetworkLayerUnit set service-time-data_]
	$self attach-queue $packet_queue
    }
}
