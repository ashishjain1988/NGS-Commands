#!/bin/bash

folderPath=/ptmp/jain/Final_Project/Raw_BC_Samples/*.sra
outfolder=/ptmp/jain/Final_Project/Raw_BC_Samples/


for f in $folderPath
do
    echo $f
    if [[ -f $f ]] 
    then
	fileName=$(basename $f)
        #echo $fileName
        file=(${fileName//./ }) #$(awk -F'.' '{print $1;}' $fileName)
        #if [ ${file[1]} = 'sra' ]
        #then
	    echo $f
	    fastq-dump -O $outfolder $f &
	#fi
    fi
done
wait

