#!/bin/bash

folderPath=/home/jain/GEO_Mouse_Datasets/GSE50561_Mouse_TGC_E9.5_Cultured/*.fastq
#outfolder=/ptmp/jain/Final_Project/Raw_BC_Samples/

for f in $folderPath
do
    if [[ -f $f ]]
    then
        #echo $f
        fileName=$(basename $f)
        out=$(dirname $f)
        file=(${fileName//./ }) #$(awk -F'.' '{print $1;}' $fileName)
        #echo $fileName" "$out" "$file[1]
        #if [ ${file[1]} == 'sra' ]
        #then
            echo $f
            exec="fastqc -o $out -f fastq $f &"
            echo $exec
            eval $exec
        #fi
    fi
done
wait
