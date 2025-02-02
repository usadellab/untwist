#!/bin/bash
#$ -l mem_free=1G,h_vmem=1G       
#$ -pe smp 20
#$ -e /mnt/data/asis/untwist/methods/complete_linkage_clustering.err
#$ -o /mnt/data/asis/untwist/methods/complete_linkage_clustering.out

echo "**** Job starts ****"              
date

echo "**** info ****"                    
echo "User: ${USER}"                     
echo "Job id: ${JOB_ID}"                 
echo "Job name: ${JOB_NAME}"             
echo "Hostname: ${HOSTNAME}"             

DIR=/mnt/data/asis/untwist
cd ${DIR}

# Carry out complete linkage clustering on IBS distances:
/mnt/bin/plink/plink_1.9/plink --double-id --allow-extra-chr --vcf results/all_public_and_all_untwist_SNP_filtered.vcf.gz --out results/all_public_and_all_untwist_SNP_filtered_complete_linkage_clustering --cluster --threads 20;

echo "**** Job ends ****"
date
