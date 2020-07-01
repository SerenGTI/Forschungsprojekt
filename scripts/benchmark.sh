#!/bin/bash

# This script requires a correctly set up /etc/hosts file and the moreutils package (needed for ts)
# This script expects two parameter and two files as input.
# The first parameter is the path to a directory containing all of the graphs. 
# The directory mustn't contain anything but the graphs in every repuired format (.gr, .adj, .bin) including weighted versions (the filenames for unweighted graphs require a leading "u_").
# The second parameter is a file containing the base names of all graphs, the respective number of nodes, edges and the biggest usable sssp sourcenode delimited by spaces
# The third parameter is the path to a directory containing only the binaries (the names of the binaries must be the original name with the name of the framework und a minus prepended). 
# The final mandatory parameter is file which will contain the results of the benchmarks (previous content will be overwritten).
# Optionally a log file can be supplied
log() { echo "$@" 1>&2; }

galois-sssp () {
    bin="$path_to_bins/galois-sssp-cpu"
    graph="$path_to_graphs/$1.gr"
    start=$((`date +%s`*1000+`date +%-N`/1000000))
    result=$(timeout 3h $bin --startNode=$2 $graph 2> /dev/null | ts '%.s')
    log "$result"
    finished=$(echo "$result" | grep 'Verification' | awk '{print $1}')
    started=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    finished=${finished//.}
    finished=$(($finished/1000))
    started=${started//.}
    started=$(($started/1000))
    time_read=$(($started-$start))
    time_calc=$(($finished-$started))
    echo "galois-sssp $1 $time_read $time_calc"
}

galois-pagerank-push () {
    bin="$path_to_bins/galois-pagerank-push-cpu"
    graph="$path_to_graphs/$1.gr"
    start=$((`date +%s`*1000+`date +%-N`/1000000))
    result=$(timeout 3h $bin --maxIterations=$pagerank_number_of_iterations $graph 2> /dev/null | ts '%.s')
    log "$result"
    finished=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    started=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    finished=${finished//.}
    finished=$(($finished/1000))
    started=${started//.}
    started=$(($started/1000))
    time_read=$(($started-$start))
    time_calc=$(($finished-$started))
    echo "galois-pagerank-push $1 $time_read $time_calc"
}
galois-pagerank-pull () {
    bin="$path_to_bins/galois-pagerank-pull-cpu"
    graph="$path_to_graphs/$1.gr"
    start=$((`date +%s`*1000+`date +%-N`/1000000))
    result=$(timeout 3h $bin --maxIterations=$pagerank_number_of_iterations --transposedGraph  $graph 2> /dev/null | ts '%.s')
    log "$result"
    finished=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    started=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    finished=${finished//.}
    finished=$(($finished/1000))
    started=${started//.}
    started=$(($started/1000))
    time_read=$(($started-$start))
    time_calc=$(($finished-$started))
    echo "galois-pagerank_pull $1 $time_read $time_calc"
}
polymer-sssp () {
    # polymer sssp
    bin="${path_to_bins}/polymer-numa-BellmandFord"
    result=$(timeout 3h ./$bin $i 0)
    time=$(grep 'BellmanFord' $result)
    time="${time//BellmanFord : }"
    time="${time//.*}"
    echo "Polymer sssp on $i" >> $result_file
    echo $time >> $result_file
}
polymer-pagerank () {
    # polymer Pagerank
    bin="${path_to_bins}/polymer-numa-PageRank"
    result=$(timeout 3h ./$bin $i $page_rank_number_of_iterations)
    time=$(grep 'PageRank' $result)
    time="${time//PageRank : }"
    time="${time//.*}"
    echo "Polymer PageRank on $i" >> $result_file
    echo $time >> $result_file
}
ligra-sssp () {
    # ligra sssp
    in="${path_to_bins}/ligra-BellmanFord"
    result=$(timeout 3h ./$bin -rounds 1 $i)
    time="${result//Running time : }"
    time="${time//.*}"
    echo "Ligra sssp on $i" >> $result_file
    echo $time >> $result_file
}
ligra-pagerank () {
    # ligra Pagerank
    bin="${path_to_bins}/ligra-PageRank"
    result=$(timeout 3h ./$bin -rounds 1 -maxiters $page_rank_number_of_iterations $i)
    time="${result//Running time : }"
    time="${time//.*}"
    echo "Ligra Pagerank on $i" >> $result_file
    echo $time >> $result_file
}

path_to_bins=/home/ubuntu/bin
path_to_graphs=/home/ubuntu/graph
pagerank_number_of_iterations=1000

galois-sssp orkut 10
galois-pagerank-push orkut
galois-pagerank-push orkut
