#!/usr/bin/env bash

#Teste para store

#num_fixed_weight= $1 # alterar

#num_images= $10 # alterar

hosts=(cloud80 cloud81 cloud82 cloud83 cloud84 cloud85)

echo "Cleaning images database"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 rm /home/gsd/dcm4che/images_database/*

echo "Removing previous dstats"

for host in "${hosts[@]}"
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host rm /home/gsd/$host.csv
done

echo "Removing previous results"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/dcm4che/results/*

echo "Creating new results file"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 touch /home/gsd/dcm4che/results/resultsSTORESCU.txt

echo "Generating dataset"

#echo $num_images

# echo "Already done"

echo "Deleting previous currentReplicas"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/dcm4che/currentReplicas/*

#echo "Creating new currentReplicas directory"

#ssh -i ~/.ssh/gsd_private_key gsd@cloud85 mkdir /home/gsd/dcm4che/currentReplicas/

echo "Copying files to currentReplicas"	

runs=5000

for i in $(seq $runs)
do
	echo $i 
	ssh -i ~/.ssh/gsd_private_key gsd@cloud85 cp /home/gsd/dcm4che/replicas3/$i.dcm /home/gsd/dcm4che/currentReplicas/
done 

#ssh -i ~/.ssh/gsd_private_key gsd@cloud85 python3 /home/gsd/dcm4che/GenerateDataset/generateDataset.py /home/gsd/dcm4che/GenerateDataset/preferences.xml 20000 20000

# echo "Starting StoreSCP"

# ssh -i ~/.ssh/gsd_private_key gsd@cloud84 nohup /home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/storescp -b STORESCP:11114 --directory /home/gsd/dcm4che/images_database -f /home/gsd/dcm4che/def-hbase-client.xml &

# sleep 7

# echo "Starting dstat"


# for host in "${hosts[@]}" 
# do
# 	echo $host
# 	ssh -i ~/.ssh/gsd_private_key gsd@$host nohup dstat -t -c -d -m -n -r --output $host.csv --noheaders > /dev/null &
# done

echo "Starting StoreSCU"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 /home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/storescu -c STORESCP@cloud84:11114 /home/gsd/dcm4che/currentReplicas

echo "Test ended"

#echo "Stoping StoreSCP"

# ssh -i ~/.ssh/gsd_private_key gsd@cloud84 ps aux | grep -i 1111[4] | awk {'print $2'} | kill

# echo "Stoping dstat"

# for host in "${hosts[@]}" 
# do
# 	echo $host
# 	ssh -i ~/.ssh/gsd_private_key gsd@$host pkill dstat
# done

# echo "Copying result files to the localhost"

# for host in "${hosts[@]}"
# do
# 	echo $host
# 	scp -i ~/.ssh/gsd_private_key gsd@$host:/home/gsd/$host.csv ~/tests_results/sym/put/run5.10
# done

# echo "resultsSTORESCU.txt"

# scp -i ~/.ssh/gsd_private_key gsd@cloud85:/home/gsd/dcm4che/results/resultsSTORESCU.txt ~/tests_results/sym/put/run5.10

echo "Done!"
