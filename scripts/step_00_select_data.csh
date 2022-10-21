#!/bin/tcsh -f
#=======================
# Select which data to
# use from RiverAtlas.
#=======================

# RiverAtlas data were already
# converted from .shp to .gmt
# files, takes a long time and
# files are stored, no need to repeat!
#foreach region ( si as au eu na sa_north sa_south )
#	ogr2ogr -f GMT RiverATLAS_v10_${region}.gmt RiverATLAS_v10_${region}.shp -lco GEOMETRY=AS_XY -t_srs "+proj=longlat +datum=WGS84"
#end


# Data set is really big with more than 281 features
# associated with each line segment in the .gmt
# file.  Here, we want only a subset (~70-ish) features which
# is a roughly 40% data reduction from the original
# .gmt file.  The list of features is:
# ID = $1
# LENGTH_KM = $4
# DIS_AV_CMS (in m^3/s), $10 = same as dis_m3_pyr $15
# ORD_STRA (dimensionless), $11
# dis_m3_pmn, $16
# dis_m3_pmx, $17
# run_mm_cyr, $18
# dor_pc_pva, $29
# ria_ha_csu (hectares), $30
# riv_tc_csu (1000 m^3), $32
# gwt_cm_cav (cm), $34
# ele_mt_cav (m), $35
# slp_dg_cav (deg), $39
# sgr_dk_rav (?), $41
# tmp_dc_cyr (degCx10), $44
# tmp_dc_cdi (degCx10), $47-$46
# tmp_dc_uyr (degCx10), $45
# pre_mm_cyr (mm), $60 -> SUM OVER ALL MONTHS => divide by 12 for mean
# pre_mm_cdi (mm), max-min-diff($62:$73) => actual range in monthly clim
# pre_mm_uyr (mm), $61 -> SUM OVER ALL MONTHS => divide by 12 for mean
# aet_mm_cyr (mm), $88 -> SUM OVER ALL MONTHS => divide by 12 for mean
# aet_mm_cdi (mm), max-min-diff($90:$101) => actual range in monthly clim
# aet_mm_uyr (mm), $89 -> SUM OVER ALL MONTHS => divide by 12 for mean
# cmi_ix_cyr (nondim[-1,1]x100), $104 - mean but with masking that does not include duplicated 100's -> for when water is frozen?
# cmi_ix_cdi (nondim[-1,1]x100), max-min-diff($106:$117) => actual range in monthly clim
# cmi_ix_uyr (nondim[-1,1]x100), $105 - same seasonal/frozen? masking as cmi_ix_cyr
# snw_pc_cyr (%%), $118
# snw_pc_cmx (%%), $120
# snw_pw_uyr (%%), $119
# ------------------------> just to check counting: glc_cl_cmj = $133
# for_pc_cse (%%), $232
# for_pc_use (%%), $233
# crp_pc_cse (%%), $234
# crp_pc_use (%%), $235
# pst_pc_cse (%%), $236
# pst_pc_use (%%), $237
# ire_pc_cse (%%), $238
# ire_pc_use (%%), $239
# gla_pc_cse (%%), $240
# gla_pc_use (%%), $241
# prm_pc_cse (%%), $242
# prm_pc_use (%%), $243
# pac_pc_cse (%%), $244
# pac_pc_use (%%), $245
# cly_pc_cav (%%), $250
# cly_pc_uav (%%), $251
# slt_pc_cav (%%), $252
# slt_pc_uav (%%), $253
# snd_pc_cav (%%), $254
# snd_pc_uav (%%), $255
# soc_th_cav (th), $256
# soc_th_uav (th), $257
# swc_pc_cyr (%%), $258
# swc_pc_cdi (%%), max-min-diff($260:$271)
# swc_pc_uur (%%), $259
# kar_pc_cse (%%), $273
# kar_pc_use (%%), $274
# ero_kh_cav, $275
# ero_kh_uav, $276
# pop_ct_csu, $277
# pop_ct_usu, $278
# ppd_pk_cav, $279
# ppd_pk_uav, $280
# urb_pc_cse, $281
# urb_pc_use, $282
# nli_ix_cav, $283
# nli_ix_uav, $284
# rdd_mk_cav, $285
# rdd_mk_uav, $286
# hft_ix_c09, $289
# hft_ix_u09, $290
# gdp_ud_cav (M$), $292 # Divide by 1e6 to put in decimal place
# gdp_ud_usu (M$), $294 # so no conflicts with site ID search.
# hdi_ix_cav, $295

#Also kept the reach ID mostly because it includes the # comment needed
#for maintaining GMT headers.  Minimal reduction in data to get rid of
#that. We go from 45MB shp file to 330 MB.gmt file (that includes all
#the other layers) to a 64MB .xyz file.  This makes sense: the file is
#now mostly coordinates with a much smaller amount of header information.

#Also, need to modify headers of segments (currently they are
#comments with `#`, need to change that to `>`) and remove the 
#now superflorous segement headers (`>` with no information).
#Process all the .gmt files from the previous batch with this
#batch run:
foreach gmt_file ( /media/sfg/dy052_pso_data_disc/HydroATLAS/RiverATLAS_shp/RiverATLAS_v10_shp/*.gmt )
    echo $gmt_file
    set bn = `basename $gmt_file .gmt`
    # Inline computed variables:
    # pmn, pmx - precip min/max
    # amn, amx - actual evapotranspiration min/max
    # cmn, cmx - climate moisture index min/max
    # smn, smx - soil water content min/max
    awk -F \| '{pmx=0; for(i=62; i<=73; i++) {if ($i>pmx) pmx=$i}; pmn=10000; for(i=62; i<=73; i++) {if ($i<pmn) pmn=$i}; amx=0; for(i=90; i<=101; i++) {if ($i>amx) amx=$i}; amn=10000; for(i=90; i<=101; i++) {if ($i<amn) amn=$i}; cmx=0; for(i=106; i<=117; i++) {if ($i>cmx) cmx=$i}; cmn=10000; for(i=106; i<=117; i++) {if ($i<cmn) cmn=$i}; smx=0; for(i=260; i<=271; i++) {if ($i>smx) smx=$i}; smn=10000; for(i=260; i<=271; i++) {if ($i<smn) smn=$i}; if (NF > 1) print $1,$4,$11,$10,$16,$17,$18,$29,$30,$32,$34,$35,$39,$41,$44,$47-$46,$45,$60,pmx-pmn,$61,$88,amx-amn,$89,$104,cmx-cmn,$105,$118,$120,$119,$232,$233,$234,$235,$236,$237,$238,$239,$240,$241,$242,$243,$244,$245,$250,$251,$252,$253,$254,$255,$256,$257,$258,smx-smn,$259,$273,$274,$275,$276,$277,$278,$279,$280,$281,$282,$283,$284,$285,$286,$289,$290,$292/1e6,$294/1e6,$295; else print $0;}' $gmt_file | sed 's/#/>/g' | awk 'NF > 1 {print $0}' > ${bn}.xyz
end

#Individual removal of Marsden Squares is
#tedious, error-prone, and slow.  Instead,
#simply find the square associated with each
#GLORICH point, sort the list, and find
#unique values.  This creates the list of
#exactly the squares we need to create tiles
#for (step_02_get_msnum).  Note that one 
#WHONDRS site lies outside of the tile range 
#of GLORICH.  I have manually created that 
#tile with a modified version of 
#step_03_make_tiles.csh.  However, if you
#wish to rerun this step, I manually added
#tile 1600 to `msnum_in_GLORICH.log` so
#all you need to do is run `step_03_make_tiles.csh`.
