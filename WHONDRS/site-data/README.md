This file documents adjustments to the downloaded data 
necessary for streamlining the data preprocessing.

# WHONDRS_S19S_Sediment_Isotopes.csv

Get rid of "_BULK" in the Sample_ID so that 
they match other Sample_ID (S19S_<IIII>-<U|M|D>)
where I = integer, e.g. 0010 and suffix is a 
choice of U, M, or D.

```
sed 's/_BULK//g' WHONDRS_S19S_Sediment_Isotopes.csv > WHONDRS_S19S_Sediment_Isotopes.csv.adj
```

Also changed the name of the variables in the header
from 82338_del_15N_permil and 63515_del_13C_permil to
simply del_15N_permil and del_13C_permil.

# WHONDRS_S19S_Sediment_NPOC.csv

Separate the incubation start and field NPOC values
into two separate files since they are different
features.  Also, modify the Sample_ID so they are
consistent with the rest of the data set.
```
# Get just the INC data, then change Sample_ID
grep -i INC WHONDRS_S19S_Sediment_NPOC.csv | sed 's/_sed_inc_icr//gI' > WHONDRS_S19S_Sediment_NPOC_INC.csv.adj

# Get just the Field data, then change Sample_ID
# Also, some samples out of range, set to max.
grep -i Field WHONDRS_S19S_Sediment_NPOC.csv | sed 's/_sed_field_icr//gI' | sed 's/Above_Range_Greater_Than_22/22/g' > WHONDRS_S19S_Sediment_NPOC_Field.csv.adj 
```

Also, changed column header variable name from
00681_NPOC_mg_per_L_as_C to NPOC_mg_per_L_as_C.

# WHONDRS_S19S_Sediment_GrainSize.csv

Get rid of "_BULK" in the Sample_ID:
```
sed 's/_BULK//g' WHONDRS_S19S_Sediment_GrainSize.csv > WHONDRS_S19S_Sediment_GrainSize.csv.adj
```

# WHONDRS_S19S_Sediment_FlowCytometry.csv

Get rid of "_FCS" in the Sample_ID:

```
sed 's/_FCS//g' WHONDRS_S19S_Sediment_FlowCytometry.csv > WHONDRS_S19S_Sediment_FlowCytometry.csv.adj
```

# WHONDRS_S19S_Sediment_CN.csv

Get rid of "_BULK" in the Sample_ID:

```
sed 's/_BULK//g' WHONDRS_S19S_Sediment_CN.csv > WHONDRS_S19S_Sediment_CN.csv.adj
```

Also, changed column header variable name from
61033_C_percent and 01472_N_percent to 
C_percent and N_percent, respectively.

