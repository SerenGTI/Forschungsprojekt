# Installation
On Ubuntu 20.04

## Install dependencies
- C++11 compiler
- libnuma

```
sudo apt-get install g++ libnuma-dev
```

## Build
The origional sourcecode you can find in the repo https://github.com/thu-pacman/GeminiGraph.git, but we found a few bugs like not zeroterminating strings and others, so we forked the repository, fixed the bugs relevant for us and used that one https://github.com/jasc7636/GeminiGraph.git

```
mkdir Gemini Gemini/src Gemini/bin
git clone https://github.com/jasc7636/GeminiGraph.git Gemini/src
cd Gemini
make -C src
cp src/toolkits/sssp bin/gemini-sssp
cp src/toolkits/pagerank bin/gemini-pagerank
```

## Run
```
mpiexec -H hosts gemini-sssp [path] [vertices] [root]
mpiexec -H hosts gemini-pagerank [path] [vertices] [iterations]
```

### Graph format
The algorithms need a binary edgelist format:
- sssp <src1: int32><dest1: int32><weight1: float32><src2: int32><dest2: int32><weight2: float32>...
- other <src1: int32><dest1: int32><src2: int32><dest2: int32>...


