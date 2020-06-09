#!/bin/bash

# IMPORTANT: This script performs a setup for Galois as described in the galois installation steps, however it will not setup hugepages.

# Arguments (supplied arguments must be ordered according to this listing):
# nd -> doesn't set up the D-Galois applications
# od -> installs only the D-Galois applications
# nj -> disables the -j flag in the building process. This option can be necessary if RAM is very limited. 

sudo apt-get install g++
sudo apt-get install cmake
sudo apt-get install libboost-all-dev
sudo apt-get install llvm
sudo apt-get install libnuma-dev

# required for both D-Galois and regular Galois
mkdir Galois Galois/src Galois/build Galois/bin
# can be made persistent by appending to the .bashrc
export PATH="$PWD/Galois/bin:$PATH"
git clone -b release-5.0 https://github.com/IntelligentSoftwareSystems/Galois Galois/src
cd Galois
cmake -S src -B build -DCMAKE_BUILD_TYPE=Release

# preparation for the building process
if [[ $1 == "nj" || $2 == "nj" ]];
then
    make_build="make -C build "
else
    make_build="make -C build -j "
fi

$make_build"graph-convert"
cp build/tools/graph-convert/graph-convert bin/galois-graph-convert

# for non distributed Galois
if [[ $1 != "od" ]];
then
    $make_build"sssp"
    cp build/lonestar/sssp/sssp bin/galois-sssp
    $make_build"pagerank-pull"
    cp build/lonestar/pagerank/pagerank-pull bin/galois-pagerank-pull
    $make_build"pagerank-push"
    cp build/lonestar/pagerank/pagerank-push bin/galois-pagerank-push
fi

# for D-Galois
if [[ $1 != "nd" ]];
then
    sudo apt-get install libopenmpi-dev
    cmake build -DGALOIS_ENABLE_DIST=1
    $make_build"sssp_pull"
    cp build/lonestardist/sssp/sssp_pull bin/d-galois-sssp-pull
    $make_build"sssp_push"
    cp build/lonestardist/sssp/sssp_push bin/d-galois-sssp-push
    $make_build"pagerank_pull"
    cp build/lonestardist/pagerank_pull bin/d-galois-pagerank-pull
    $make_build"pagerank_push"
    cp build/lonestardist/pagerank_push bin/d-galois-pagerank-push
fi
