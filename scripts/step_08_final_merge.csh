#!/bin/tcsh -f
#==========================
# Take the list of chemical
# data from GLORICH's
# hydrochemistry.csv and
# merge that with the
# step_06_output.txt that
# has the key parameters
# in RiverAtlas located
# to the GLORICH points.
#==========================

set chem_data = ./step_07_output.csv
set phys_data = ./step_06_output.txt
set output = step_08_output.csv

#==============Step_06 reran, this can be safely removed===========
# TODO: In step_06, there are two superflorous
# commas in the final awk write line.  Rerunning
# step_06 will take too long, so edit it out here
#sed 's/,//g' $phys_data > phys_data.txt.tmp
#set phys_data = phys_data.txt.tmp
#===================================================================

# For each line in the chemistry
# data, look up the corresponding
# value in the physical data
# (lon, stream_order, height)
# and create a new output file
#awk -v pd=$phys_data -F, 'NR > 1 {print $1, system("grep "id" "pd), $10, $14}' $chem_data > out.tmp

# Header for feeding this data directly into
# older existing ML model.
#echo "US_Longitude_dec.deg, US_Latitude_dec.deg, US_Water.Column.Height_cm, SW_pH, DO_perc.sat, Stream_Order" > $output

# Header for feeding this data directly into
# newer ML model trained specifically with RA_dm
# and RA_SO variables.
#echo "US_Longitude_dec.deg, US_Latitude_dec.deg, RA_dm, SW_pH, DO_perc.sat, RA_SO" > $output

echo Working on header...
# Newer header with more general SuperLearner and
# pulling out more vars from RA and GL.
#echo "GL_ID, RA_lon_deg, RA_lat_deg, RA_current_ms, RA_SO, RA_dep_m, GL_temp_oC, GL_pH, GL_DO_mgl, GL_DOSAT, GL_TOC" > $output
echo `head -1 $phys_data ` `head -1 $chem_data` | sed 's/ /,/g' > $output

# 1. Remove extra quotation marks (all floats are quoted in hydrochemistry.csv)
# 2. For each row in hydrochemistry, search the physical data file by ID
#    and append the hydrochemistry data to the physical data, column ids
#    in GL/hydrochemistry.csv at "print myline":
#    ---> $8 - Temperature
#    ---> $10 - pH
#    ---> $12 - DO_mgL
#    ---> $14 - DOSAT
#    ---> $56 - TOC (as close as possible to NPOC)
# 3. Seach for any ,, (both pH and DO are missing -> no new data)
#    and skip them (-v -> reverses search)
# 4. Get rid of any remaining commas (i.e. embedded in text strings)
# 5. Coalesce the final output.
#sed 's/\"//g' $chem_data | awk -v pd=$phys_data -F, 'NR > 1 {OFS=","; cmd = ("grep " $1 " " pd); cmd | getline myline; print myline, $8,$10,$12,$14,$56}' | grep -v ,, | sed 's/,/\ /g' | awk '{OFS=","; print $2,$3,$4/$8,$5,$6,$10,$11,$12}' >> $output

# Above line is older version drawing directly from GL/hydrochemistry.csv.
# This newer version below pulls from condensed GLORICH data (output from
# step 7).  No need to select column values among all GLORICH variables,
# just skip over the GLORICH id in the chem data.
#awk -v pd=$phys_data 'NR > 1 {cmd = ("grep " $1 " " pd); cmd | getline myline; print myline, $2,$3,$4,$5,$6}' $chem_data | awk '{OFS=","; print $2,$3,$4/$8,$5,$6,$10,$11,$12,$13,$14}' >> $output

# Line above should work, but running out of processes
# during execution.  Tried increasing noproc in
# /etc/security/limits.conf, but no effect  So do it
# in two stages here:
# This issue is documented here: https://www.gnu.org/software/gawk/manual/html_node/Close-Files-And-Pipes.html
# and can also be remedied with close(cmd).
# So, to fix this number of subprocesses and the grep issues
# identified below, comment out this block and use the block
# below!
#===============================================================
# OLD BUGGY VERSION
#===============================================================
#head -7000 $chem_data > chem1.tmp
#head -1 $chem_data > chem2.tmp
#awk 'NR > 7000 {print $0}' $chem_data >> chem2.tmp

#echo Working on first batch...

# REALLY OLD STUFF DOUBLE COMMENTED!!!
## Older line with fewer RiverAtlas features
##awk -v pd=$phys_data 'NR > 1 {cmd = ("grep " $1 " " pd); cmd | getline myline; print myline, $1,$2,$3,$4,$5,$6}' chem1.tmp | awk '{OFS=","; print $10,$2,$3,$4/$8,$5,$6,$11,$12,$13,$14,$15}' >> $output

# Include lots more RiverAtlas features.  There's nothing
# intricate about column ordering in step_09, so just append
# everything here and convert spaces to commas.  Adding -F,
# to interpret the step_07_output.csv.
#
# Adding "D" to the grep search in the physics file because
# the physcs site ID is always prefixed with D. Otherwise,
# site ID integers can pick up high-precision values in the
# output.
#
# HOWEVER, this is still buggy because if grep doesn't find an
# ID in the file, getline just uses whatever was the previous
# successful search value that had been sent! (Basically
# just repeating what is in a buffer.)
#awk -v pd=$phys_data -F, 'NR > 1 {cmd = ("grep D" $1 " " pd); cmd | getline myline; print myline,$0}' chem1.tmp | sed 's/ /,/g' >> $output

#echo Working on second batch...

## Older line with fewer RiverAtlas features
##awk -v pd=$phys_data 'NR > 1 {cmd = ("grep " $1 " " pd); cmd | getline myline; print myline,$1,$2,$3,$4,$5,$6}' chem2.tmp | awk '{OFS=","; print $10,$2,$3,$4/$8,$5,$6,$11,$12,$13,$14,$15}' >> $output
#awk -v pd=$phys_data -F, 'NR > 1 {cmd = ("grep D" $1 " " pd); cmd | getline myline; print myline,$0}' chem2.tmp | sed 's/ /,/g' >> $output

#echo Done!  Cleaning up...
#rm -f chem2.tmp chem1.tmp
#rm -f phys_data.txt.tmp

# A typical line might look like:
# @D301449|301449|7|"HS15s 8.74014388830847 47.9399454047143 @D20428051 15.380 4 0.977079 58.2199385562,301449,7.7,
# @D301449|301449|7|"HS15s 8.74014388830847 47.9399454047143 @D20428051 15.380 4 0.977079 58.2199385562,301449,,

# Line for experimentation:
# With files:
#jovyan@f3a1a2eccb99:~/work/test$ cat a.txt
#A
#B
#C
#D
#E
#F
#jovyan@f3a1a2eccb99:~/work/test$ cat a1.txt
#aA 1
#aB 2
#aC 3
#
#awk -v pd=a1.txt -F, '{cmd = ("if grep -q " $1 " "pd"; then grep a" $1 " " pd " ; else echo NOT_FOUND; fi"); cmd | getline myline; print myline,$0; close(cmd);}' a.txt

# For each line in chem_data,
#    check if there is a grep match for that id ($1 in chem_data)
#    if there is a match,
#        send the match to getline
#    else
#        sned NOT_FOUND to getline
#    fi
#    take the value in getline and concatenate it with the values in chem_data
# done
# Replace any spaces with commas to make a CSV file.
# Automatically filter out any NOT_FOUND values.
# This is probably twice as slow as necessary since there is a duplicated
# grep statement for the same thing in a large file.
echo Working on each line...
awk -v pd=$phys_data -F, 'NR > 1 {cmd = ("if grep -q D" $1 " " pd "; then grep D" $1 " " pd "; else echo NOT_FOUND; fi"); cmd | getline myline; print myline,$0; close(cmd); }' $chem_data | sed 's/ /,/g' > ${output}.with.missing

echo Filtering out NOT_FOUND...
grep -v NOT_FOUND ${output}.with.missing > tmp.csv

echo Reformatting GLORICH ID to integer...
# Typical GLORICH ID lines were:
#@D100010|100010|7|"HS15s,lon,lat,rest,of,data...
# And we only want the first number.  So, use | as
# a delimiter to get:
#@D100010 , "HS15s,lon,lat,rest,of,data...
# Then cut the file for the first, 3rd, and all
# following columns to get:
#@D100010 ,lon,lat,rest,of,data...
# Finally search replace all "@D" to nothing and
# append to the file we put the header in.
awk -F\| '{print $1,",",$4}' tmp.csv | cut --delimiter=, -f1,3- | sed 's/@D//g' >> $output
${output}

echo Done!
