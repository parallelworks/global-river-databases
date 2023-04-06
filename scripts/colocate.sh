#!/bin/tcsh
#==============================
# For a given lon, lat ($1 $2)
# pair, query the RiverAtlas
# database for the physical 
# properties at this location.
#
# This script is a streamlined
# one-point-at-a-time version
# of step_06_make_database.
# See comments therein for 
# reasoning behind GMT opts/cmds.
#
# STDOUT of main output is
# redirected to colocated.header
# (if id == "header") or 
# colocated.XXXXXXXXXX (random
# text) so the script runs quietly
# and in parallel across multiple 
# nodes and mktemp random naming
# is all handled internally here.
#
# It is recommended to run it first
# in "header mode" once on its own,
# this will ensure that the data are
# decompressed and ready to go and
# there are no clashes with multiple
# processes attempting to decompress
# the same files at the same time.
#============================

# INPUTS
set id = $1
set lon = $2
set lat = $3

if ( $id == "header" ) then
# Only print the header
echo GL_id GL_lon GL_lat RA_cms_cyr RA_cms_cmn RA_cms_cmx RA_SO RA_dm RA_lm my_lm RA_xam2 run_mm_cyr dor_pc_pva gwt_cm_cav ele_mt_cav slp_dg_cav sgr_dk_rav tmp_dc_cyr tmp_dc_cdi tmp_dc_uyr pre_mm_cyr pre_mm_cdi pre_mm_uyr aet_mm_cyr aet_mm_cdi aet_mm_uyr cmi_ix_cyr cmi_ix_cdi cmi_ix_uyr snw_pc_cyr snw_pc_cmx snw_pc_uyr for_pc_cse for_pc_use crp_pc_cse crp_pc_use pst_pc_cse pst_pc_use ire_pc_cse ire_pc_use gla_pc_cse gla_pc_use prm_pc_cse prm_pc_use pac_pc_cse pac_pc_use cly_pc_cav cly_pc_uav slt_pc_cav slt_pc_uav snd_pc_cav snd_pc_uav soc_th_cav soc_th_uav swc_pc_cyr swc_pc_cdi swc_pc_uyr kar_pc_cse kar_pc_use ero_kh_cav ero_kh_uav pop_ct_csu pop_ct_usu ppd_pk_cav ppd_pk_uav urb_pc_cse urb_pc_use nli_ix_cav nli_ix_uav rdd_mk_cav rdd_mk_uav hft_ix_c09 hft_ix_u09 gdp_md_cav gdp_md_usu hdi_ix_cav dist_m RA_lon RA_lat > colocated.header

chmod a+rw colocated.header

else

# Set output file
set tmp_out_file = `mktemp -p $PWD colocated.XXXXXXXXXX`

# Find closest point in RiverAtlas and extract data

# Set context (mount point into container of directory with processing scripts)
cd /work

# Determine which tile lon,lat is in.
set msnum = `/usr/local/hb2/bin/hb_msnum $lon $lat`

# Get the tile file names
# Note path here has to match mount point
# of RiverAtlas files into container.
set tile_files = `ls -l /data/*.${msnum} | awk '$5 != 0 {print $9}'`

# Create a temporary file that stores .xy
# Use mktemp to avoid clashes when parallelizing
set tmp_xy_file = `mktemp -p $PWD XXXXXXXXXX.xy`
echo $lon $lat > $tmp_xy_file

# Prepare a temporary file that stores results of matching lines
# (within the search radius specified in gmtselect, below)
set tmp_lines_file = `mktemp -p $PWD XXXXXXXXXX.lines`
set tmp_match_file = `mktemp -p $PWD XXXXXXXXXX.match`

# Search tile files for points within
gmt gmtselect $tile_files -C${tmp_xy_file}+d-10k -fg > $tmp_lines_file

# Find closest line to search point
set xydif = `gmt mapproject ${tmp_xy_file} -L${tmp_lines_file}+p -fg`

# Extract the segment of the closest matching point
gmt gmtconvert $tmp_lines_file -Q$xydif[4] > $tmp_match_file
 
# This other variant outputs the actual coordinate
# of the closest point detected.
set xydxy = `gmt mapproject ${tmp_xy_file} -L${tmp_lines_file} -fg`

# Determine the length of the closest matching segment.
set seg_len = `gmt gmtspatial ${tmp_match_file} -Qe+l | awk '{print $3}' | gmt gmtmath -Q STDIN STDIN 30 IFELSE =`

# Print output
echo $id `cat ${tmp_xy_file}` `awk -v len=$seg_len '$1 == ">" { dep=$11/(10*$10); xsecta=($11)/$3; print $5,$6,$7,$4,dep,$3,len,xsecta,$8,$9,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,$71,$72,$73,$74;}' ${tmp_match_file}` $xydif[3] $xydxy[4] $xydxy[5] > ${tmp_out_file}

chmod a+rw ${tmp_out_file}

# Clean up
rm -f $tmp_xy_file
rm -f $tmp_lines_file
rm -f $tmp_match_file

endif
