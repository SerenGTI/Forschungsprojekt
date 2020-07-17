#!/bin/bash
source benchmark.sh

path_to_graphs=/home/fp-ss20/graph
#graph_info=/home/ubuntu/graph/graph_info.txt
path_to_bins=/home/fp-ss20/bin
#host_file=/home/ubuntu/host_file
#result_file=$4
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
nodes_flickr=105939
nodes_friendster=68349467
nodes_orkut=3072442
nodes_twitter=52579683
nodes_wikipedia=12150977

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

#benchmark_gemini_bfs
#benchmark_ligra_bfs
#benchmark_polymer_bfs
#benchmark_ligra_pagerank_delta
#benchmark_polymer_pagerank_delta
#benchmark_polymer_pagerank_write
