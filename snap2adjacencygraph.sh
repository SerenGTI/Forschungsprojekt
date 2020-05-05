#!/bin/bash

sourceFile=$1
targetFile=$2
currentNode=0
numberOfEdges=$(grep '[0-9]' $sourceFile | wc -l)
offset=0
biggestNumber=$(grep -Eo '[0-9]+' $sourceFile | sort -rn | head -n 1)
# initialize the output file
echo "AdjacencyGraph" > $targetFile
echo "to be replaced by the number of nodes" >> $targetFile
echo $numberOfEdges >> $targetFile

for (( currentNode = 0; currentNode <= $biggestNumber; currentNode++ ))
do
    pattern="^${currentNode}[[:space:]]"
    offset=$(( $offset + $(grep "$pattern" $sourceFile | wc -l) ))
    echo $offset >> $targetFile
done

sed -i "2s/.*/$currentNode/" $targetFile

for (( activeNode = 0; activeNode <= $currentNode; activeNode++ ))
do
    pattern="^${activeNode}[[:space:]]"
    edgesOfActiveNode=$(grep "$pattern" $sourceFile)
    antiPattern="${activeNode} "
    # removes the source nodes
    edgesOfActiveNode="${edgesOfActiveNode//$antiPattern}"
    if ! [[ -z $edgesOfActiveNode ]];
    then
        echo "$edgesOfActiveNode" >> $targetFile
    fi
done
