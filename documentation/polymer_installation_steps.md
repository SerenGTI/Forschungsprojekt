#Polymer installation

1. install gcc & g++, if needed
```
sudo apt install gcc g++ make
```

2. install numa lib
```
sudo apt install libnuma-dev
```

3. clone polymer
```
git clone https://github.com/realstolz/polymer
```

4. build the system by running
```
make
```
  in the directory polymer was cloned to (here polymer/).


#Usage
```
PageRank: ./numa-PageRank [graph file] [maximum iteration]
SPMV: ./numa-SPMV [graph file] [maximum iteration]
BP: ./numa-BP [graph file] [maximum iteration]
BFS: ./numa-BFS [graph file] [start vertex number]
BellmanFord: ./numa-BellmanFord [graph file] [start vertex number]
ConnectedComponents: ./numa-Components [graph file]
```
