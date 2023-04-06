#!/bin/bash
#===================================
# This script sets up the data needed
# for colocate to run, launches
# a Docker container with the data 
# mounted in it, and runs the colocation.
#==================================

# Grab inputs to propagate
id=$1
lon=$2
lat=$3

# Select RiverAtlas data directory
# Get absolute path for mounting into container
ra_data_dir=$(realpath ../RiverAtlas/tiles_compressed)

# Count number of compressed files
#num_compressed=`ls -1 ${ra_data_dir}/*.gz | wc -l`
#if [ $num_compressed -gt 0 ]; then

if compgen -G "${ra_data_dir}*.gz" > /dev/null; then
    # Compressed files exist, decompress
    workdir=`pwd`
    cd ${ra_data_dir}
    gunzip *.gz
    cd $workdir
fi

# Start Docker container, mount data dir, run colocate
if [ `sudo systemctl is-active docker` == "active" ]
then
    #echo Docker daemon is already started. Do nothing.
    sleep 1
else
    #echo Docker daemon not started. Starting Docker daemon...
    sudo systemctl start docker
fi
sudo docker run --rm -v ${ra_data_dir}:/data -v $(pwd):/work -w /work parallelworks/gmt /work/colocate.sh $id $lon $lat
