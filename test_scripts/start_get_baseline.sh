#script de inicio de teste de GET

echo "Preparing to start GET test"

echo "Stopping previous dstat"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 pkill dstat

echo "Copying previous dstats to localhost"

scp -i ~/.ssh/gsd_private_key gsd@cloud84:/home/gsd/cloud84.csv ~/tests_results/baseline/get/run3.10/

scp -i ~/.ssh/gsd_private_key gsd@cloud85:/home/gsd/cloud85.csv ~/tests_results/baseline/get/run3.10/

echo "Deleting previous dstats"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 rm /home/gsd/cloud84.csv

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/cloud85.csv

echo "Copying previous results to localhost"

scp -i ~/.ssh/gsd_private_key gsd@cloud85:/home/gsd/dcm4che/results/* ~/tests_results/baseline/get/run3.10/

echo "Deleting previous results"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/dcm4che/results/*

echo "Creating new results file"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 touch /home/gsd/dcm4che/results/resultsGETSCU.txt

echo "Deleting received images"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 rm /home/gsd/1.*

echo "Starting dstat cloud84"

ssh -i ~/.ssh/gsd_private_key gsd@cloud84 nohup dstat -t -c -d -m -n -r --output cloud84.csv --noheaders > /dev/null &

echo "Starting GET test"

ssh -i ~/.ssh/gsd_private_key gsd@cloud85 nohup /home/gsd/dcm4che/test_scripts/script_get_baseline.sh 

echo "Test ended. Done!!!!"