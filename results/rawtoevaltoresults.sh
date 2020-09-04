cd raw
for file in *; do
  if [[ "$file" =~ ^(.*)-([1-9]+)(.*)$ ]]; then
    if [[ "$file" =~ ^(.*)-hp-(.*)$ ]]; then
      number=$(echo "$file" | awk -F "-" '{print $3}' | awk -F "." '{print $1}')
      ../../scripts/benchmark/benchmark_evaluation.sh "$file" | awk -v number=$number '{print $1 " " $2  "-hp-" number "hread " $3 " " $4 " " $5 " " $6}' > "../eval/$file"
    else
      number=$(echo "$file" | awk -F "-" '{print $2}' | awk -F "." '{print $1}')
      ../../scripts/benchmark/benchmark_evaluation.sh "$file" | awk -v number=$number '{print $1 " " $2  "-" number "thread " $3 " " $4 " " $5 " " $6}' > "../eval/$file"
    fi
  else
    ../../scripts/benchmark/benchmark_evaluation.sh "$file" > "../eval/$file"
  fi
done
cd ..
cat eval/* | sort > results.txt
