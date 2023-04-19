#!/bin/bash
#$ -l mem_free=3G,h_vmem=3G       
#$ -pe smp 60
#$ -e /mnt/data/asis/untwist/methods/filter_out_SNPs_with_exceeding_heterzygosity.err
#$ -o /mnt/data/asis/untwist/methods/filter_out_SNPs_with_exceeding_heterzygosity.out

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

# Filter out Sites with a heterozygosity above a given threshold. See file
# ./methods/filter_out_SNPs_with_exceeding_heterzygosity.js for details. 
java -jar ./methods/vcffilterjs.jar -f ./methods/filter_out_SNPs_with_exceeding_heterzygosity.js ./results/all_public_and_all_untwist_SNP_filtered_NOT_LD_pruned.vcf.gz | gzip > ./results/all_public_and_all_untwist_SNP_filtered_heterozygosity_NOT_LD_pruned.vcf.gz;

echo "**** Job ends ****"
date
