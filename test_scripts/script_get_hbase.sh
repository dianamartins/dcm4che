#!/usr/bin/env bash

runs=1000 # mudar

max=$(ls -l /home/gsd/dcm4che/replicas/*.dcm | wc -l)

echo "Starting dstat cloud85"

nohup dstat -t -c -d -m -n -r --output cloud85.csv --noheaders > /dev/null &

echo "Starting get clients"

for i in $(seq $runs)
do
	#r=$RANDOM
	#f=$(( r %=$max-1 ))
	#echo $f
	echo $i

	#if test $f -eq 0
	#then
	#	f=1
	#fi
	#echo "Image $f chosen"
	sop=$(/home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/dcmdump /home/gsd/dcm4che/replicas/$i.dcm | grep '(0008,0018)'| grep -o '\[[0-9.]*\]' | grep -o '[0-9.]*')

	echo "Getting $sop"
	/home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/getscu -c DCMQRSCP@cloud84:11113 -L IMAGE -m SOPInstanceUID=$sop StudyInstanceUID=1 SeriesInstanceUID=1  #>> query.log
	mv /home/gsd/dcm4che/results/resultsGETSCU.txt /home/gsd/dcm4che/results/store$i.txt
	#cat query.log	
done

echo "Test ended"

echo "Stoping dstat"

pkill dstat

echo "Done!"