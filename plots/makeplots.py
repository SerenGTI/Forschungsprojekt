
from makedata import *
from plotFunctions import *



distributed = False
singleNode = True

sssp = False
bfs = False
pr = True

calcTimes = False
execTimes = False
overheads = False


galoisSpeedup = False

### PLOTS
#SINGLE NODE
if singleNode and ( sssp or bfs or pr or calcTimes or execTimes or overheads):
	## CALC TIME
	#SSSP
	if sssp or calcTimes:
		grouped_bar_plot(graphs, frameworks, calcTimeSSSP_singleNode, yErrs=yErrCalcSSSP_singleNode, title='SSSP single node', yLabel='Calculation time (s)', saveToFile="singleNodeSSSP_calcTime.png")

	#BFS
	if bfs or calcTimes:
		grouped_bar_plot(graphs, frameworks, calcTimeBFS_singleNode, yErrs=yErrCalcBFS_singleNode, title='BFS single node', yLabel='Calculation time (s)', saveToFile="singleNodeBFS_calcTime.png")

	if pr or calcTimes:
		grouped_bar_plot(graphs, singleNode_frameworks_pr.values(), calcTimePR_singleNode, yErrs=yErrCalcPR_singleNode, title='PR single node (ugly)', yLabel='Calculation time (s)', saveToFile="singleNodePR_calcTime.png", scaleFactor=3.25)




	## EXEC TIME
	#SSSP
	if sssp or execTimes:
		grouped_bar_plot(graphs, frameworks, execTimeSSSP_singleNode, yErrs=yErrExecSSSP_singleNode, title='SSSP single node', yLabel='Execution time (s)', saveToFile="singleNodeSSSP_execTime.png")

	#BFS
	if bfs or execTimes:
		grouped_bar_plot(graphs, frameworks, execTimeBFS_singleNode, yErrs=yErrExecBFS_singleNode, title='BFS single node', yLabel='Execution time (s)', saveToFile="singleNodeBFS_execTime.png")

	if pr or execTimes:
		grouped_bar_plot(graphs, singleNode_frameworks_pr.values(), execTimePR_singleNode, yErrs=yErrExecPR_singleNode, title='PR single node (ugly)', yLabel='Execution time (s)', saveToFile="singleNodePR_execTime.png")






	## OVERHEAD
	#SSSP
	if sssp or overheads:
		grouped_bar_plot(graphs, frameworks, overheadSSSP_singleNode, title='Overhead time of each framework during SSSP', yLabel='Overhead time (s)', saveToFile="singleNodeSSSP_overheadTime.png")

		grouped_bar_plot(graphs, frameworks, overheadSSSPNormalized_singleNode, title='SSSP single node', yLabel='Overhead time (s) (normalized)', saveToFile="singleNodeSSSP_overheadTimeNormalized.png", yScale='linear')

	#BFS
	if bfs or overheads:
		grouped_bar_plot(graphs, frameworks, overheadBFS_singleNode, title='Overhead time of each framework during BFS', yLabel='Overhead time (s)', saveToFile="singleNodeBFS_overheadTime.png")

		grouped_bar_plot(graphs, frameworks, overheadBFSNormalized_singleNode, title='BFS single node', yLabel='Overhead time (s) (normalized)', saveToFile="singleNodeBFS_overheadTimeNormalized.png", yScale='linear')

	if pr or overheads:
		grouped_bar_plot(graphs, singleNode_frameworks_pr.values(), overheadPR_singleNode, title='Overhead time of each framework during PR', yLabel='Overhead time (s)', saveToFile="singleNodePR_overheadTime.png", scaleFactor=3.25)

		grouped_bar_plot(graphs, singleNode_frameworks_pr.values(), overheadPRNormalized_singleNode, title='PR single node', yLabel='Overhead time (s) (normalized)', saveToFile="singleNodePR_overheadTimeNormalized.png", yScale='linear', scaleFactor=3.25)





## GALOIS THREAD COUNT
if galoisSpeedup:
	line_plot(graphs, x, speedupGaloisSSSP, yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeSSSPGaloisThreads.png")

	line_plot(graphs, x[:-5], speedupGaloisSSSP, title='Speedup SSSP', yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeSSSPGaloisThreads_short.png")

	line_plot(graphs, x, speedupGaloisBFS, title='SpeedupBFS', yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeBFSGaloisThreads.png")

	line_plot(graphs, x, speedupGaloisPRPush, title='Speedup PR Push', xLabel='Thread count', yScale='linear', saveToFile="singleNodePRPushGaloisThreads.png")

	line_plot(graphs, x, speedupGaloisPRPull, title='Speedup PR Pull', yLabel='Average calculation time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodePRPullGaloisThreads.png")





#DISTRIBUTED
if distributed and ( sssp or bfs or pr or calcTimes or execTimes or overheads):
	## CALC TIME
	#SSSP

	if sssp or calcTimes:
		grouped_bar_plot(graphs, dist_frameworks_sssp.values(), calcTimeSSSP_distributed, yErrs=yErrCalcSSSP_distributed, yLabel='Calculation time (s)', saveToFile="distributedSSSP_calcTime.png")

	#BFS
	if bfs or calcTimes:
		grouped_bar_plot(graphs, dist_frameworks_bfs.values(), calcTimeBFS_distributed, yErrs=yErrCalcBFS_distributed, yLabel='Calculation time (s)', saveToFile="distributedBFS_calcTime.png")

	#PR
	if pr or calcTimes:
		grouped_bar_plot(graphs, dist_frameworks_pr.values(), calcTimePR_distributed, yErrs=yErrCalcPR_distributed, yLabel='Calculation time (s)', saveToFile="distributedPR_calcTime.png")


	## EXEC TIME
	#SSSP
	if sssp or execTimes:
		grouped_bar_plot(graphs, dist_frameworks_sssp.values(), execTimeSSSP_distributed, yErrs=yErrExecSSSP_distributed, yLabel='Execution time (s)', saveToFile="distributedSSSP_execTime.png")

	#BFS
	if bfs or execTimes:
		grouped_bar_plot(graphs, dist_frameworks_bfs.values(), execTimeBFS_distributed, yErrs=yErrExecBFS_distributed, yLabel='Execution time (s)', saveToFile="distributedBFS_execTime.png")

	#PR
	if pr or calcTimes:
		grouped_bar_plot(graphs, dist_frameworks_pr.values(), execTimePR_distributed, yErrs=yErrExecPR_distributed, yLabel='Calculation time (s)', saveToFile="distributedPR_execTime.png")

	## OVERHEAD
	#SSSP
	if sssp or overheads:
		grouped_bar_plot(graphs, dist_frameworks_sssp.values(), overheadSSSP_distributed, title='Overhead time of each framework during SSSP', yLabel='Overhead time (s)', saveToFile="distributedSSSP_overheadTime.png")

		grouped_bar_plot(graphs, dist_frameworks_sssp.values(), overheadSSSPNormalized_distributed, title='SSSP distributed', yLabel='Overhead time (s) (normalized)', saveToFile="distributedSSSP_overheadTimeNormalized.png", yScale='linear')

		grouped_bar_plot(graphs, dist_frameworks_sssp.values(), overheadSSSP_distributed_normalizedToGalois, yLabel='Galois Push overhead times', saveToFile="distributedSSSP_overheadTimeNormalizedToGalois.png", yScale='linear')

	#BFS
	if bfs or overheads:
		grouped_bar_plot(graphs, dist_frameworks_bfs.values(), overheadBFS_distributed, title='Overhead time of each framework during BFS', yLabel='Overhead time (s)', saveToFile="distributedBFS_overheadTime.png")

		grouped_bar_plot(graphs, dist_frameworks_bfs.values(), overheadBFSNormalized_distributed, title='BFS distributed', yLabel='Overhead time (s) (normalized)', saveToFile="distributedBFS_overheadTimeNormalized.png", yScale='linear')

	#PR
	if pr or overheads:
		grouped_bar_plot(graphs, dist_frameworks_pr.values(), overheadPR_distributed, title='Overhead time of each framework during PR', yLabel='Overhead time (s)', saveToFile="distributedPR_overheadTime.png")

		grouped_bar_plot(graphs, dist_frameworks_pr.values(), overheadPRNormalized_distributed, title='PR distributed', yLabel='Overhead time (s) (normalized)', saveToFile="distributedPR_overheadTimeNormalized.png", yScale='linear')

