# global-river-databases

This repository contains reformatted and merged versions of 
[RiverAtlas](https://www.hydrosheds.org/hydroatlas)
and [GLORICH](https://doi.pangaea.de/10.1594/PANGAEA.902360) global river
databases. The resulting merged data set is used as the input for making automated, 
continental-scale estimates of river sediment respiration rates archived 
in [dynamic-learning-rivers](https://github.com/parallelworks/dynamic-learning-rivers). 
The machine learning (ML) workflow to generate these estimates uses the 
[SuperLearner](https://github.com/parallelworks/sl_core) stacked ensemble 
of ML models. Data from the WHONDRS project is also included here to document
the preprocessing steps necessary for creating a training data set.

The code, in `./scripts`, searches for the closest RiverAtlas data point 
(physical information about each river segment) for each data point in the 
GLORICH database (river chemistry). Intermediate data saved at key
steps are available in `./GLORICH` and `./RiverAtlas` while more information 
about the data processing and the final results are in `./scripts/`.
The code in `./scripts` uses [GMT](https://www.generic-mapping-tools.org/) and
to ensure portability on cloud resources, uses a containerized version of
GMT that is described in the Dockerfile in `./container`.

The `./WHONDRS` directory contains a copy of the WHONDRS data that can be
used to train an ML model predicting river sediment respiration rate. This
data is processed by `./notebooks/whondrs_preproc.ipynb` into a format that
is directly usable by the ML workflow.

The contents of each directory are distributed under different licenses.
RiverAtlas is licensed under a [Creative Commons Attribution (CC-BY) 4.0 International License](https://creativecommons.org/licenses/by/4.0/). RiverAtlas was created/published by:
```
Linke, S., Lehner, B., Ouellet Dallaire, C., Ariwi, J., Grill, G., Anand, M., Beames, P., Burchard-Levine, V., Maxwell, S., Moidu, H., Tan, F., Thieme, M. (2019). Global hydro-environmental sub-basin and river reach characteristics at high spatial resolution. Scientific Data 6: 283. doi: https://doi.org/10.1038/s41597-019-0300-6
```
GLORICH is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC-BY-NC-SA-4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/). GLORICH was created/published by:
```
Hartmann et al. (2014) A Brief Overview of the GLObal RIver Chemistry Database, GLORICH. Procedia Earth and Planetary Science, 10, 23-27: https://doi.org/10.1016/j.proeps.2014.08.005
```

WHONDRS is distributed under two different CC licenses and only partial copies are
available here. The FTICR data is under a
[Creative Commons Universal 1.0 Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/) 
while the `site_data` are under a
[Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/). 
Please see the following citations for the full WHONDRS data set:
```
Garayburu-Caruso V A ; Goldman A E ; Toyoda J G ; Chu R ; Renteria L ; Stegen J C ; Sengupta A ; Torgeson J M ; Willi K ; Ross M (2022): FTICR-MS Data from Multi-continent River Water and Sediment and from Coastal River Fresh and Saline Sediment Associated with: Dissolved Organic Matter Functional Trait Relationships are Conserved Across Rivers. Early Career Research Program: Watershed Perturbation-Response Traits Derived Through Ecological Theory - Worldwide Hydrobiogeochemistry Observation Network for Dynamic River Systems (WHONDRS), ESS-DIVE repository. Dataset. doi:10.15485/1824222 accessed via https://data.ess-dive.lbl.gov/datasets/doi:10.15485/1824222 on 2024-01-16

Goldman A E ; Arnon S ; Bar-Zeev E ; Chu R K ; Danczak R E ; Daly R A ; Delgado D ; Fansler S ; Forbes B ; Garayburu-Caruso V A ; Graham E B ; Laan M ; McCall M L ; McKever S ; Patel K F ; Ren H ; Renteria L ; Resch C T ; Rod K A ; Tfaily M ; Tolic N ; Torgeson J M ; Toyoda J G ; Wells J ; Wrighton K C ; Stegen J C ; WHONDRS Consortium T (2020): WHONDRS Summer 2019 Sampling Campaign: Global River Corridor Sediment FTICR-MS, Dissolved Organic Carbon, Aerobic Respiration, Elemental Composition, Grain Size, Total Nitrogen and Organic Carbon Content, Bacterial Abundance, and Stable Isotopes (v8). River Corridor and Watershed Biogeochemistry SFA, ESS-DIVE repository. Dataset. doi:10.15485/1729719 accessed via https://data.ess-dive.lbl.gov/datasets/doi:10.15485/1729719 on 2024-01-16
```

Finally, the data reformatting scripts themselves are distributed under the MIT license.

