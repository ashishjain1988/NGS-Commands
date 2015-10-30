#!/bin/bash

folderPath=/ptmp/jain/Final_Project/Tophat_Output/*

for f in $folderPath 
do
    if [[ -d $f ]]; then
        #fileName=$(basename $f)
	#echo $f
	align=`awk 'BEGIN{FS=":"}{print $2;}' $f/align_summary.txt | grep "input"`
	echo $(basename $f)" has"$align
    fi
done
