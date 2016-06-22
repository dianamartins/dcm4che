#!/usr/bin/env bash

nimages=$1
echo "nunber of images"
echo $nimages
exi=$(ls -l replicas/ | wc -l)

echo $exi

if test $exi -eq 1
then
	echo $exi
	echo "going to generate images"
	cp temp_preferences.xml preferences.xml
	sed -i "s/NIMAGES/$nimages/g" preferences.xml
	echo "Going to generate"
	python3 generateDataset.py preferences.xml
	echo "Finished generating"
	./dcm4che-3.3.8-SNAPSHOT/bin/storescu -c storescp@proxies:6263 replicas
fi

