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

logv () { # writes to stdout
    echo "$@" 1>&2; 
}
log () { # writes to stdout and stderr
    echo "$@"
    echo "#$@" 1>&2; 
}

convert_time () { # from float or exponential seconds to integer microsceconds
    local res=$1
    if [[ "$res" == *e* ]]; then
        local m=$(cut -d'e' -f1 <<<"$res" | sed -e 's/^-0*/-/g' -e 's/^+0*/+/g' -e 's/^0//g')
        local e=$(cut -d'e' -f2 <<<"$res" | sed -e 's/^-0*/-/g' -e 's/^+0*/+/g' -e 's/^0//g')
        local res=$(python3 -c "print($m*10**$e)")
    fi
    local res=$(python3 -c "print($res*1000000)" | sed -e 's/\..*//g')
    echo $res
}

get_time () { # timestamp in microsceconds
    echo $((`date +%s`*1000000+`date +%-N`/1000))
}

galois-sssp () {
    local bin="$path_to_bins/galois-sssp-cpu"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin --startNode=$2 $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'Verification' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-sssp $1 $2 $dur_read $dur_calc $dur_exec"
}

galois-sssp-push-dist () {
    local bin="$path_to_bins/galois-sssp-push-dist"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec --hostfile $host_file $bin --startNode=$2 $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Reading graph complete.' | tail -1 | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-sssp-push-dist $1 $2 $dur_read $dur_calc $dur_exec"
}

galois-sssp-pull-dist () {
    local bin="$path_to_bins/galois-sssp-pull-dist"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec --hostfile $host_file $bin --startNode=$2 $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Reading graph complete.' | tail -1 | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-sssp-pull-dist $1 $2 $dur_read $dur_calc $dur_exec"
}

galois-pagerank-push () {
    local bin="$path_to_bins/galois-pagerank-push-cpu"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin --maxIterations=$pagerank_number_of_iterations $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-pagerank-push $1 $pagerank_number_of_iterations $dur_read $dur_calc $dur_exec"
}

galois-pagerank-push-dist () {
    local bin="$path_to_bins/galois-pagerank-push-dist"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec --hostfile $host_file $bin --maxIterations=$pagerank_number_of_iterations $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Reading graph complete.' | tail -1 | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-pagerank-push-dist $1 $pagerank_number_of_iterations $dur_read $dur_calc $dur_exec"
}

galois-pagerank-pull () {
    local bin="$path_to_bins/galois-pagerank-pull-cpu"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin --maxIterations=$pagerank_number_of_iterations --transposedGraph  $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-pagerank_pull $1 $pagerank_number_of_Iterations $dur_read $dur_calc $dur_exec"
}

galois-pagerank-pull-dist () {
    local bin="$path_to_bins/galois-pagerank-pull-dist"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    # transposed graph not yet working
    local result=$(timeout 3h mpiexec --hostfile $host_file $bin --maxIterations=$pagerank_number_of_iterations --transposedGraph $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Reading graph complete.' | tail -1 | awk '{print $1}')
    echo "time started: $time_started_calc"
    echo "time finished: $time_finished_calc"
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-pagerank-pull-dist $1 $pagerank_number_of_iterations $dur_read $dur_calc $dur_exec"
}

polymer-sssp () {
    local bin="${path_to_bins}/polymer-sssp"
    local graph="${path_to_graphs}/$1.adj"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin $graph 2> /dev/null $startnode)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(echo $result | grep "BellmanFord" | awk '{print $NF}')
    local dur_calc=$(convert_time $dur_calc)
    log "polymer-sssp $1 $2 - $dur_calc $dur_exec"
}

polymer-pagerank () {
    local bin="${path_to_bins}/polymer-pagerank"
    local graph="${path_to_graphs}/u_$1.adj"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin $graph 2> /dev/null $pagerank_number_of_iterations)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(echo $result | grep 'PageRank' | awk '{print $NF}')
    local dur_calc=$(convert_time $dur_calc)
    log "polymer-pagerank $1 $pagerank_number_of_iterations - $dur_calc $dur_exec"
}

ligra-sssp () {
    local bin="${path_to_bins}/ligra-sssp"
    local graph="${path_to_graphs}/$1.adj"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin -r $2 -rounds 1 $graph)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc="${result//Running time : }"
    local dur_calc=$(convert_time $dur_calc)
    log "ligra-sssp $1 $2 - $dur_calc $dur_exec"
}

ligra-pagerank () {
    local bin="${path_to_bins}/ligra-pagerank"
    local graph="${path_to_graphs}/u_${1}.adj"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin -rounds 1 -maxiters $pagerank_number_of_iterations $graph)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc="${result//Running time : }"
    local dur_calc=$(convert_time $dur_calc)
    log "ligra-pagerank $1 $pagerank_number_of_iterations - $dur_calc $dur_exec"
}

gemini-sssp () {
    local bin="${path_to_bins}/gemini-sssp"
    local graph="${path_to_graphs}/$1.bin"
    local time_start=$(get_time)
    # TODO currently calculates the result 6 times (probably source code alteration)
    local result=$(timeout 3h $bin $graph $number_of_nodes $2)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(echo $result | grep 'exec_time=' | tail -1)
    echo "gemini-sssp dur_calc: $dur_calc"
    dur_calc="${dur_calc//*exec_time=}"
    echo "gemini-sssp dur_calc: $dur_calc"
    dur_calc="${dur_calc//(s)*}"
    echo "gemini-sssp dur_calc: $dur_calc"
    dur_calc=$(convert_time $dur_calc)
    echo "gemini-sssp dur_calc: $dur_calc"
    log "gemini-sssp $1 $2 - $dur_calc $dur_exec"
}

# TODO figure out why pagerank produces segfault
gemini-pagerank () {
    local bin="${path_to_bins}/gemini-pagerank"
    local graph="u_${path_to_graphs}/$1.bin"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin $graph $number_of_nodes $pagerank_number_of_iterations)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(echo $result | grep 'exec_time=' | tail -1)
i   dur_calc="${dur_calc//exec_time=}"
    dur_calc="${dur_calc//(s)}"
    dur_calc=$(convert_time $dur_calc)
    log "gemini-pagerank $1 $pagerank_number_of_iterations - $dur_calc $dur_exec"
}

path_to_graphs=/home/ubuntu/graph
graph_info=/home/ubuntu/graph/graph_info.txt
path_to_bins=/home/ubuntu/bin
host_file=/home/ubuntu/host_file
#result_file=$4
pagerank_number_of_iterations=1000

benchmark () {
    #echo "# benchmark results (elapsed time in micro )" > $result_file
    time_start=$(get_time)
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
	    gemini-sssp $graph $startnode
	    # gemini-pagerank $graph
	    #distributed
	    galois-sssp-push-dist $graph $startnode
	    galois-sssp-pull-dist $graph $startnode
	    galois-pagerank-push-dist $graph
	    # galois-pagerank-pull-dist $graph
        done
    done < $graph_info
    log "benchmark took $(($(get_time)-time_start))"
}

benchmark 1
