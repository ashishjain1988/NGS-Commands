#!/bin/bash

folderPath=/ptmp/jain/Final_Project/Raw_BC_Samples/*.fastq

for f in $folderPath 
do
    if [[ -f $f ]]; then
        fileName=$(basename $f)
	echo $fileName
	file=(${fileName//./ }) #$(awk -F'.' '{print $1;}' $fileName)
	echo ${file[0]}
    fi
done
