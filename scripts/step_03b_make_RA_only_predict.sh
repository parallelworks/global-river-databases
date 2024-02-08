#!/bin/bash
#======================================
# This script will take the name of
# a COMPRESSED tile file as input
# and locally decompress it and
# convert the data inside to a file
# so that only the first and last
# points of each segment/stream
# are retained and they are posted
# on the same line as the other
# variables in the header.
#
# This step will convert the RiverAtlas
# data only into a format that can be used
# with making ML predictions.
#======================================

# Set input file
compressed_input=$1
bn=`basename $compressed_input .gz`

# Decompress it locally
gunzip -c $compressed_input > ./tmp.xyz

#===================================================================
# Convert
#===================================================================
# 1) -E flag in gmt convert saves only first and last point of reach.
#    This is useful because it makes all segments have only two points
#    so we can manage the data. We don't need all the middle points since
#    at the scale we're plotting the data, the middle points cannot be
#    seen. The data look like:
#  > @ID d1 d2 d3 ... <header data>
#  x1 y1 <start point>
#  x2 y2 <end point>
#
# 2) Convert all newlines to spaces - we want to collapse all the segment
#    start and end points to the same line as the header data.
#
# 3) But of course, we've removed too many newlines (all the data are
#    now on one line, so apply a filter to conver the leading ">" of
#    each record to a newline; this will break each segment into its own line.
#    The data now look like:
# @ID d1 d2 d3 ... <header data> ... x1 y1 x2 y2
#
# 4) We need to reinsert the ">" (or any character really) into each line
#    because we want to use the filter from step_04_test_databash.csh almost
#    exactly as it is with minimal changes since it is so brittle. When we do
#    this step, also skip the first line since that is a spurious, unneeded
#    newline due to step 3.
gmt convert tmp.xyz -E | tr '\n' ' ' | tr '>' '\n' | awk 'NR > 1 {print ">",$0 }' > tmp2.xyz

#===================================================================
# Extract the data the same way as in step_04 and step_06.
#===================================================================

# Write header for newer version with many more RiverAtlas records
echo RA_ID,lon1,lat1,lon2,lat2,RA_cms_cyr,RA_cms_cmn,RA_cms_cmx,RA_SO,RA_dm,RA_lm,RA_xam2,run_mm_cyr,dor_pc_pva,gwt_cm_cav,ele_mt_cav,slp_dg_cav,sgr_dk_rav,tmp_dc_cyr,tmp_dc_cdi,tmp_dc_uyr,pre_mm_cyr,pre_mm_cdi,pre_mm_uyr,aet_mm_cyr,aet_mm_cdi,aet_mm_uyr,cmi_ix_cyr,cmi_ix_cdi,cmi_ix_uyr,snw_pc_cyr,snw_pc_cmx,snw_pc_uyr,for_pc_cse,for_pc_use,crp_pc_cse,crp_pc_use,pst_pc_cse,pst_pc_use,ire_pc_cse,ire_pc_use,gla_pc_cse,gla_pc_use,prm_pc_cse,prm_pc_use,pac_pc_cse,pac_pc_use,cly_pc_cav,cly_pc_uav,slt_pc_cav,slt_pc_uav,snd_pc_cav,snd_pc_uav,soc_th_cav,soc_th_uav,swc_pc_cyr,swc_pc_cdi,swc_pc_uyr,kar_pc_cse,kar_pc_use,ero_kh_cav,ero_kh_uav,pop_ct_csu,pop_ct_usu,ppd_pk_cav,ppd_pk_uav,urb_pc_cse,urb_pc_use,nli_ix_cav,nli_ix_uav,rdd_mk_cav,rdd_mk_uav,hft_ix_c09,hft_ix_u09,gdp_md_cav,gdp_md_usu,hdi_ix_cav > step_03b_output_${bn}

# Use RiverAtlas length instead of calculated length
# for cross sectional area calc
awk '$1 == ">" {OFS=","; dep=$11/(10*$10); xsecta=($11)/$3; print $2,$76,$77,$78,$79,$5,$6,$7,$4,dep,$3,xsecta,$8,$9,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,$71,$72,$73,$74;}' tmp2.xyz >> step_03b_output_${bn}

# Clean up
rm tmp2.xyz
rm tmp.xyz

