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

log () { echo "$@" 1>&2; }

convert_time () { # from float or exponential seconds to integer microsceconds
    local res=$1
    if [[ "$res" == *e* ]]; then
        local m=$(cut -d'e' -f1 <<<"$res" | sed -e 's/^-0*/-/g' -e 's/^0//g')
        local e=$(cut -d'e' -f2 <<<"$res" | sed -e 's/^-0*/-/g' -e 's/^0//g')
        local res=$(python -c "print($m*10**$e)")
    fi
    local res=$(python -c "print($res*1000000)" | sed -e 's/\..*//g')
    echo $res
}

get_time () { # timestamp in microsceconds
    echo $((`date +%s`*1000000+`date +%-N`/1000))
}

galois-sssp () {
    local bin="$path_to_bins/galois-sssp-cpu"
    local graph="$path_to_graphs/$1.gr"
    local start=$((`date +%s`*1000000+`date +%-N`/1000))
    local result=$(timeout 3h $bin --startNode=$2 $graph 2> /dev/null | ts '%.s')
    log "$result"
    local finished=$(echo "$result" | grep 'Verification' | awk '{print $1}')
    local started=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local finished=${finished//.}
    local started=${started//.}
    local time_read=$(($started-$start))
    local time_calc=$(($finished-$started))
    echo "galois-sssp $1 $2 $time_read $time_calc"
}

galois-pagerank-push () {
    local bin="$path_to_bins/galois-pagerank-push-cpu"
    local graph="$path_to_graphs/$1.gr"
    local start=$((`date +%s`*1000000+`date +%-N`/1000))
    local result=$(timeout 3h $bin --maxIterations=$pagerank_number_of_iterations $graph 2> /dev/null | ts '%.s')
    log "$result"
    local finished=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local started=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local finished=${finished//.}
    local started=${started//.}
    local time_read=$(($started-$start))
    local time_calc=$(($finished-$started))
    echo "galois-pagerank-push $1 $pagerank_number_of_iterations $time_read $time_calc"
}

galois-pagerank-pull () {
    local bin="$path_to_bins/galois-pagerank-pull-cpu"
    local graph="$path_to_graphs/$1.gr"
    local start=$((`date +%s`*1000000+`date +%-N`/1000))
    local result=$(timeout 3h $bin --maxIterations=$pagerank_number_of_iterations --transposedGraph  $graph 2> /dev/null | ts '%.s')
    log "$result"
    local finished=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local started=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local finished=${finished//.}
    local started=${started//.}
    local time_read=$(($started-$start))
    local time_calc=$(($finished-$started))
    echo "galois-pagerank_pull $1 $pagerank_number_of_Iterations $time_read $time_calc"
}

polymer-sssp () {
    local bin="${path_to_bins}/polymer-sssp"
    local graph="${path_to_graphs}/$1.adj"
    local result=$(timeout 3h $bin $graph 2> /dev/null $startnode)
    log "$result"
    local time_calc=$(echo $result | grep "BellmanFord" | awk '{print $NF}')
    local time_calc=$(echo "$time_calc*1000000" | bc)
    local time_calc=${time_calc//.*}
    echo "polymer-sssp $1 $2 - $time_calc"
}

polymer-pagerank () {
    local bin="${path_to_bins}/polymer-pagerank"
    local graph="${path_to_graphs}/u_$1.adj"
    local result=$(timeout 3h $bin $graph 2> /dev/null $pagerank_number_of_iterations)
    local time_calc=$(echo $result | grep 'PageRank' | awk '{print $NF}')
    local time_calc=$(echo "$time_calc*1000000" | bc)
    local time_calc=${time_calc//.*}
    echo "polymer-pagerank $1 $pagerank_number_of_iterations - $time_calc"
}

ligra-sssp () {
    local bin="${path_to_bins}/ligra-sssp"
    local graph="${path_to_graphs}/$1.adj"
    local result=$(timeout 3h $bin -r $2 -rounds 1 $graph)
    log "$result"
    local time_calc="${result//Running time : }"
    local time_calc=$(echo "${time_calc}*1000000" | bc)
    local time_calc="${time_calc//.*}"
    echo "ligra-sssp $1 $2 - $time_calc"
}

ligra-pagerank () {
    local bin="${path_to_bins}/ligra-pagerank"
    local graph="${path_to_graphs}/u_${1}.adj"
    local result=$(timeout 3h $bin -rounds 1 -maxiters $pagerank_number_of_iterations $graph)
    log "$result"
    local time_calc="${result//Running time : }"
    local time_calc=$(echo "${time_calc}*1000000" | bc)
    local time_calc="${time_calc//.*}"
    echo "ligra-pagerank $1 $2 - $time_calc"
}

path_to_graphs=/home/ubuntu/graph
graph_info=/home/ubuntu/graph/graph_info.txt
path_to_bins=/home/ubuntu/bin
#result_file=$4
pagerank_number_of_iterations=1000

benchmark () {
    #echo "# benchmark results (elapsed time in micro )" > $result_file
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
            polymer-sssp $graph $startnode
            polymer-pagerank $graph
            ligra-sssp $graph $startnode
            ligra-pagerank $graph
        done
    done < $graph_info
}

#benchmark 1
ligra-sssp test 0
ligra-pagerank test
