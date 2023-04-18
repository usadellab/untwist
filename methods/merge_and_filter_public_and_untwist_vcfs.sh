#!/bin/bash
#$ -l mem_free=3G,h_vmem=3G       
#$ -pe smp 60
#$ -e /mnt/data/asis/untwist/methods/merge_and_filter_public_and_untwist_vcfs.err
#$ -o /mnt/data/asis/untwist/methods/merge_and_filter_public_and_untwist_vcfs.out

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
/mnt/bin/bcftools/bcftools-1.9/bcftools merge --merge all -l methods/vcfList.txt -Oz -o ./results/all_public_and_all_untwist_SNP_UNFILTERED.vcf.gz --threads ${NSLOTS};

# And also filter variants, retaining:
# - only SNPs
# - only bi-allelic SNPs
# - those SNPs who have less than 10% of the genotypes with missing data
# - those SNPs with a mapping depth of at least 3 
# - those SNPs with read quality score of at least 20
# - those SNPs with at least minor allele frequency of 0.05
/mnt/bin/bcftools/bcftools-1.9/bcftools view --threads ${NSLOTS} -i '%QUAL>=20 & FORMAT/DP>=3 & F_MISSING<0.1' -m2 -M2 -v snps -q 0.05:minor -Oz -o ./results/all_public_and_all_untwist_SNP_filtered_NOT_LD_pruned.vcf.gz ./results/all_public_and_all_untwist_SNP_UNFILTERED.vcf.gz;

echo "**** Job ends ****"
date
