#!/bin/bash

sourceFile=$1
targetFile=$2
currentNode=0
numberOfEdges=$(grep '[0-9]' $sourceFile | wc -l)
offset=0
# initialize the output file
echo "AdjacencyGraph" > $targetFile
echo "to be replaced by the number of nodes" >> $targetFile
echo $numberOfEdges >> $targetFile

while [ $(grep -m 1 $currentNode $sourceFile | wc -l) -ge 1 ]
do
    pattern="^${currentNode} "
    offset=$(( $offset + $(grep "$pattern" $sourceFile | wc -l) ))
    echo $offset >> $targetFile
    let currentNode=$currentNode+1
done

sed -i "2s/.*/$currentNode/" $targetFile

for (( activeNode = 0; activeNode < $currentNode; activeNode++ ))
do
    pattern="^${activeNode} "
    edgesOfActiveNode=$(grep "$pattern" $sourceFile)
    antiPattern="${activeNode} "
    # removes the source nodes
    edgesOfActiveNode="${edgesOfActiveNode//$antiPattern}"
    if ! [[ -z $edgesOfActiveNode ]];
    then
        echo "$edgesOfActiveNode" >> $targetFile
    fi
done
