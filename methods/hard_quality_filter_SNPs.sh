#!/bin/bash
#$ -l mem_free=1G,h_vmem=1G       
#$ -pe smp 20
#$ -e /mnt/data/asis/untwist/methods/hard_quality_filter_SNPs.err
#$ -o /mnt/data/asis/untwist/methods/hard_quality_filter_SNPs.out

echo "**** Job starts ****"              
date

echo "**** info ****"                    
echo "User: ${USER}"                     
echo "Job id: ${JOB_ID}"                 
echo "Job name: ${JOB_NAME}"             
echo "Hostname: ${HOSTNAME}"             

DIR=/mnt/data/asis/untwist
cd ${DIR}

/mnt/bin/bcftools/bcftools-1.9/bcftools filter -e '%QUAL<20 || FORMAT/DP<3' -Oz -o ./results/all_public_and_all_untwist_SNP_filtered_hard.vcf.gz --threads 20 ./results/all_public_and_all_untwist_SNP_filtered_from_ata.vcf.gz

echo "**** Job ends ****"
date
