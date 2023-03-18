#!/bin/bash
#$ -l mem_free=40G,h_vmem=40G       
#$ -pe smp 20
#$ -e /mnt/data/asis/untwist/methods/filter_merged_public_and_untwist_vcf.err
#$ -o /mnt/data/asis/untwist/methods/filter_merged_public_and_untwist_vcf.out

echo "**** Job starts ****"              
date

echo "**** info ****"                    
echo "User: ${USER}"                     
echo "Job id: ${JOB_ID}"                 
echo "Job name: ${JOB_NAME}"             
echo "Hostname: ${HOSTNAME}"             

DIR=/mnt/data/asis/untwist
cd ${DIR}

# Apply the filtering and write a bed-file:
#/mnt/bin/plink/plink_1.9/plink --vcf results/public_and_untwist_bcftools_filtered.vcf.gz --recode vcf bgz --out results/public_and_untwist_bcftools_and_plink_filtered --allow-extra-chr --maf 0.05 --biallelic-only --hwe 0.001 --double-id --vcf-half-call m;
/mnt/bin/plink/plink_1.9/plink --vcf results/public_and_untwist_bcftools_filtered.vcf.gz --recode vcf bgz --out results/public_and_untwist_bcftools_and_plink_filtered --allow-extra-chr --maf 0.05 --biallelic-only --double-id --vcf-half-call m --mind 0.1;

echo "**** Job ends ****"
date
