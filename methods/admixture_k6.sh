#!/bin/bash
#$ -l mem_free=1G,h_vmem=1G       
#$ -pe smp 60
#$ -e /mnt/data/asis/untwist/methods/admixture_k6_torque.err
#$ -o /mnt/data/asis/untwist/methods/admixture_k6_torque.out

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

# Try the following number of populations:
i=6
/mnt/data/asis/software/dist/admixture_linux-1.3.0/admixture -j60 --cv $FILE.bed $i > ${FILE}_admixture_k${i}.out

# Print the cross validation performance for each of the above runs:
awk '/CV/ {print $3,$4}' ${FILE}_admixture_k${i}.out | cut -c 4,7-20 > ${FILE}_admixture_k${i}.cv.error

# END ADMIXTURE script

echo "**** Job ends ****"
date
