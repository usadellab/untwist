#!/bin/bash

DIR=/mnt/data/asis/untwist
cd ${DIR}

# Find all `UNT` accessions in public VCF and write them into a respective
# results file:
grep -m 1 -P '^#CHROM' ./material/NC_all_gatk_CAM_casom_CAMPUB223_54UNT.vcf | sed -e 's/\s\+/\n/g' | grep -P '^UNT_\d+' | paste -sd ',' > ./results/NC_all_gatk_CAM_casom_CAMPUB223_54UNT_accessions_to_exclude.txt;
