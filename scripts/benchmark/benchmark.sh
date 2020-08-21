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

galois-sssp-cpu () {
    local bin="$path_to_bins/galois-sssp-cpu"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin -t=$threads --startNode=$2 $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'Verification' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-sssp-cpu $1 $2 $dur_read $dur_calc $dur_exec"
}

galois-sssp-push-dist () {
    local bin="$path_to_bins/galois-sssp-push-dist"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec -H $hosts $bin -t=$threads --runs=1 --startNode=$2 $graph 2> /dev/null | ts '%.s')
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
    local result=$(timeout 3h mpiexec -H $hosts $bin -t=$threads --runs=1 --startNode=$2 $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Reading graph complete.' | tail -1 | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-sssp-pull-dist $1 $2 $dur_read $dur_calc $dur_exec"
}

galois-pagerank-push-cpu () {
    local bin="$path_to_bins/galois-pagerank-push-cpu"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin -t=$threads --maxIterations=$pagerank_number_of_iterations $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-pagerank-push-cpu $1 $pagerank_number_of_iterations $dur_read $dur_calc $dur_exec"
}

galois-pagerank-push-dist () {
    local bin="$path_to_bins/galois-pagerank-push-dist"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec -H $hosts $bin -t=$threads --runs=1 --maxIterations=$pagerank_number_of_iterations $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Reading graph complete.' | tail -1 | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-pagerank-push-dist $1 $pagerank_number_of_iterations $dur_read $dur_calc $dur_exec"
}

galois-pagerank-pull-cpu () {
    local bin="$path_to_bins/galois-pagerank-pull-cpu"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin -t=$threads --maxIterations=$pagerank_number_of_iterations --transposedGraph  $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-pagerank-pull-cpu $1 $pagerank_number_of_iterations $dur_read $dur_calc $dur_exec"
}

galois-pagerank-pull-dist () {
    local bin="$path_to_bins/galois-pagerank-pull-dist"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec -H $hosts $bin -t=$threads --runs=1 --maxIterations=$pagerank_number_of_iterations $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Reading graph complete.' | tail -1 | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-pagerank-pull-dist $1 $pagerank_number_of_iterations $dur_read $dur_calc $dur_exec"
}

galois-bfs-cpu () {
    local bin="$path_to_bins/galois-bfs-cpu"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin -t=$threads --startNode=$2 $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'Verification' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Read ' | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-bfs-cpu $1 $2 $dur_read $dur_calc $dur_exec"
}

galois-bfs-push-dist () {
    local bin="$path_to_bins/galois-bfs-push-dist"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec -H $hosts $bin -t=$threads --runs=1 --startNode=$2 $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Reading graph complete.' | tail -1 | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-bfs-push-dist $1 $2 $dur_read $dur_calc $dur_exec"
}

galois-bfs-pull-dist () {
    local bin="$path_to_bins/galois-bfs-pull-dist"
    local graph="$path_to_graphs/$1.gr"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec -H $hosts $bin -t=$threads --runs=1 --startNode=$2 $graph 2> /dev/null | ts '%.s')
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local time_finished_calc=$(echo "$result" | grep 'STAT_TYPE' | awk '{print $1}')
    local time_started_calc=$(echo "$result" | grep 'Reading graph complete.' | tail -1 | awk '{print $1}')
    local dur_read=$((${time_started_calc//.}-$time_start))
    local dur_calc=$((${time_finished_calc//.}-${time_started_calc//.}))
    log "galois-bfs-pull-dist $1 $2 $dur_read $dur_calc $dur_exec"
}

polymer-sssp () {
    local bin="${path_to_bins}/polymer-sssp"
    local graph="${path_to_graphs}/$1.adj"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin $graph $startnode 2> /dev/null)
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
    local result=$(timeout 3h $bin $graph $pagerank_number_of_iterations 2> /dev/null)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(echo $result | grep 'PageRank' | awk '{print $NF}')
    local dur_calc=$(convert_time $dur_calc)
    log "polymer-pagerank $1 $pagerank_number_of_iterations - $dur_calc $dur_exec"
}

polymer-pagerank-delta () {
    local bin="${path_to_bins}/polymer-pagerank-delta"
    local graph="${path_to_graphs}/u_$1.adj"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin $graph $pagerank_number_of_iterations 2> /dev/null)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(echo $result | grep 'PageRankDelta' | awk '{print $NF}')
    local dur_calc=$(convert_time $dur_calc)
    log "polymer-pagerank-delta $1 $pagerank_number_of_iterations - $dur_calc $dur_exec"
}

polymer-bfs () {
    local bin="${path_to_bins}/polymer-bfs"
    local graph="${path_to_graphs}/u_$1.adj"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin $graph $startnode 2> /dev/null)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(echo $result | grep "BFS" | awk '{print $NF}')
    local dur_calc=$(convert_time $dur_calc)
    log "polymer-bfs $1 $2 - $dur_calc $dur_exec"
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

ligra-pagerank-delta () {
    local bin="${path_to_bins}/ligra-pagerank-delta"
    local graph="${path_to_graphs}/u_${1}.adj"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin -rounds 1 -maxiters $pagerank_number_of_iterations $graph)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc="${result//Running time : }"
    local dur_calc=$(convert_time $dur_calc)
    log "ligra-pagerank-delta $1 $pagerank_number_of_iterations - $dur_calc $dur_exec"
}

ligra-bfs () {
    local bin="${path_to_bins}/ligra-bfs"
    local graph="${path_to_graphs}/u_$1.adj"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin -r $2 -rounds 1 $graph)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc="${result//Running time : }"
    local dur_calc=$(convert_time $dur_calc)
    log "ligra-bfs $1 $2 - $dur_calc $dur_exec"
}

gemini-sssp () {
    local bin="${path_to_bins}/gemini-sssp"
    local graph="${path_to_graphs}/$1.bin"
    local time_start=$(get_time)
    local result=$(timeout 3h $bin $graph $3 $2)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(grep 'exec_time=' <<<"$result" | tail -1)
    local dur_calc="${dur_calc//exec_time=}"
    local dur_calc="${dur_calc//(s)}"
    local dur_calc=$(convert_time $dur_calc)
    log "gemini-sssp $1 $2 - $dur_calc $dur_exec"
}

gemini-pagerank () {
    local bin="${path_to_bins}/gemini-pagerank"
    local graph="${path_to_graphs}/u_$1.bin"
    local time_start=$(get_time)
    local result="$(timeout 3h $bin $graph $2 $pagerank_number_of_iterations)"
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(grep 'exec_time=' <<<"$result" | tail -1)
    local dur_calc="${dur_calc//exec_time=}"
    local dur_calc="${dur_calc//(s)}"
    local dur_calc=$(convert_time $dur_calc)
    log "gemini-pagerank $1 $pagerank_number_of_iterations - $dur_calc $dur_exec"
}

gemini-bfs () {
    local bin="${path_to_bins}/gemini-bfs"
    local graph="${path_to_graphs}/u_$1.bin"
    local time_start=$(get_time)
    local result="$(timeout 3h $bin $graph $3 $2)"
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(grep 'exec_time=' <<<"$result" | tail -1)
    local dur_calc="${dur_calc//exec_time=}"
    local dur_calc="${dur_calc//(s)}"
    local dur_calc=$(convert_time $dur_calc)
    log "gemini-bfs $1 $2 - $dur_calc $dur_exec"
}

gemini-sssp-dist () {
    local bin="${path_to_bins}/gemini-sssp"
    local graph="${path_to_graphs}/$1.bin"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec -H $hosts $bin $graph $3 $2)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(grep 'exec_time=' <<<"$result" | tail -1)
    local dur_calc="${dur_calc//exec_time=}"
    local dur_calc="${dur_calc//(s)}"
    local dur_calc=$(convert_time $dur_calc)
    log "gemini-sssp-dist $1 $2 - $dur_calc $dur_exec"
}

gemini-pagerank-dist () {
    local bin="${path_to_bins}/gemini-pagerank"
    local graph="${path_to_graphs}/u_$1.bin"
    local time_start=$(get_time)
    local result="$(timeout 3h mpiexec -H $hosts $bin $graph $2 $pagerank_number_of_iterations)"
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(grep 'exec_time=' <<<"$result" | tail -1)
    local dur_calc="${dur_calc//exec_time=}"
    local dur_calc="${dur_calc//(s)}"
    local dur_calc=$(convert_time $dur_calc)
    log "gemini-pagerank-dist $1 $pagerank_number_of_iterations - $dur_calc $dur_exec"
}

gemini-bfs-dist () {
    local bin="${path_to_bins}/gemini-bfs"
    local graph="${path_to_graphs}/u_$1.bin"
    local time_start=$(get_time)
    local result=$(timeout 3h mpiexec -H $hosts $bin $graph $3 $2)
    local dur_exec=$(($(get_time)-$time_start))
    logv "$result"
    local dur_calc=$(grep 'exec_time=' <<<"$result" | tail -1)
    local dur_calc="${dur_calc//exec_time=}"
    local dur_calc="${dur_calc//(s)}"
    local dur_calc=$(convert_time $dur_calc)
    log "gemini-bfs-dist $1 $2 - $dur_calc $dur_exec"
}

giraph-sssp () {
    local graph="$1.gir"
    $($HADOOP_HOME/bin/hadoop dfs -rmr /output/$graph)
    local time_start=$(get_time)
    # hardcoded for our current setup
    local result=$(timeout 3h $HADOOP_HOME/bin/hadoop jar $GIRAPH_HOME/giraph-examples/target/giraph-examples-1.3.0-SNAPSHOT-for-hadoop-1.2.1-jar-with-dependencies.jar org.apache.giraph.GiraphRunner org.apache.giraph.examples.GeneralShortestPathsComputation $2 -vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat -vip /input/$graph -vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat -op /output/$graph -w 1 2>&1 | ts '%.s')
    local time_finish=$(get_time)
    local dur_exec=$(($time_finish-$time_start))
    logv "$result"
    local dur_init=$(echo "$result" | grep 'Initialize (ms)')
    local dur_init="${dur_init##*Initialize (ms)=}"
    local dur_init=$((dur_init*1000))
    local start_calc=$(echo "$result" | grep 'Running job' | awk '{print $1}')
    local start_calc=$(convert_time $start_calc)
    local dur_calc=$(($time_finish-$start_calc))
    local dur_calc_giraph=$(echo "$result" | grep 'Superstep ' | awk -F '=' '{s += $2} END {print s*1000}')
    log "giraph-sssp $1 $2 $dur_init $dur_calc $dur_exec $dur_calc_giraph"
}

giraph-sssp-dist () {
    local graph="$1.gir"
    $($HADOOP_HOME/bin/hadoop dfs -rmr /output/$graph)
    local time_start=$(get_time)
    # hardcoded for our current setup
    local result=$(timeout 3h $HADOOP_HOME/bin/hadoop jar $GIRAPH_HOME/giraph-examples/target/giraph-examples-1.3.0-SNAPSHOT-for-hadoop-1.2.1-jar-with-dependencies.jar org.apache.giraph.GiraphRunner org.apache.giraph.examples.GeneralShortestPathsComputation $2 -vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat -vip /input/$graph -vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat -op /output/$graph -w 5 2>&1 | ts '%.s')
    local time_finish=$(get_time)
    local dur_exec=$(($time_finish-$time_start))
    logv "$result"
    local dur_init=$(echo "$result" | grep 'Initialize (ms)')
    local dur_init="${dur_init##*Initialize (ms)=}"
    local dur_init=$((dur_init*1000))
    local start_calc=$(echo "$result" | grep 'Running job' | awk '{print $1}')
    local start_calc=$(convert_time $start_calc)
    local dur_calc=$(($time_finish-$start_calc))
    local dur_calc_giraph=$(echo "$result" | grep 'Superstep ' | awk -F '=' '{s += $2} END {print s*1000}')
    log "giraph-sssp-dist $1 $2 $dur_init $dur_calc $dur_exec $dur_calc_giraph"
}

giraph-pagerank () {
    local graph="$1.gir"
    $($HADOOP_HOME/bin/hadoop dfs -rmr /output/$graph)
    local time_start=$(get_time)
    # hardcoded for our current setup
    local result=$(timeout 3h $HADOOP_HOME/bin/hadoop jar $GIRAPH_HOME/giraph-examples/target/giraph-examples-1.3.0-SNAPSHOT-for-hadoop-1.2.1-jar-with-dependencies.jar org.apache.giraph.GiraphRunner org.apache.giraph.examples.SimplePageRankComputation -vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat -vip /input/$graph -vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat -op /output/$graph -mc org.apache.giraph.examples.SimplePageRankComputation\$SimplePageRankMasterCompute -wc org.apache.giraph.examples.SimplePageRankComputation\$SimplePageRankWorkerContext -w 1 2>&1 | ts '%.s')
    local time_finish=$(get_time)
    local dur_exec=$(($time_finish-$time_start))
    logv "$result"
    local start_calc=$(echo "$result" | grep 'Running job' | awk '{print $1}')
    local start_calc=$(convert_time $start_calc)
    local dur_calc=$(($time_finish-$start_calc))
    local dur_calc_giraph=$(echo "$result" | grep 'Superstep ' | awk -F '=' '{s += $2} END {print s*1000}')
    log "giraph-pagerank $1 $pagerank_number_of_iterations - $dur_calc $dur_exec $dur_calc_giraph"
}

giraph-pagerank-dist () {
    local graph="$1.gir"
    $($HADOOP_HOME/bin/hadoop dfs -rmr /output/$graph)
    local time_start=$(get_time)
    # hardcoded for our current setup
    local result=$(timeout 3h $HADOOP_HOME/bin/hadoop jar $GIRAPH_HOME/giraph-examples/target/giraph-examples-1.3.0-SNAPSHOT-for-hadoop-1.2.1-jar-with-dependencies.jar org.apache.giraph.GiraphRunner org.apache.giraph.examples.SimplePageRankComputation -vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat -vip /input/$graph -vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat -op /output/$graph -mc org.apache.giraph.examples.SimplePageRankComputation\$SimplePageRankMasterCompute -wc org.apache.giraph.examples.SimplePageRankComputation\$SimplePageRankWorkerContext -w 5 2>&1 | ts '%.s')
    local time_finish=$(get_time)
    local dur_exec=$(($time_finish-$time_start))
    logv "$result"
    local start_calc=$(echo "$result" | grep 'Running job' | awk '{print $1}')
    local start_calc=$(convert_time $start_calc)
    local dur_calc=$(($time_finish-$start_calc))
    local dur_calc_giraph=$(echo "$result" | grep 'Superstep ' | awk -F '=' '{s += $2} END {print s*1000}')
    log "giraph-pagerank-dist $1 $pagerank_number_of_iterations - $dur_calc $dur_exec $dur_calc_giraph"
}
