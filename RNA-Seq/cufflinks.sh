#!/bin/bash

genomePath=/work/LAS/Wurtele_Lab/Saccharomyces_cerevisiae/Ensembl/EF4/
folderPath=/ptmp/jain/Final_Project/Tophat_Output_For_Cufflinks/*
outFolder=./Cufflink_Output

for f in $folderPath
do
   if [[ -d $f ]]; then
        fileName=$(basename $f)
	echo $fileName
        cufflinks -p 12 -g $genomePath/Annotation/Genes/genes.gtf -o $outFolder/$fileName $f/accepted_hits.bam &
    fi
done
wait

