#!/bin/tcsh -f
#=============================
# Now we are ready to assemble
# everything! Find stream order
# and depth for all points in
# GLORICH (i.e. find RiverAtlas
# records that match GLORICH
# sites but not yet merging
# GLORICH and RiverAtlas ->
# the merge is in step 08.)
#=============================

# Input data is set up with ID
# in comments of line above.
set infile = ~/work/GLORICH/Sampling_Locations_v1.gmt

# Only generate these files if we need do. Do not overwrite
# since it takes a few mins to make them.
#
# Also, second awk filder on line below will grab only x,y
# in rough CONUS domain to speed up processing.
if ( 1 == 1 ) then
    # CONUS prefilter to accelerate run
    #awk '{if ($1 != "#") {print f,$0}; {f=$2};}' $infile | awk '$3 > 20 && $3 < 55 && $2 < -50 && $2 > -150 {print $0}' > ixy.tmp

    # Global
    awk '{if ($1 != "#") {print f,$0}; {f=$2};}' $infile > ixy.tmp

    # Extract just the lon, lat
    # and create a file for each (for use with
    # gmtselect).
    awk '{print $0 > NR".ixy.tmp"}' ixy.tmp
    awk '{print $2, $3 > NR".xy.tmp"}' ixy.tmp
endif

# Determine the number of points and loop over
# each point.  End loop with less than to account
# for the header line in the count.
@ nmax = `wc -l $infile | awk '{print $1}'`
@ nn = 1

echo $nmax
echo $nn

# Older version of the data that has limited inputs from RiverAtlas
#echo GL_id lon lat RA_cms RA_SO RA_dm RA_lm RA_xam2 dist_m > step_06_output.txt

# Newer version with many more RiverAtlas records
echo GL_id GL_lon GL_lat RA_cms_cyr RA_cms_cmn RA_cms_cmx RA_SO RA_dm RA_lm my_lm RA_xam2 run_mm_cyr dor_pc_pva gwt_cm_cav ele_mt_cav slp_dg_cav sgr_dk_rav tmp_dc_cyr tmp_dc_cdi tmp_dc_uyr pre_mm_cyr pre_mm_cdi pre_mm_uyr aet_mm_cyr aet_mm_cdi aet_mm_uyr cmi_ix_cyr cmi_ix_cdi cmi_ix_uyr snw_pc_cyr snw_pc_cmx snw_pc_uyr for_pc_cse for_pc_use crp_pc_cse crp_pc_use pst_pc_cse pst_pc_use ire_pc_cse ire_pc_use gla_pc_cse gla_pc_use prm_pc_cse prm_pc_use pac_pc_cse pac_pc_use cly_pc_cav cly_pc_uav slt_pc_cav slt_pc_uav snd_pc_cav snd_pc_uav soc_th_cav soc_th_uav swc_pc_cyr swc_pc_cdi swc_pc_uyr kar_pc_cse kar_pc_use ero_kh_cav ero_kh_uav pop_ct_csu pop_ct_usu ppd_pk_cav ppd_pk_uav urb_pc_cse urb_pc_use nli_ix_cav nli_ix_uav rdd_mk_cav rdd_mk_uav hft_ix_c09 hft_ix_u09 gdp_md_cav gdp_md_usu hdi_ix_cav dist_m RA_lon RA_lat > step_06_output.txt

while ($nn < $nmax)

    # Get lon, lat
    set xy = `cat ${nn}.xy.tmp`

    # Determine which tile it is in.
    set msnum = `~/work/bin/hb_msnum $xy[1] $xy[2]`

    # Get the tile file names
    set tile_files = `ls -l ~/work/RiverAtlas/tiles/*.${msnum} | awk '$5 != 0 {print $9}'`

    echo Working on $nn at $xy with MS $msnum searching $tile_files
 
    # Search tile files for points within
    # 50m of this point using approx.
    # method (flat Earth).  Use 50 m since
    # the resolution of the topography used
    # to create RiverAtlas, the Shuttle Radar
    # Topography Mission, is 1 arc-second or
    # ~30 m.  Using values less than 30 m will
    # result in no points found.  Since arc-second
    # is a unit option, work with that instead
    # of km or m.
    #
    # These comments were written before the
    # use of -fg, so unclear as to what units
    # I was working in.  Work in two steps:
    # First create a list of candidate points
    # (line files) using a large search radius
    # of 10 km.
    gmt gmtselect $tile_files -C${nn}.xy.tmp+d-10k -fg > lines.tmp

    # Find the shortest distance between the
    # reaches (i.e. lines) found above and
    # the search point.  The result here are:
    # cols 1/2: the lon/lat coordinates of the search point
    # col 3: the distance in meters
    #----and with +p---
    # col 4: the ID/index for the line segment that has the closest point
    # col 5: the fractional, along-line index to the closest point.
    # So, use the 4th column to grab the corresponding
    # header from the lines file.
    set xydif = `gmt mapproject ${nn}.xy.tmp -Llines.tmp+p -fg`

    # Extract the segment of the closest matching point
    gmt gmtconvert lines.tmp -Q$xydif[4] > closest_line.tmp

    #----------------------------------------------------------
    # This other variant outputs the actual coordinate
    # of the closest point detected.
    set xydxy = `gmt mapproject ${nn}.xy.tmp -Llines.tmp -fg`

    # Plot the detected best point
    #echo $xydxy[4] $xydxy[5] | psxy -J -R -B -Sc0.1 -Ggreen -P -O -K >> ${id}.ps
    #----------------------------------------------------------
    
    # Determine the length of the closest matching segment.
    # If that segment is zero long -> only one point -> assume
    # it is 30 m long, which is the lower limit of resolution
    # of the RiverAtlas dataset.
    set seg_len = `gmt gmtspatial closest_line.tmp -Qe+l | awk '{print $3}' | gmt gmtmath -Q STDIN STDIN 30 IFELSE =`
    
    # Grab header from the closest line segment
    # I think this is buggy.  See below.
    #awk '$1 == ">" {print $0}' lines.tmp | awk -v ii=$xydif[4] 'NR == ii {print $2,$3,$4,$6/(10*$5)}' > ${nn}.idsh.tmp
    
    #=======================================================
    # Does not find closest point!
    #=======================================================
    #gmtselect $tile_files -C${nn}.xy.tmp+d-1k -fg -V | awk '$1 == ">" {print $3,$4,$6/(10*$5)}' > ${nn}.dsh.tmp

    # May need to check how many reaches are discovered
    # and iteratively zoom in.  But for now, assume that
    # 0.1 km is a sufficiently small search radius.
    # This line depended on the buggy line, above.
    # Ignore for now.
    #echo `cat ${nn}.ixy.tmp` `cat ${nn}.idsh.tmp` $xydif[3] >> step_05_output.txt

    # Calculate the depth in m based on the volume (in x103 m3)
    # divided by the area (in hectares, 1 ha = 10000 m2) so the
    # Conversion factor looks like:
    # V thousand m3 | 1x103 m3     | 1 ha
    #----------------------------------------- = V/(10*A) = meters
    # A hectares   | 1 thousand m3 | 10000 m2
    # (volume_x10^3_m^3 * 1000)/(length_meters) = x-section area m^2

    # Old version with fewer features from RiverAtlas
    #echo `cat ${nn}.ixy.tmp` `awk -v len=$seg_len '$1 == ">" { dep=$6/(10*$5); xsecta=($6*1000)/len; print $3,$4,dep,len,xsecta;}' closest_line.tmp` $xydif[3] >> step_06_output.txt

    # New version with many more features from RiverAtlas
    # Also use RiverAtlas length instead of calculated length for depth/current/xsect estimates
    echo `cat ${nn}.ixy.tmp` `awk -v len=$seg_len '$1 == ">" { dep=$11/(10*$10); xsecta=($11)/$3; print $5,$6,$7,$4,dep,$3,len,xsecta,$8,$9,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,$71,$72,$73,$74;}' closest_line.tmp` $xydif[3] $xydxy[4] $xydxy[5] >> step_06_output.txt

    rm -f lines.tmp
    rm -f closest_line.tmp
    
    # Move to the next file
    @ nn = $nn + 1

end

# While we should do this to clean up, since
# generating these files takes a few min, don't
# autodelete while developing/testing.
#rm -f *xy.tmp
