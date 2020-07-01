#!/bin/bash

# This script requires a correctly set up /etc/hosts file and the moreutils package (needed for ts)
# This script expects two parameter and two files as input.
# The first parameter is the path to a directory containing all of the graphs. 
# The directory mustn't contain anything but the graphs in every repuired format (.gr, .adj, .bin) including weighted versions (the filenames for unweighted graphs require a leading "u_").
# The second parameter is a file containing the base names of all graphs, the respective number of nodes, edges and the biggest usable sssp sourcenode delimited by spaces
# The third parameter is the path to a directory containing only the binaries (the names of the binaries must be the original name with the name of the framework und a minus prepended). 
# The final mandatory parameter is file which will contain the results of the benchmarks (previous content will be overwritten).
# Optionally a log file can be supplied

# $1 graph $2 sssp startnode $3 number of nodes
galois-sssp () {
    bin="${path_to_bins}/galois-sssp-cpu"
    graph="${graphs}/${1}.gr"
    result=$(timeout 3h ./$bin $graph | ts '%.s')
    finished=$(grep 'Verification' $result | awk '{print $1}')
    started=$(grep 'Read ' $result | awk '{print $1}')
    finished="${finished//.}"
    finished="${finished//[0-9][0-9][0-9]$}"
    started="${started//.}"
    started="${started//[0-9][0-9][0-9]$}"
    time=$(( $finished - $started ))
}
galois-pagerank-push () {
    # pagerank push
    bin="${path_to_bins}/galois-pagerank-push-cpu"
    graph="${graphs}/${1}.gr"
    result=$(timeout 3h ./$bin $i | ts '%.s')
    finished=$(grep 'STAT_TYPE' $result | awk '{print $1}')
    started=$(grep 'Read ' $result | awk '{print $1}')
    finished="${finished//.}"
    finished="${finished//[0-9][0-9][0-9]$}"
    started="${started//.}"
    started="${started//[0-9][0-9][0-9]$}"
    time=$(( $finished - $started ))
}
galois-pagerank-pull () {
    # pagerank pull
    bin="${path_to_bins}/galois-pagerank-pull-cpu"
    graph="${graphs}/${1}.gr"
    result=$(timeout 3h ./$bin --transposedGraph $i | ts '%.s')
    finished=$(grep 'STAT_TYPE' $result | awk '{print $1}')
    started=$(grep 'Read ' $result | awk '{print $1}')
    finished="${finished//.}"
    finished="${finished//[0-9][0-9][0-9]$}"
    started="${started//.}"
    started="${started//[0-9][0-9][0-9]$}"
    time=$(( $finished - $started ))
}
polymer-sssp () {
    # polymer sssp
    bin="${path_to_bins}/polymer-numa-BellmandFord"
    graph="${graphs}/${1}.adj"
    result=$(timeout 3h ./$bin $i 0)
    time=$(grep 'BellmanFord' $result)
    time="${time//BellmanFord : }"
    time="${time//.}"
}
polymer-pagerank () {
    # polymer Pagerank
    bin="${path_to_bins}/polymer-numa-PageRank"
    graph="${graphs}/u_${1}.adj"
    result=$(timeout 3h ./$bin $i $page_rank_number_of_iterations)
    time=$(grep 'PageRank' $result)
    time="${time//PageRank : }"
    time="${time//.}"
}
ligra-sssp () {
    # ligra sssp
    bin="${path_to_bins}/ligra-BellmanFord"
    graph="${graphs}/${1}.adj"
    result=$(timeout 3h ./$bin -rounds 1 $i)
    time="${result//Running time : }"
    time="${time//.}"
}
ligra-pagerank () {
    # ligra Pagerank
    bin="${path_to_bins}/ligra-PageRank"
    graph="${graphs}/u_${1}.adj"
    result=$(timeout 3h ./$bin -rounds 1 -maxiters $page_rank_number_of_iterations $i)
    time="${result//Running time : }"
    time="${time//.}"
}

graphs=$1
graph_info=$2
path_to_bins=$3
result_file=$4
iterations=10
pagerank_number_of_iterations=5
echo "# benchmark results (elapsed time in milliseconds )" > $result_file

while read -r line; do
    for i in {1..$iterations}; do
        graph=$(echo "$line" | awk '{print $1}')
        number_of_nodes=$(echo "${line}" | awk '{print $2}')
        maxstartnode=$(echo "${line}" | awk '{print $3}')
        startnode=$RANDOM
        let "startnode %= $maxstartnode"
        echo "$line"
        echo "$startnode"
        galois-sssp $graph $startnode $number_of_nodes
        galois-pagerank-push $graph $startnode $number_of_nodes
        galois-pagerank-pull $graph $startnode $number_of_nodes
        #polymer-sssp $graph $startnode $number_of_nodes
        #polymer-pagerank $graph $startnode $number_of_nodes
        #ligra-sssp $graph $startnode $number_of_nodes
        #ligra-pagerank $graph $startnode $number_of_nodes
    done
done < $graph_info
