
import numpy as np
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import matplotlib

#
# values = [[f1_g1,f1_g2,...],[f2_g1,f2_g2,...],...]
def grouped_bar_plot(group_names, legend_names, values, colors_=None, yErrs=None, width=0.35, scaleFactor=None, title='', yLabel='', yScale='log', saveToFile=None):
	group_count = len(group_names)

	if len(legend_names) != len(values):
		raise Exception("Size mismatch: Expected " + str(len(legend_names)) + " categories, got " + str(len(values)))

	if scaleFactor == None:
		scaleFactor = (len(legend_names) + 1.5) * width

	fig, ax = plt.subplots()

	ind = np.arange(group_count)

	ps = []
	i = 0
	for element in values:
		yErr = None
		if not yErrs == None:
			yErr = yErrs[i].copy()
			while group_count > len(yErr):
				yErr.append(float('nan'))
		tmp = element.copy()
		while group_count > len(tmp):
			tmp.append(float('nan'))

		if not colors_ == None:
			ps.append(ax.bar(scaleFactor * ind + i * width, tmp, width, yerr=yErr, bottom=0, color=colors_[legend_names[i]]))
		else:
			ps.append(ax.bar(scaleFactor * ind + i * width, tmp, width, yerr=yErr, bottom=0))
		i += 1

	ax.set_xticks(scaleFactor * ind + (len(legend_names)-1) / 2 * width)
	ax.set_xticklabels(group_names)
	if not yScale == None:
		ax.set_yscale(yScale)
	ax.set_title(title)
	ax.set_ylabel(yLabel)

	ax.legend(ps, legend_names)

	if saveToFile != None:
		plt.savefig(saveToFile, transparent=True)
	else:
		plt.show()


#
# values is a dictionary
def line_plot(legend_names, x, values, title='', yLabel='', xLabel='', yScale=None, saveToFile=None, ylim=None):

	if len(legend_names) != len(values):
		raise Exception("Size mismatch: Expected " + str(len(legend_names)) + " categories, got " + str(len(values)))

	fig, ax = plt.subplots()

	ps = []
	for element in legend_names: 
		x.sort()
		tmp = []
		for x_ in x:
			tmp.append(values[element][x_])

		l, = ax.plot(x, tmp, 'o--')
		ps.append(l)

	if yScale != None:
		ax.set_yscale(yScale)
	ax.set_title(title)
	ax.set_ylabel(yLabel)
	ax.set_xlabel(xLabel)
	if ylim != None:
		ax.set_ylim(ylim)

	
	ax.legend(ps, legend_names)

	if saveToFile != None:
		plt.savefig(saveToFile, transparent=True)
	else:
		plt.show()



