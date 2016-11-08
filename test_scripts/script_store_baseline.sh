# #!/usr/bin/env bash

echo "Teste para store baseline"

echo "Deleting previous currentReplicas"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/dcm4che/currentReplicas/

echo "Creating new currentReplicas directory"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 mkdir /home/gsd/dcm4che/currentReplicas/

echo "Copying files to currentReplicas"	

runs=1000

for i in $(seq $runs)
do
	echo $i 
	ssh -i ~/.ssh/gsd_private_key gsd@cloud85 cp /home/gsd/dcm4che/replicas/$i.dcm /home/gsd/dcm4che/currentReplicas/
done 

# # ADAPTAR DIRETORIAS

# num_fixed_weight=1 # alterar

# num_images=10 # alterar

#echo "Generating dataset"

# #echo $num_images

#ssh -i ~/.ssh/gsd_private_key gsd@cloud85 python3 /home/gsd/dcm4che/GenerateDataset/generateDataset.py /home/gsd/dcm4che/GenerateDataset/preferences.xml 1 20000

echo "Cleaning images database"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 rm /home/gsd/dcm4che/images_database/*

echo "Removing previous dstats"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 rm /home/gsd/cloud84.csv

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 rm /home/gsd/DICOMDIR.csv

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/cloud85.csv

echo "Removing previous results"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/dcm4che/results/*

echo "Creating new results file"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 touch /home/gsd/dcm4che/results/resultsSTORESCU.txt

echo "Cleaning DICOMDIR"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 rm /home/gsd/dcm4che/DICOMDIR

echo "Starting StoreSCP"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 nohup /home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/storescp -b STORESCP:11114 --directory /home/gsd/dcm4che/images_database &

echo "Starting dstat"

hosts=(cloud84 cloud85)

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 nohup dstat -t -c -d -m -n -r --output cloud84.csv --noheaders > /dev/null &

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 nohup dstat -t -c -d -m -n -r --output cloud85.csv --noheaders > /dev/null &

echo "Starting StoreSCU"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 /home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/storescu -c STORESCP@cloud84:11114 /home/gsd/dcm4che/currentReplicas

echo "Test ended"

echo "Stoping dstat"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 pkill dstat

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 pkill dstat

sleep 4

echo "Starting new dstat to DICOMDIR"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 nohup dstat -t -c -d -m -n -r --output DICOMDIR.csv --noheaders > /dev/null &

echo "Creating and updating DICOMDIR"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 /home/gsd/dcm4che/dcm4che-assembly/target/dcm4che-3.3.8-SNAPSHOT-bin/dcm4che-3.3.8-SNAPSHOT/bin/dcmdir -c /home/gsd/dcm4che/DICOMDIR /home/gsd/dcm4che/images_database

echo "Stopping DICOMDIR dstat"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 pkill dstat

# echo "Copying results to the localhost"

# scp -i ~/.ssh/gsd_private_key gsd@cloud84:/home/gsd/cloud84.csv ~/tests_results/baseline/put/run5.10

# scp -i ~/.ssh/gsd_private_key gsd@cloud84:/home/gsd/DICOMDIR.csv ~/tests_results/baseline/put/run5.10

# scp -i ~/.ssh/gsd_private_key gsd@cloud85:/home/gsd/cloud85.csv ~/tests_results/baseline/put/run5.10

# scp -i ~/.ssh/gsd_private_key gsd@cloud85:/home/gsd/dcm4che/results/resultsSTORESCU.txt ~/tests_results/baseline/put/run5.10

echo "Done!"