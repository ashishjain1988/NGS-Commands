#!/bin/bash

jarPath=/ptmp/jain/Trimmomatic-0.33/
folderPath=/ptmp/jain/Final_Project/Raw_BC_Samples/*.fastq
fastqPath=/ptmp/jain/Final_Project/Raw_BC_Samples/Trimmed/

for f in $folderPath
do
    if [[ -f $f ]]; then
        echo $f
	fileName=$(basename $f)
        echo $fileName
        file=(${fileName//./ }) #$(awk -F'.' '{print $1;}' $fileName)
        #echo ${file[0]}
	java -jar $jarPath/trimmomatic-0.33.jar SE -phred33 $f  $fastqPath/${file[0]}"_trimmed.fastq" ILLUMINACLIP:$jarPath/adapters/TruSeq3-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 &
    fi
done
wait

