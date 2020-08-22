
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


def insertAt(idx, val, list):
    if idx < 0:
        return
    if idx >= len(list):
        while idx > len(list):
            list.append(float('nan'))
        list.append(val)
        return
    else:
        list[idx] = val
        return 


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



#### SSSP TIMES
calcTimesSSSPByFramework = []
yErrCalcSSSPByFramework = []

execTimesSSSPByFramework = []
yErrExecSSSPByFramework = []

overheadTimesSSSPByFramework = []
overheadTimesSSSPByFrameworkNormalized = []
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
	k = 0
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

	calcTimesSSSPByFramework.append(tmpCalc)
	yErrCalcSSSPByFramework.append(tmpYErrCalc)
	execTimesSSSPByFramework.append(tmpExec)
	yErrExecSSSPByFramework.append(tmpYErrExec)
	overheadTimesSSSPByFramework.append(overhead)
	overheadTimesSSSPByFrameworkNormalized.append(overheadNormalized)

#### BFS TIMES

calcTimesBFSByFramework = []
yErrCalcBFSByFramework = []

execTimesBFSByFramework = []
yErrExecBFSByFramework = []

overheadTimesBFSByFramework = []
overheadTimesBFSByFrameworkNormalized = []
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
	k = 0
	for g in graphs:
		for i in range(len(graph)):
			if g == graph[i] and fname == algo[i]:
				tmpCalc.append(calcTime[i])
				tmpYErrCalc.append(sqrt(yErrCalc[i]))

				tmpExec.append(totalTime[i])
				tmpYErrExec.append(sqrt(yErrExec[i]))

				overhead.append(totalTime[i] - calcTime[i])
				overheadNormalized.append((totalTime[i] - calcTime[i])/graphSize[k])
		k += 1 # graph index

	calcTimesBFSByFramework.append(tmpCalc)
	yErrCalcBFSByFramework.append(tmpYErrCalc)
	execTimesBFSByFramework.append(tmpExec)
	yErrExecBFSByFramework.append(tmpYErrExec)
	overheadTimesBFSByFramework.append(overhead)
	overheadTimesBFSByFrameworkNormalized.append(overheadNormalized)



### GALOIS CALC TIME/THREAD COUNT
speedupSSSPGaloisByCPUCount = {}
speedupBFSGaloisByCPUCount = {}
speedupPRPushGaloisByCPUCount = {}
speedupPRPullGaloisByCPUCount = {}
x = []
for g in graphs:
	speedupSSSPGaloisByCPUCount[g] = []
	speedupBFSGaloisByCPUCount[g] = []
	speedupPRPushGaloisByCPUCount[g] = []
	speedupPRPullGaloisByCPUCount[g] = []

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

	for j in range(len(x)):
		if xVal == x[j]:
			if 'sssp' in algo[i]:
				insertAt(j, sqrt(calcTime[i]), speedupSSSPGaloisByCPUCount[graph[i]])
			elif 'bfs' in algo[i]:
				insertAt(j, sqrt(calcTime[i]), speedupBFSGaloisByCPUCount[graph[i]])
			elif 'pagerank-push' in algo[i]:
				insertAt(j, sqrt(calcTime[i]), speedupPRPushGaloisByCPUCount[graph[i]])
			elif 'pagerank-pull' in algo[i]:
				insertAt(j, sqrt(calcTime[i]), speedupPRPullGaloisByCPUCount[graph[i]])
			break

# Calculations for speedup
for g in graphs:
	tSSSP = speedupSSSPGaloisByCPUCount[g][0]
	tBFS = speedupBFSGaloisByCPUCount[g][0]
	tPRPush = speedupPRPushGaloisByCPUCount[g][0]
	tPRPull = speedupPRPullGaloisByCPUCount[g][0]
	for i in range(len(speedupSSSPGaloisByCPUCount[g])):
		speedupSSSPGaloisByCPUCount[g][i] = tSSSP / speedupSSSPGaloisByCPUCount[g][i]
		speedupBFSGaloisByCPUCount[g][i] = tBFS / speedupBFSGaloisByCPUCount[g][i]
		speedupPRPushGaloisByCPUCount[g][i] = tPRPush / speedupPRPushGaloisByCPUCount[g][i]
		speedupPRPullGaloisByCPUCount[g][i] = tPRPull / speedupPRPullGaloisByCPUCount[g][i]


### PLOTS


from plotFunctions import *

## CALC TIME
#SSSP
if True:
	grouped_bar_plot(graphs, frameworks, calcTimesSSSPByFramework, yErrs=yErrCalcSSSPByFramework, title='SSSP single node', yLabel='Calculation time (s)', saveToFile="singleNodeSSSP_calcTime.png")

#BFS
if True:
	grouped_bar_plot(graphs, frameworks, calcTimesBFSByFramework, yErrs=yErrCalcBFSByFramework, title='BFS single node', yLabel='Calculation time (s)', saveToFile="singleNodeBFS_calcTime.png")

## EXEC TIME
#SSSP
if True:
	grouped_bar_plot(graphs, frameworks, execTimesSSSPByFramework, yErrs=yErrExecSSSPByFramework, title='SSSP single node', yLabel='Execution time (s)', saveToFile="singleNodeSSSP_execTime.png")

#BFS
if True:
	grouped_bar_plot(graphs, frameworks, execTimesBFSByFramework, yErrs=yErrExecBFSByFramework, title='BFS single node', yLabel='Execution time (s)', saveToFile="singleNodeBFS_execTime.png")

## OVERHEAD
#SSSP
if True:
	grouped_bar_plot(graphs, frameworks, overheadTimesSSSPByFramework, title='Overhead time of each framework during SSSP', yLabel='Overhead time (s)', saveToFile="singleNodeSSSP_overheadTime.png")

	grouped_bar_plot(graphs, frameworks, overheadTimesSSSPByFrameworkNormalized, title='SSSP single node', yLabel='Overhead time (s) (normalized)', saveToFile="singleNodeSSSP_overheadTimeNormalized.png", yScale='linear')

#BFS
if True:
	grouped_bar_plot(graphs, frameworks, overheadTimesBFSByFramework, title='Overhead time of each framework during BFS', yLabel='Overhead time (s)', saveToFile="singleNodeBFS_overheadTime.png")

	grouped_bar_plot(graphs, frameworks, overheadTimesBFSByFrameworkNormalized, title='BFS single node', yLabel='Overhead time (s) (normalized)', saveToFile="singleNodeBFS_overheadTimeNormalized.png", yScale='linear')

## GALOIS THREAD COUNT
if True:
	line_plot(graphs, x, speedupSSSPGaloisByCPUCount, title='Speedup SSSP', yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeSSSPGaloisThreads.png")

	line_plot(graphs, x, speedupBFSGaloisByCPUCount, title='SpeedupBFS', yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeBFSGaloisThreads.png")

	line_plot(graphs, x, speedupPRPushGaloisByCPUCount, title='Speedup PR Push', xLabel='Thread count', yScale='linear', saveToFile="singleNodePRPushGaloisThreads.png")

	line_plot(graphs, x, speedupPRPullGaloisByCPUCount, title='Speedup PR Pull', yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodePRPullGaloisThreads.png")
