#!/bin/bash
#$ -l mem_free=40G,h_vmem=40G       
#$ -pe smp 20
#$ -e /mnt/data/asis/untwist/methods/admixture_k3.err
#$ -o /mnt/data/asis/untwist/methods/admixture_k3.out

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
FILE=results/public_and_untwist_bcftools_and_plink_filtered

# Try the following number of populations:
i=3
/mnt/data/asis/software/dist/admixture_linux-1.3.0/admixture -j20 --cv $FILE.bed $i > ${FILE}_admixture_k${i}.out

# Print the cross validation performance for each of the above runs:
awk '/CV/ {print $3,$4}' ${FILE}_admixture_k${i}.out | cut -c 4,7-20 > ${FILE}_admixture_k${i}.cv.error

# END ADMIXTURE script

echo "**** Job ends ****"
date
