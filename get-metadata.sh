#!/bin/bash
set -u

base=NCBI_SRA_Metadata_Full_20150901

# download and extract SRA data if necessary
if [ ! -d $base ]; then
    sraftp=ftp://ftp.ncbi.nlm.nih.gov/sra
    wget "$sraftp/reports/Metadata/${base}.tar.gz"
    gunzip ${base}.tar.gz
    tar -xf ${base}.tar
    cd $base
    rm SRA_Accessions SRA_Files_Md5 SRA_Run_Members
    find . -name '*.xml' | xargs -I {} mv {} . 2> /dev/null
    find . -type d | xargs rmdir
fi


# ======================================================
# Parse *.study.xml files
# ======================================================
echo -e "SRA_id\tstudy_id\tstudy_title\tabstract" > study.tab
find $base -name '*study.xml' | while read f
do
    xmlstarlet sel \
        -t \
        -m '/STUDY_SET/STUDY' \
            -o "$f" \
            -o $'\t' \
            -v 'IDENTIFIERS/PRIMARY_ID' \
            -o $'\t' \
            -v 'DESCRIPTOR/STUDY_TITLE' \
            -o $'\t' \
            -v 'DESCRIPTOR/STUDY_ABSTRACT' \
            -n \
        -b $f
done >> study.tab &



# ======================================================
# Parse *.sample.xml files
# ======================================================
echo -e "SRA_id\tsample_id\tsample_title\ttaxon_id\tspecies" > sample.tab
find $base -name '*sample.xml' | while read f
do
    xmlstarlet sel \
        -t \
        -m '/SAMPLE_SET/SAMPLE' \
            -o "$f" \
            -o $'\t' \
            -v 'IDENTIFIERS/PRIMARY_ID' \
            -o $'\t' \
            -v 'TITLE' \
            -o $'\t' \
            -v 'SAMPLE_NAME/TAXON_ID' \
            -o $'\t' \
            -v 'SAMPLE_NAME/SCIENTIFIC_NAME' \
            -n \
        -b $f
done >> sample.tab &



# ======================================================
# Parse *.sample.xml files extracting attributes
# ======================================================
echo -e "SRA_id\tsample_id\tsample_tag\tsample_value" > sample-attributes.tab
find $base -name '*sample.xml' | while read f
do
    xmlstarlet sel \
        -t \
        -m '/SAMPLE_SET/SAMPLE' \
            -o '___'$'\t' \
            -o $f \
            -o $'\t' \
            -v 'IDENTIFIERS/PRIMARY_ID' -n \
            -m 'SAMPLE_ATTRIBUTES/SAMPLE_ATTRIBUTE' \
                -v 'TAG' \
                -o $'\t' \
                -v 'VALUE' \
                -n \
            -b \
        -b $f
done |
    awk -v OFS="\t" -v FS="\t" '
        $1 == "___" {file=$2; id=$3}
        $1 != "___" {print file, id, $0}
    ' >> sample-attributes.tab &



# ======================================================
# Parse *.experiment.xml
# ======================================================
echo -e "SRA_id\texperiment_id\tsample_id\tdesign_description\tlibrary_name\tlibrary_strategy\tlibrary_source\tinstrument_model" > experiment.tab
find $base -name '*experiment.xml' | while read f
do
    xmlstarlet sel \
        -t \
        -m '/EXPERIMENT_SET/EXPERIMENT' \
            -o "$f" \
            -o $'\t' \
            -v 'IDENTIFIERS/PRIMARY_ID' \
            -o $'\t' \
            -v 'DESIGN/SAMPLE_DESCRIPTOR/IDENTIFIERS/PRIMARY_ID' \
            -o $'\t' \
            -v 'DESIGN/DESIGN_DESCRIPTION' \
            -o $'\t' \
            -v 'DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_NAME' \
            -o $'\t' \
            -v 'DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_STRATEGY' \
            -o $'\t' \
            -v 'DESIGN/LIBRARY_DESCRIPTOR/LIBRARY_SOURCE' \
            -o $'\t' \
            -v 'PLATFORM//INSTRUMENT_MODEL' \
            -n \
        -b $f
done >> experiment.tab &


# ======================================================
# Count the number of samples per submission
# ======================================================
wait
echo -e "SRA_id\tsamples" > sample-count.tab
cut -f1 sample.tab |
    uniq -c |
    awk 'BEGIN{OFS="\t"} NR > 1 {print $2, $1}' >> sample-count.tab

datfiles=$(ls {experiment,sample,study}*.tab)


# extract SRA ids from filenames
for j in $datfiles
do 
    sed -ri 's/^[^\t]*\/([^.]+)[^\t]+/\1/' $j &
done

# count number of species per SRA id
wait
echo -e "SRA_id\tspecies_count" > species-per-id.tab
awk -v FS="\t" -v OFS="\t" 'NR > 1 {print $1, $4}' sample.tab |
    sort -u |
    cut -f1 |
    uniq -c |
    awk -v OFS="\t" '{print $1, $2}' >> species-per-id.tab


# ====================================================================
# Extract RNA-Seq data
# ====================================================================

rnaseq_ids=RNA-Seq_ids.txt
awk -F $'\t' '$6 == "RNA-Seq" {print $1}' experiment.tab |
    sort -u > $rnaseq_ids

[[ -d rnaseq ]] || mkdir rnaseq
for f in $datfiles
do
    out=rnaseq/$f
    head -1 $f > $out
    join -t $'\t' $rnaseq_ids <(sort $f) >> $out &
done


# ====================================================================
# Merge files
# ====================================================================
cd rnaseq
join -t $'\t' --header study.tab sample.tab |
    join -t $'\t' --header /dev/stdin sample-count.tab > a.tab

# the sample id should equal 5
# sort by sample id
cat <(head -1 a.tab) <(sort -t $'\t' -k 5,5 <(tail -n +2 a.tab)) > b.tab

# sort experiment by sample id
cat <(head -1 experiment.tab) <(sort -t $'\t' -k 3,3 <(tail -n +2 experiment.tab)) > c.tab

join -1 5 -2 3 -t $'\t' --header b.tab c.tab > RNA-seq_sra.tab

rm a.tab b.tab c.tab
cd ..


