./dcm4che-3.3.8-SNAPSHOT/bin/dcmqrscp -b dcmqrscp:6262 -f def-hbase-client.xml --dicomdir dicomdir/DICOMDIR > query.log &
./dcm4che-3.3.8-SNAPSHOT/bin/storescp -b storescp:6263 -f def-hbase-client.xml --directory dircomdir > store.log &
 tail -f *.log
