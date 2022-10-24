#!/bin/tcsh -f
#===========================
# Add -Z<Stream_Order> to
# each header record.  This
# is duplicated information
# but useful for plotting.
#==========================

# To set this up after step_03,
# I first moved all the tiles
# from step_03 into a new dir
# tiles_noz.  The new tiles will
# be copied over to the
# newly created tiles dir.

mkdir -p tiles

foreach file ( tiles_noz/*.xyz.* )

    echo Working on $file

    set bn = `basename $file`

    echo $bn
    
    awk '{ if ($1 == ">") {print $0,"-Z"$4;} else {print $0} }' $file > tiles/${bn}

end
