#!/bin/bash
#===================================
# This script sets up the data needed
# for colocate to run, launches
# a Docker container with the data 
# mounted in it, and runs the colocation.
#==================================

# Select RiverAtlas data directory
ra_data_dir=~/RiverAtlas/tiles_compressed

# Count number of compressed files
num_compressed=`ls -1 ${ra_data_dir}/*.gz | wc -l`

if [ $num_compressed -gt 0 ]; then
    # Compressed files exist, decompress
    workdir=`pwd`
    cd ${ra_data_dir}
    gunzip *.gz
    cd $workdir
fi

# Start Docker container, mount data dir, run colocate
sudo docker run --rm -v ${ra_data_dir}:/data stefanfgary/socks ls /data
