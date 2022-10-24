#!/bin/tcsh -f
#==============================
# The GLORICH hydrochemistry data
# has many sites and many samples
# per site.  Here, we want to condense
# the data by finding just the mean
# properties of a given site.
# This is also an opportunity to
# pull just the data we want from
# GLORICH.
#==============================

set infile = /opt/GLORICH/hydrochemistry.csv
set outfile = step_07_output.txt

echo Grabbing data...
# 1. Remove all quotes (all values are are quoted,
#    including numbers).
# 2. Pull out just the columns we want.
#    $1 -- site ID
#    $8 -- temperature
#    $10 - pH
#    $12 - DO_mgL
#    $14 - DOSAT
#    $56 - TOC (as close as possible to NPOC)
# 3. There are several lines that do not contain the variables we want.
#    Replace missing values with NaN.
# 4. Remove any lines that have an ID and only NaN (no
#    data that we want collected at this site).
# 4. Sort all rows based on the first column (the site ID) to ensure all
#    data for a particular site are grouped together.
sed 's/\"//g' $infile | awk -F, '{OFS=","; print $1,$8,$10,$12,$14,$56}' | awk -F, '{ for(N=1; N<=NF; N++) if($N=="") $N="NaN"} {print $1,$2,$3,$4,$5,$6}' | awk '$2 != "NaN" || $3 != "NaN" || $4 != "NaN" || $5 != "NaN" || $6 != "NaN" {print $0}' | sort -k 1,1 -g > tmp1.xyz

# There may be some exceptionally high carbon values that
# begin to overlap numerically with the site ID.  However,
# there is not actual overlap, so we can safely use a simple
# grep, but this should be verified with future releases of
# GLORICH.

echo Done with grabbing data.  Applying sanity filter...

set nlines = `wc -l tmp1.xyz`
echo Starting with $nlines lines.
echo "================================================="
head -1 tmp1.xyz
gmtmath tmp1.xyz UPPER -Sl =
gmtmath tmp1.xyz LOWER -Sl =
gmtmath tmp1.xyz MEAN -Sl =
gmtmath tmp1.xyz STD -Sl =
echo "================================================="

# In the lines below, NR == 1 is added to ensure
# header line is always printed.

# Remove absurdly high temperatures
# Goes from 945473 -> 548369 lines.
awk 'NR == 1 || $2 < 100 {print $0}' tmp1.xyz > tmp2.xyz

set nlines = `wc -l tmp2.xyz`
echo Ending with $nlines lines.
echo "================================================="
head -1 tmp2.xyz
gmtmath tmp2.xyz UPPER -Sl =
gmtmath tmp2.xyz LOWER -Sl =
gmtmath tmp2.xyz MEAN -Sl =
gmtmath tmp2.xyz STD -Sl =
echo "================================================="

echo Done with sanity filter.  Finding means per site...
# The first column is the site ID.  
# 1. Grab the header line.
# 2. Split large file into file for each site.
# 3. For each site, find the mean values.
awk 'NR==1 {print $0}' tmp2.xyz > $outfile
awk 'NR > 1 {print $0 >> $1".tmp.xyz"}' tmp2.xyz
rm -f tmp1.xyz
rm -f tmp2.xyz
foreach file ( `ls -1 *.tmp.xyz` )
    #echo Working on $file
    gmtmath $file MEAN -Sl = >> $outfile
    rm -f $file
end
echo Done!

# MANUALLY replaced all tabs with comma to make a csv
# file, too.  Used cntrl-V + tab in terminal to insert
# literal tab, eg.:
# sed 's/ /,/g' step_07_output.txt > step_07_output.csv
