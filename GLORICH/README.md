List of changes to original GLORICH dataset:

+ `hydrochemistry.csv` - original file (UNMODIFIED)

Two files reformatted from the original
`Sampling_Locations_v1.shp`:
+ `Sampling_Locations_v1.gmt`
+ `Sampling_Locations_v1.xy`

One file manually changed (with spreadsheet equations)
to compute annual sum (*_sum), climatological range (*_cdi)
and mean (*_ann) of runoff (q), precip (Hijm_P),
air temp (Hijm_T), Windspeed, and GroundFrostDays. This was
done to extract key climatological indeces from the monthly
climatology originally provided while dropping the original
montly climatology. We don't need the values for each month
but we do want the indeces. Finally, also coalesced the 2000
and 1990 population indeces into a population growth
(a difference) rather than the population itself (RiverAtlas
provides a more recent total population index).
+ `catchment_properties.csv`
