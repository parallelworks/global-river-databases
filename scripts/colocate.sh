#!/bin/tcsh
#==============================
# For a given lon, lat ($1 $2)
# pair, query the RiverAtlas
# database for the physical 
# properties at this location.
#
# This script is a streamlined
# one-point-at-a-time version
# of step_06_make_database
#============================

# INPUTS
set lon = $1
set lat = $2

# Determine which tile lon,lat is in.
set msnum = `/usr/local/hb2/bin/hb_msnum $lon $lat`

# Get the tile file names
# Note path here has to match mount point
# of RiverAtlas files into container.                                                                                                                                                                                                           
set tile_files = `ls -l /data/*.${msnum} | awk '$5 != 0 {print $9}'`

# Search tile files for points within                                                                                                                                                                                                        
gmt gmtselect $tile_files -C${nn}.xy.tmp+d-10k -fg > lines.tmp
