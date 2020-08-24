
import numpy as np
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import matplotlib

#
# values = [[f1_g1,f1_g2,...],[f2_g1,f2_g2,...],...]
def grouped_bar_plot(group_names, legend_names, values, yErrs=None, width=0.35, scaleFactor=None, title='', yLabel='', yScale='log', saveToFile=None):
	group_count = len(group_names)

	if len(legend_names) != len(values):
		raise Exception("Size mismatch: Expected " + str(len(legend_names)) + " categories, got " + str(len(values)))


	if scaleFactor == None:
		scaleFactor = group_count / len(legend_names) + 1

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
		plt.savefig(saveToFile)
	else:
		plt.show()


#
# values is a dictionary
def line_plot(legend_names, x, values, yErrs=None, title='', yLabel='', xLabel='', yScale=None, saveToFile=None):

	if len(legend_names) != len(values):
		raise Exception("Size mismatch: Expected " + str(len(legend_names)) + " categories, got " + str(len(values)))

	fig, ax = plt.subplots()

	ps = []
	for element in legend_names: 
		tmp = values[element].copy()
		yErr = None
		if not yErrs == None:
			yErr = yErrs[element].copy()
			while len(x) > len(yErr):
				yErr.append(float('nan'))
		while len(x) > len(tmp):
			tmp.append(float('nan'))

		if not yErr == None:
			l = ax.errorbar(x, tmp, yerr=yErr, fmt='--o')
			ps.append(l)
		else:
			l, = ax.plot(x, tmp, 'o--')
			ps.append(l)

	if yScale != None:
		ax.set_yscale(yScale)
	ax.set_title(title)
	ax.set_ylabel(yLabel)
	ax.set_xlabel(xLabel)

	
	ax.legend(ps, legend_names)

	if saveToFile != None:
		plt.savefig(saveToFile)
	else:
		plt.show()



