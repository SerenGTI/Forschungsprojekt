
import numpy as np
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import matplotlib

plt.style.use('./style.mplstyle')


graphs = ('flickr', 'orkut', 'wikipedia', 'twitter', 'rMat27', 'friendster', 'rMat28')
vals = [2, 117, 378, 1963, 2147, 2586, 4294];



fig, ax = plt.subplots()


ax.bar(graphs, vals, 0.4)
	


ax.set_xticklabels(graphs, rotation=-45)
ax.set_yscale("linear")
ax.set_title("")
ax.set_ylabel("# of edges (Million)")

saveToFile = "graphsize.png"
if saveToFile != None:
	plt.savefig(saveToFile, transparent=True)
else:
	plt.show()






