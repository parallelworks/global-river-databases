#!/bin/tcsh -f
#=====================================
# Consider removing or tagging outliers
# so the data can be used more efficiently
# later.
#
# No weighting is applied here yet
# because need to think through how to
# apply a single weight across many
# variables.
#
# Ultimately, now that we have applied
# a sanity filter, it may not be
# necessary to apply any weighting at
# all.
#=====================================

set infile = step_08_output.csv
set outfile = step_09_output.csv

# Copy infile to temporary file without commas
# and the drop the header; this file is only
# used to compute statistics for each variable/
# column.
sed 's/,/ /g' $infile | awk 'NR>1{print $0}' > tmp.xyz

# Find key statistics associated with each column:
set means = `gmt gmtmath -Ca tmp.xyz MEAN -Sl =`
set stdev = `gmt gmtmath -Ca tmp.xyz STD -Sl =`
set max = `gmt gmtmath -Ca tmp.xyz UPPER -Sl =`
set min = `gmt gmtmath -Ca tmp.xyz LOWER -Sl =`

echo Initial Statistics:
@ n = 1
foreach var ( `head -1 $infile | sed 's/,/ /g'` )
    echo "===================================="
    echo $n " --- " $var $means[$n] " +/- " $stdev[$n] " min: " $min[$n] " max: " $max[$n]
    @ n = $n + 1
end

# Clean up
rm -f tmp.xyz

#===============Removal==================

# In the lines below, NR == 1 is added to ensure
# header line is always printed.

# Stream speed == 0 -> drop 3 lines
# Note this is ||, so streams for which the min value for
# the year = 0 ($5) are still allowed as long as there is
# a non-zero value at some point in the year.
# There is even a stream whose mean value for the year is
# zero to 0.000 but since there is a non-zero max value
# in $6, it is still allowed.
awk -F, 'NR == 1 || $4 != 0 || $5 != 0 || $6 != 0 {OFS=","; print $0;}' $infile > tmp1.csv

#============Not an issue any more=================
# Absurdly high temperatures -> drop 1000+ lines -> sites!
# This means that we need to prefilter the GLORICH
# data before we merge.
# By removing these temperatures, the lines with crazy high
# pH are also removed.  Apply the temp and pH sanity checks
# in step 07 first.
#awk -F, 'NR == 1 || $79 < 100 {OFS=","; print $0;}' tmp1.csv > tmp2.csv

# -999 in clay, sand, silt data sets at limited locations.
sed 's/-999/NaN/g' tmp1.csv > tmp2.csv

#===============Recheck stats============

# Copy infile to temporary file without commas
# and drop the header:
sed 's/,/ /g' tmp2.csv | awk 'NR>1{print $0}' > tmp.xyz

# Find key statistics associated with each column:
set means = `gmt gmtmath -Ca tmp.xyz MEAN -Sl =`
set stdev = `gmt gmtmath -Ca tmp.xyz STD -Sl =`
set max = `gmt gmtmath -Ca tmp.xyz UPPER -Sl =`
set min = `gmt gmtmath -Ca tmp.xyz LOWER -Sl =`

echo Post-Filter Statistics:
@ n = 1
foreach var ( `head -1 $infile | sed 's/,/ /g'` )
    echo "===================================="
    echo $n " --- " $var $means[$n] " +/- " $stdev[$n] " min: " $min[$n] " max: " $max[$n]
    @ n = $n + 1
end

# Clean up
rm tmp.xyz
rm tmp1.csv
mv tmp2.csv $outfile

