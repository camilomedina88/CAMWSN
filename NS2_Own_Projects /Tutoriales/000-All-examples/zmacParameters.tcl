if { $ack == 1 } {
    ### 20 is IP header length, $to + $tno is worst case backoff
    Mac/802_11 set slotsize_ [expr ([Mac/802_11 set payloadSize_] + 20 + [Mac/802_11 set ether_hdr_len_] +\
                                    [Mac/802_11 set ether_ack_len_] + ($to + $tno)) * 8 / $channelBandwidth]
    puts "Setting slot size to [Mac/802_11 set slotsize_]"
} else {
    Mac/802_11 set slotsize_ [expr ([Mac/802_11 set payloadSize_] + 20 + [Mac/802_11 set ether_hdr_len_] +\
                                    ($to + $tno)) * 8 / $channelBandwidth]
    puts "Setting slot size to [Mac/802_11 set slotsize_]"
}

Mac/802_11 set zmacMode_ $zmacMode; #1=> lcl    2=> hcl    3=> forced hcl mode (hcl always on)
Mac/802_11 set ack_ $ack
Mac/802_11 set to_ $to
Mac/802_11 set tno_ $tno
Mac/802_11 set timeSyncErrorFlag_ $timeSyncErrorFlag
Mac/802_11 set timeSyncErrorValue_ $timeSyncErrorValue
