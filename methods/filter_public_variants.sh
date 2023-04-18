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
# that are the newest sequencing version:
/mnt/bin/bcftools/bcftools-1.9/bcftools view --threads ${NSLOTS} -S ./material/Campub_Accessions.txt -Oz -o ./results/NC_all_gatk_CAM_casom_CAMPUB223_54UNT_valid_samples.vcf.gz ./material/NC_all_gatk_CAM_casom_CAMPUB223_54UNT.vcf

# Index for merging:
/mnt/bin/bcftools/bcftools-1.9/bin/bcftools index --threads ${NSLOTS} ./results/NC_all_gatk_CAM_casom_CAMPUB223_54UNT_valid_samples.vcf.gz

echo "**** Job ends ****"
date
