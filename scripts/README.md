# Prerequisites

The data processing here was done in a Docker container
[stefanfgary/socks](https://hub.docker.com/r/stefanfgary/socks)
that already had the [Generic Mapping Tools](https://www.generic-mapping-tools.org/) installed.
The Dockerfile for this container and additional instructions
for how to launch it are available in [this GitHub repository](https://github.com/stefangary/socks).

The only additional software is ogr2ogr. I used the ogr2ogr
tool in GDAL outside of the Docker container on an Ubuntu18
laptop. This [blog post is a good way to install GDAL](http://www.sarasafavi.com/installing-gdalogr-on-ubuntu.html).  The takeaway is:
```bash
sudo add-apt-repository ppa:ubuntugis/ppa && sudo apt-get update
sudo apt-get install gdal-bin
```

I also had to manually add libproj with:
```bash
sudo apt-get install libproj-dev
```

# GLORICH

## Data source

### Downloaded GLORICH from

[PANGEA](https://doi.pangaea.de/10.1594/PANGAEA.902360)
on November 20, 2020. It comes as a 150MB `.zip`
file, unzips to 466MB.

### Citation

Hartmann et al. (2014) A Brief Overview of the GLObal RIver Chemistry Database, GLORICH. Procedia Earth and Planetary Science, 10, 23-27: https://doi.org/10.1016/j.proeps.2014.08.005.

## Data organization

`Documentation_Final_2019_05_24.pdf` provides an
excellent summary of the data. Each line in
`hydrochemistry.csv` contains the chemical observations
and a site ID.  The ID is used to sync with
`sampling_locations.csv`

## Data conversion

To convert the shapefiles from ArcGIS format 
(some kind of XML) to an easier (IMO) to use 
xyz columnar data (basically a .csv, but uses spaces
instead of commas), use `ogr2ogr` which is part of 
GDAL.

```bash
ogr2ogr -f GMT Catchments_v1.gmt Catchments_v1.shp -lco GEOMETRY=AS_XY -t_srs "+proj=longlat +datum=WGS84"
```

This operation takes a 167MB file defining the 
catchments of each GLORICH sample site to a 359MB 
file (more than doubling - but a shapefile may 
have additional ancilliary files; it's unclear to 
me to what extent data from the ancilliary files 
is rolled into the output .gmt file).

Although there is a `sampling_locations.csv` file provided
with GLORICH, it is not straightforward to use
because they have different datums referencing the
lon/lat pairs.  Also, the precision in the .csv file is
too low to colocate sites to specific reaches.  Unfortunately,
there is some error in the dataset so that some sites listed
in the `hydrochemistry.csv` are listed in the `sampling_locations.csv`
file but not in the .gmt file that results from the operation
below.  I had to choose between using all sites at low precision
(x,y from sampling_locations.csv) or only ~90% of sites at
high precision (x,y from `Sampling_Locations_v1.gmt`).  I picked
the latter b/c of the need to colocate reach-by-reach to
stream order. So convert that data with ogr2ogr as well.
Use this line:

```bash
ogr2ogr -f GMT Sampling_Locations_v1.gmt Sampling_Locations_v1.shp -lco GEOMETRY=AS_XY -t_srs "+proj=longlat +datum=WGS84"
```

This is nice except that the information about the
sampling site is in the comment above each point.  To
extract lon, lat given a GLORICH site ID:

```bash
grep D100351 Sampling_Locations_v1.gmt -C1 | tail -1
```

where 100351 is an example site ID and use the D prefix
to ensure that grep does not pull out a numerical string
within the high precision decimals.

To make a rough plot:
```bash
psxy Catchments_v1.gmt -JM6i -R-180/180/-70/70 -Y1i -Wthinnest -P -K > out.ps
psxy Sampling_Locations_v1.gmt -J -R -Sc0.01 -P -O -Gred >> out.ps
ps2pdf out.ps
```

Note that polygons are separated by `>` characters 
and `#` below the start of each polygon are polygon 
headers with the catchment ID for cross linking with 
the rest of the GLORICH dataset.

## Manual changes

The `catchment_properties.csv` file can be used as is and
there is no need to go back the .shp because I can look
up by site ID.  For this file, manually created columns
to find mean and seasonal cycle amplitude of runoff,
precip, temp, and wind.  (Manual as in created new
columns in spreadsheet software, applied equations, and
saved a new file.) (Note that runoff and precip
were mistakenly labeled as means but really annual sums!)
Also found the sum of the ground frost days.  Monthly
data columns were removed to save space as were the
"not defined", LITHO_CHECKSUM, and GLC_PREC_COV columns.
Also computed the 2000 - 1990 population growth and removed
1990, 1995, and 2000 population densities.  Due to manual
changes and small file size, this preprocessed version
of the file is copied in this repo.

Altitude, Catch_Slope, PermafrostIndex, ET, and ETpot
overlap with RiverAtlas, but retained here for sanity
cross checking.

# RiverATLAS and BasinATLAS

## Data source

These two data sets are subsets of 
[HydroATLAS](https://www.hydrosheds.org/page/hydroatlas), 
distribued by HydroSHEDS.  The data are available for 
download on [figshare](https://figshare.com/articles/HydroATLAS_version_1_0/9890531).

### Acknowledgement

The following copyright statement must be displayed with, attached to or embodied in (in a reasonably prominent manner) the documentation or metadata of any Licensee Product or Program provided to an End User when utilizing the Licensed Materials:

This product ["="">insert Licensee Derivative Product name] incorporates data from the HydroSHEDS database which is © World Wildlife Fund, Inc. (2006-2013) and has been used herein under license. WWF has not evaluated the data as altered and incorporated within ["="">insert Licensee Derivative Product name], and therefore gives no warranty regarding its accuracy, completeness, currency or suitability for any particular purpose. Portions of the HydroSHEDS database incorporate data which are the intellectual property rights of © USGS (2006-2008), NASA (2000-2005), ESRI (1992-1998), CIAT (2004-2006), UNEP-WCMC (1993), WWF (2004), Commonwealth of Australia (2007), and Her Royal Majesty and the British Crown and are used under license. The HydroSHEDS database and more information are available at http://www.hydrosheds.org.

### Citation

The scientific citation for the HydroSHEDS database is:

Lehner, B., Verdin, K., Jarvis, A. (2008): New global hydrography derived from spaceborne elevation data. Eos, Transactions, AGU, 89(10): 93-94.

General citations and acknowledgements of HydroATLAS should be made as follows:

Linke, S., Lehner, B., Ouellet Dallaire, C., Ariwi, J., Grill, G., Anand, M., Beames, P., Burchard-Levine, V., Maxwell, S., Moidu, H., Tan, F., Thieme, M. (2019). Global hydro-environmental sub-basin and river reach characteristics at high spatial resolution. Scientific Data 6: 283. DOI: 10.1038/s41597-019-0300-6.
We kindly ask users to cite both source data and HydroATLAS in any published material produced using the data. If possible, online links to the HydroATLAS website should be provided (http://www.hydrosheds.org/page/hydroatlas).


1. RiverATLAS download is 2.4GB and unzips to 13.0GB

2. BasinATLAS download is 4.0GB and unzips to 11.5GB

## Data conversion

Focus on RiverATLAS first since that is the one with the data we really
want: stream order.  (Update: In hindsight, never ended up using BasinATLAS).
RiverATLAS is broken into subregions, each with
its own shapefile.  Starting with the si shapefile, used exactly the same
conversion line as above and it seems to work (which is miraculous
given that the *.shp files in RiverATLAS appear to be binaries while
the *.shp files in GLORICH are text files).  This will take a while...

```bash
ogr2ogr -f GMT RiverATLAS_v10_si.gmt RiverATLAS_v10_si.shp -lco GEOMETRY=AS_XY -t_srs "+proj=longlat +datum=WGS84"
```

I ran the rest as a tcsh batch job:
```tcsh
foreach region ( as au eu na sa_north sa_south )
	ogr2ogr -f GMT RiverATLAS_v10_${region}.gmt RiverATLAS_v10_${region}.shp -lco GEOMETRY=AS_XY -t_srs "+proj=longlat +datum=WGS84"
	end
```

And then to plot for sanity check (don't do this all the time, it's slow):
```bash
psxy RiverATLAS_v10_si.gmt -JM6i -R-180/180/-70/70 -Y1i > out.ps
ps2pdf out.ps
```

Based in the GLORICH data availability, the only region we won't use
here is "gr" for Greenland.  Otherwise, all the other shapefiles are
covered.

## Data processing

We really just want stream order, but could also grab volume/area as a proxy
for the average height in the reach.  Could also grab discharge estimate.

Data seems really big, but simplifies if all we want is these few vars.
For example, grabbing DIS_AV_CMS (in m^3/s), ORD_STRA (dimensionless), 
ria_ha_csu (hectares), riv_tc_csu (1000 m^3) as:

```bash
awk -F \| '{if (NF > 1) print $1,$10,$11,$30,$32; else print $0;}' RiverATLAS_v10_ar.gmt > RiverATLAS_v10_ar.xyz
```

Also kept the reach ID mostly because it includes the # comment needed
for maintaining GMT headers.  Minimal reduction in data to get rid of
that. We go from 45MB shp file to 330 MB.gmt file (that includes all
the other layers) to a 64MB .xyz file.  This makes sense: the file is
now mostly coordinates with a much smaller amount of header information.

Also, need to modify headers of segments (currently they are
comments with `#`, need to change that to `>`) and remove the 
now superflorous segement headers (`>` with no information).
Process all the .gmt files from the previous batch with this
batch run:
```tcsh
foreach file ( *.gmt )
	set bn = `basename $file .gmt`
	awk -F \| '{if (NF > 1) print $1,$10,$11,$30,$32; else print $0;}' ${bn}.gmt | sed 's/#/>/g' | awk 'NF > 1 {print $0}' > ${bn}.xyz
	end
```

At this level of cutting down, the global data is 1.6GB.

# Removing Marsden Squares:
36*, 37*, 38*, 56*, 57*, 58* can be deleted b/c no
Antarctic coverage.
```bash
rm -f 3[678]*.poly.xy
rm -f 5[678]*.poly.xy
```

Individual removal of Marsden Squares is
tedious, error-prone, and slow.  Instead,
simply find the square associated with each
GLORICH point, sort the list, and find
unique values.  This creates the list of
exactly the squares we need to create tiles
for (step_02_get_msnum).  Note that one 
WHONDRS site lies outside of the tile range 
of GLORICH.  I have manually created that 
tile with a modified version of 
step_03_make_tiles.csh.  However, if you
wish to rerun this step, I manually added
tile 1600 to `msnum_in_GLORICH.log` so
all you need to do is run `step_03_make_tiles.csh`.

# Pipeline

The data processing is documented in the numbered scripts.
None of the original downloaded data is retained 
because 1) it is really big and 2) it takes a long time run the
processing so it's unlikely to be repeated.  The distilled
files are saved here.  Below is a brief summary of each step.
The process is complicated by the fact that the RiverAtlas
data set is very large so it was tiled so searches for
co-locating a site can run much faster (i.e. search within
a 1x1 degree tile instead of a whole contient's file).

+ `step_00_select_data.csh`: Pull out just the variables of
interest from RiverAtlas and basically save it in the same format.
The list of compressed intermediate file output is below, each
file is clearly too large for pushing to GitHub.
207M RiverATLAS_v10_af.xyz.gz
 42M RiverATLAS_v10_ar.xyz.gz
208M RiverATLAS_v10_as.xyz.gz
107M RiverATLAS_v10_au.xyz.gz
141M RiverATLAS_v10_eu.xyz.gz
145M RiverATLAS_v10_na.xyz.gz
140M RiverATLAS_v10_sa_north.xyz.gz
 71M RiverATLAS_v10_sa_south.xyz.gz
 94M RiverATLAS_v10_si.xyz.gz
+ `step_01_make_tile_poly.csh`: Make polygons delineating
tile outlines (polygon files not stored here).
+ `step_02_get_msnum.csh`: Get the WMO MS numbers for each
point in GLORICH and then sort and uniq the list to figure
out which tiles we need.
+ `step_03_make_tiles.csh`: Use the list of polygons from Step 02
(polygons created in Step 01) to sort the reformatted data from
Step 00 into small tiles that will be faster to search through
than the larger files.  These smaller files can also be archived
on GitHub.
+ `step_03a_add_Z.csh`: Add `-Z <stream_order>` flag to each segment
in the .xyz tile files.  This is useful for plotting. The resulting
data are the same, just with stream order duplicated and the second
instance of that data is more prominent.  This step is optional
since further processing (aside from plotting) would have access
to stream order alongside all the other data. The
`../RiverAtlas/ties` directory archived here is the result of
Step 3a, not Step 3.  The intermediate result from Step 3 is not
retained.
+ `step_04_test_database.csh`: Test building the database with a
small number of data points - use the original WHONDRS summer 2019
data where there is independent stream order data.  This allows
for plotting the RiverAtlas co-located stream order versus the
WHONDRS stream order.
+ `step_05_plot_stream_order.csh`: Compare WHONDRS stream order
(manual look up from a high resolution data set) to RiverAtlas
stream order (automated look up from a slightly lower resolution
data set).  The results are broadly consistent with a distinct
one unit offset because RiverAtlas is lower resolution, so the
order 1 reaches in the WHONDRS stream order are not resolved
while the order 2 reaches in WHONDRS are viewed as order 1
reaches in RiverAtlas.
+ `step_06_make_database.csh`: for each GLORICH lon,lat point,
find the closest RiverAtlas reach and store the results in
`step_06_output.txt`.  The GL_ID will be used to merge this
co-located data with the GLORICH chemcial data in Step 8.
+`step_07_condense_GLORICH.sh`: for each GLORICH site, find
representative temp, pH, oxygen, and carbon.  Run a bunch of
quality control filters to drop huge outliers, etc. This
step takes raw data from GLORICH's `hydrochemistry.csv` and
condenses it into `step_07_output.<txt|csv>`.
+`step_08_final_merge.csh`: For each GLORICH site ID, get
the chemical data (Step 07, from GLORICH) and the physical
data (Step 06, from RiverAtlas) and put those data together
on a single line.
+`step_09_filter_and_weight.csh`: Apply sanity check filters
on the merged data.
+`step_10_avg_dup_sites.csh`: Some GLORICH sites have different
GL_ID but the same lon, lat.  Any duplicated sites (those with same
lon, lat) are merged into a single site by averaging their values.
Since the physical data are same (set by lon, lat lookups) this
step essentially is only averaging over the chemical data. To verify
that there are indeed duplicate sites in `step_09_output.csv`, use
the following command:
```bash
 awk -F, '{print $2,$3}' step_09_output.csv | sort -n | uniq -c | awk '{print $1}' | gmt gmtmath STDIN UPPER -Sl =
```
(Awk grabs the 2nd and 3rd column using , as a field delimiter,
then numerically sort the output so identical lon, lat are next
to each other in the list, then count the number of repeated,
adjacent lines with uniq, awk extracts just the counts of repeated
lines, and gmtmath find the maximum number of repeated lines
(in this case, there is one lon, lat pair repeated 8 times, there
are 212 sites where lon, lat is repeated once, 21 sites where
lon, lat is repeated 3x, 4 sites where lon, lat is repeated 4x,
and 2 sites where lon, lat is repeated 6x.)

# Run times

+ step_06_make_database.sh ~17 hours on a single CPU (by far the most demanding step - should be parallelized)
+ step_08_final_merge.sh ~10 mins
+ step_09_filter_and_weight.sh 