#!/bin/bash
#$ -l mem_free=1G,h_vmem=1G       
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

DIR=/mnt/data/asis/untwist/results
cd ${DIR}

# For documentation, please see
# https://www.cog-genomics.org/plink/1.9/strat
# (last accessed 03/18/23)
/mnt/bin/plink/plink_1.9/plink --threads 20 --double-id --allow-extra-chr --vcf all_public_and_all_untwist_SNP_filtered.vcf.gz --pca 20 header tabs var-wts --make-rel square --out all_public_and_all_untwist_SNP_filtered_pca;

echo "**** Job ends ****"
date
