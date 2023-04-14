#!/bin/bash
#$ -l mem_free=3G,h_vmem=3G       
#$ -pe smp 60
#$ -e /mnt/data/asis/untwist/methods/filter_public_variants.err
#$ -o /mnt/data/asis/untwist/methods/filter_public_variants.out

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
# that are the newest sequencing version. And also filter SNPs, retaining:
# - only bi-allelic
# - those who have less than 10% of the genotypes with missing data
# - those with a mapping depth of at least 3 (> 2)
# - those with read quality score of at least 20 (> 19)
# - those with at least minor allele frequency of 0.05
/mnt/bin/bcftools/bcftools-1.9/bcftools view --threads ${NSLOTS} -S ./material/Campub_Accessions.txt -i '%QUAL>19 && FORMAT/DP>2 && F_MISSING<0.1' -m2 -M2 -v snps -q 0.05:minor -Oz -o ./results/NC_all_gatk_CAM_casom_CAMPUB223_54UNT_valid_samples_filtered.vcf.gz ./material/NC_all_gatk_CAM_casom_CAMPUB223_54UNT.vcf

# Index for merging:
/mnt/bin/bcftools/bcftools-1.9/bin/bcftools index --threads ${NSLOTS} ./results/NC_all_gatk_CAM_casom_CAMPUB223_54UNT_valid_samples_filtered.vcf.gz

echo "**** Job ends ****"
date
