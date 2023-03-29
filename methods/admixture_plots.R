require(ggplot2)
require(ggdendro)
require(tidyr)

#' Set working directory
if (dir.exists("/mnt/data/asis/untwist/")) {
  setwd("/mnt/data/asis/untwist/")
}

#' Load Admixture cross validation results:
admxtr_cv_errs <- do.call(rbind, lapply(system(
  "ls results/all_public_and_all_untwist_SNP_filtered_admixture_k*.cv.error",
  intern = TRUE
), function(x) {
  read.table(x,
    sep = " ",
    stringsAsFactors = FALSE,
    col.names = c("k", "cross.validation.error")
  )
}))

#' Plot Admixture cross validation errors
pdf(
  "./results/all_public_and_all_untwist_SNP_filtered_admixture_cv_error_scatter_plot.pdf"
)
plot(admxtr_cv_errs[, "k"],
  admxtr_cv_errs[, "cross.validation.error"],
  type = "b", xlab = "Number of populations (k)",
  ylab = "Cross Validation Error", xaxt = "n"
)
axis(1, at = admxtr_cv_errs[, "k"])
dev.off()

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


#' Plot Admixture results as barplot for each k:
admxtr_unt_accs <- read.table(
  "./results/all_public_and_all_untwist_SNP_filtered.fam",
  stringsAsFactors = FALSE
)[[1]]

for (k in admxtr_cv_errs[, "k"]) {
  #' Read in Admixture results for current k:
  admxtr_tbl_k <- read.table(paste0(
    "results/all_public_and_all_untwist_SNP_filtered.", k, ".Q"
  ), stringsAsFactors = FALSE)
  admxtr_tbl_k$accession <- admxtr_unt_accs

  #' Order the table so it matches the result of above `hclust`:
  admxtr_tbl_k <-
    admxtr_tbl_k[
      match(unt_hclust$labels[unt_hclust$order], admxtr_tbl_k$accession),
    ]
  #' Save the table:
  write.table(admxtr_tbl_k, paste0(
    "./results/all_public_and_all_untwist_SNP_filtered_admixture_k",
    k, "_result_table.tsv"
  ),
  sep = "\t", row.names = FALSE, quote = FALSE
  )

  #' Plot
  pdf(
    paste0(
      "./results/all_public_and_all_untwist_SNP_filtered_admixture_k",
      k, "_barplot_IBS_hclust.pdf"
    ),
    width = 21, height = 7
  )
  old_par <- par(mfrow = 2:1)
  plot(unt_hclust, xlab = "", sub = "", cex = 0.5)
  barplot(
    t(as.matrix(
      admxtr_tbl_k[, setdiff(colnames(admxtr_tbl_k), "accession")]
    )),
    col = rainbow(k), ylab = "Ancestry", border = "black", las = 2,
    names.arg = admxtr_tbl_k$accession, cex.names = 0.5
  )
  dev.off()

  #' Generate a circular tree plot with barplots attached to each leaf.
  #' See
  #' https://stackoverflow.com/questions/69227317/create-a-circular-phylogeny-with-stacked-bar-in-r
  #' (last accessed 03/29/2023)
  unt_tree <- dendro_data(unt_hclust)
  admxtr_tibble_k <- pivot_longer(admxtr_tbl_k, paste0("V", 1:3))
  scale <- 15
  ax <- length(unique(admxtr_tibble_k$accession))
  gg_plot <- ggplot() +
    geom_col(
      data = admxtr_tibble_k,
      aes(
        x = accession,
        y = value, fill = factor(name)
      )
    ) +
    geom_segment(
      data = unt_tree$segments,
      aes(x = x, y = -y * scale, xend = xend, yend = -yend * scale)
    ) +
    coord_polar() +
    theme_minimal(axis.line=element_blank(),
      axis.text.x=element_blank(),
      axis.text.y=element_blank(),
      axis.ticks=element_blank(),
      axis.title.x=element_blank(),
      axis.title.y=element_blank(),
      legend.position="none",
      panel.background=element_blank(),
      panel.border=element_blank(),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      plot.background=element_blank()) +
    #' theme_dendro() +
    theme(
      legend.position = "none"
    )
}
