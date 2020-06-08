# Installation

## install dependencies

### requirements
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
git clone -b release-5.0 https://github.com/IntelligentSoftwareSystems/Galois Galois/src
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

### single source shortest path
```
make -C build -j sssp
cp build/lonestar/sssp/sssp bin/galois-sssp
```

### single source shortest path (pull, distributed)
```
make -C build -j sssp_pull
cp build/lonestardist/sssp/sssp_pull bin/d-galois-sssp-pull
```

### single source shortest path (push, distributed)
```
make -C build -j sssp_push
cp build/lonestardist/sssp/sssp_push bin/d-galois-sssp-push
```

### page rank (pull)
```
make -C build -j pagerank-pull
cp build/lonestar/pagerank/pagerank-pull bin/galois-pagerank-pull
```

### page rank (push)
```
make -C build -j pagerank-push
cp build/lonestar/pagerank/pagerank-push bin/galois-pagerank-push
```

### page rank (pull, distributed)
```
make -C build/lonestardist/pagerank -j pagerank_pull
cp build/lonestardist/pagerank/pagerank_pull bin/d-galois-pagerank-pull
```

### page rank (push, distributed)
```
make -C build/lonestardist/pagerank -j pagerank_push
cp build/lonestardist/pagerank/pagerank_push bin/d-galois-pagerank-push
```

### graph converter
```
make -C build -j graph-convert
cp build/tools/graph-convert/graph-convert bin/galois-graph-convert
```

# Graph converting
Graphs should be a list of type *<SOURCE> <TARGET> <WEIGHT>* seperated by newline.
```
galois-graph-convert -edgelist2gr -edgeType=int32|int64|float32|float64 <INPUT> <OUTPUT>
```
The weight is optional. If there are no weights the command can be run without *-edgeType*. The *-edgeType* specifys the datatype used for the weight.
*IMPORTANT:* galois-sssp needs weights and produces a *Segmentation Fault* without

A lot of edge-list-graph-files have comments at the of top of the file. The galois-convert tool will fail if comments are present . You can remove those with (NUMBER=#comments+1)
```
tail -n +<NUMBER> old > new
```

If you want to add a weight of 1 to every edge to make a weighted graph out of an unweighted one.
```
awk '{print $0, "1"}' old > new
```
