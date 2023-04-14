#!/bin/bash
#$ -l mem_free=3G,h_vmem=3G       
#$ -pe smp 60
#$ -e /mnt/data/asis/untwist/methods/merge_public_and_untwist_vcfs_and_filter_result.err
#$ -o /mnt/data/asis/untwist/methods/merge_public_and_untwist_vcfs_and_filter_result.out

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


# Select only those accessions (genotypes) that we are allowed to publish and
# that are the newest sequencing version: 
/mnt/bin/bcftools/bcftools-1.9/bcftools view --threads ${NSLOTS} -S ./material/NC_all_gatk_CAM_casom_CAMPUB223_54UNT.vcf --force-samples -Oz -o ./material/NC_all_gatk_CAM_casom_CAMPUB223_54UNT_valid_samples.vcf ./material/NC_all_gatk_CAM_casom_CAMPUB223_54UNT.vcf
/mnt/bin/bcftools/bcftools-1.9/bcftools view --threads ${NSLOTS} -S ./material/NC_all_gatk_CAM_casom_CAMPUB223_54UNT.vcf --force-samples -Oz -o ./material/NC_all_gatk_UNT_check_all_reseq_valid_samples.vcf ./material/NC_all_gatk_UNT_check_all_reseq.vcf


# Merge public and Untwist Camelina variants:
/mnt/bin/bcftools/bcftools-1.9/bin/bcftools index --threads ${NSLOTS} ./material/NC_all_gatk_CAM_casom_CAMPUB223_54UNT_valid_samples.vcf
/mnt/bin/bcftools/bcftools-1.9/bin/bcftools index --threads ${NSLOTS} ./material/NC_all_gatk_UNT_check_all_reseq_valid_samples.vcf
/mnt/bin/bcftools/bcftools-1.9/bin/bcftools merge -l ./material/vcfList.txt -Oz -o ./material/all_public_and_all_untwist_SNP_unfiltered.vcf.gz --threads ${NSLOTS}


# Filter SNPs, retaining:
# - only bi-allelic
# - those who have less than 10% of the genotypes with missing data
# - those with a mapping depth of at least 3
# - those with read quality score of at least 20
# - those with at least minor allele frequency of 0.05
/mnt/bin/bcftools/bcftools-1.9/bcftools view --threads ${NSLOTS} -e '%QUAL<20 || FORMAT/DP<3' -i 'F_MISSING<0.1' -m2 -M2 -v snps -q 0.05:minor -Oz -o ./material/all_public_and_all_untwist_SNP_filtered.vcf.gz ./material/all_public_and_all_untwist_SNP_unfiltered.vcf.gz


echo "**** Job ends ****"
date
