#!/bin/tcsh -f
#=====================
# Compare the WHONDRS
# stream order values
# with the values
# determined via
# RiverAtlas
#=====================

# Find the correlation coefficient
awk -F, 'NR > 1 && $4 != " " {print $4 > "x.x"; print $8 > "y.y";}' step_04_output.csv
gmtmath x.x y.y CORRCOEFF -Sl =

# Plot the data
psbasemap -JX4i -R0/10/0/10 -BWeSn -Bpxa2f1+l"WHONDRS stream order" -Bpya2f1+l"RiverATLAS stream order" -P -K > step_05_output.ps
awk -F, 'NR > 1 && $4 != " " {print $4, $8}' step_04_output.csv | psxy -J -R -B -Sc0.25 -Gblack -P -O -K >> step_05_output.ps

# Create a 1-1 line
echo 0 0 > line.xy
echo 10 10 >> line.xy
psxy line.xy -J -R -B -Wthick,red -P -O -K >> step_05_output.ps

# Create a 1-1 line that is shifted down to show bias
rm -f line.xy
echo 1 0 > line.xy
echo 10 9 >> line.xy
psxy line.xy -J -R -B -Wthick,red,-- -P -O -K >> step_05_output.ps

# Plot the differences versus point distance
psbasemap -JX4i -R0/10000/-5/5 -Y5i -BWeSn -Bpxa2000f1000+l"Distance from given point to reach meters" -Bpya2f1+l"Stream order difference" -P -O -K >> step_05_output.ps
awk -F, 'NR > 1 {print $78,$4-$8}' step_04_output.csv | psxy -J -R -B -Sc0.1 -Gblack -P -O -K >> step_05_output.ps

# Clean up
rm -f line.xy
ps2pdf step_05_output.ps
rm -f step_05_output.ps
rm -f x.x y.y


