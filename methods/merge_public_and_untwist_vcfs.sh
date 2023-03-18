
#!/bin/bash
#$ -l mem_free=40G,h_vmem=40G       
#$ -pe smp 20
#$ -e /mnt/data/asis/untwist/methods/merge_public_and_untwist_vcfs.err
#$ -o /mnt/data/asis/untwist/methods/merge_public_and_untwist_vcfs.out

echo "**** Job starts ****"              
date

echo "**** info ****"                    
echo "User: ${USER}"                     
echo "Job id: ${JOB_ID}"                 
echo "Job name: ${JOB_NAME}"             
echo "Hostname: ${HOSTNAME}"             

DIR=/mnt/data/asis/untwist
cd ${DIR}

# First we need to index the two to be merged VCF files:
/mnt/bin/bcftools/bcftools-1.9/bcftools index -f results/NC_all_gatk_CAMPUB223_snpsonly_bcftools_filtered.vcf.gz --threads 20;
/mnt/bin/bcftools/bcftools-1.9/bcftools index -f results/UNT54.raw.merge_bcftools_filtered.vcf.gz --threads 20;

# Now we can merge them:
/mnt/bin/bcftools/bcftools-1.9/bcftools merge --merge all -l methods/vcfList.txt --missing-to-ref -Oz -o results/public_and_untwist_bcftools_filtered.vcf.gz --threads 20;

echo "**** Job ends ****"
date
