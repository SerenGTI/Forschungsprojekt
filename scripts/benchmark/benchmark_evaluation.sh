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
    error=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | grep "ERROR" | wc -l)
    timeout=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | grep "TIMEOUT" | wc -l)
    if [[ $error -gt 0 ]]; then
      echo "$graph $algorithm ERROR ERROR ERROR ERROR"
    elif [[ $timeout -gt 0 ]]; then
      echo "$graph $algorithm TIMEOUT TIMEOUT TIMEOUT TIMEOUT"
    else
      if [[ "$algorithm" == *gemini* ]]; then
        means=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | awk '{s1+=$5} {s2+=$6} END {print s1/10000000 " " (s2-5*s1)/10000000}')
        mean1=$(echo "$means" | awk '{print $1}')
        mean2=$(echo "$means" | awk '{print $2}')
        vars=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | awk -v m1="$mean1" -v m2="$mean2" '{s1+=($5/1000000-m1)**2} {s2+=(($6-5*$5)/1000000-m2)**2} END {print s1/9 " " s2/9}')
      elif [[ "$algorithm" == *giraph* ]]; then
        means=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | awk '{s1+=$7} {s2+=$6} END {print s1/10000000 " " s2/10000000}')
        mean1=$(echo "$means" | awk '{print $1}')
        mean2=$(echo "$means" | awk '{print $2}')
        vars=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | awk -v m1="$mean1" -v m2="$mean2" '{s1+=($7/1000000-m1)**2} {s2+=($6/1000000-m2)**2} END {print s1/9 " " s2/9}')
      else
        means=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | awk '{s1+=$5} {s2+=$6} END {print s1/10000000 " " s2/10000000}')
        mean1=$(echo "$means" | awk '{print $1}')
        mean2=$(echo "$means" | awk '{print $2}')
        vars=$(cat ${@} | grep "^#" | grep "$graph" | grep "$algorithm " | awk -v m1="$mean1" -v m2="$mean2" '{s1+=($5/1000000-m1)**2} {s2+=($6/1000000-m2)**2} END {print s1/9 " " s2/9}')
      fi
      if [[ "$result" != "0 0" ]]; then
        if [[ $mean1 == 0 ]] || [[ $mean2 == 0 ]]; then
          echo "$graph $algorithm ERROR ERROR ERROR ERROR"
        else
          echo "$graph $algorithm $means $vars"
        fi
      fi
    fi
  done
done
