#' Read results of Fst calculation done for each site (SNP):
fst <- read.table(
  "./results/all_public_and_all_untwist_SNP_filtered_Fst.weir.fst",
  header = TRUE
)

#' Normalize the Fst data, i.e. set negative values to zero:
x <- fst$WEIR_AND_COCKERHAM_FST
x[which(x < 0)] <- 0

#' Compute the mean Fst for all sites:
mean_fst <- mean(x)

#' Save results to the output-file:
writeLines(
  paste(
    "Mean Fst for all sites, comparing Untwist with public lines:",
    mean_fst,
    sep = "\t"
  ),
  "./results/mean_Fst.txt"
)
