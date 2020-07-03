# Ligra installation

## Installing the required dependencies gcc g++ and make
```
sudo apt install gcc g++ make
```

## Installing Ligra itself
1. Clone the Ligra repository
```
git clone https://github.com/jshun/ligra.git
```
2. Build it
```
export OPENMP=1
cd ligra/apps
make -j
```

# Usage
## Input graph format
The input format is the same as with Polymer. It uses the *AdjacencyList* or the *WeightedAdjacencyList* format.

## Supported Algorithms
Ligra supports the following algorithms
- Breath-First Search (BFS)
```
./BFS [-r startNode] graphFile
```
- Betweenness Centrality (BC)
```
./BC [-r startNode] graphFile
```
- Graph Eccentricity Estimation (Radii)
```
./Radii graphFile
```
- Bellman-Ford shortest Paths
```
./BellmanFord [-r startNode]
```
- PageRank graphFile
```
./PageRank [-maxiters int] graphFile
```
- Connected Components (CC)
```
./Components graphFile
```
- Maximal Independent Set (MIS)
```
./MIS [-checkCorrectness] graphFile
```
- K-core Decomposition
```
./KCore graphFile
```
Graph must be symmetric
- Triangle Counting
```
./Triangle graphFile
```
- Collaborative Filtering (CF)
```
./CF [-K] [-numiter int] [-step double] [-lambda double] [-randInit] graphFile
```
Graph must be symmetic, weighted and bipartite


Common options along these algorithms are
```
[-rounds int] Specify the number of rounds the algorithm will be benchmarked. 3 is default
[-s] For symmetric and undirected graphs
[-b] If graph is stored as binary
[-m] mmap
[-c] For compressed graphs using the ligra encode programm
```

To convert a graph into a compressed one
```
./encoder [-s] [-w] adjacencyGraph compressedGraph
```
with the option s for symmetric graphs and the option w for weighted graphs
