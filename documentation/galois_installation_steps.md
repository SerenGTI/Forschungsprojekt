# Installation
On Ubuntu 20.04

## install dependencies

### requirements
- C++ compiler (has to be C++-17 compliant(gcc >= 7, clang >= 7))
- cmake >= 3.13
- Boost library >= 1.58.0 (full install recommended)
- LLVM >= 7.0 (with RTTI support)
```
sudo apt-get install g++ cmake libboost-all-dev llvm
```

### required for distributed
```
sudo apt-get install libopenmpi-dev
```

### optional
Linux HUGE_PAGES support (2MB pagesize (ideally allocation of huge pages on kernel boot (hugepages=<num_of_pages>), if multiple huge page sizes are supported a selection (hugepagesz=<size>) should be made pre allocation))
If the mmap system call is used to allocate huge pages, a pseudo filesystem of type hugelbfs has to be mounted (for further information "https://www.kernel.org/doc/Documentation/vm/hugetlbpage.txt")
libnuma support
MPICH2 for distributed systems
CUDA for distributed heterogenous systems
```
sudo apt-get install libnuma-dev
```


#### setup hugepages
There are many ways to setup hugepages. We could only get it to work using *systemd*. If your system doesn't use systemd, you could try an other one.
1. create hugepagesgroup
```
groupadd my-hugetlbfs
```
2.  get the ID or whatever of the group
The output should be of the format *my-hugetlbfs:x:<ID>:*
```
getent group my-hugetlbfs
```
3. add your user to the group
adduser <USER> my-hugetlbfs
4. edit */etc/sysctl.conf*
<NUMBER> is the number of hugepages you want to set and <ID> is the id from step 2.
```
  vm.nr_hugepages = <NUMBER>
  vm.hugetlb_shm_group = <ID>
```
5. create path to mount hugepages
```
mkdir <MOUNTPOINT>
```
6. edit */etc/fstab*
<MOUNTPOINT> is the mountpoint and <ID> is the id from step 2.
```
hugetlbfs <MOUNTPOINT> hugetlbfs mode=1770,gid=<ID> 0 0
```
7. reboot
```
sudo reboot
```
8. check everything worked
```
grep "Huge" /sys/devices/system/node/node*/meminfo
grep "Hugepagesize:" /proc/meminfo
```

## prepare build
```
mkdir Galois Galois/src Galois/build Galois/bin
# Version5: git clone -b release-5.0 https://github.com/IntelligentSoftwareSystems/Galois Galois/src
git clone -b release-6.0 https://github.com/IntelligentSoftwareSystems/Galois Galois/src
cd Galois
cmake -S src -B build -DCMAKE_BUILD_TYPE=Release
```
If you want D-Galois
```
cmake build -DGALOIS_ENABLE_DIST=1
```
If ease of use is a concern you may want to export the path to the binaries
```
export PATH="$HOME/Galois/bin:$PATH"
```

## build applications
*Important Note:* If RAM is very limited omit the *-j* flag on the make commands, otherwise you may run out of memory. The build-process will take much longer. (On 4GB-RAM the build crashed with the -j option)

We assume you have enabled the D-GALOIS

### single source shortest path
```
# Version5: make -C build -j sssp
# Version5: cp build/lonestar/sssp/sssp bin/galois-sssp
make -C build -j sssp-cpu
cp build/lonestar/analytics/cpu/sssp/sssp-cpu bin/galois-sssp-cpu
```

### single source shortest path (pull, distributed)
```
# Version5: make -C build -j sssp_pull
# Version5: cp build/lonestardist/sssp/sssp_pull bin/d-galois-sssp-pull
make -C build -j sssp-pull-dist
cp build/lonestar/analytics/distributed/sssp/sssp-pull-dist bin/galois-sssp-pull-dist
```

### single source shortest path (push, distributed)
```
# Version5: make -C build -j sssp_push
# Version5: cp build/lonestardist/sssp/sssp_push bin/d-galois-sssp-push
make -C build -j sssp-push-dist
cp build/lonestar/analytics/distributed/sssp/sssp-push-dist bin/galois-sssp-push-dist
```

### page rank (pull)
```
# Version5: make -C build -j pagerank-pull
# Version5: cp build/lonestar/pagerank/pagerank-pull bin/galois-pagerank-pull
make -C build -j pagerank-pull-cpu
cp build/lonestar/analytics/cpu/pagerank/pagerank-pull-cpu bin/galois-pagerank-pull-cpu
```

### page rank (push)
```
# Version5: make -C build -j pagerank-push
# Version5: cp build/lonestar/pagerank/pagerank-push bin/galois-pagerank-push
make -C build -j pagerank-push-cpu
cp build/lonestar/analytics/cpu/pagerank/pagerank-push-cpu bin/galois-pagerank-push-cpu
```

### page rank (pull, distributed)
```
# Version5: make -C build/lonestardist/pagerank -j pagerank_pull
# Version5: cp build/lonestardist/pagerank/pagerank_pull bin/d-galois-pagerank-pull
make -C build -j pagerank-pull-dist
cp build/lonestar/analytics/distributed/pagerank/pagerank-pull-dist bin/galois-pagerank-pull-dist
```

### page rank (push, distributed)
```
# Version5: make -C build/lonestardist/pagerank -j pagerank_push
# Version5: cp build/lonestardist/pagerank/pagerank_push bin/d-galois-pagerank-push
make -C build -j pagerank-push-dist
cp build/lonestar/analytics/distributed/pagerank/pagerank-push-dist bin/galois-pagerank-push-dist
```

### bfs
```
make -C build -j bfs-cpu
cp build/lonestar/analytics/cpu/bfs/bfs-cpu bin/galois-bfs-cpu
```

### bfs (push, distributed)
```
make -C build -j bfs-push-dist
cp build/lonestar/analytics/distributed/bfs/bfs-push-dist bin/galois-bfs-push-dist
```

### bfs (pull, distributed)
```
make -C build -j bfs-pull-dist
cp build/lonestar/analytics/distributed/bfs/bfs-pull-dist bin/galois-bfs-pull-dist
```

### graph converter
```
make -C build -j graph-convert
cp build/tools/graph-convert/graph-convert bin/galois-graph-convert
```
### graph converter (huge)
```
make -C build -j graph-convert-huge
cp build/tools/graph-convert/graph-convert-huge bin/galois-graph-convert-huge
```
### graph converter (distributed)
```
make -C build -j dist-graph-convert
cp build/tools/dist-graph-convert/dist-graph-convert bin/galois-dist-graph-convert
```

# Graph converting
Graphs should be a list of type *<SOURCE> <TARGET> <WEIGHT>* seperated by newline.

## using galois-graph-convert
```
# Version5: galois-graph-convert -edgelist2gr -edgeType=int32|int64|float32|float64 <INPUT> <OUTPUT>
galois-graph-convert --edgelist2gr --edgeType=int32|int64|float32|float64 <INPUT> <OUTPUT>
```
The weight is optional. If there are no weights the command can be run without *-edgeType*. The *-edgeType* specifys the datatype used for the weight.
*IMPORTANT:* galois-sssp needs weights and produces a *Segmentation Fault* without

## using galois-graph-convert-huge
There also is a program called graph-convert-huge. The name suggests it can be used to convert big graph. It has a very weak documentation und help page, but it seems to work for weighted graphs as well as for unweighted graphs. And also don't break for edge lists with commentaries (#). For small graphs it produces slightly bigger graph files as the normal graph convert.
```
galois-graph-convert-huge <INPUT> <OUTPUT>
```

## other helpful things
A lot of edge-list-graph-files have comments at the of top of the file. The galois-convert tool will fail if comments are present . You can remove those with (NUMBER=#comments+1)
```
tail -n +<NUMBER> old > new
```

If you want to add a weight of 1 to every edge to make a weighted graph out of an unweighted one.
```
awk '{print $0, "1"}' old > new
```

If your want to remove weigths from the graph
```
awk 'NF{NF-=1};1' old > new
```

# Run distributed
*IMPORTANT:* The pull will need the transposed graph, you either could transpose the graph, or specify to read the graph transposed wit the --transposedGraph option for the algorithms

## run on each core of one machine
```
GALOIS_DO_NOT_BIND_THREADS=1 mpirun <ALGORITHM> <GRAPH>
```
or
```
GALOIS_DO_NOT_BIND_THREADS=1 mpiexec <ALGORITHM> <GRAPH>
```

## Setup Cluster

## 1. Setup mpi
Make sure on every node is the exact same version of *mpirun* installed. You can check this with
```
mpirun --version
```

### 2. Setup hostnames
To keep the overview it's recommended to first setup the hostnames in the */etc/hosts*.
You have to choose a Master and one or multiple Slave nodes. The Master node needs the (name, ip) pairs of Master and all the Slaves.
Each Slave needs his own and the Master (name, ip) pair. This is not neccessary, but reccomendet, you can also use IP adresses.

### 3. Setup ssh connection
Each Node communicates using ssh. Therefore a passwordless ssh configuration from the master node to all slave nodes and back is needed.
You schould create on each Node a ssh key with and add the public key of the master node to each slave node and the public key of each slave node to the master node.
Try each connection to make sure all hosts are added to the trusted hosts.

### 4. Setup data
Make sure that each node has the exact same user and the algorithm to use such as the graph is at the exact same location on each machine.
*IMPORTANT:* Do never use relative paths for the algorithm and the graph file. Only absolute paths works.

### 5. Run the algorithm
Now you are able to run the algorithm distributed. Host1 to Hostn are the names you set for each node in step two.
If you want to also run multiple processes on each machine, write that hostname mutiple times into the list after -H.
```
GALOIS_DO_NOT_BIND_THREADS=1 mpirun -H <HOST1>,<HOST2>,...,<HOSTn> <ALGORITHM> <GRAPH>
```
