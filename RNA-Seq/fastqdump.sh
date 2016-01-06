#!/bin/bash
#This file takes accession number list as input
folderPath=/work/LAS/jain/sra/SRR13634*.sra
outfolder=/work/LAS/Wurtele_Lab/Yeast/Fastq_Files1/
filePath=/work/LAS/Wurtele_Lab/Yeast/ribosomal_SRR_Accessions.txt
toolPath=/work/LAS/Wurtele_Lab/sratoolkit.2.5.4-1-ubuntu64/bin

IFS=$'\n'       # make newlines the only separator
set -f          # disable globbing
for i in $(cat "$filePath"); do
        exec='$toolPath/fastq-dump -Z $i >$outfolder/$i".fastq" &'
        #exec='$toolPath/prefetch $i &'
        echo $exec
        eval $exec
done
wait

#for f in $folderPath
#do
    #echo $f
    #if [[ -f $f ]]
    #then
        #fileName=$(basename $f)
        #echo $fileName
        #file=(${fileName//./ }) #$(awk -F'.' '{print $1;}' $fileName)
        #if [ ${file[1]} = 'sra' ]
        #then
        #echo $f
        #$toolPath/fastq-dump -O $outfolder $f &
        #fi
   #fi
#done
wait

