# Installation

## install dependencies

### required
- C++ compiler (has to be C++-17 compliant(gcc >= 7, clang >= 7))
- cmake >= 3.13
- Boost library >= 1.58.0 (full install recommended)
- LLVM >= 7.0 (with RTTI support)
```
sudo apt-get install g++
sudo apt-get install cmake
sudo apt-get install libboost-all-dev
sudo apt-get install llvm
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
There are many ways to setup hugepages. The only way worked for us is the way using *systemd*. If your system doesn't uses systemd, you could try an other one.
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
With <NUMBER> is the number of hugepages you want to set and <ID> is the id from step 2.
```
  vm.nr_hugepages = <NUMBER>
  vm.hugetlb_shm_group = <ID>
```
5. create path to mount hugepages
```
mkdir <MOUNTPOINT>
```
6. edit */etc/fstab*
With <MOUNTPOINT is the mountpoint and <ID> is the id from step 2.
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
git clone -b release-5.0 https://github.com/IntelligentSoftwareSystems/Galois Galois/src
cd Galois
cmake -S src -B build -DCMAKE_BUILD_TYPE=Release
```
If you easy want to call the algorithms, add those to your path
```
export PATH="$HOME/Galois/bin:$PATH"
```

## build applications

### single source shortest path
```
make -C build sssp
cp build/lonestar/sssp/sssp bin/galois-sssp
```

### page rank (pull)
```
make -C build pagerank-pull
cp build/lonestar/pagerank/pagerank-pull bin/galois/pagerank-pull
```

### page rank (push)
```
make -C build pagerank-push
cp build/lonestar/pagerank/pagerank-push bin/galois/pagerank-push
```

### graph converter
```
make -C build graph-convert
cp build/tools/graph-convert/graph-convert bin/galois-graph-convert
```

# Graph converting
Graphs should be a list of type *<SOURCE> <TARGET> <WEIGHT>* seperated by newline.
```
galois-graph-convert -edgelist2gr -edgeType=int32|int64|float32|float64 <INPUT> <OUTPUT>
```
The weight is optional. If no weight in the list the command can be run with no argument *-edgeType*. The *-edgeType* specifys the datatype used for the weight.
*IMPORTANT:* galois-sssp needs weights and produces a *Segmentation Fault* without

A lot of edge-list-graph-files have commentars on top of the file. The algorithm in galois-convert will fail on this commentars. You can remove thos with (NUMBER=#commentars+1)
```
tail -n +<NUMBER> old > new
```

If you want to add a weight of 1 to every edge to make a weighted graph out of an unweighted one.
```
awk '{print $0, "1"}' old > new
```
