#!/bin/bash
set -e
file=$1
echo "=== Format metric file ==="
echo $file

l=$(jq length $file)
i=0
while [ $i -lt $l ]
do
  time=$(date -v $[-5*$i]M)
  echo $i
  cat $file | jq --argjson i $i --arg t $time '.[$i].Timestamp |= $t' > tmp.json && mv tmp.json $file
  i=$[$i+1]
done

echo "replace autoscaling group name.."

sed -i '' -e 's/#ASGPLACEHOLDER#/Test Predictive ASG/g' $file

echo "=== Complete ==="
