#!/bin/bash
#$ -l mem_free=3G,h_vmem=3G       
#$ -pe smp 1
#$ -e /mnt/data/asis/untwist/methods/calculate_Fst.err
#$ -o /mnt/data/asis/untwist/methods/calculate_Fst.out

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
DIR=/mnt/data/asis/untwist
cd ${DIR}

# Generate a list of all public Camelina line identifiers (accesions):
/mnt/bin/bcftools/bcftools-1.9/bcftools query -l ./results/all_public_and_all_untwist_SNP_filtered.vcf.gz \
  | grep -P '^CAM' > ./results/all_public_and_all_untwist_SNP_filtered_Public_lines.txt

# Generate a list of all Untwist Camelina line identifiers (accesions):
/mnt/bin/bcftools/bcftools-1.9/bcftools query -l ./results/all_public_and_all_untwist_SNP_filtered.vcf.gz \
  | grep -P '^UNT' > ./results/all_public_and_all_untwist_SNP_filtered_UNT_lines.txt

# Calculate the Fst statistic for all sites (SNPs), comparing public with
# Untwist lines:
/mnt/bin/vcftools/bin/vcftools --gzvcf ./results/all_public_and_all_untwist_SNP_filtered.vcf.gz \
  --out ./results/all_public_and_all_untwist_SNP_filtered_Fst \
  --weir-fst-pop ./results/all_public_and_all_untwist_SNP_filtered_UNT_lines.txt \
  --weir-fst-pop ./results/all_public_and_all_untwist_SNP_filtered_Public_lines.txt

# Clean up:
rm ./results/all_public_and_all_untwist_SNP_filtered_Public_lines.txt \
  ./results/all_public_and_all_untwist_SNP_filtered_UNT_lines.txt

# Compute mean Fst for all sites comparing Untwist with public lines:
Rscript ./methods/calculate_mean_Fst.R

echo "**** Job ends ****"
date
