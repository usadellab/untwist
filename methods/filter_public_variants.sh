#!/bin/bash
#$ -l mem_free=40G,h_vmem=40G       
#$ -pe smp 20
#$ -e /mnt/data/asis/untwist/methods/filter_public_variants.err
#$ -o /mnt/data/asis/untwist/methods/filter_public_variants.out

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
# https://samtools.github.io/bcftools/howtos/filtering.html
# (last accessed 03/18/23)
/mnt/bin/bcftools/bcftools-1.9/bcftools filter -s FilterColumn --threads 20 -i 'QUAL>20 && FORMAT/DP>3' -O z -o results/NC_all_gatk_CAMPUB223_snpsonly_bcftools_filtered.vcf.gz material/NC_all_gatk_CAMPUB223_snpsonly.vcf;

echo "**** Job ends ****"
date
