
import numpy as np
import matplotlib.pyplot as plt
import matplotlib


#
# values = [[f1_g1,f1_g2,...],[f2_g1,f2_g2,...],...]
def grouped_bar_plot(group_names, legend_names, values, colors=None, width=0.35, scaleFactor=None, title='', yLabel='', yScale='log', saveToFile=None):
	group_count = len(group_names)

	if len(legend_names) != len(values):
		raise "Size mismatch: Expected " + len(legend_names) + " categories, got " + len(values)


	if scaleFactor == None:
		scaleFactor = group_count / len(legend_names) + 1

	fig, ax = plt.subplots()

	ind = np.arange(group_count)

	ps = []
	i = 0
	for element in values: 
		tmp = element.copy()
		while group_count > len(tmp):
			tmp.append(float('nan'))
		ps.append(ax.bar(scaleFactor * ind + i * width, tmp, width, bottom=0))
		i += 1

	ax.set_xticks(scaleFactor * ind + (len(legend_names)-1) / 2 * width)
	ax.set_xticklabels(group_names)
	ax.set_yscale(yScale)
	ax.set_title(title)
	ax.set_ylabel(yLabel)

	ax.legend(ps, legend_names)

	if saveToFile != None:
		plt.savefig(saveToFile)
	else:
		plt.show()



