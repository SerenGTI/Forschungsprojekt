#!/bin/bash

# This script requires a correctly set up /etc/hosts file and the moreutils package
# This script expects two parameter and one files as input.
# The first parameter is the path to a directory containing all of the graphs. 
# The directory mustn't contain anything but the graphs in every repuired format (.gr, .adj, .bin) including weighted versions (the filenames for weighted graphs require a leading "w_").
# The second parameter is the path to a directory containing only the binaries (the names of the binaries must be the original name with the name of the framework und a minus prepended). 
# The file will contain the results of the benchmarks.

# TODO decide if unweighted graphs are to be supported

graphs=$(ls $1)
path_to_bins=$2
result_file=$3
page_rank_number_of_iterations=1000
echo "# benchmark results (elapsed time in seconds )" > $result_file

for i in $graphs; do
    # galois
    if [[ $i == *.gr ]];
    then
        # shared memory
        # sssp
        bin="${path_to_bins}/galois-sssp-cpu"
        result=$(timeout 3h ./$bin $i | ts '%s')
        finished=$(grep 'Verification' $result | awk '{print $1}')
        started=$(grep 'Read ' $result | awk '{print $1}')
        echo "Galois-sssp on $i" >> $result_file
        echo $(( $finished - $started )) >> $result_file
        # pagerank push
        bin="${path_to_bins}/galois-pagerank-push-cpu"
        result=$(timeout 3h ./$bin $i | ts '%s')
        finished=$(grep 'STAT_TYPE' $result | awk '{print $1}')
        started=$(grep 'Read ' $result | awk '{print $1}')
        echo "Galois-pagerank-push on $i" >> $result_file
        echo $(( $finished - $started )) >> $result_file
        # pagerank pull
        # TODO transposed graph
        # distributed
    fi
    # polymer and ligra
    if [[ $i == *.adj ]];
    then
        # shared memory
        # polymer
        # sssp
        bin="${path_to_bins}/numa-BellmandFord"
        result=$(timeout 3h ./$bin $i 0 | ts '%s')
        # TODO stop time
        # pagerank
        bin="${path_to_bins}/numa-PageRank"
        result=$(timeout 3h ./$bin $i $page_rank_number_of_iterations | ts '%s')
        # TODO stop time
        # ligra
        # sssp
        bin="${path_to_bins}/BellmanFord"
        result=$(timeout 3h ./$bin $i | ts '%s')
        # TODO stop time
        # pagerank
        bin="${path_to_bins}/PageRank"
        result=$(timeout 3h ./$bin -maxiters $page_rank_number_of_iterations $i | ts '%s')
    fi
    # gemini
    if [[ $i == *.bin ]];
    then
        #TODO gemini
    fi
done
