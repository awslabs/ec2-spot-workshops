#!/bin/bash
set -e
file=$1
group=$2
echo "=== Format metric file ==="
echo $file
echo $group

l=$(jq length $file)
i=0
while [ $i -lt $l ]
do
  time=$(date --d="$[5*$i] minutes ago")
  cat $file | jq --argjson i $i --arg t "$time" '.[$i].Timestamp |= $t' > tmp.json && mv tmp.json $file
  i=$[$i+1]
done

echo "replace autoscaling group name.."

sed -i $file -e "s/#ASGPLACEHOLDER#/$group/g"

echo "=== Complete ==="
