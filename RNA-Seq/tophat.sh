#!/bin/bash

genomePath=/ptmp/jain/Final_Project/Raw_BC_Samples/Homo_sapiens/UCSC/hg19/
folderPath=/ptmp/jain/Final_Project/Raw_BC_Samples/Trimmed/*.fastq
output=/ptmp/jain/Final_Project/Tophat_Output/

for f in $folderPath
do
    if [[ -f $f ]]; then
        fileName=$(basename $f)
        sampleName=(${fileName//./ })
        echo tophat -p 12 -G $genomePath/Annotation/Genes/genes.gtf -o $output/${sampleName[0]}  $genomePath/Sequence/Bowtie2Index/genome $f &
        tophat -p 12 -G $genomePath/Annotation/Genes/genes.gtf -o $output/${sampleName[0]}  $genomePath/Sequence/Bowtie2Index/genome $f &
    fi
done
wait

