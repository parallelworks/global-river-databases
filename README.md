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

The contents of each directory are distributed under different licenses.
RiverAtlas is licensed under a [Creative Commons Attribution (CC-BY) 4.0 International License](https://creativecommons.org/licenses/by/4.0/). RiverAtlas was created/published by:
```
Linke, S., Lehner, B., Ouellet Dallaire, C., Ariwi, J., Grill, G., Anand, M., Beames, P., Burchard-Levine, V., Maxwell, S., Moidu, H., Tan, F., Thieme, M. (2019). Global hydro-environmental sub-basin and river reach characteristics at high spatial resolution. Scientific Data 6: 283. doi: https://doi.org/10.1038/s41597-019-0300-6
```
GLORICH is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC-BY-NC-SA-4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/). GLORICH was created/published by:
```
Hartmann et al. (2014) A Brief Overview of the GLObal RIver Chemistry Database, GLORICH. Procedia Earth and Planetary Science, 10, 23-27: https://doi.org/10.1016/j.proeps.2014.08.005
```
Finally, the data reformatting scripts themselves are distributed under the MIT license.

