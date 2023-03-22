#!/bin/bash
#$ -l mem_free=1G,h_vmem=1G       
#$ -pe smp 20
#$ -e /mnt/data/asis/untwist/methods/generate_IBS_and_allele_count_distances.err
#$ -o /mnt/data/asis/untwist/methods/generate_IBS_and_allele_count_distances.out

echo "**** Job starts ****"              
date

echo "**** info ****"                    
echo "User: ${USER}"                     
echo "Job id: ${JOB_ID}"                 
echo "Job name: ${JOB_NAME}"             
echo "Hostname: ${HOSTNAME}"             

DIR=/mnt/data/asis/untwist/results
cd ${DIR}

# Apply the filtering and write a bed-file:
/mnt/bin/plink/plink_1.9/plink --threads 20 --vcf all_public_and_all_untwist_SNP_filtered.vcf.gz --out all_public_and_all_untwist_SNP_filtered --distance square 1-ibs allele-ct --allow-extra-chr --double-id;

echo "**** Job ends ****"
date
