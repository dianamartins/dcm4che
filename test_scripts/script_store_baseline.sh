#!/usr/bin/env bash

#Teste para store

# ADAPTAR DIRETORIAS

num_fixed_weight=1 # alterar

num_images=10 # alterar

echo "Generating dataset"

#echo $num_images

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 python3 /home/gsd/dcm4che/GenerateDataset/generateDataset.py /home/gsd/dcm4che/GenerateDataset/preferences.xml $num_fixed_weight $num_images

echo "Starting StoreSCP"

# Descarregar binarios da master e colocar nas variaveis de ambiente para não ter de andar com paths

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 nohup storescp -b STORESCP:11114 --directory /home/gsd/dcm4che/images_database &

echo "Cleaning images database"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 rm /home/gsd/dcm4che/images_database/*

echo "Cleaning DICOMDIR"

ssh -i ~/.ssh/gsd/private_key gsd@cloud84 rm /home/gsd/dcm4che/DICOMDIR

echo "Starting dstat"

hosts=(cloud84 cloud85)

for host in "${hosts[@]}" 
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host nohup dstat -t -c -d -m -n -r --output $host.csv --noheaders > /dev/null &
done

echo "Starting StoreSCU"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 storescu -c STORESCP@cloud84:11114 /home/gsd/dcm4che/replicas

echo "Test ended"

echo "Creating and updating DICOMDIR"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 dcmdir -c /home/gsd/dcm4che/DICOMDIR /home/gsd/dcm4che/images_database

echo "Stoping dstat"

for host in "${hosts[@]}" 
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host pkill dstat
done

echo "Done!"