
from makedata import *
from plotFunctions import *



distributed = False
singleNode = False

sssp = False
bfs = False
pr = False

calcTimes = False
execTimes = False
overheads = False


galoisSpeedup = True


colors = {"Galois":"#1f77b4",
"Galois Push":"#1e2bb5",
"Galois Pull":"#1eb5a8",
"Gemini":"#ff7f0e",
"Giraph":"#2ca02c",
"Ligra":"#d62728",
"Polymer":"#9467bd",
"Polymer Delta":"#bc65bb"}

### PLOTS
#SINGLE NODE
if singleNode and ( sssp or bfs or pr or calcTimes or execTimes or overheads):
	## CALC TIME
	#SSSP
	if sssp or calcTimes:
		grouped_bar_plot(graphs, frameworks, calcTimeSSSP_singleNode, yErrs=yErrCalcSSSP_singleNode, yLabel='Calculation time (s)', saveToFile="singleNodeSSSP_calcTime.png", colors_=colors)

	#BFS
	if bfs or calcTimes:
		grouped_bar_plot(graphs, frameworks, calcTimeBFS_singleNode, yErrs=yErrCalcBFS_singleNode, yLabel='Calculation time (s)', saveToFile="singleNodeBFS_calcTime.png", colors_=colors)

	#PR
	if pr or calcTimes:
		grouped_bar_plot(graphs, list(singleNode_frameworks_pr.values()), calcTimePR_singleNode, yErrs=yErrCalcPR_singleNode, yLabel='Calculation time (s)', saveToFile="singleNodePR_calcTime.png", colors_=colors)




	## EXEC TIME
	#SSSP
	if sssp or execTimes:
		grouped_bar_plot(graphs, frameworks, execTimeSSSP_singleNode, yErrs=yErrExecSSSP_singleNode, yLabel='Execution time (s)', saveToFile="singleNodeSSSP_execTime.png", colors_=colors)

	#BFS
	if bfs or execTimes:
		grouped_bar_plot(graphs, frameworks, execTimeBFS_singleNode, yErrs=yErrExecBFS_singleNode, yLabel='Execution time (s)', saveToFile="singleNodeBFS_execTime.png", colors_=colors)

	#PR
	if pr or execTimes:
		grouped_bar_plot(graphs, list(singleNode_frameworks_pr.values()), execTimePR_singleNode, yErrs=yErrExecPR_singleNode, yLabel='Execution time (s)', saveToFile="singleNodePR_execTime.png", colors_=colors)






	## OVERHEAD
	#SSSP
	if sssp or overheads:
		grouped_bar_plot(graphs, frameworks, overheadSSSP_singleNode, yLabel='Overhead time (s)', saveToFile="singleNodeSSSP_overheadTime.png", colors_=colors)

		grouped_bar_plot(graphs, frameworks, overheadSSSPNormalized_singleNode, yLabel='Overhead time (s) (normalized)', saveToFile="singleNodeSSSP_overheadTimeNormalized.png", yScale='linear', colors_=colors)

	#BFS
	if bfs or overheads:
		grouped_bar_plot(graphs, frameworks, overheadBFS_singleNode, yLabel='Overhead time (s)', saveToFile="singleNodeBFS_overheadTime.png", colors_=colors)

		grouped_bar_plot(graphs, frameworks, overheadBFSNormalized_singleNode, yLabel='Overhead time (s) (normalized)', saveToFile="singleNodeBFS_overheadTimeNormalized.png", yScale='linear', colors_=colors)

	if pr or overheads:
		grouped_bar_plot(graphs, list(singleNode_frameworks_pr.values()), overheadPR_singleNode, yLabel='Overhead time (s)', saveToFile="singleNodePR_overheadTime.png", colors_=colors)

		grouped_bar_plot(graphs, list(singleNode_frameworks_pr.values()), overheadPRNormalized_singleNode, yLabel='Overhead time (s) (normalized)', saveToFile="singleNodePR_overheadTimeNormalized.png", yScale='linear', colors_=colors)





## GALOIS THREAD COUNT
if galoisSpeedup:
	line_plot(graphs, x, speedupGaloisSSSP, yLabel='Avg. calc time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeSSSPGaloisThreads.png", ylim=[0,20])

	line_plot(graphs, x, speedupGaloisBFS, yLabel='Avg. calc time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeBFSGaloisThreads.png", ylim=[0,11])

	line_plot(graphs, x, speedupGaloisPRPush, xLabel='Thread count', yLabel='Avg. calc time speedup', yScale='linear', saveToFile="singleNodePRPushGaloisThreads.png", ylim=[0.85,2.5])

	line_plot(graphs, x, speedupGaloisPRPull, yLabel='Avg. calc time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodePRPullGaloisThreads.png", ylim=[0.5,2.6])


## GALOIS HP THREAD COUNT
if galoisSpeedup:
	line_plot(graphs, xHP, speedupGaloisSSSP_HP, yLabel='Avg. calc time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeSSSPGaloisHPThreads.png", ylim=[0,20])

	line_plot(graphs, xHP, speedupGaloisBFS_HP, yLabel='Avg. calc time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodeBFSGaloisHPThreads.png", ylim=[0,11])

	line_plot(graphs, xHP, speedupGaloisPRPush_HP,  xLabel='Thread count', yLabel='Avg. calc time speedup', yScale='linear', saveToFile="singleNodePRPushGaloisHPThreads.png", ylim=[0.85,2.5])

	line_plot(graphs, xHP, speedupGaloisPRPull_HP, yLabel='Avg. calc time speedup', xLabel='Thread count', yScale='linear', saveToFile="singleNodePRPullGaloisHPThreads.png", ylim=[0.5,2.6])





#DISTRIBUTED
if distributed and ( sssp or bfs or pr or calcTimes or execTimes or overheads):
	## CALC TIME
	#SSSP


	if sssp or calcTimes:
		grouped_bar_plot(graphs, list(dist_frameworks_sssp.values()), calcTimeSSSP_distributed, yErrs=yErrCalcSSSP_distributed, yLabel='Calculation time (s)', saveToFile="distributedSSSP_calcTime.png", colors_=colors)

	#BFS
	if bfs or calcTimes:
		grouped_bar_plot(graphs, list(dist_frameworks_bfs.values()), calcTimeBFS_distributed, yErrs=yErrCalcBFS_distributed, yLabel='Calculation time (s)', saveToFile="distributedBFS_calcTime.png", colors_=colors)

	#PR
	if pr or calcTimes:
		grouped_bar_plot(graphs, list(dist_frameworks_pr.values()), calcTimePR_distributed, yErrs=yErrCalcPR_distributed, yLabel='Calculation time (s)', saveToFile="distributedPR_calcTime.png", colors_=colors)


	## EXEC TIME
	#SSSP
	if sssp or execTimes:
		grouped_bar_plot(graphs, list(dist_frameworks_sssp.values()), execTimeSSSP_distributed, yErrs=yErrExecSSSP_distributed, yLabel='Execution time (s)', saveToFile="distributedSSSP_execTime.png", colors_=colors)

	#BFS
	if bfs or execTimes:
		grouped_bar_plot(graphs, list(dist_frameworks_bfs.values()), execTimeBFS_distributed, yErrs=yErrExecBFS_distributed, yLabel='Execution time (s)', saveToFile="distributedBFS_execTime.png", colors_=colors)

	#PR
	if pr or calcTimes:
		grouped_bar_plot(graphs, list(dist_frameworks_pr.values()), execTimePR_distributed, yErrs=yErrExecPR_distributed, yLabel='Execution time (s)', saveToFile="distributedPR_execTime.png", colors_=colors)

	## OVERHEAD
	#SSSP
	if sssp or overheads:
		grouped_bar_plot(graphs, list(dist_frameworks_sssp.values()), overheadSSSP_distributed, yLabel='Overhead time (s)', saveToFile="distributedSSSP_overheadTime.png", colors_=colors)

		grouped_bar_plot(graphs, list(dist_frameworks_sssp.values()), overheadSSSPNormalized_distributed, yLabel='Overhead time (s) (normalized)', saveToFile="distributedSSSP_overheadTimeNormalized.png", yScale='linear', colors_=colors)

		grouped_bar_plot(graphs, list(dist_frameworks_sssp.values()), execTimeSSSP_distributed_normalizedToGalois, yLabel='Galois Push execution times', saveToFile="distributedSSSP_executionTimeNormalizedToGalois.png", yScale='log', colors_=colors)

	#BFS
	if bfs or overheads:
		grouped_bar_plot(graphs, list(dist_frameworks_bfs.values()), overheadBFS_distributed, yLabel='Overhead time (s)', saveToFile="distributedBFS_overheadTime.png", colors_=colors)

		grouped_bar_plot(graphs, list(dist_frameworks_bfs.values()), overheadBFSNormalized_distributed, yLabel='Overhead time (s) (normalized)', saveToFile="distributedBFS_overheadTimeNormalized.png", yScale='linear', colors_=colors)

	#PR
	if pr or overheads:
		grouped_bar_plot(graphs, list(dist_frameworks_pr.values()), overheadPR_distributed, yLabel='Overhead time (s)', saveToFile="distributedPR_overheadTime.png", colors_=colors)

		grouped_bar_plot(graphs, list(dist_frameworks_pr.values()), overheadPRNormalized_distributed, yLabel='Overhead time (s) (normalized)', saveToFile="distributedPR_overheadTimeNormalized.png", yScale='linear', colors_=colors)

