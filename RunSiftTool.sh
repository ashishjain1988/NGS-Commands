#!/bin/bash
vcf2tsvpath=/usr/local/bin
snpSffpath=/home/ashish/snpEff
customconvertorjar=/home/ashish
mkdir ./result_run
java -Xmx4g -jar $snpSffpath/snpEff.jar hg19 $1 > ./result_run/snpEffann.vcf
java -jar $snpSffpath/SnpSift.jar annotate $snpSffpath/db/00-All.vcf -v ./result_run/snpEffann.vcf > ./result_run/dbSNP.vcf
java -jar $snpSffpath/SnpSift.jar annotate $snpSffpath/db/clinvar.vcf -v ./result_run/dbSNP.vcf > ./result_run/clinVar.vcf
java -Xmx4g -jar $snpSffpath/SnpSift.jar dbnsfp -v -db $snpSffpath/dbNSFP2.9.txt.gz ./result_run/clinVar.vcf > ./dbNSFP-result.vcf
rm -r ./result_run
$vcf2tsvpath/vcf2tsv ./dbNSFP-result.vcf >./result.txt
java -jar $customconvertorjar/vcf-info-parser.jar vcfFile=dbNSFP-result.vcf txtFile=result.txt

