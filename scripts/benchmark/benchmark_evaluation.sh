#!/bin/bash

# find algorithms
algorithms=()
result=$(cat ${@} | grep "^#" | awk '{print $1}')
for line in $result; do
  if [[ " ${algorithms[@]} " != *" ${line:1} "* ]]; then
    algorithms+=("${line:1}")
  fi
done

# find graphs
graphs=()
result=$(cat ${@} | grep "^#" | awk '{print $2}')
for line in $result; do
  if [[ " ${graphs[@]} " != *" $line "* ]]; then
    graphs+=("$line")
  fi
done

# evaluate
for graph in ${graphs[@]}; do
  for algorithm in ${algorithms[@]}; do
    if [[ "$algorithm" == *gemini* ]]; then
      result=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | awk '{s1+=$5} {s2+=$6} END {print s1/10000000 " " (s2-5*s1)/10000000}')
    else
      result=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | awk '{s1+=$5} {s2+=$6} END {print s1/10000000 " " s2/10000000}')
    fi
    if [[ "$result" != "0 0" ]]; then
      echo "$graph $algorithm $result"
    fi
  done
done
