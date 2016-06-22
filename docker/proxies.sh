#!/usr/bin/env bash

./dcm4che-3.3.8-SNAPSHOT/bin/dcmqrscp -b dcmqrscp:6262 -f store-share-client.xml --dicomdir dicomdir/DICOMDIR  -d dicomdir> query.log &
./dcm4che-3.3.8-SNAPSHOT/bin/storescp -b storescp:6263 -f store-share-client.xml --directory dicomdir > store.log &
#./dcm4che-3.3.8-SNAPSHOT/bin/storescp -b storescp:6263 --directory dicomdir > store.log &
tail -f *.log
