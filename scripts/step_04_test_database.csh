#!/bin/tcsh -f
#=============================
# Now we are ready to assemble
# everything!  This step 04
# is essentially the same as
# step 06 except that it is
# operating only over the
# WHONDRS sites and merging
# WHONDRS data with RiverAtlas.
#
# Step 06 will find the RiverAtlas
# records that match GLORICH sites.
#
# The key goal is to test
# that the stream order found
# here is the same as in the
# WHONDRS data and first
# try the merge on a small scale.
#
# Also make some plots to
# diagnose differences (plots
# will not be made for in
# step 06).
#=============================

# Input data
set infile = /home/sfg/Desktop/active_projects/ParallelWorks/DOE_SBIR_PhaseI_2020/WHONDRS/Unpublished_Data/WHONDRS_S19S_StreamOrder.csv

# Stream order colorscale
makecpt -Cno_green -T1/10/1 > so.cpt.tmp

# Extract just the lon, lat, stream order data
# and create a file for each (for use with
# gmtselect).  Skip the header line and
# number each point to search starting with 1.
awk -F, 'NR > 1 {OFS=","; print $1,$7,$8,$9 > (NR-1)".ixys.tmp";}' $infile
awk -F, 'NR > 1 {print $7,$8 > (NR-1)".xy.tmp"}' $infile

# Determine the number of points and loop over
# each point.  End loop with less than to account
# for the header line in the count.
@ nmax = `wc -l $infile | awk '{print $1}'`
@ nn = 1

echo $nmax
echo $nn

# Older version of the data that has limited inputs from RiverAtlas
#echo WH_ID,lon,lat,WH_SO,RA_cms,RA_SO,RA_dm,RA_lm,RA_xam2,dist_m > step_04_output.csv

# Newer version with many more RiverAtlas records
echo WH_ID,lon,lat,WH_SO,RA_cms_cyr,RA_cms_cmn,RA_cms_cmx,RA_SO,RA_dm,RA_lm,my_lm,RA_xam2,run_mm_cyr,dor_pc_pva,gwt_cm_cav,ele_mt_cav,slp_dg_cav,sgr_dk_rav,tmp_dc_cyr,tmp_dc_cdi,tmp_dc_uyr,pre_mm_cyr,pre_mm_cdi,pre_mm_uyr,aet_mm_cyr,aet_mm_cdi,aet_mm_uyr,cmi_ix_cyr,cmi_ix_cdi,cmi_ix_uyr,snw_pc_cyr,snw_pc_cmx,snw_pc_uyr,for_pc_cse,for_pc_use,crp_pc_cse,crp_pc_use,pst_pc_cse,pst_pc_use,ire_pc_cse,ire_pc_use,gla_pc_cse,gla_pc_use,prm_pc_cse,prm_pc_use,pac_pc_cse,pac_pc_use,cly_pc_cav,cly_pc_uav,slt_pc_cav,slt_pc_uav,snd_pc_cav,snd_pc_uav,soc_th_cav,soc_th_uav,swc_pc_cyr,swc_pc_cdi,swc_pc_uyr,kar_pc_cse,kar_pc_use,ero_kh_cav,ero_kh_uav,pop_ct_csu,pop_ct_usu,ppd_pk_cav,ppd_pk_uav,urb_pc_cse,urb_pc_use,nli_ix_cav,nli_ix_uav,rdd_mk_cav,rdd_mk_uav,hft_ix_c09,hft_ix_u09,gdp_md_cav,gdp_md_usu,hdi_ix_cav,dist_m > step_04_output.csv

while ($nn < $nmax)

    # Get lon, lat
    set xy = `cat ${nn}.xy.tmp`

    # Get site ID
    set id = `cat ${nn}.ixys.tmp | awk -F, '{print $1}'`
    
    # Set plot domain
    set dx = 0.2
    set dy = 0.2
    set xmin = `gmtmath -Q $xy[1] $dx SUB =`
    set xmax = `gmtmath -Q $xy[1] $dx ADD =`
    set ymin = `gmtmath -Q $xy[2] $dy SUB =`
    set ymax = `gmtmath -Q $xy[2] $dy ADD =`
    psbasemap -JM5i -BWeSn+t${id} -Bp0.25 -X1i -Y2i -R${xmin}/${xmax}/${ymin}/${ymax} -P -K > ${id}.ps
        
    # Determine which tile it is in.
    set msnum = `/usr/local/hb2/bin/hb_msnum $xy[1] $xy[2]`

    # Get the tile file names
    set tile_files = `ls -l /opt/RiverAtlas/tiles/*.${msnum} | awk '$5 != 0 {print $9}'`
    
    echo Working on $nn at $xy with MS $msnum searching $tile_files

    # Plot all available data in zoom in
    psxy $tile_files -J -R -B -Wthicker -Cso.cpt.tmp -P -O -K >> ${id}.ps
    
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
    gmtselect $tile_files -C${nn}.xy.tmp+d-10k -fg > lines.tmp

    # Plot the line segments found
    psxy lines.tmp -J -R -B -Wthinnest,black -P -O -K >> ${id}.ps

    # Plot the search point
    psxy ${nn}.xy.tmp -J -R -B -Wthin,blue -S+0.2 -P -O -K >> ${id}.ps
    
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
    set xydif = `mapproject ${nn}.xy.tmp -Llines.tmp+p -fg`

    # This other variant outputs the actual coordinate
    # of the closest point detected.
    set xydxy = `mapproject ${nn}.xy.tmp -Llines.tmp -fg`

    # Plot the detected best point
    echo $xydxy[4] $xydxy[5] | psxy -J -R -B -Sc0.1 -Ggreen -P -O -K >> ${id}.ps

    # Extract the segment of the closest matching point
    gmtconvert lines.tmp -Q$xydif[4] > closest_line.tmp

    # Determine the length of the closest matching segment.
    # If that segment is zero long -> only one point -> assume
    # it is 30 m long, which is the lower limit of resolution
    # of the RiverAtlas dataset.
    gmtspatial closest_line.tmp -Qe+l | awk '{print $3}'
    set seg_len = `gmtspatial closest_line.tmp -Qe+l | awk '{print $3}' | gmtmath -Q STDIN STDIN 30 IFELSE =`
    
    # Plot the closest line
    psxy closest_line.tmp -J -R -B -Wthinnest,red -P -O -K -t25 >> ${id}.ps

    # Put in a colorbar
    psscale -Dx0.0i/-0.5i+w5i/0.25i+h -Cso.cpt.tmp -P -O >> ${id}.ps
    
    # Grab header from the closest line segment
    # I think this line is buggy. See below.
    #awk '$1 == ">" {print $0}' lines.tmp | awk -v ii=$xydif[4] 'NR == ii {print $3,$4,$6/(10*$5)}' > ${nn}.dsh.tmp
   
    #=======================================================
    # Does not find closest point!
    #=======================================================
    #gmtselect $tile_files -C${nn}.xy.tmp+d-1k -fg -V | awk '$1 == ">" {print $3,$4,$6/(10*$5)}' > ${nn}.dsh.tmp

    # May need to check how many reaches are discovered
    # and iteratively zoom in.  But for now, assume that
    # 0.1 km is a sufficiently small search radius.
    # This line used the buggy line, above.  Ignore for now.
    #echo `cat ${nn}.ixys.tmp` `cat ${nn}.dsh.tmp` $xydif[3] >> output.txt

    # (cubic meters/sec)/(depth_meters*width_meters) = m/s
    # (volume_x10^3_m^3 * 1000)/(area_hectare*10000) = (m^3)/(m^2)
    # (volume_x10^3_m^3 * 1000)/(length_meters) = x-section area m^2
    # ---> (volume_x10^3_m^3 * 1000)/(length_kilometers*1000) = x-section area m^2
    
    # Old version with fewer features from RiverAtlas
    #echo `cat ${nn}.ixys.tmp` `awk -v len=$seg_len '$1 == ">" {OFS=","; dep=$6/(10*$5); xsecta=($6*1000)/len; print ","$3,$4,dep,len,xsecta",";}' closest_line.tmp` $xydif[3] >> step_04_output.csv

    # New version with many more features from RiverAtlas
    # Also use RiverAtlas length instead of calculated length
    # for cross sectional area calc
    echo `cat ${nn}.ixys.tmp` `awk -v len=$seg_len '$1 == ">" {OFS=","; dep=$11/(10*$10); xsecta=($11)/$3; print ","$5,$6,$7,$4,dep,$3,len,xsecta,$8,$9,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,$71,$72,$73,$74",";}' closest_line.tmp` $xydif[3] >> step_04_output.csv



    # 1 2          3         4        5          6          7
    # > @NHYRIV_ID LENGTH_KM ORD_STRA DIS_AV_CMS dis_m3_pmn dis_m3_pmx

    # 8          9          10         11
    # run_mm_cyr dor_pc_pva ria_ha_csu riv_tc_csu

    # 12         13... 74
    # gwt_cm_cav ele_mt_cav slp_dg_cav sgr_dk_rav tmp_dc_cyr 0 tmp_dc_uyr pre_mm_cyr -10000 pre_mm_uyr aet_mm_cyr -10000 aet_mm_uyr cmi_ix_cyr -10000 cmi_ix_uyr snw_pc_cyr snw_pc_cmx snw_pc_uyr for_pc_cse for_pc_use crp_pc_cse crp_pc_use pst_pc_cse pst_pc_use ire_pc_cse ire_pc_use gla_pc_cse gla_pc_use prm_pc_cse prm_pc_use pac_pc_cse pac_pc_use cly_pc_cav cly_pc_uav slt_pc_cav slt_pc_uav snd_pc_cav snd_pc_uav soc_th_cav soc_th_uav swc_pc_cyr -10000 swc_pc_uyr kar_pc_cse kar_pc_use ero_kh_cav ero_kh_uav pop_ct_csu pop_ct_usu ppd_pk_cav ppd_pk_uav urb_pc_cse urb_pc_use nli_ix_cav nli_ix_uav rdd_mk_cav rdd_mk_uav hft_ix_c09 hft_ix_u09 0 0 hdi_ix_cav


    # Clean up
    rm -f lines.tmp
    rm -f closest_line.tmp
    ps2pdf ${id}.ps
    rm -f ${id}.ps
    mv ${id}.pdf ${id}.pdf.tmp
    
    # Move to the next file
    @ nn = $nn + 1

end
