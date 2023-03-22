#/bin/bash
### project name

###$ -N subsample
###$ -N merge
###$ -N Filters1
#$ -N Filters2

### output folder for log files
#$ -o ./logs 

### combine output/error message into one file
#$ -j y

### current working directory
#$ -cwd

### number of cores to be used
#$ -pe smp 20

### memory requirement for this job
#$ -l h_vmem=1g

### Redirect to run on spike (another option -P LowPriority.p, BigMem.p, Test.p or just leave out for default queue)
#$ -P Test.p


## script

# subsample
#/mnt/bin/bcftools/bcftools-1.9/bcftools view --threads ${NSLOTS} -S CAMPUBsamples.txt -Oz -o CAMPPUBonly.vcf.gz NC_all_gatk_CAM_casom_CAMPUB223_54UNT.vcf
#/mnt/bin/bcftools/bcftools-1.9/bcftools view --threads ${NSLOTS} -S UNTWISTsamples.txt -Oz -o UNTWISTonly.vcf.gz NC_all_gatk_UNT_check_all_reseq.vcf


# merge
#/mnt/bin/bcftools/bcftools-1.9/bin/bcftools index --threads ${NSLOTS} CAMPUBonly.vcf.gz
#/mnt/bin/bcftools/bcftools-1.9/bin/bcftools index --threads ${NSLOTS} UNTWISTonly.vcf.gz
#/mnt/bin/bcftools/bcftools-1.9/bin/bcftools merge -l vcfList.txt -Oz -o all_public_and_all_untwist_SNP.vcf.gz --threads ${NSLOTS}


# Filters1
#/mnt/bin/bcftools/bcftools-1.9/bcftools view --threads ${NSLOTS} -i 'F_MISSING<0.1' -m2 -M2 -v snps -q 0.05:minor -Oz -o all_public_and_all_untwist_GTMissing10Percent_MAF05_bialleicSNPs.vcf.gz all_public_and_all_untwist_SNP.vcf.gz


#Filters2
/mnt/bin/bcftools/bcftools-1.9/bcftools filter -s LowQual -e '%QUAL<20 || FORMAT/DP<3' -Oz -o all_public_and_all_untwist_SNP_filtered.vcf.gz --threads ${NSLOTS} all_public_and_all_untwist_GTMissing10Percent_MAF05_bialleicSNPs.vcf.gz
