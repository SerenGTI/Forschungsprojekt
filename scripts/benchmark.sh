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

# $1 graph $2 sssp startnode $3 number of nodes
galois-sssp () {
    local bin="$path_to_bins/galois-sssp-cpu"
    local graph="$path_to_graphs/$1.gr"
    local start=$((`date +%s`*1000+`date +%-N`/1000000))
    local result=$(timeout 3h $bin --startNode=$2 $graph 2> /dev/null | ts '%.s')
    log "$result"
    local finished=$(echo "$result" | grep 'Verification' | awk '{print $1}')
    local started=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local finished=${finished//.}
    local finished=$(($finished/1000))
    local started=${started//.}
    local started=$(($started/1000))
    local time_read=$(($started-$start))
    local time_calc=$(($finished-$started))
    echo "galois-sssp $1 $startnode $time_read $time_calc"
}

galois-pagerank-push () {
    local bin="$path_to_bins/galois-pagerank-push-cpu"
    local graph="$path_to_graphs/$1.gr"
    local start=$((`date +%s`*1000+`date +%-N`/1000000))
    local result=$(timeout 3h $bin --maxIterations=$pagerank_number_of_iterations $graph 2> /dev/null | ts '%.s')
    log "$result"
    local finished=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local started=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local finished=${finished//.}
    local finished=$(($finished/1000))
    local started=${started//.}
    local started=$(($started/1000))
    local time_read=$(($started-$start))
    local time_calc=$(($finished-$started))
    echo "galois-pagerank-push $1 $startnode $time_read $time_calc"
}

galois-pagerank-pull () {
    local bin="$path_to_bins/galois-pagerank-pull-cpu"
    local graph="$path_to_graphs/$1.gr"
    local start=$((`date +%s`*1000+`date +%-N`/1000000))
    local result=$(timeout 3h $bin --maxIterations=$pagerank_number_of_iterations --transposedGraph  $graph 2> /dev/null | ts '%.s')
    log "$result"
    local finished=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local started=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local finished=${finished//.}
    local finished=$(($finished/1000))
    local started=${started//.}
    local started=$(($started/1000))
    local time_read=$(($started-$start))
    local time_calc=$(($finished-$started))
    echo "galois-pagerank_pull $1 $startnode $time_read $time_calc"
}

polymer-sssp () {
    # polymer sssp
    bin="${path_to_bins}/polymer-numa-BellmandFord"
    graph="${path_to_graphs}/${1}.adj"
    result=$(timeout 3h ./$bin $i 0)
    time=$(grep 'BellmanFord' $result)
    time="${time//BellmanFord : }"
    time="${time//.}"
}

polymer-pagerank () {
    # polymer Pagerank
    bin="${path_to_bins}/polymer-numa-PageRank"
    graph="${path_to_graphs}/u_${1}.adj"
    result=$(timeout 3h ./$bin $i $page_rank_number_of_iterations)
    time=$(grep 'PageRank' $result)
    time="${time//PageRank : }"
    time="${time//.}"
}

ligra-sssp () {
    # ligra sssp
    bin="${path_to_bins}/ligra-BellmanFord"
    graph="${path_to_graphs}/${1}.adj"
    result=$(timeout 3h ./$bin -rounds 1 $i)
    time="${result//Running time : }"
    time="${time//.}"
}

ligra-pagerank () {
    # ligra Pagerank
    bin="${path_to_bins}/ligra-PageRank"
    graph="${path_to_graphs}/u_${1}.adj"
    result=$(timeout 3h ./$bin -rounds 1 -maxiters $page_rank_number_of_iterations $i)
    time="${result//Running time : }"
    time="${time//.}"
}

path_to_graphs=/home/ubuntu/graph
graph_info=/home/ubuntu/graph/graph_info.txt
path_to_bins=/home/ubuntu/bin
#result_file=$4
pagerank_number_of_iterations=1000

benchmark () {
    #echo "# benchmark results (elapsed time in milliseconds )" > $result_file
    while read -r line; do
	for ((i=1; i<=$1; i++)); do
            graph=$(echo "$line" | awk '{print $1}')
            number_of_nodes=$(echo "${line}" | awk '{print $2}')
            maxstartnode=$(echo "${line}" | awk '{print $3}')
            startnode=$RANDOM
            let "startnode %= $maxstartnode"
            galois-sssp $graph $startnode
            galois-pagerank-push $graph
            galois-pagerank-pull $graph
            #polymer-sssp $graph $startnode $number_of_nodes
            #polymer-pagerank $graph $startnode $number_of_nodes
            #ligra-sssp $graph $startnode $number_of_nodes
            #ligra-pagerank $graph $startnode $number_of_nodes
        done
    done < $graph_info
}

benchmark 10
