#!/bin/bash

sourceFile=$1
targetFile=$2
currentNode=0
numberOfEdges=$(grep '^[0-9]' $sourceFile | wc -l)
offset=0
biggestNumber=$(awk '{print $1}' $sourceFile | sort -rn | head -n 1)
biggestNumberContender=$(awk '{print$2}' $sourceFile | sort -rn | head -n 1)
if (( $biggestNumberContender > $biggestNumber ));
then
    biggestNumber=$biggestNumberContender
fi
# initialize the output file
echo "AdjacencyGraph" > $targetFile
echo "to be replaced by the number of nodes" >> $targetFile
echo $numberOfEdges >> $targetFile

for (( currentNode = 0; currentNode <= $biggestNumber; currentNode++ ))
do
    pattern="^${currentNode}[[:space:]]"
    occurences=$(grep "$pattern" $sourceFile | wc -l)
    echo $offset >> $targetFile
    offset=$(( $offset + $occurences ))
done

sed -i "2s/.*/$currentNode/" $targetFile

for (( activeNode = 0; activeNode <= $currentNode; activeNode++ ))
do
    pattern="^${activeNode}[[:space:]]"
    edgesOfActiveNode=$(grep "$pattern" $sourceFile | awk '{print $2}')
    # removes the source nodes
    if ! [[ -z $edgesOfActiveNode ]];
    then
        echo "$edgesOfActiveNode" >> $targetFile
    fi
done

weights=$(grep '^[0-9]' $sourceFile | awk '{print $3}')
if ! [[ -z $weights ]];
then
    echo "$weights" >> $targetFile
fi
