#!/bin/bash
source benchmark.sh

path_to_graphs=/home/fp-ss20/graph
#graph_info=/home/ubuntu/graph/graph_info.txt
path_to_bins=/home/fp-ss20/bin
host_file=/home/ubuntu/host_file
#result_file=$4
threads=2
#hosts=129.69.210.223,129.69.210.224
hosts=129.69.210.223,129.69.210.224,129.69.210.225,129.69.210.226,129.69.210.227
pagerank_number_of_iterations=5

#Name,           Nodes,      Edges,      MaxSourceNodeId   RandomStartNodes
#flickrEdges,    105939,     2416948,    74591             5114,73690,23892,30641,38088,16717,68726,25185,31011,42329
#friendster,     68349467,   2586147869, 56110198          39797743,35222816,1794578,43131729,20457996,490332,4274039,10253002,30789169,54514110
#orkut,          3072442,    117184899,  2724230           1345950,1962322,2692187,1198261,163962,1407061,1613980,1976485,2350837,1834214
#twitterMpi,     52579683,   1963263821, 43983853          9226150,28694596,11344459,8641427,34012760,43840792,106660,26370335,38559695,19217596
#wikipedia,      12150977,   378142420,  12114967          6712096,1761449,4340524,4857604,7825079,6241517,10821044,3259457,8277471,7539859

startnodes_flickr=(5114 73690 23892 30641 38088 16717 68726 25185 31011 42329)
startnodes_friendster=(39797743 35222816 1794578 43131729 20457996 490332 4274039 10253002 30789169 54514110)
startnodes_orkut=(1345950 1962322 2692187 1198261 163962 1407061 1613980 1976485 2350837 1834214)
startnodes_twitter=(9226150 28694596 11344459 8641427 34012760 43840792 106660 26370335 38559695 19217596)
startnodes_wikipedia=(6712096 1761449 4340524 4857604 7825079 6241517 10821044 3259457 8277471 7539859)
startnodes_rMat27=(29388743 31111039 29590628 13101874 50173050 41951863 29267577 11951675 22500259 47296074)
startnodes_rMat28=(42172507 18972996 34475079 9158728 31365500 96481238 63989057 42656526 62460984 44933962)
nodes_flickr=105939
nodes_friendster=68349467
nodes_orkut=3072442
nodes_twitter=52579683
nodes_wikipedia=12150977
nodes_rMat27=63098080
nodes_rMat28=121280102

benchmark_polymer_sssp() {
  for startnode in ${startnodes_flickr[@]}; do
    polymer-sssp flickr $startnode
  done
  for startnode in ${startnodes_friendster[@]}; do
    polymer-sssp friendster $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    polymer-sssp orkut $startnode
  done
  for startnode in ${startnodes_twitter[@]}; do
    polymer-sssp twitter $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    polymer-sssp wikipedia $startnode
  done
}

benchmark_polymer_pagerank() {
  for startnode in ${startnodes_flickr[@]}; do
    polymer-pagerank flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    polymer-pagerank friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    polymer-pagerank orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    polymer-pagerank twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    polymer-pagerank wikipedia
  done
}

benchmark_ligra_sssp() {
  for startnode in ${startnodes_flickr[@]}; do
    ligra-sssp flickr $startnode
  done
  for startnode in ${startnodes_friendster[@]}; do
    ligra-sssp friendster $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    ligra-sssp orkut $startnode
  done
  for startnode in ${startnodes_twitter[@]}; do
    ligra-sssp twitter $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    ligra-sssp wikipedia $startnode
  done
}

benchmark_ligra_pagerank() {
  for startnode in ${startnodes_flickr[@]}; do
    ligra-pagerank flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    ligra-pagerank friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    ligra-pagerank orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    ligra-pagerank twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    ligra-pagerank wikipedia
  done
}

benchmark_gemini_sssp() {
  for startnode in ${startnodes_flickr[@]}; do
    gemini-sssp flickr $startnode $nodes_flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    gemini-sssp friendster $startnode $nodes_friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    gemini-sssp orkut $startnode $nodes_orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    gemini-sssp twitter $startnode $nodes_twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    gemini-sssp wikipedia $startnode $nodes_wikipedia
  done
}

benchmark_gemini_pagerank() {
  for startnode in ${startnodes_flickr[@]}; do
    gemini-pagerank flickr $nodes_flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    gemini-pagerank friendster $nodes_friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    gemini-pagerank orkut $nodes_orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    gemini-pagerank twitter $nodes_twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    gemini-pagerank wikipedia $nodes_wikipedia
  done
}

benchmark_gemini_bfs() {
  for startnode in ${startnodes_flickr[@]}; do
    gemini-bfs flickr $startnode $nodes_flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    gemini-bfs friendster $startnode $nodes_friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    gemini-bfs orkut $startnode $nodes_orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    gemini-bfs twitter $startnode $nodes_twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    gemini-bfs wikipedia $startnode $nodes_wikipedia
  done
}

benchmark_ligra_bfs() {
  for startnode in ${startnodes_flickr[@]}; do
    ligra-bfs flickr $startnode
  done
  for startnode in ${startnodes_friendster[@]}; do
    ligra-bfs friendster $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    ligra-bfs orkut $startnode
  done
  for startnode in ${startnodes_twitter[@]}; do
    ligra-bfs twitter $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    ligra-bfs wikipedia $startnode
  done
}

benchmark_polymer_bfs() {
  for startnode in ${startnodes_flickr[@]}; do
    polymer-bfs flickr $startnode
  done
  for startnode in ${startnodes_friendster[@]}; do
    polymer-bfs friendster $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    polymer-bfs orkut $startnode
  done
  for startnode in ${startnodes_twitter[@]}; do
    polymer-bfs twitter $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    polymer-bfs wikipedia $startnode
  done
}

benchmark_ligra_pagerank_delta() {
  for startnode in ${startnodes_flickr[@]}; do
    ligra-pagerank-delta flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    ligra-pagerank-delta friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    ligra-pagerank-delta orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    ligra-pagerank-delta twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    ligra-pagerank-delta wikipedia
  done
}

benchmark_polymer_pagerank_delta() {
  for startnode in ${startnodes_flickr[@]}; do
    polymer-pagerank-delta flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    polymer-pagerank-delta friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    polymer-pagerank-delta orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    polymer-pagerank-delta twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    polymer-pagerank-delta wikipedia
  done
}

benchmark_polymer_pagerank_write() {
  for startnode in ${startnodes_flickr[@]}; do
    polymer-pagerank-write flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    polymer-pagerank-write friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    polymer-pagerank-write orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    polymer-pagerank-write twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    polymer-pagerank-write wikipedia
  done
}

benchmark_galois_sssp_cpu() {
  for startnode in ${startnodes_flickr[@]}; do
    galois-sssp-cpu flickr $startnode
  done
  for startnode in ${startnodes_friendster[@]}; do
    galois-sssp-cpu friendster $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    galois-sssp-cpu orkut $startnode
  done
  for startnode in ${startnodes_twitter[@]}; do
    galois-sssp-cpu twitter $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    galois-sssp-cpu wikipedia $startnode
  done
}

benchmark_galois_pagerank_push_cpu() {
  for startnode in ${startnodes_flickr[@]}; do
    galois-pagerank-push-cpu flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    galois-pagerank-push-cpu friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    galois-pagerank-push-cpu orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    galois-pagerank-push-cpu twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    galois-pagerank-push-cpu wikipedia
  done
}

benchmark_galois_pagerank_pull_cpu() {
  for startnode in ${startnodes_flickr[@]}; do
    galois-pagerank-pull-cpu flickr
  done
  for startnode in ${startnodes_friendster[@]}; do
    galois-pagerank-pull-cpu friendster
  done
  for startnode in ${startnodes_orkut[@]}; do
    galois-pagerank-pull-cpu orkut
  done
  for startnode in ${startnodes_twitter[@]}; do
    galois-pagerank-pull-cpu twitter
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    galois-pagerank-pull-cpu wikipedia
  done
}

benchmark_galois_bfs_cpu() {
  for startnode in ${startnodes_flickr[@]}; do
    galois-bfs-cpu flickr $startnode
  done
  for startnode in ${startnodes_friendster[@]}; do
    galois-bfs-cpu friendster $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    galois-bfs-cpu orkut $startnode
  done
  for startnode in ${startnodes_twitter[@]}; do
    galois-bfs-cpu twitter $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    galois-bfs-cpu wikipedia $startnode
  done
}

benchmark_ligra_rMat() {
  for startnode in ${startnodes_rMat27[@]}; do
    ligra-sssp rMat27 $startnode
    ligra-bfs rMat27 $startnode
    ligra-pagerank rMat27
    ligra-pagerank-delta rMat27
  done
  for startnode in ${startnodes_rMat28[@]}; do
    ligra-sssp rMat28 $startnode
    ligra-bfs rMat28 $startnode
    ligra-pagerank rMat28
    ligra-pagerank-delta rMat28
  done
}

benchmark_polymer_rMat() {
  for startnode in ${startnodes_rMat27[@]}; do
    polymer-sssp rMat27 $startnode
    polymer-bfs rMat27 $startnode
    polymer-pagerank rMat27
    polymer-pagerank-delta rMat27
    polymer-pagerank-write rMat27
  done
  for startnode in ${startnodes_rMat28[@]}; do
    polymer-sssp rMat28 $startnode
    polymer-bfs rMat28 $startnode
    polymer-pagerank rMat28
    polymer-pagerank-delta rMat28
    polymer-pagerank-write rMat28
  done
}

benchmark_gemini_rMat() {
  for startnode in ${startnodes_rMat27[@]}; do
    gemini-sssp rMat27 $startnode $nodes_rMat27
    gemini-bfs rMat27 $startnode $nodes_rMat27
    gemini-pagerank rMat27 $nodes_rMat27
  done
  for startnode in ${startnodes_rMat28[@]}; do
    gemini-sssp rMat28 $startnode $nodes_rMat28
    gemini-bfs rMat28 $startnode $nodes_rMat28
    gemini-pagerank rMat28 $nodes_rMat28
  done
}

benchmark_galois_rMat27() {
  for startnode in ${startnodes_rMat27[@]}; do
    galois-sssp-cpu rMat27 $startnode
    galois-bfs-cpu rMat27 $startnode
    galois-pagerank-push-cpu rMat27
    galois-pagerank-pull-cpu rMat27
  done
}

benchmark_galois_rMat28() {
  for startnode in ${startnodes_rMat28[@]}; do
    galois-sssp-cpu rMat28 $startnode
    galois-bfs-cpu rMat28 $startnode
    galois-pagerank-push-cpu rMat28
    galois-pagerank-pull-cpu rMat28
  done
}

test_galois_dist() {
  galois-sssp-push-dist flickr 1
  galois-sssp-pull-dist flickr 1
  galois-bfs-push-dist flickr 1
  galois-bfs-pull-dist flickr 1
  galois-pagerank-push-dist flickr
  galois-pagerank-pull-dist flickr
}

benchmark_galois_dist_flickr() {
  for startnode in ${startnodes_flickr[@]}; do
    galois-sssp-push-dist flickr $startnode
    galois-sssp-pull-dist flickr $startnode
    galois-bfs-push-dist flickr $startnode
    galois-bfs-pull-dist flickr $startnode
    galois-pagerank-push-dist flickr
    galois-pagerank-pull-dist flickr
  done
}
benchmark_galois_dist_friendster() {
  for startnode in ${startnodes_friendster[@]}; do
    galois-sssp-push-dist friendster $startnode
    galois-sssp-pull-dist friendster $startnode
    galois-bfs-push-dist friendster $startnode
    galois-bfs-pull-dist friendster $startnode
    galois-pagerank-push-dist friendster
    galois-pagerank-pull-dist friendster
  done
}
benchmark_galois_dist_orkut() {
  for startnode in ${startnodes_orkut[@]}; do
    galois-sssp-push-dist orkut $startnode
    galois-sssp-pull-dist orkut $startnode
    galois-bfs-push-dist orkut $startnode
    galois-bfs-pull-dist orkut $startnode
    galois-pagerank-push-dist orkut
    galois-pagerank-pull-dist orkut
  done
}
benchmark_galois_dist_twitter() {
  for startnode in ${startnodes_twitter[@]}; do
    galois-sssp-push-dist twitter $startnode
    galois-sssp-pull-dist twitter $startnode
    galois-bfs-push-dist twitter $startnode
    galois-bfs-pull-dist twitter $startnode
    galois-pagerank-push-dist twitter
    galois-pagerank-pull-dist twitter
  done
}
benchmark_galois_dist_wikipedia() {
  for startnode in ${startnodes_wikipedia[@]}; do
    galois-sssp-push-dist wikipedia $startnode
    galois-sssp-pull-dist wikipedia $startnode
    galois-bfs-push-dist wikipedia $startnode
    galois-bfs-pull-dist wikipedia $startnode
    galois-pagerank-push-dist wikipedia
    galois-pagerank-pull-dist wikipedia
  done
}
benchmark_galois_dist_rMat27() {
  for startnode in ${startnodes_rMat27[@]}; do
    galois-sssp-push-dist rMat27 $startnode
    galois-sssp-pull-dist rMat27 $startnode
    galois-bfs-push-dist rMat27 $startnode
    galois-bfs-pull-dist rMat27 $startnode
    galois-pagerank-push-dist rMat27
    galois-pagerank-pull-dist rMat27
  done
}
benchmark_galois_dist_rMat28() {
  for startnode in ${startnodes_rMat28[@]}; do
    galois-sssp-push-dist rMat28 $startnode
    galois-sssp-pull-dist rMat28 $startnode
    galois-bfs-push-dist rMat28 $startnode
    galois-bfs-pull-dist rMat28 $startnode
    galois-pagerank-push-dist rMat28
    galois-pagerank-pull-dist rMat28
  done
}

benchmark_giraph_sssp() {
  for startnode in ${startnodes_flickr[@]}; do
    giraph-sssp flickr $startnode
  done
  for startnode in ${startnodes_friendster[@]}; do
    giraph-sssp friendster $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    giraph-sssp orkut $startnode
  done
  for startnode in ${startnodes_twitter[@]}; do
    giraph-sssp twitter $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    giraph-sssp wikipedia $startnode
  done
  for startnode in ${startnodes_rMat27[@]}; do
    giraph-sssp rMat27 $startnode
  done
  for startnode in ${startnodes_rMat28[@]}; do
    giraph-sssp rMat28 $startnode
  done
}

benchmark_giraph_pagerank_dist() {
  for startnode in ${startnodes_flickr[@]}; do
    giraph-pagerank-dist flickr
  done
  for startnode in ${startnodes_orkut[@]}; do
    giraph-pagerank-dist orkut
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    giraph-pagerank-dist wikipedia
  done
  for startnode in ${startnodes_twitter[@]}; do
    giraph-pagerank-dist twitter
  done
  for startnode in ${startnodes_friendster[@]}; do
    giraph-pagerank-dist friendster
  done
  for startnode in ${startnodes_rMat27[@]}; do
    giraph-pagerank-dist rMat27
  done
  for startnode in ${startnodes_rMat28[@]}; do
    giraph-pagerank-dist rMat28
  done
}

benchmark_giraph_sssp_dist_klein() {
  for startnode in ${startnodes_flickr[@]}; do
    giraph-sssp-dist flickr $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    giraph-sssp-dist orkut $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    giraph-sssp-dist wikipedia $startnode
  done
}

benchmark_gemini_dist() {
  for startnode in ${startnodes_flickr[@]}; do
    gemini-sssp-dist flickr $startnode $nodes_flickr
    gemini-bfs-dist flickr $startnode $nodes_flickr
    gemini-pagerank-dist flickr $nodes_flickr
  done
  for startnode in ${startnodes_orkut[@]}; do
    gemini-sssp-dist orkut $startnode $nodes_orkut
    gemini-bfs-dist orkut $startnode $nodes_orkut
    gemini-pagerank-dist orkut $nodes_orkut
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    gemini-sssp-dist wikipedia $startnode $nodes_wikipedia
    gemini-bfs-dist wikipedia $startnode $nodes_wikipedia
    gemini-pagerank-dist wikipedia $nodes_wikipedia
  done
  for startnode in ${startnodes_twitter[@]}; do
    gemini-sssp-dist twitter $startnode $nodes_twitter
    gemini-bfs-dist twitter $startnode $nodes_twitter
    gemini-pagerank-dist twitter $nodes_twitter
  done
  for startnode in ${startnodes_friendster[@]}; do
    gemini-sssp-dist friendster $startnode $nodes_friendster
    gemini-bfs-dist friendster $startnode $nodes_friendster
    gemini-pagerank-dist friendster $nodes_friendster
  done
  for startnode in ${startnodes_rMat27[@]}; do
    gemini-sssp-dist rMat27 $startnode $nodes_rMat27
    gemini-bfs-dist rMat27 $startnode $nodes_rMat27
    gemini-pagerank-dist rMat27 $nodes_rMat27
  done
  for startnode in ${startnodes_rMat28[@]}; do
    gemini-sssp-dist rMat28 $startnode $nodes_rMat28
    gemini-bfs-dist rMat28 $startnode $nodes_rMat28
    gemini-pagerank-dist rMat28 $nodes_rMat28
  done
}

benchmark_galois_cpu() {
  for startnode in ${startnodes_flickr[@]}; do
    galois-sssp-cpu flickr $startnode
    galois-bfs-cpu flickr $startnode
    galois-pagerank-push-cpu flickr
    galois-pagerank-pull-cpu flickr
  done
  for startnode in ${startnodes_orkut[@]}; do
    galois-sssp-cpu orkut $startnode
    galois-bfs-cpu orkut $startnode
    galois-pagerank-push-cpu orkut
    galois-pagerank-pull-cpu orkut
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    galois-sssp-cpu wikipedia $startnode
    galois-bfs-cpu wikipedia $startnode
    galois-pagerank-push-cpu wikipedia
    galois-pagerank-pull-cpu wikipedia
  done
  for startnode in ${startnodes_twitter[@]}; do
    galois-sssp-cpu twitter $startnode
    galois-bfs-cpu twitter $startnode
    galois-pagerank-push-cpu twitter
    galois-pagerank-pull-cpu twitter
  done
  for startnode in ${startnodes_friendster[@]}; do
    galois-sssp-cpu friendster $startnode
    galois-bfs-cpu friendster $startnode
    galois-pagerank-push-cpu friendster
    galois-pagerank-pull-cpu friendster
  done
  for startnode in ${startnodes_rMat27[@]}; do
    galois-sssp-cpu rMat27 $startnode
    galois-bfs-cpu rMat27 $startnode
    galois-pagerank-push-cpu rMat27
    galois-pagerank-pull-cpu rMat27
  done
  for startnode in ${startnodes_rMat28[@]}; do
    galois-sssp-cpu rMat28 $startnode
    galois-bfs-cpu rMat28 $startnode
    galois-pagerank-push-cpu rMat28
    galois-pagerank-pull-cpu rMat28
  done
}

benchmark_giraph_bfs_dist() {
  for startnode in ${startnodes_flickr[@]}; do
    giraph-bfs-dist flickr $startnode
  done
  for startnode in ${startnodes_friendster[@]}; do
    giraph-bfs-dist friendster $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    giraph-bfs-dist orkut $startnode
  done
  for startnode in ${startnodes_twitter[@]}; do
    giraph-bfs-dist twitter $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    giraph-bfs-dist wikipedia $startnode
  done
  for startnode in ${startnodes_rMat27[@]}; do
    giraph-bfs-dist rMat27 $startnode
  done
  for startnode in ${startnodes_rMat28[@]}; do
    giraph-bfs-dist rMat28 $startnode
  done
}

benchmark_giraph_pagerank() {
  for startnode in ${startnodes_flickr[@]}; do
    giraph-pagerank flickr
  done
  for startnode in ${startnodes_orkut[@]}; do
    giraph-pagerank orkut
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    giraph-pagerank wikipedia
  done
  for startnode in ${startnodes_twitter[@]}; do
    giraph-pagerank twitter
  done
  for startnode in ${startnodes_friendster[@]}; do
    giraph-pagerank friendster
  done
  for startnode in ${startnodes_rMat27[@]}; do
    giraph-pagerank rMat27
  done
  for startnode in ${startnodes_rMat28[@]}; do
    giraph-pagerank rMat28
  done
}

benchmark_giraph_bfs() {
  for startnode in ${startnodes_flickr[@]}; do
    giraph-bfs flickr $startnode
  done
  for startnode in ${startnodes_friendster[@]}; do
    giraph-bfs friendster $startnode
  done
  for startnode in ${startnodes_orkut[@]}; do
    giraph-bfs orkut $startnode
  done
  for startnode in ${startnodes_twitter[@]}; do
    giraph-bfs twitter $startnode
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    giraph-bfs wikipedia $startnode
  done
  for startnode in ${startnodes_rMat27[@]}; do
    giraph-bfs rMat27 $startnode
  done
  for startnode in ${startnodes_rMat28[@]}; do
    giraph-bfs rMat28 $startnode
  done
}

benchmark_giraph() {
  for startnode in ${startnodes_flickr[@]}; do
    giraph-sssp flickr $startnode
    giraph-bfs flickr $startnode
    giraph-pagerank flickr
  done
  for startnode in ${startnodes_orkut[@]}; do
    giraph-sssp orkut $startnode
    giraph-bfs orkut $startnode
    giraph-pagerank orkut
  done
  for startnode in ${startnodes_wikipedia[@]}; do
    giraph-sssp wikipedia $startnode
    giraph-bfs wikipedia $startnode
    giraph-pagerank wikipedia
  done
  for startnode in ${startnodes_twitter[@]}; do
    giraph-sssp twitter $startnode
    giraph-bfs twitter $startnode
    giraph-pagerank twitter
  done
  for startnode in ${startnodes_friendster[@]}; do
    giraph-sssp friendster $startnode
    giraph-bfs friendster $startnode
    giraph-pagerank friendster
  done
  for startnode in ${startnodes_rMat27[@]}; do
    giraph-sssp rMat27 $startnode
    giraph-bfs rMat27 $startnode
    giraph-pagerank rMat27
  done
  for startnode in ${startnodes_rMat28[@]}; do
    giraph-sssp rMat28 $startnode
    giraph-bfs rMat28 $startnode
    giraph-pagerank rMat28
  done
}


time_start=$(get_time)
benchmark_giraph
dur_exec=$((($(get_time)-$time_start)/1000000))
echo "benchmark took $dur_exec seconds"
