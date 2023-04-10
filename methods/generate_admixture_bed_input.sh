#!/bin/bash
#$ -l mem_free=1G,h_vmem=1G       
#$ -pe smp 60
#$ -e /mnt/data/asis/untwist/methods/generate_admixture_bed_input.err
#$ -o /mnt/data/asis/untwist/methods/generate_admixture_bed_input.out

echo "**** Job starts ****"              
date

echo "**** info ****"                    
echo "User: ${USER}"                     
echo "Job id: ${JOB_ID}"                 
echo "Job name: ${JOB_NAME}"             
echo "Hostname: ${HOSTNAME}"             

DIR=/mnt/data/asis/untwist/results
cd ${DIR}

# The following was adapted from
# https://speciationgenomics.github.io/ADMIXTURE/
# last access on 03/16/23
FILE=all_public_and_all_untwist_SNP_filtered

# Generate the input file in plink format
/mnt/bin/plink/plink_1.9/plink --threads 60 --vcf ${FILE}.vcf.gz --make-bed --out $FILE --allow-extra-chr --double-id --vcf-half-call m; 

# ADMIXTURE does not accept chromosome names that are not human chromosomes. We
# will thus just exchange the first column by 0
awk '{$1="0";print $0}' $FILE.bim > $FILE.bim.tmp
mv $FILE.bim.tmp $FILE.bim

echo "**** Job ends ****"
date
