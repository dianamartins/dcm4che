#!/usr/bin/env bash

runs=$1

max=$(ls -l replicas/*.dcm | wc -l)

echo $max

for i in $(seq $runs)
do
	r=$RANDOM
	f=$(( r %=$max-1 ))
	echo $f

	if test $f -eq 0
	then
		f=1
	fi
	echo $f
	sop=$(./dcm4che-3.3.8-SNAPSHOT/bin/dcmdump replicas/$f.dcm | grep "(0008,0018)"| grep -o "\[[0-9.]*\]" | grep -o "[0-9.]*")

	echo $SOPInstanceUID
	./dcm4che-3.3.8-SNAPSHOT/bin/getscu -c dcmqrscp@proxies:6262 -L IMAGE -m SOPInstanceUID=$sop StudyInstanceUID=1 SeriesInstanceUID=1 >> query.log
	mv results/resultsGETSCU.txt results/store$i.txt
	cat query.log	
done