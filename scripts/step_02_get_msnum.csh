#!/bin/tcsh -f
#=========================
# Get the WMO MS numbers
# for each point in GLORICH
# and then sort and uniq
# the list to figure out
# which tiles we need.
#=========================

# For some reason, the system
# call appends a zero to each
# msnum.  So, run awk again to
# divide by 10 to get rid of
# that extra zero.
awk '{print system("/usr/local/hb2/bin/hb_msnum "$0)/10}' /opt/GLORICH/Sampling_Locations_v1.xy | awk '{print $1/10}' | sort -n | uniq > msnum_in_GLORICH.log
