
#!/bin/bash
#$ -l mem_free=20G,h_vmem=20G       
#$ -pe smp 1
#$ -e /mnt/data/asis/untwist/methods/filter_out_LD_correlated_SNPs.err
#$ -o /mnt/data/asis/untwist/methods/filter_out_LD_correlated_SNPs.out

echo "**** Job starts ****"              
date

echo "**** info ****"                    
echo "User: ${USER}"                     
echo "Job id: ${JOB_ID}"                 
echo "Job name: ${JOB_NAME}"             
echo "Hostname: ${HOSTNAME}"             

DIR=/mnt/data/asis/untwist
cd ${DIR}

/mnt/bin/bcftools/bcftools-1.9/bcftools +prune -l0.9 -w 10kb -Oz -o ./results/all_public_and_all_untwist_SNP_filtered.vcf.gz ./results/all_public_and_all_untwist_SNP_filtered_heterozygosity_NOT_LD_pruned.vcf.gz;

echo "**** Job ends ****"
date
