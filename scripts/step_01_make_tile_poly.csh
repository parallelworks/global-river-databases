#!/bin/tcsh -f
#===============================
# Make the polygons for all the
# WMO 10x10 degree squares so
# we can tile the WHONDRS data
#===============================

set l1_list = ( 1 3 5 7 )

set l2_list = ( 0 1 2 3 4 5 6 7 8 )

set l3_list = ( 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 )

foreach l1 ( $l1_list )

    foreach l2 ( $l2_list )

	foreach l3 ( $l3_list )

	    set msnum = ${l1}${l2}${l3}
	
	    set bnds = `/usr/local/hb2/bin/hb_msq10bounds ${msnum} | awk -F/ '{print $1, $2, $3, $4}'`

	    # Test we get the same value back from hb_msnum.
	    set xavg = `gmtmath -Q $bnds[1] $bnds[2] ADD 2.0 DIV =`
	    set yavg = `gmtmath -Q $bnds[3] $bnds[4] ADD 2.0 DIV =`
	    set msnum_check = `/usr/local/hb2/bin/hb_msnum $xavg $yavg`

	    # Print output to verify.
	    echo $msnum $msnum_check $bnds[1] $bnds[2] $bnds[3] $bnds[4] 

	    # Create the polygon files, named by msnum.
	    echo $bnds[1] $bnds[3] > ${msnum}.poly.xy
	    echo $bnds[1] $bnds[4] >> ${msnum}.poly.xy
	    echo $bnds[2] $bnds[4] >> ${msnum}.poly.xy
	    echo $bnds[2] $bnds[3] >> ${msnum}.poly.xy
	    echo $bnds[1] $bnds[3] >> ${msnum}.poly.xy
	end

    end

end
    
