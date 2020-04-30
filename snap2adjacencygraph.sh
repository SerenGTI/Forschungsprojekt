#!/bin/bash

sourceFile=$1
targetFile=$2
currentNode=0
# initialize the output file
echo "AdjacencyGraph" > $targetFile

while [ $(grep $currentNode $sourceFile | wc -l) -ge 1 ]
do
    pattern="^${currentNode} "
    offset=$(grep "$pattern" $sourceFile | wc -l)
    echo $offset >> $targetFile
    let currentNode=$currentNode+1
done

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
