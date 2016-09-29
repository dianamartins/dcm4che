#script de inicio de teste de GET

echo "Preparing to start GET test"

hosts_1=(cloud80 cloud81 cloud82 cloud83 cloud84)

hosts_2=(cloud80 cloud81 cloud82 cloud83 cloud84 cloud85)

echo "Stopping previous dstat"

for host in "${hosts_1[@]}"
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host pkill dstat
done

echo "Copying previous dstats to localhost"

for host in "${hosts_2[@]}"
do
	echo $host
	scp -i ~/.ssh/gsd_private_key gsd@$host:/home/gsd/$host.csv ~/tests_results/get/
done

echo "Deleting previous dstats"

for host in "${hosts_2[@]}"
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host rm /home/gsd/$host.csv
done

echo "Copying previous results to localhost"

scp -i ~/.ssh/gsd_private_key gsd@cloud85:/home/gsd/dcm4che/results/* ~/tests_results/get/

echo "Deleting previous results"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/dcm4che/results/*

echo "Creating new results file"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 touch /home/gsd/dcm4che/results/resultsGETSCU.txt

echo "Deleting received images"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/1.*

echo "Starting dstats"

for host in "${hosts_1[@]}" 
do
	echo $host
	ssh -i ~/.ssh/gsd_private_key gsd@$host nohup dstat -t -c -d -m -n -r --output $host.csv --noheaders > /dev/null &
done

echo "Starting GET test"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 nohup /home/gsd/dcm4che/test_scripts/script_get_hbase.sh 

echo "Test ended. Done!!!!"