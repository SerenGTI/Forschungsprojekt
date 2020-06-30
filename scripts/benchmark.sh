#!/bin/bash

# This script requires a correctly set up /etc/hosts file and the moreutils package
# This script expects two parameter and one files as input.
# The first parameter is the path to a directory containing all of the graphs. 
# The directory mustn't contain anything but the graphs in every repuired format (.gr, .adj, .bin) including weighted versions (the filenames for unweighted graphs require a leading "u_").
# The second parameter is the path to a directory containing only the binaries (the names of the binaries must be the original name with the name of the framework und a minus prepended). 
# The file will contain the results of the benchmarks.

# TODO decide if unweighted graphs are to be supported

graphs=$(ls $1)
path_to_bins=$2
result_file=$3
page_rank_number_of_iterations=5
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
        bin="${path_to_bins}/galois-pagerank-pull-cpu"
        result=$(timeout 3h ./$bin --transposedGraph $i | ts '%s')
        finished=$(grep 'STAT_TYPE' $result | awk '{print $1}')
        started=$(grep 'Read ' $result | awk '{print $1}')
        echo "Galois-pagerank-pull on $i" >> $result_file
        echo $(( $finished - $started )) >> $result_file
        # distributed
    fi
    # polymer and ligra
    if [[ $i == *.adj ]];
    then
        # sssp
        if [[ $i != +(u_) ]];
        then
            # polymer sssp
            bin="${path_to_bins}/polymer-numa-BellmandFord"
            result=$(timeout 3h ./$bin $i 0)
            time=$(grep 'BellmanFord' $result)
            time="${time//BellmanFord : }"
            time="${time//.*}"
            echo "Polymer sssp on $i" >> $result_file
            echo $time >> $result_file
            # ligra sssp
            bin="${path_to_bins}/ligra-BellmanFord"
            result=$(timeout 3h ./$bin -rounds 1 $i)
            time="${result//Running time : }"
            time="${time//.*}"
            echo "Ligra sssp on $i" >> $result_file
            echo $time >> $result_file
        fi
        # pagerank
        if [[ $i == +(u_) ]];
        then
            # polymer Pagerank
            bin="${path_to_bins}/polymer-numa-PageRank"
            result=$(timeout 3h ./$bin $i $page_rank_number_of_iterations)
            time=$(grep 'PageRank' $result)
            time="${time//PageRank : }"
            time="${time//.*}"
            echo "Polymer PageRank on $i" >> $result_file
            echo $time >> $result_file
            # ligra Pagerank
            bin="${path_to_bins}/ligra-PageRank"
            result=$(timeout 3h ./$bin -rounds 1 -maxiters $page_rank_number_of_iterations $i)
            time="${result//Running time : }"
            time="${time//.*}"
            echo "Ligra Pagerank on $i" >> $result_file
            echo $time >> $result_file
        fi
    fi
    # gemini
    if [[ $i == *.bin ]];
    then
        #TODO gemini
    fi
done
