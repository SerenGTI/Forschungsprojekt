
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
from math import sqrt
plt.style.use('./style.mplstyle')


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



#[graph, algo, calc, exec]
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
        yErrCalc[i] = float(data[i][4])
    except ValueError:
        yErrCalc[i] = float('nan')
    try:
        yErrExec[i] = float(data[i][5])
    except ValueError:
        yErrExec[i] = float('nan')



#sorted by size of graph
graphs = ('flickr', 'orkut', 'wikipedia', 'twitter', 'rMat27', 'friendster', 'rMat28')
#sorted alphabetically
frameworks = ('Galois', 'Gemini', 'Giraph', 'Ligra', 'Polymer')


calcTimesSSSPByFramework = []
yErrCalcSSSPByFramework = []

execTimesSSSPByFramework = []
yErrExecSSSPByFramework = []
for f in frameworks:
	tmpExec = []
	tmpCalc = []
	tmpYErrCalc = []
	tmpYErrExec = []
	fname = f.lower() + "-sssp"
	if f == 'Galois':
		fname += "-cpu-96thread" # select Galois thread count here
	for g in graphs:
		for i in range(len(graph)):
			if g == graph[i] and fname == algo[i]:
				tmpCalc.append(calcTime[i])
				tmpYErrCalc.append(sqrt(yErrCalc[i]))

				tmpExec.append(totalTime[i])
				tmpYErrExec.append(sqrt(yErrExec[i]))
	calcTimesSSSPByFramework.append(tmpCalc)
	yErrCalcSSSPByFramework.append(tmpYErrCalc)
	execTimesSSSPByFramework.append(tmpExec)
	yErrExecSSSPByFramework.append(tmpYErrExec)



calcTimesGaloisByCPUCount = {}
yErrsGaloisByCPUCount = {}
x = []
for i in range(len(graph)):
    if not 'galois-sssp' in algo[i]:
        continue
    if '-dist' in algo[i]:
        continue

    if not graph[i] in calcTimesGaloisByCPUCount:
        calcTimesGaloisByCPUCount[graph[i]] = []
        yErrsGaloisByCPUCount[graph[i]] = []

    xVal = int(algo[i][16:-6]) # galois-sssp- und thread abschneiden
    if not xVal in x:
        x.append(xVal)

x.sort()
for i in range(len(graph)):
    if not 'galois-sssp' in algo[i]:
        continue
    if '-dist' in algo[i]:
        continue

    xVal = int(algo[i][16:-6])

    idx = -1
    for j in range(len(x)):
        if xVal == x[j]:
            insertAt(j, sqrt(calcTime[i]), calcTimesGaloisByCPUCount[graph[i]])
            insertAt(j, sqrt(yErrCalc[i]), yErrsGaloisByCPUCount[graph[i]])




from plotFunctions import *

grouped_bar_plot(graphs, frameworks, calcTimesSSSPByFramework, yErrs=yErrCalcSSSPByFramework, title='Single-source Shortest-path on one calculation node with standard deviation', yLabel='Calculation time (s)', saveToFile="singleNodeSSSP_calcTime.png")

grouped_bar_plot(graphs, frameworks, execTimesSSSPByFramework, yErrs=yErrExecSSSPByFramework, title='Single-source Shortest-path on one calculation node with standard deviation', yLabel='Execution time (s)', saveToFile="singleNodeSSSP_execTime.png")

line_plot(graphs, x, calcTimesGaloisByCPUCount, title='Galois Single-source Shortest-path times by thread count with standard deviation', yErrs=yErrsGaloisByCPUCount, yLabel='Calculation times (s)', xLabel='Thread count', yScale='log', saveToFile="singleNodeSSSPGaloisThreads.png")
