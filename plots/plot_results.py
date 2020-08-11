import numpy as np
import matplotlib.pyplot as plt
import matplotlib
plt.rcParams["figure.figsize"] = (10,10)

colors = ['tab:blue', 'tab:orange', 'tab:green', 'tab:red', 'tab:purple', 'tab:brown', 'tab:pink', 'tab:gray', 'tab:olive', 'tab:cyan', 'navy', 'indigo', 'black']
scale = 'log'

def toNumpyArrays(array):
    graph = np.empty(len(array), dtype=object)
    algo = np.empty(len(array), dtype=object)
    calcTime = np.empty(len(array))
    totalTime = np.empty(len(array))

    for i in range(len(array)):
        graph[i] = array[i][0]
        algo[i] = array[i][1]
        try:
            calcTime[i] = float(array[i][2])
        except ValueError:
            calcTime[i] = float('nan')
        try:
            totalTime[i] = float(array[i][3])
        except ValueError:
            totalTime[i] = float('nan')
    
    return graph, algo, calcTime, totalTime

def plotAlgosOnePlot(plot, x, y, color):
    index = 0
    for g in np.unique(color):
        i = np.where(color == g)
        plot.scatter(x[i], y[i], color=colors[index], label=g)
        index += 1
    plot.legend()
    plt.yscale(scale)

def plotAlgosTwoPlots(plot, x, y, color):
    fig, (ax1, ax2) = plot.subplots(2)
    
    index = 0
    i = np.where(np.logical_or(x == 'flickr', np.logical_or(x == 'orkut', x == 'wikipedia')))
    x1 = x[i]
    c1 = color[i]
    y1 = y[i]
    for g in np.unique(c1):
        i = np.where(c1 == g)
        ax1.scatter(x1[i], y1[i], color=colors[index], label=g)
        index += 1
    ax1.legend()
    ax1.set_yscale(scale)

    index = 0
    i = np.where(np.logical_or(x == 'rMat28', np.logical_or(x == 'rMat27', np.logical_or(x == 'twitter', x == 'friendster'))))
    x1 = x[i]
    c1 = color[i]
    y1 = y[i]
    for g in np.unique(c1):
        i = np.where(c1 == g)
        ax2.scatter(x1[i], y1[i], color=colors[index], label=g)
        index += 1
    ax1.legend()
    ax2.set_yscale(scale)
    

data = []

with open('../results.txt') as f:
    for line in f:
        data.append([])
        for entry in line.split():
            data[-1].append(entry)

algorithms = ['bfs', 'pagerank', 'sssp']
algorithmData = {}

for algorithm in algorithms:
    algorithmData[algorithm] = []
    for entry in data:
        if algorithm in entry[1]: #and ('1' in entry[1] or '4' in entry[1] or '9' in entry[1]):
            #if '1t' in entry[1]:
            #    entry[1] = '1'
            #elif '48t' in entry[1]:
            #    entry[1] = '48'
            #elif '96t' in entry[1]:
            #    entry[1] = '96'
            algorithmData[algorithm].append(entry)

#for algorithm in algorithms:
if True:
    graph, algo, calcTime, _ = toNumpyArrays(algorithmData[algorithm])
    plotAlgosTwoPlots(plt, graph, calcTime, algo)
    plt.savefig('{}_{}_galois.png'.format(algorithm, scale), dpi=300)
    #for g in np.unique(graph):
    #    norm = calcTime[np.where(np.logical_and(graph==g, algo=='1'))[0][0]]
    #    i = np.where(graph==g)
    #    calcTime[i] = calcTime[i] / norm
    #plotAlgosOnePlot(plt, algo.astype(np.int), calcTime, graph)
    #plt.savefig('{}_galois.png'.format(algorithm), dpi=300)
# plt.show()