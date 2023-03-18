#!/bin/bash
#$ -l mem_free=40G,h_vmem=40G       
#$ -pe smp 20
#$ -e /mnt/data/asis/untwist/methods/principal_component_analysis.err
#$ -o /mnt/data/asis/untwist/methods/principal_component_analysis.out

echo "**** Job starts ****"              
date

echo "**** info ****"                    
echo "User: ${USER}"                     
echo "Job id: ${JOB_ID}"                 
echo "Job name: ${JOB_NAME}"             
echo "Hostname: ${HOSTNAME}"             

DIR=/mnt/data/asis/untwist
cd ${DIR}

# For documentation, please see
# https://www.cog-genomics.org/plink/1.9/strat
# (last accessed 03/18/23)
/mnt/bin/plink/plink_1.9/plink --threads 20 --double-id --allow-extra-chr --vcf results/public_and_untwist_bcftools_and_plink_filtered.vcf.gz --pca 20 header tabs var-wts --make-rel square --out results/public_and_untwist_bcftools_and_plink_filtered_pca;

echo "**** Job ends ****"
date
