#!/bin/bash
echo $AWS_BATCH_JOB_ARRAY_INDEX
python3 Autocallable.Note.py $1 $2 $3
