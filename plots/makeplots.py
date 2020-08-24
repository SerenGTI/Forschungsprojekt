
from makedata import *
from plotFunctions import *



distributed = True
singleNode = True

galoisSpeedup = True

sssp = True
bfs = True
pr = True


### PLOTS



#SINGLE NODE
if singleNode:
	## CALC TIME
	#SSSP
	if sssp:
		grouped_bar_plot(graphs, frameworks, calcTimeSSSP_singleNode, yErrs=yErrCalcSSSP_singleNode, title='SSSP single node', yLabel='Calculation time (s)', saveToFile="singleNodeSSSP_calcTime.png")

	#BFS
	if bfs:
		grouped_bar_plot(graphs, frameworks, calcTimeBFS_singleNode, yErrs=yErrCalcBFS_singleNode, title='BFS single node', yLabel='Calculation time (s)', saveToFile="singleNodeBFS_calcTime.png")

	## EXEC TIME
	#SSSP
	if sssp:
		grouped_bar_plot(graphs, frameworks, execTimeSSSP_singleNode, yErrs=yErrExecSSSP_singleNode, title='SSSP single node', yLabel='Execution time (s)', saveToFile="singleNodeSSSP_execTime.png")

	#BFS
	if bfs:
		grouped_bar_plot(graphs, frameworks, execTimeBFS_singleNode, yErrs=yErrExecBFS_singleNode, title='BFS single node', yLabel='Execution time (s)', saveToFile="singleNodeBFS_execTime.png")

	## OVERHEAD
	#SSSP
	if sssp:
		grouped_bar_plot(graphs, frameworks, overheadSSSP_singleNode, title='Overhead time of each framework during SSSP', yLabel='Overhead time (s)', saveToFile="singleNodeSSSP_overheadTime.png")

		grouped_bar_plot(graphs, frameworks, overheadSSSPNormalized_singleNode, title='SSSP single node', yLabel='Overhead time (s) (normalized)', saveToFile="singleNodeSSSP_overheadTimeNormalized.png", yScale='linear')

	#BFS
	if bfs:
		grouped_bar_plot(graphs, frameworks, overheadBFS_singleNode, title='Overhead time of each framework during BFS', yLabel='Overhead time (s)', saveToFile="singleNodeBFS_overheadTime.png")

		grouped_bar_plot(graphs, frameworks, overheadBFSNormalized_singleNode, title='BFS single node', yLabel='Overhead time (s) (normalized)', saveToFile="singleNodeBFS_overheadTimeNormalized.png", yScale='linear')

	## GALOIS THREAD COUNT
	if galoisSpeedup:
		line_plot(graphs, x, speedupGaloisSSSP, title='Speedup SSSP', yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeSSSPGaloisThreads.png")

		line_plot(graphs, x, speedupGaloisBFS, title='SpeedupBFS', yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeBFSGaloisThreads.png")

		line_plot(graphs, x, speedupGaloisPRPush, title='Speedup PR Push', xLabel='Thread count', yScale='linear', saveToFile="singleNodePRPushGaloisThreads.png")

		line_plot(graphs, x, speedupGaloisPRPull, title='Speedup PR Pull', yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodePRPullGaloisThreads.png")





#DISTRIBUTED
if distributed:
	## CALC TIME
	#SSSP

	if sssp:
		grouped_bar_plot(graphs, dist_frameworks_sssp.values(), calcTimeSSSP_distributed, yErrs=yErrCalcSSSP_distributed, title='SSSP distributed', yLabel='Calculation time (s)', saveToFile="distributedSSSP_calcTime.png")

	#BFS
	if bfs:
		grouped_bar_plot(graphs, dist_frameworks_bfs.values(), calcTimeBFS_distributed, yErrs=yErrCalcBFS_distributed, title='BFS distributed', yLabel='Calculation time (s)', saveToFile="distributedBFS_calcTime.png")

	## EXEC TIME
	#SSSP
	if sssp:
		grouped_bar_plot(graphs, dist_frameworks_sssp.values(), execTimeSSSP_distributed, yErrs=yErrExecSSSP_distributed, title='SSSP distributed', yLabel='Execution time (s)', saveToFile="distributedSSSP_execTime.png")

	#BFS
	if bfs:
		grouped_bar_plot(graphs, dist_frameworks_bfs.values(), execTimeBFS_distributed, yErrs=yErrExecBFS_distributed, title='BFS distributed', yLabel='Execution time (s)', saveToFile="distributedBFS_execTime.png")

	## OVERHEAD
	#SSSP
	if sssp:
		grouped_bar_plot(graphs, dist_frameworks_sssp.values(), overheadSSSP_distributed, title='Overhead time of each framework during SSSP', yLabel='Overhead time (s)', saveToFile="distributedSSSP_overheadTime.png")

		grouped_bar_plot(graphs, dist_frameworks_sssp.values(), overheadSSSPNormalized_distributed, title='SSSP distributed', yLabel='Overhead time (s) (normalized)', saveToFile="distributedSSSP_overheadTimeNormalized.png", yScale='linear')

	#BFS
	if bfs:
		grouped_bar_plot(graphs, dist_frameworks_bfs.values(), overheadBFS_distributed, title='Overhead time of each framework during BFS', yLabel='Overhead time (s)', saveToFile="distributedBFS_overheadTime.png")

		grouped_bar_plot(graphs, dist_frameworks_bfs.values(), overheadBFSNormalized_distributed, title='BFS distributed', yLabel='Overhead time (s) (normalized)', saveToFile="distributedBFS_overheadTimeNormalized.png", yScale='linear')

