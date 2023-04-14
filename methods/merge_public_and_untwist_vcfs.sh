#!/bin/bash
#$ -l mem_free=3G,h_vmem=3G       
#$ -pe smp 60
#$ -e /mnt/data/asis/untwist/methods/merge_public_and_untwist_vcfs.err
#$ -o /mnt/data/asis/untwist/methods/merge_public_and_untwist_vcfs.out

echo "**** Job starts ****"              
date

echo "**** info ****"                    
echo "User: ${USER}"                     
echo "Job id: ${JOB_ID}"                 
echo "Job name: ${JOB_NAME}"             
echo "Hostname: ${HOSTNAME}"             
echo "Number of threads: ${NSLOTS}"
echo "****------****"                    

DIR=/mnt/data/asis/untwist
cd ${DIR}

# Merge the two respective variant matrices (VCF files):
/mnt/bin/bcftools/bcftools-1.9/bcftools merge --merge all -l methods/vcfList.txt -Oz -o ./results/all_public_and_all_untwist_SNP_filtered_NOT_LD_pruned.vcf.gz --threads ${NSLOTS};

echo "**** Job ends ****"
date
