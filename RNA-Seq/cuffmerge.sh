#!/bin/bash

folderPath=/ptmp/jain/Final_Project/Cufflink_Output/*

touch assemblies.txt
for f in $folderPath 
do
    if [[ -d $f ]]; then
        echo $f"/transcripts.gtf" >>assemblies.txt
    fi
done
