#!/bin/sh

for x in $(find .);do
    if [[ "$x" =~ .*nf_.* ]];then
        echo "mv $x $(echo $x |sed -e 's/nf_//')"
        mv $x $(echo $x |sed -e 's/nf_//')
    else
        echo ">> $x"
    fi
done