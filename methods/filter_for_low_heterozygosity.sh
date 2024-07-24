#!/bin/bash
#$ -l mem_free=1G,h_vmem=1G       
#$ -pe smp 20
#$ -e /mnt/data/project/asis_TO_SORT/untwist/methods/filter_for_low_heterozygosity.err
#$ -o /mnt/data/project/asis_TO_SORT/untwist/methods/filter_for_low_heterozygosity.out

echo "**** Job starts ****"              
date

echo "**** info ****"
echo "User: ${USER}"
echo "Job id: ${JOB_ID}"
echo "Job name: ${JOB_NAME}"
echo "Hostname: ${HOSTNAME}"
echo "Number of threads: ${NSLOTS}"
echo "****------****"


# Set working directory:
DIR=/mnt/data/project/asis_TO_SORT/untwist
cd ${DIR}


# Exclude all sites with an heterozygocity rate above the below threshold:
/mnt/bin/bcftools/bcftools-1.20/bin/bcftools view -i 'F_PASS(GT="het")<0.5 && F_PASS(GT="het")>0.0 && F_PASS(GT="ref")>0.0 && F_PASS(GT="hom")>0.0' --threads ${NSLOTS} -Oz -o ./results/all_public_and_all_untwist_SNP_filtered_heterozygosity_bcf_NOT_LD_pruned.vcf.gz ./results/all_public_and_all_untwist_SNP_filtered_NOT_LD_pruned.vcf.gz;


echo "**** Job ends ****"
date
