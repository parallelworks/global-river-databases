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

