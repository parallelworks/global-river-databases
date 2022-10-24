#!/bin/bash
#==========================
# There are GLORICH sites
# with different IDs but
# the same xy coordinates.
#
# The original data processing
# loop assumed that location
# duplication would not occur,
# so this must be corrected now.
#
# Temporary sanity check:
# For each site, report the
# avg and std (stds should be mostly zero!!!)
#==========================

input=step_09_output.csv
output=step_10_output.csv

# Convert the input to xyz (no commas)
input_xyz_tmp=step_09_output.xyz.tmp
sed 's/,/ /g' $input > $input_xyz_tmp

echo "======================================="

echo Verify that there are no duplicated site IDs...
awk 'NR>1{print $1}' $input_xyz_tmp  | sort -n | uniq -c | gmt gmtmath -Ca STDIN UPPER -Sl =

echo Verify that there are duplicated lons...
awk 'NR>1{print $2}' $input_xyz_tmp  | sort -n | uniq -c | gmt gmtmath -Ca STDIN UPPER -Sl =

echo Verify that there are duplicated lats...
awk 'NR>1{print $3}' $input_xyz_tmp  | sort -n | uniq -c | gmt gmtmath -Ca STDIN UPPER -Sl =

echo "======================================="

# Grab a list of just x and y,
# sort the list, and find uniq values.
awk 'NR>1{print $2,$3}' $input_xyz_tmp | sort | uniq -c > tmp.cxy
awk '{print $2,$3}' tmp.cxy > tmp.xy
awk '{print $1}' tmp.cxy > tmp.c
rm -f tmp.cxy

# Sort the list based on just x and y
# For each line in the uniq list of x,y, search for
# all xy in the main list and spit out the average
# and standard deviation values. grep -e is required
# because otherwise minus signs in the numbers are
# interpreted as - for option flags.
echo Finding means...
awk -v file=$input_xyz_tmp '{cmd = "grep -e "$1" "file" | grep -e "$2" | gmt gmtmath -Ca STDIN MEAN -Sl ="; cmd | getline myline; print myline}' tmp.xy > means.xyz.tmp

#============================================================
# I tested with standard deviations
# to cross-check that the expected
# number of sites got averaged/merged
# out.  This is not really helpful
# for ML predictions later, so skip/drop
# this information.
#echo Finding standard deviations...
#awk -v file=$input_xyz_tmp '{cmd = "grep -e "$1" "file" | grep -e "$2" | gmt gmtmath -Ca STDIN STD -Sl ="; cmd | getline myline; print myline}' tmp.xy > stds.xyz.tmp

#header_base=`head -1 $input`
#echo $header_base,num_dup,$header_base | sed 's/ /,/g' > $output

#paste --delimiters=, means.xyz.tmp tmp.c stds.xyz.tmp | sed 's/\t/,/g' >> $output
#=========================================

# Instead, simply add the header to the means:
echo `head -1 $input` > $output
sed 's/\t/,/g' means.xyz.tmp >> $output

# Clean up
rm -f tmp.xy
rm -f tmp.c
rm -f means.xyz.tmp
#rm -f stds.xyz.tmp
rm -f $input_xyz_tmp
