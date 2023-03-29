#----------------------------------------
# Use official Ubuntu 22.04 as parent image
#----------------------------------------

FROM ubuntu:latest

# Switch to root user since default user
# in the jupyter container is jovyan.
USER root

# Set the working directory to /app
# for additional software.
WORKDIR /app

# Add the GMT configuration file
# provided with this Dockerfile.
ADD ConfigUser.cmake .

#----------------------------------------
# Dependencies from Ubuntu repositories
#----------------------------------------
RUN add-apt-repository ppa:ubuntugis/ppa && apt-get update && apt-get install -y \
    wget \
    apt-utils \
    git-core \
    gfortran \
    software-properties-common \
    subversion \
    build-essential \
    cmake \
    libcurl4-gnutls-dev \
    libnetcdf-dev \
    libfftw3-dev \
    libpcre3-dev \
    liblapack-dev \
    graphicsmagick \
    ffmpeg \
    tcsh \
    parallel \
    libblas-dev \
    libgdal1-dev \
    gdal-bin \
    libproj-dev

# For some applications (not mine), GMT
# will use libgdal, but Ubuntu 18.04
# can't find it in apt-get, so commented
# out for now.
#     libgdal1-dev \

#----------------------------------------
# Download and Install GMT and land/coast data
#----------------------------------------
# Following the instructions at: http://gmt.soest.hawaii.edu/projects/gmt/wiki/BuildingGMT#Building-GMT-from-source
# Why from source?  In the past, there were
# some bugs in the standard GMT builds
# available with apt-get. ~1GB
RUN git clone https://github.com/GenericMappingTools/gmt.git; \
    wget ftp://ftp.soest.hawaii.edu/gshhg/gshhg-gmt-2.3.7.tar.gz; \
    wget ftp://ftp.soest.hawaii.edu/dcw/dcw-gmt-1.1.4.tar.gz; \
    mkdir -p /usr/local/src; \
    tar -xvzf gshhg-gmt-2.3.7.tar.gz; \
    mv gshhg-gmt-2.3.7 /usr/local/src; \
    tar -xvzf dcw-gmt-1.1.4.tar.gz; \
    mv dcw-gmt-1.1.4 /usr/local/src; \
    mv ConfigUser.cmake /app/gmt/cmake/ConfigUser.cmake; \
    cd gmt; \
    mkdir build; \
    cd build; \
    cmake ..; \
    make; \
    make install; \
    make clean

#----------------------------------------
# Done
#----------------------------------------
RUN ["echo", "Done building PW GMT!"]
