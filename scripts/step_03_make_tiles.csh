#!/bin/tcsh
#=============================
# For each region, loop over a
# set of Marsden squares to
# create data tiles.
#=============================

# From step 2, we know that we
# have only 134 MS tiles to create
# which is sufficiently small to
# do with a simple brute force
# approach.
foreach msnum ( `cat msnum_in_GLORICH.log ` )

    foreach file ( `ls --color=never /opt/RiverAtlas/*.xyz` )

	echo Working on $file $msnum
	gmtselect $file -F${msnum}.poly.xy > ${file}.${msnum}

    end

end
