#!/usr/bin/env bash

#Teste para store

#num_fixed_weight= $1 # alterar

#num_images= $10 # alterar

hosts=(cloud80 cloud81 cloud82 cloud83 cloud84 cloud85)

echo "Removing previous dstats"

for host in "${hosts[@]}"
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host rm /home/gsd/$host.csv
done

echo "Removing previous results"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/dcm4che/results/*

echo "Creating new results file"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 touch /home/gsd/dcm4che/results/resultsGETSCU.txt

echo "Deleting previously received images"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/1.*

echo "Starting DCMQRSCP"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 nohup /home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/dcmqrscp -b DCMQRSCP:11113 --dicomdir /home/gsd/dcm4che/DICOMDIR -f /home/gsd/dcm4che/def-hbase-client.xml -d /home/gsd/dcm4che/images_database/ &

sleep 7

echo "Starting dstat"

for host in "${hosts[@]}" 
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host nohup dstat -t -c -d -m -n -r --output $host.csv --noheaders > /dev/null &
done

echo "Starting GetSCU"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 /home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/getscu -c DCMQRSCP@cloud84:11113 -L STUDY -m StudyInstanceUID=1 PatientWeight=70

echo "Test ended"

#echo "Stoping StoreSCP"

# ssh -i ~/.ssh/gsd_private_key gsd@cloud84 ps aux | grep -i 1111[4] | awk {'print $2'} | kill

echo "Stoping dstat"

for host in "${hosts[@]}" 
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host pkill dstat
done

echo "Copying result files to the localhost"

for host in "${hosts[@]}"
do
	echo $host
	scp -i ~/.ssh/gsd_private_key gsd@$host:/home/gsd/$host.csv ~/tests_results/scan3/run5.10/
done

echo "Copying scan results"

scp -i ~/.ssh/gsd_private_key gsd@cloud85:/home/gsd/dcm4che/results/* ~/tests_results/scan3/run5.10/

echo "Done!"
