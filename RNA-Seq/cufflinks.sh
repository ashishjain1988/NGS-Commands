#!/bin/bash

folderPath=/ptmp/jain/Final_Project/tophat_output/*

for f in $folderPath
do
    if [[ -d $f ]]; then
        fileName=$(basename $f)
	echo $fileName
        cufflinks -p 8 -o ./cufflink_output/$fileName $f/accepted_hits.bam &
    fi
done
wait

