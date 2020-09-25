# Polymer installation
On Ubuntu 20.04
## Installing the required dependencies
1. gcc, g++ and make
```
sudo apt install gcc g++ make
```
2. the NUMA library
```
sudo apt install libnuma-dev
```

## Installing Polymer itself
Clone the Polymer repository
```
git clone https://github.com/realstolz/polymer
```
and build the system by running `make` in the directory polymer was cloned into
```
cd polymer
make
```



# Usage
## Input Graph Format
The input format is the same as with Ligra. It uses the *AdjacencyList* or the *WeightedAdjacencyList* format.

## Supported Algorithms
Polymer supports the following algorithms with the supplied command line invocations
- Page Rank (PR)
```
./numa-PageRank [graph file] [maximum iteration]
```
- Sparse matrix-vector multiplication (SPMV) 
```
./numa-SPMV [graph file] [maximum iteration]
```
- Bayesian belief propagation (BP) requires a weighted input graph
```
./numa-BP [graph file] [maximum iteration]
```
- Breadth-first search (BFS)
```
./numa-BFS [graph file] [start vertex number]
```
- Single Source Shortest Path (SSSP) based on the Bellman Ford Algorithm, requires a weighted input graph.
```
./numa-BellmanFord [graph file] [start vertex number]
```
- Connected Components (CC)
```
./numa-Components [graph file]
```
