library(SNPRelate)

w_d <- '/mnt/data/asis/untwist'
if (dir.exists(w_d)) {
  setwd(w_d)
}

vcf_fn <- "./results/all_public_and_all_untwist_SNP_filtered_from_ata.vcf.gz"
gds_fn <-  "./results/all_public_and_all_untwist_SNP_filtered.gds"
snpgdsVCF2GDS(vcf_fn, gds_fn)

genofile <- snpgdsOpen(gds_fn)
snpset <- snpgdsLDpruning(genofile, ld.threshold=0.4)
