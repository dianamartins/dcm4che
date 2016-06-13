#!/usr/bin/env bash

nimages=$1
echo "nunber of images"
echo $nimages
cp temp_preferences.xml preferences.xml
sed -i "s/NIMAGES/$nimages/g" preferences.xml
python3 generateDataset.py preferences.xml
./dcm4che-3.3.8-SNAPSHOT/bin/storescu -c storescp@proxies:6263 replicas
