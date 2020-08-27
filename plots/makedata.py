
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
from math import sqrt
import re
plt.style.use('./style.mplstyle')

#sorted by size of graph
graphs = ('flickr', 'orkut', 'wikipedia', 'twitter', 'rMat27', 'friendster', 'rMat28')
#graph sizes in million edges
graphSize = (2, 117, 378, 1963, 2147, 2586, 4294)
#sorted alphabetically
frameworks = ('Galois', 'Gemini', 'Giraph', 'Ligra', 'Polymer')




## RAW DATA
#[graph, algo, calc, exec, varCalc, varExec]
data = []
with open('../results/results.txt') as f:
    for line in f:
        data.append([])
        for entry in line.split():
            data[-1].append(entry)

graph = np.empty(len(data), dtype=object)
algo = np.empty(len(data), dtype=object)
calcTime = np.empty(len(data))
totalTime = np.empty(len(data))
yErrCalc = np.empty(len(data))
yErrExec = np.empty(len(data))

for i in range(len(data)):

    graph[i] = data[i][0]
    algo[i] = data[i][1]
    try:
        calcTime[i] = float(data[i][2])
    except ValueError:
        calcTime[i] = float('nan')
    try:
        totalTime[i] = float(data[i][3])
    except ValueError:
        totalTime[i] = float('nan')
    try:
        yErrCalc[i] = sqrt(float(data[i][4]))
    except ValueError:
        yErrCalc[i] = float('nan')
    try:
        yErrExec[i] = sqrt(float(data[i][5]))
    except ValueError:
        yErrExec[i] = float('nan')










#### SSSP TIMES SINGLE NODE
calcTimeSSSP_singleNode = []
yErrCalcSSSP_singleNode = []

execTimeSSSP_singleNode = []
yErrExecSSSP_singleNode = []

overheadSSSP_singleNode = []
overheadSSSPNormalized_singleNode = []
for f in frameworks:
    tmpExec = []
    tmpCalc = []
    tmpYErrCalc = []
    tmpYErrExec = []
    overhead = []
    overheadNormalized = []
    fname = f.lower() + "-sssp"
    if f == 'Galois':
        fname += "-cpu-96thread" # select Galois thread count here
    k = 0 # graph index
    for g in graphs:
        for i in range(len(graph)):
            if g == graph[i] and fname == algo[i]:
                tmpCalc.append(calcTime[i])
                tmpYErrCalc.append(yErrCalc[i])

                tmpExec.append(totalTime[i])
                tmpYErrExec.append(yErrExec[i])

                overhead.append(totalTime[i] - calcTime[i])
                overheadNormalized.append((totalTime[i] - calcTime[i])/graphSize[k])
        k += 1 # graph index

    calcTimeSSSP_singleNode.append(tmpCalc)
    yErrCalcSSSP_singleNode.append(tmpYErrCalc)
    execTimeSSSP_singleNode.append(tmpExec)
    yErrExecSSSP_singleNode.append(tmpYErrExec)
    overheadSSSP_singleNode.append(overhead)
    overheadSSSPNormalized_singleNode.append(overheadNormalized)




## SSSP DISTRIBUTED
dist_frameworks_sssp = {
    "galois-sssp-push-dist":"Galois Push",
    "galois-sssp-pull-dist":"Galois Pull",
    "gemini-sssp-dist":"Gemini",
    "giraph-sssp-dist":"Giraph"}

calcTimeSSSP_distributed = []
yErrCalcSSSP_distributed = []

execTimeSSSP_distributed = []
yErrExecSSSP_distributed = []

overheadSSSP_distributed = []
overheadSSSPNormalized_distributed = []
for f in dist_frameworks_sssp:
    tmpExec = []
    tmpCalc = []
    tmpYErrCalc = []
    tmpYErrExec = []
    overhead = []
    overheadNormalized = []
    
    k = 0 # graph index
    for g in graphs:
        for i in range(len(graph)):
            if g == graph[i] and f == algo[i]:
                tmpCalc.append(calcTime[i])
                tmpYErrCalc.append(yErrCalc[i])

                tmpExec.append(totalTime[i])
                tmpYErrExec.append(yErrExec[i])

                overhead.append(totalTime[i] - calcTime[i])
                overheadNormalized.append((totalTime[i] - calcTime[i])/graphSize[k])
        k += 1 # graph index

    calcTimeSSSP_distributed.append(tmpCalc)
    yErrCalcSSSP_distributed.append(tmpYErrCalc)
    execTimeSSSP_distributed.append(tmpExec)
    yErrExecSSSP_distributed.append(tmpYErrExec)
    overheadSSSP_distributed.append(overhead)
    overheadSSSPNormalized_distributed.append(overheadNormalized)

overheadSSSP_distributed_normalizedToGalois = []

#print("Overhead comparison distributed SSSP")
i = 0
for k in dist_frameworks_sssp:
    overheadSSSP_distributed_normalizedToGalois.append([])
    #print(dist_frameworks_sssp[k])
    for j in range(len(overheadSSSP_distributed[i])):
        #print(graphs[j] + ": ", calcTimeSSSP_distributed[i][j]/calcTimeSSSP_distributed[2][j])
        overheadSSSP_distributed_normalizedToGalois[i].append(overheadSSSP_distributed[i][j]/overheadSSSP_distributed[0][j]) 
    i += 1






#### BFS SINGLE NODE
calcTimeBFS_singleNode = []
yErrCalcBFS_singleNode = []

execTimeBFS_singleNode = []
yErrExecBFS_singleNode = []

overheadBFS_singleNode = []
overheadBFSNormalized_singleNode = []
for f in frameworks:
    tmpExec = []
    tmpCalc = []
    tmpYErrCalc = []
    tmpYErrExec = []
    overhead = []
    overheadNormalized = []
    fname = f.lower() + "-bfs"
    if f == 'Galois':
        fname += "-cpu-96thread" # select Galois thread count here
    k = 0 # graph index

    for g in graphs:
        for i in range(len(graph)):
            if g == graph[i] and fname == algo[i]:
                tmpCalc.append(calcTime[i])
                tmpYErrCalc.append(yErrCalc[i])

                tmpExec.append(totalTime[i])
                tmpYErrExec.append(yErrExec[i])

                overhead.append(totalTime[i] - calcTime[i])
                overheadNormalized.append((totalTime[i] - calcTime[i])/graphSize[k])
        k += 1 # graph index


    calcTimeBFS_singleNode.append(tmpCalc)
    yErrCalcBFS_singleNode.append(tmpYErrCalc)
    execTimeBFS_singleNode.append(tmpExec)
    yErrExecBFS_singleNode.append(tmpYErrExec)
    overheadBFS_singleNode.append(overhead)
    overheadBFSNormalized_singleNode.append(overheadNormalized)



### BFS DISTRIBUTED
dist_frameworks_bfs = {
    "galois-bfs-push-dist":"Galois Push",
    "galois-bfs-pull-dist":"Galois Pull",
    "gemini-bfs-dist":"Gemini",
    "giraph-bfs-dist":"Giraph"}

calcTimeBFS_distributed = []
yErrCalcBFS_distributed = []

execTimeBFS_distributed = []
yErrExecBFS_distributed = []

overheadBFS_distributed = []
overheadBFSNormalized_distributed = []
for f in dist_frameworks_bfs:
    tmpExec = []
    tmpCalc = []
    tmpYErrCalc = []
    tmpYErrExec = []
    overhead = []
    overheadNormalized = []
    
    k = 0 # graph index
    for g in graphs:
        for i in range(len(graph)):
            if g == graph[i] and f == algo[i]:
                tmpCalc.append(calcTime[i])
                tmpYErrCalc.append(yErrCalc[i])

                tmpExec.append(totalTime[i])
                tmpYErrExec.append(yErrExec[i])

                overhead.append(totalTime[i] - calcTime[i])
                overheadNormalized.append((totalTime[i] - calcTime[i])/graphSize[k])
        k += 1 # graph index


    calcTimeBFS_distributed.append(tmpCalc)
    yErrCalcBFS_distributed.append(tmpYErrCalc)
    execTimeBFS_distributed.append(tmpExec)
    yErrExecBFS_distributed.append(tmpYErrExec)
    overheadBFS_distributed.append(overhead)
    overheadBFSNormalized_distributed.append(overheadNormalized)












#### PAGERANK SINGLE NODE
singleNode_frameworks_pr = {
    "galois-pagerank-push-cpu-96thread":"Galois Push",
    "galois-pagerank-pull-cpu-96thread":"Galois Pull",
    "gemini-pagerank":"Gemini",
    "giraph-pagerank":"Giraph",
    "ligra-pagerank":"Ligra",
    "ligra-pagerank-delta":"Ligra Delta",
    "polymer-pagerank":"Polymer",
    "polymer-pagerank-delta":"Polymer Delta"}

calcTimePR_singleNode = []
yErrCalcPR_singleNode = []

execTimePR_singleNode = []
yErrExecPR_singleNode = []

overheadPR_singleNode = []
overheadPRNormalized_singleNode = []
for f in singleNode_frameworks_pr:
    tmpExec = []
    tmpCalc = []
    tmpYErrCalc = []
    tmpYErrExec = []
    overhead = []
    overheadNormalized = []
    
    k = 0 # graph index
    for g in graphs:
        for i in range(len(graph)):
            if g == graph[i] and f == algo[i]:
                tmpCalc.append(calcTime[i])
                tmpYErrCalc.append(yErrCalc[i])

                tmpExec.append(totalTime[i])
                tmpYErrExec.append(yErrExec[i])

                overhead.append(totalTime[i] - calcTime[i])
                overheadNormalized.append((totalTime[i] - calcTime[i])/graphSize[k])
        k += 1 # graph index


    calcTimePR_singleNode.append(tmpCalc)
    yErrCalcPR_singleNode.append(tmpYErrCalc)
    execTimePR_singleNode.append(tmpExec)
    yErrExecPR_singleNode.append(tmpYErrExec)
    overheadPR_singleNode.append(overhead)
    overheadPRNormalized_singleNode.append(overheadNormalized)



### PR DISTRIBUTED
dist_frameworks_pr = {
    "galois-pagerank-push-dist":"Galois Push",
    "galois-pagerank-pull-dist":"Galois Pull",
    "gemini-pagerank-dist":"Gemini",
    "giraph-pagerank-dist":"Giraph"}

calcTimePR_distributed = []
yErrCalcPR_distributed = []

execTimePR_distributed = []
yErrExecPR_distributed = []

overheadPR_distributed = []
overheadPRNormalized_distributed = []
for f in dist_frameworks_pr:
    tmpExec = []
    tmpCalc = []
    tmpYErrCalc = []
    tmpYErrExec = []
    overhead = []
    overheadNormalized = []
    
    k = 0 # graph index
    for g in graphs:
        for i in range(len(graph)):
            if g == graph[i] and f == algo[i]:
                tmpCalc.append(calcTime[i])
                tmpYErrCalc.append(yErrCalc[i])

                tmpExec.append(totalTime[i])
                tmpYErrExec.append(yErrExec[i])

                overhead.append(totalTime[i] - calcTime[i])
                overheadNormalized.append((totalTime[i] - calcTime[i])/graphSize[k])
        k += 1 # graph index


    calcTimePR_distributed.append(tmpCalc)
    yErrCalcPR_distributed.append(tmpYErrCalc)
    execTimePR_distributed.append(tmpExec)
    yErrExecPR_distributed.append(tmpYErrExec)
    overheadPR_distributed.append(overhead)
    overheadPRNormalized_distributed.append(overheadNormalized)











### GALOIS CALC TIME SPEEDUP
speedupGaloisSSSP = {}
speedupGaloisBFS = {}
speedupGaloisPRPush = {}
speedupGaloisPRPull = {}
x = []
for g in graphs:
    speedupGaloisSSSP[g] = {}
    speedupGaloisBFS[g] = {}
    speedupGaloisPRPush[g] = {}
    speedupGaloisPRPull[g] = {}

for i in range(len(graph)):
    if not 'galois' in algo[i]:
        continue
    if '-dist' in algo[i]:
        continue
    
    num = int(re.sub('\D', '', algo[i]))
    if not num in x:
        x.append(num)
x.sort()

for i in range(len(graph)):
    if not 'galois' in algo[i]:
        continue
    if '-dist' in algo[i]:
        continue
    
    xVal = int(re.sub('\D', '', algo[i]))
    
    if 'sssp' in algo[i]:
        speedupGaloisSSSP[graph[i]][xVal] = calcTime[i]
    elif 'bfs' in algo[i]:
        speedupGaloisBFS[graph[i]][xVal] = calcTime[i]
    elif 'pagerank-push' in algo[i]:
        speedupGaloisPRPush[graph[i]][xVal] = calcTime[i]
    elif 'pagerank-pull' in algo[i]:
        speedupGaloisPRPull[graph[i]][xVal] = calcTime[i]



#print(speedupGaloisPRPush)
# Calculations for speedup
for g in graphs:
    tSSSP = speedupGaloisSSSP[g][1]
    tBFS = speedupGaloisBFS[g][1]
    tPRPush = speedupGaloisPRPush[g][1]
    tPRPull = speedupGaloisPRPull[g][1]
    for x_ in x:
        speedupGaloisSSSP[g][x_] = tSSSP / speedupGaloisSSSP[g][x_]
        speedupGaloisBFS[g][x_] = tBFS / speedupGaloisBFS[g][x_]
        speedupGaloisPRPush[g][x_] = tPRPush / speedupGaloisPRPush[g][x_]
        speedupGaloisPRPull[g][x_] = tPRPull / speedupGaloisPRPull[g][x_]


if False:
    for g in graphs:
        if g == 'flickr' or g == 'orkut':
            continue
        tmp = speedupGaloisBFS[g]
        print(g)
        last = 1
        xs = []
        for k in tmp:
            xs.append(k)
        xs.sort()
        for k in xs:
            print(k, tmp[k], tmp[k] / tmp[last])
            #last = k
