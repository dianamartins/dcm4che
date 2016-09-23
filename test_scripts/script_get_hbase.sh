#!/usr/bin/env bash

runs=1 # mudar

max=$(ssh -i ~/.ssh/gsd_private_key gsd@cloud85 ls -l /home/gsd/dcm4che/replicas/*.dcm | wc -l)

echo "Maximum $max"

echo "Starting DCMQRSCP"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 nohup /home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/dcmqrscp -b DCMQRSCP:11113 --dicomdir /home/gsd/dcm4che/DICOMDIR -f /home/gsd/dcm4che/def-hbase-client.xml -d /home/gsd/dcm4che/images_database/ &

sleep 7

echo "Starting dstat"

hosts=(cloud80 cloud81 cloud82 cloud83 cloud84 cloud85)

for host in "${hosts[@]}" 
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host nohup dstat -t -c -d -m -n -r --output $host.csv --noheaders > /dev/null &
done

echo "Starting get clients"

for i in $(seq $runs)
do
	r=$RANDOM
	f=$(( r %=$max-1 ))
	echo $f

	if test $f -eq 0
	then
		f=1
	fi
	echo "Image $f chosen"
	sop=$(ssh -i ~/.ssh/gsd_private_key gsd@cloud85 "/home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/dcmdump /home/gsd/dcm4che/replicas/$f.dcm | grep '(0008,0018)'| grep -o '\[[0-9.]*\]' | grep -o '[0-9.]*'")

	echo "Getting $sop"
	ssh -i ~/.ssh/gsd_private_key gsd@cloud85 /home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/getscu -c DCMQRSCP@cloud84:11113 -L IMAGE -m SOPInstanceUID=$sop StudyInstanceUID=1 SeriesInstanceUID=1 >> query.log
	ssh -i ~/.ssh/gsd_private_key gsd@cloud85 mv /home/gsd/dcm4che/results/resultsGETSCU.txt /home/gsd/dcm4che/results/store$i.txt
	cat query.log	
done

echo "Test ended"

#echo "Stopping DCMQRSCP"

#ssh -i ~/.ssh/gsd_private_key gsd@cloud84 ps aux | grep -i 1111[3] | awk {'print $2'} | kill -9

echo "Stoping dstat"

for host in "${hosts[@]}" 
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host pkill dstat
done

echo "Done!"