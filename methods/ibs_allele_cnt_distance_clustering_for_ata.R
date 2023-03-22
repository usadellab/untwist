require(cluster)

#' Set working directory
if (dir.exists("/mnt/data/asis/untwist/")) {
  setwd("/mnt/data/asis/untwist/")
}

#' The following clusters the accessions based on 1-IBS distances
#' --------------------------------------------------------------

#' Load distance matrix:
unt_1_min_ibs_mtrx <- read.table(
  "results/all_public_and_all_untwist_SNP_filtered.mdist",
  stringsAsFactors = FALSE
)
#' Read and set the row (accession) identifier. Clean them, because PLINK had
#' to duplicate them, see plink --double-id
unt_accession_names <- sub(
  "\\t\\S+$", "",
  readLines(
    "results/all_public_and_all_untwist_SNP_filtered.mdist.id"
  )
)
rownames(unt_1_min_ibs_mtrx) <- unt_accession_names

#' hclust
unt_hclust <- hclust(as.dist(unt_1_min_ibs_mtrx), method = "average")
pdf("./results/hclust_on_1_min_IBS_tree_for_ata.pdf", width = 21, height = 7)
plot(unt_hclust, cex=0.5)
dev.off()


#' The following clusters the accessions based on allele count distances:
#' --------------------------------------------------------------

#' Load distance matrix:
unt_1_min_ibs_mtrx <- read.table(
  "results/all_public_and_all_untwist_SNP_filtered.dist",
  stringsAsFactors = FALSE
)
#' Read and set the row (accession) identifier. Clean them, because PLINK had
#' to duplicate them, see plink --double-id
unt_accession_names <- sub(
  "\\t\\S+$", "",
  readLines(
    "results/all_public_and_all_untwist_SNP_filtered.dist.id"
  )
)
rownames(unt_1_min_ibs_mtrx) <- unt_accession_names

#' hclust
unt_hclust <- hclust(as.dist(unt_1_min_ibs_mtrx), method = "average")
pdf("./results/hclust_on_allele_cnts_tree_for_ata.pdf", width = 21, height = 7)
plot(unt_hclust, cex=0.5)
dev.off()
