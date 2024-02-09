#!/bin/bash
#==============================
# Start a container and run
# the plotting script specified in
# $1 in the container, e.g:
#
# gmt_plot.sh fig01_sites_map.sh
#
#==============================

# Docker will automatically pull the container
# if it is not already present on the system.

# Get location of this repo
pushd ../
data_dir=`pwd`
popd
work_dir=`pwd`

# Name of script to run
run_script=$1

# Start container and run the plotting job
sudo docker run --mount src=${data_dir},target=/data,type=bind --mount src=${work_dir},target=/work,type=bind --rm parallelworks/gmt /work/${run_script}

# Done!
