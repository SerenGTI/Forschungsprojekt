
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

plt.style.use('./style.mplstyle')

#[graph, algo, calc, exec]
data = []
with open('../results.txt') as f:
    for line in f:
        data.append([])
        for entry in line.split():
            data[-1].append(entry)

graph = np.empty(len(data), dtype=object)
algo = np.empty(len(data), dtype=object)
calcTime = np.empty(len(data))
totalTime = np.empty(len(data))

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



colors = ['tab:blue', 'tab:orange', 'tab:green', 'tab:red', 'tab:purple']

#sorted by size of graph
graphs = ('flickr', 'orkut', 'wikipedia', 'twitter', 'rMat27', 'friendster', 'rMat28')
#sorted alphabetically
frameworks = ('Galois', 'Gemini', 'Giraph', 'Ligra', 'Polymer')


calcTimesSSSPByFramework = []
execTimesSSSPByFramework = []

for f in frameworks:
	tmpExec = []
	tmpCalc = []
	fname = f.lower() + "-sssp"
	if f == 'Galois':
		fname += "-cpu-96thread"
	for g in graphs:
		for i in range(len(graph)):
			if g == graph[i] and fname == algo[i]:
				tmpCalc.append(calcTime[i])
				tmpExec.append(totalTime[i])
	calcTimesSSSPByFramework.append(tmpCalc)
	execTimesSSSPByFramework.append(tmpExec)


from plotFunctions import grouped_bar_plot

grouped_bar_plot(graphs, frameworks, calcTimesSSSPByFramework, title='Single-source Shortest-path on one calculation node', yLabel='Calculation times (s)', saveToFile="singleNodeSSSP.png")

