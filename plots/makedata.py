
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

if False:
    k = 0
    gr = 0
    s = np.zeros(len(graphs)-1)
    for f in frameworks:
        if f == 'Giraph':
            k += 1
            continue
        for i in range(len(calcTimeSSSP_singleNode[k])):
            s[i] += calcTimeSSSP_singleNode[k][i]
        k += 1
    s /= 4
    #print("average calculation time:", s)
    k = 0
    for f in frameworks:
        # if f == 'Giraph':
        #     k += 1
        #     continue
        #print(f)
        for i in range(1, len(execTimeSSSP_singleNode[k])):
            pass
            #print(graphs[i], round((execTimeSSSP_singleNode[k][i] / execTimeSSSP_singleNode[0][i]) * 100), "%")
            #print(graphs[i], round(execTimeSSSP_singleNode[k][i] * 100) / 100, "s")
        k += 1

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

execTimeSSSP_distributed_normalizedToGalois = []

#print("Overhead comparison distributed SSSP")
i = 0
for k in dist_frameworks_sssp:
    execTimeSSSP_distributed_normalizedToGalois.append([])
    for j in range(len(execTimeSSSP_distributed[i])):
        execTimeSSSP_distributed_normalizedToGalois[i].append(execTimeSSSP_distributed[i][j]/execTimeSSSP_distributed[0][j]) 
    i += 1

if False:
    for i in range(len(execTimeSSSP_distributed_normalizedToGalois[0])):
        print(graphs[i], end=" & ")
        for j in range(len(execTimeSSSP_distributed_normalizedToGalois)):
            print(round(execTimeSSSP_distributed_normalizedToGalois[j][i] * 100)/100,end=" & (")
            print(round(execTimeSSSP_distributed[j][i] * 10)/10 ,end=") & ")
        print("\\\\")
#print(graphs)








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

if False:
    k = 0
    v = []
    for f in frameworks:
        print(f)
        print(calcTimeBFS_singleNode[k])
        print([round(calcTimeBFS_singleNode[k][i]/calcTimeBFS_singleNode[3][i] * 100) / 100 for i in range(len(calcTimeBFS_singleNode[k]))])
        k += 1





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
    #"ligra-pagerank-delta":"Ligra Delta",
    #"polymer-pagerank":"Polymer",
    "polymer-pagerank-delta":"Polymer Delta"
    }

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


if False:
    k = 0
    values = {}
    for f in singleNode_frameworks_pr:
        if 'ligra' in f or 'polymer' in f:
            values[f] = execTimePR_singleNode[k]
        k += 1

    ligra = []
    polymer = []

    for l in range(len(values["ligra-pagerank"])):
        v1 = values["ligra-pagerank"][l]
        v2 = values["ligra-pagerank-delta"][l]
        v = abs((v1-v2) / max(v1,v2))
        ligra.append(v)
    # print(ligra)
    # print(sum(ligra) / len(ligra))

    for l in range(len(values["polymer-pagerank"])):
        v1 = values["polymer-pagerank"][l]
        v2 = values["polymer-pagerank-delta"][l]
        if v1>v2:
            print("delta")
        else:
            print("reg")
        v = abs((v1-v2) / max(v1,v2))
        polymer.append(v)

    print(polymer)
    print(sum(polymer[:-1]) / len(polymer[:-1])) 

if False:
    print(calcTimePR_singleNode[0])
    






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



if False:
    #GaloisPush = 0
    #GaloisPull = 1
    print([calcTimePR_distributed[0][i] / calcTimePR_distributed[1][i] for i in range(len(graphs))])

    print(execTimePR_distributed[1][1], execTimePR_distributed[2][1])










if False:
    for i in range(len(graphs)):
        timeGaloisDist = round(execTimeSSSP_distributed[0][i] * 10)/10
        timeGeminiDist = round(execTimeSSSP_distributed[2][i] * 10)/10
        timeGiraphDist = round(execTimeSSSP_distributed[3][i] * 10)/10
        timeGalois = round(execTimeSSSP_singleNode[0][i] * 10)/10
        timeGemini = round(execTimeSSSP_singleNode[1][i] * 10)/10
        timeGiraph = round(execTimeSSSP_singleNode[2][i] * 10)/10

        # timeGaloisDist = round(execTimeBFS_distributed[0][i] * 10)/10
        # timeGeminiDist = round(execTimeBFS_distributed[2][i] * 10)/10
        # timeGiraphDist = round(execTimeBFS_distributed[3][i] * 10)/10
        # timeGalois = round(execTimeBFS_singleNode[0][i] * 10)/10
        # timeGemini = round(execTimeBFS_singleNode[1][i] * 10)/10
        # timeGiraph = round(execTimeBFS_singleNode[2][i] * 10)/10

        # timeGaloisDist = round(execTimePR_distributed[0][i] * 10)/10
        # timeGeminiDist = round(execTimePR_distributed[2][i] * 10)/10
        # timeGiraphDist = round(execTimePR_distributed[3][i] * 10)/10
        # timeGalois = round(execTimePR_singleNode[1][i] * 10)/10
        # timeGemini = round(execTimePR_singleNode[2][i] * 10)/10
        # timeGiraph = round(execTimePR_singleNode[3][i] * 10)/10
        print(timeGiraph/timeGiraphDist)

        print("&", graphs[i], "&", timeGalois, "&", timeGaloisDist, "&", timeGemini, "&", timeGeminiDist, "&", timeGiraph, "&", timeGiraphDist, "\\\\")


        # for j in range(len(frameworks)):
        #     if frameworks[j] == 'Ligra' or frameworks[j] == 'Polymer':
        #         continue
        #     print(graphs[i],frameworks[j], execTimeSSSP_singleNode[j][i])
        # for j in range(len(dist_frameworks_sssp)):
        #     if list(dist_frameworks_sssp.values())[j] == 'Galois Pull':
        #         continue
        #     print(graphs[i],list(dist_frameworks_sssp.values())[j], "dist", execTimeSSSP_distributed[j][i])










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
    if '-hp-' in algo[i]:
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
    if '-hp-' in algo[i]:
        continue

    tmp = re.sub('\D', '', algo[i])
    if '032' in tmp:
        continue # Werte mit vorangestellter 0 nicht werten
    xVal = int(tmp)
    
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
    maxs = []
    for g in graphs:
        if g == "flickr" or g == 'orkut':
            continue
        tmp = speedupGaloisBFS[g]
        print(g)
        last = 1
        xs = []
        for k in tmp:
            xs.append(k)
        xs.sort()
        tmps = []
        for k in xs:
            tmps.append(tmp[k])
            print(k, round(tmp[k]*10)/10)
        maxs.append(max(tmps))
        #print("inter: ", (tmp[32] - tmp[16])/(32-16) * (24-16) + tmp[16])
            #last = k
            #
        # for k in (16,32,40,48,96):
        #      print(k ,speedupGaloisSSSP[g][k])
    print(maxs)







###SPEEDUP GALOIS HP
speedupGaloisSSSP_HP = {}
speedupGaloisBFS_HP = {}
speedupGaloisPRPush_HP = {}
speedupGaloisPRPull_HP = {}


xHP = []
for g in graphs:
    speedupGaloisSSSP_HP[g] = {}
    speedupGaloisBFS_HP[g] = {}
    speedupGaloisPRPush_HP[g] = {}
    speedupGaloisPRPull_HP[g] = {}

for i in range(len(graph)):
    if not 'galois' in algo[i]:
        continue
    if '-dist' in algo[i]:
        continue
    if not '-hp-' in algo[i]:
        continue
    
    num = int(re.sub('\D', '', algo[i]))
    if not num in xHP:
        xHP.append(num)
xHP.sort()

for i in range(len(graph)):
    if not 'galois' in algo[i]:
        continue
    if '-dist' in algo[i]:
        continue
    if not '-hp-' in algo[i]:
        continue
    
    tmp = re.sub('\D', '', algo[i])
    xVal = int(tmp)
    
    if 'sssp' in algo[i]:
        if '032' in tmp:
            continue
        speedupGaloisSSSP_HP[graph[i]][xVal] = calcTime[i]
    elif 'bfs' in algo[i]:
        if '032' in tmp:
            continue
        speedupGaloisBFS_HP[graph[i]][xVal] = calcTime[i]
    elif 'pagerank-push' in algo[i]:
        if xVal == 32 and not '032' in tmp:
            continue
        speedupGaloisPRPush_HP[graph[i]][xVal] = calcTime[i]
    elif 'pagerank-pull' in algo[i]:
        if '032' in tmp:
            continue
        speedupGaloisPRPull_HP[graph[i]][xVal] = calcTime[i]



#print(speedupGaloisPRPush_HP)
# Calculations for speedup
for g in graphs:
    tSSSP = speedupGaloisSSSP_HP[g][1]
    tBFS = speedupGaloisBFS_HP[g][1]
    tPRPush = speedupGaloisPRPush_HP[g][1]
    tPRPull = speedupGaloisPRPull_HP[g][1]
    for x_ in xHP:
        speedupGaloisSSSP_HP[g][x_] = tSSSP / speedupGaloisSSSP_HP[g][x_]
        speedupGaloisBFS_HP[g][x_] = tBFS / speedupGaloisBFS_HP[g][x_]
        speedupGaloisPRPush_HP[g][x_] = tPRPush / speedupGaloisPRPush_HP[g][x_]
        speedupGaloisPRPull_HP[g][x_] = tPRPull / speedupGaloisPRPull_HP[g][x_]

# for g in graphs:
#     print(g, max([speedupGaloisPRPush[g][k] for k in xHP]))
    # print(g, max([speedupGaloisPRPush_HP[g][k] for k in xHP]))

if False:
    means_noHP = {}
    means_HP = {}
    vars_noHP = {}
    vars_HP = {}
    for xVal in xHP:
        pass
        #print(xVal,"&",xVal,end="&")
    #print("\\\\")
    for xVal in xHP:
        mean = 0
        for k in graphs:
            mean += speedupGaloisSSSP[k][xVal]
        mean /= len(graphs)
        #val = round(mean * 10)/ 10
        val = mean
        means_noHP[xVal] = val
        #print(val, end="&")

        variance = 0
        for k in graphs:
            variance += (speedupGaloisSSSP[k][xVal] - mean)**2
        variance /= len(graphs)
        variance = round(variance * 10) / 10
        vars_noHP[xVal] = variance
        #print(variance, end="&")

    print("\\\\")
    for xVal in xHP:
        meanHP = 0
        for k in graphs:
            meanHP += speedupGaloisSSSP_HP[k][xVal]
        meanHP /= len(graphs)
        #val = round(meanHP * 10)/ 10
        val = meanHP
        #print(val, end="&")
        means_HP[xVal] = val

        variance = 0
        for k in graphs:
            variance += (speedupGaloisSSSP_HP[k][xVal] - meanHP)**2
        variance /= len(graphs)
        variance = round(variance * 10)/ 10
        #print(variance, end="&")
        vars_HP[xVal] = variance


    print("\\\\")


    print()
    for x_ in xHP:
        print(vars_noHP[x_] > vars_HP[x_])

        print(x_,"&", means_noHP[x_],"&", means_HP[x_],"&", vars_noHP[x_],"&", vars_HP[x_],"\\\\")


    valuesForMeanSpeedup = {"Means no HP": means_noHP, "Means HP": means_HP, "Variances no HP": vars_noHP, "Variances HP": vars_HP}

    from plotFunctions import line_plot
    line_plot(["Means no HP", "Means HP", "Variances no HP", "Variances HP"], xHP, valuesForMeanSpeedup, yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="meanSpeedup.png")


if False:
    for g in graphs:
        maxSSSP_noHP = round(max([speedupGaloisSSSP[g][i] for i in x]) * 10) / 10
        maxSSSP_HP = round(max([speedupGaloisSSSP_HP[g][i] for i in xHP]) * 10) / 10

        maxBFS_noHP = round(max([speedupGaloisBFS[g][i] for i in x]) * 10) / 10
        maxBFS_HP = round(max([speedupGaloisBFS_HP[g][i] for i in xHP]) * 10) / 10

        print(g, end=" & ")

        if maxSSSP_HP > maxSSSP_noHP:
             print(maxSSSP_noHP, "& \\bf", maxSSSP_HP, end=" & ")
        else:
             print("\\bf", maxSSSP_noHP, "& ", maxSSSP_HP, end=" & ")
        if maxBFS_HP > maxBFS_noHP:
            print(maxBFS_noHP, "& \\bf", maxBFS_HP, "\\\\")
        else:
            print("\\bf", maxBFS_noHP, "&", maxBFS_HP, "\\\\")









#### TIMES GALOIS HUGEPAGES
calcTimeSSSP_HP = []
calcTimeBFS_HP = []
calcTimePRPull_HP = []
calcTimePRPush_HP = []

execTimeSSSP_HP = []
execTimeBFS_HP = []
execTimePRPull_HP = []
execTimePRPush_HP = []

for g in graphs:
    for i in range(len(graph)):
        if not "galois" in algo[i]:
            continue
        if not "-hp-" in algo[i]:
            continue
        if not "96thread" in algo[i]:
            continue

        if not g in graph[i]:
            continue

        if "sssp" in algo[i]:
            calcTimeSSSP_HP.append(calcTime[i])
            execTimeSSSP_HP.append(totalTime[i])
        elif "bfs" in algo[i]:
            calcTimeBFS_HP.append(calcTime[i])
            execTimeBFS_HP.append(totalTime[i])
        elif "pagerank-pull" in algo[i]:
            calcTimePRPull_HP.append(calcTime[i])
            execTimePRPull_HP.append(totalTime[i])
        elif "pagerank-push" in algo[i]:
            calcTimePRPush_HP.append(calcTime[i])
            execTimePRPush_HP.append(totalTime[i])
if False:
    calcTimeSSSP = calcTimeSSSP_singleNode[0]
    calcTimeBFS = calcTimeBFS_singleNode[0]
    calcTimePRPush = calcTimePR_singleNode[0]
    calcTimePRPull = calcTimePR_singleNode[1]

    execTimeSSSP = execTimeSSSP_singleNode[0]
    execTimeBFS = execTimeBFS_singleNode[0]
    execTimePRPush = execTimePR_singleNode[0]
    execTimePRPull = execTimePR_singleNode[1]
    for i in range(len(graphs)):
        print("&", graphs[i], end=" & ")
        if calcTimeSSSP[i] < calcTimeSSSP_HP[i]:
            print("\\bf", round(calcTimeSSSP[i] * 100) / 100,"&", round(calcTimeSSSP_HP[i] * 100) / 100, end=" & ")
        else:
            print(round(calcTimeSSSP[i] * 100) / 100,"& \\bf", round(calcTimeSSSP_HP[i] * 100) / 100, end=" & ")

        if execTimeSSSP[i] < execTimeSSSP_HP[i]:
            print("\\bf", round(execTimeSSSP[i] * 10) / 10,"&", round(execTimeSSSP_HP[i] * 10) / 10, end=" ")
        else:
            print(round(execTimeSSSP[i] * 10) / 10,"& \\bf", round(execTimeSSSP_HP[i] * 10) / 10, end=" ")

        print("\\\\")
    
    print("\\midrule")


    for i in range(len(graphs)):
        print("&", graphs[i], end=" & ")
        if calcTimeBFS[i] < calcTimeBFS_HP[i]:
            print("\\bf", round(calcTimeBFS[i] * 100) / 100,"&", round(calcTimeBFS_HP[i] * 100) / 100, end=" & ")
        else:
            print(round(calcTimeBFS[i] * 100) / 100,"& \\bf", round(calcTimeBFS_HP[i] * 100) / 100, end=" & ")

        if execTimeBFS[i] < execTimeBFS_HP[i]:
            print("\\bf", round(execTimeBFS[i] * 10) / 10,"&", round(execTimeBFS_HP[i] * 10) / 10, end=" ")
        else:
            print(round(execTimeBFS[i] * 10) / 10,"& \\bf", round(execTimeBFS_HP[i] * 10) / 10, end=" ")

        print("\\\\")
        
    print("\\midrule")

    for i in range(len(graphs)):
        print("&", graphs[i], end=" & ")
        if calcTimePRPush[i] < calcTimePRPush_HP[i]:
            print("\\bf", round(calcTimePRPush[i] * 1000) / 1000,"&", round(calcTimePRPush_HP[i] * 1000) / 1000, end=" & ")
        else:
            print(round(calcTimePRPush[i] * 1000) / 1000,"& \\bf", round(calcTimePRPush_HP[i] * 1000) / 1000, end=" & ")

        if execTimePRPush[i] < execTimePRPush_HP[i]:
            print("\\bf", round(execTimePRPush[i] * 10) / 10,"&", round(execTimePRPush_HP[i] * 10) / 10, end=" ")
        else:
            print(round(execTimePRPush[i] * 10) / 10,"& \\bf", round(execTimePRPush_HP[i] * 10) / 10, end=" ")

        print("\\\\")

    print("\\midrule")

    for i in range(len(graphs)):
        print("&", graphs[i], end=" & ")
        if calcTimePRPull[i] < calcTimePRPull_HP[i]:
            print("\\bf", round(calcTimePRPull[i] * 100) / 100,"&", round(calcTimePRPull_HP[i] * 100) / 100, end=" & ")
        else:
            print(round(calcTimePRPull[i] * 100) / 100,"& \\bf", round(calcTimePRPull_HP[i] * 100) / 100, end=" & ")

        if execTimePRPull[i] < execTimePRPull_HP[i]:
            print("\\bf", round(execTimePRPull[i] * 10) / 10,"&", round(execTimePRPull_HP[i] * 10) / 10, end=" ")
        else:
            print(round(execTimePRPull[i] * 10) / 10,"& \\bf", round(execTimePRPull_HP[i] * 10) / 10, end=" ")

        print("\\\\")
    print("\\bottomrule")
