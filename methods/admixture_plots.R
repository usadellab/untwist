require(RColorBrewer)
require(dendextend)
require(ape)
require(bnpsd)

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
#' Fix wrong reading of two digits for k:
admxtr_cv_errs <- admxtr_cv_errs[order(admxtr_cv_errs$k), ]

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
#' "Sanitize" the names of the Untwist accessions (lines):
message(
  "Removing trailing '_new' and '_reseq' from the names of Untwist accessions.\n",
  "Uncomment the respective line, if this is not desired."
)
#' Sanitize the names for hierarchcical clustering:
unt_accession_names <- sub(
  "(_new|_reseq)$", "", unt_accession_names
)
rownames(unt_1_min_ibs_mtrx) <- unt_accession_names
#' Read in accession names and sanitize them for the ADMIXTURE barplot:
admxtr_unt_accs <- sub(
  "(_new|_reseq)$", "",
  read.table(
    "./results/all_public_and_all_untwist_SNP_filtered.fam",
    stringsAsFactors = FALSE
  )[[1]]
)


#' hclust
unt_hclust <- hclust(as.dist(unt_1_min_ibs_mtrx), method = "average")


#' Plot Admixture results as barplot for each k:
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
  unt_class_col <- brewer.pal(3, "Set1")
  unt_accs_cols <- unlist(lapply(admxtr_tbl_k$accession, function(acc_id) {
    if (grepl("^UNT", acc_id)) {
      unt_class_col[[1]]
    } else {
      unt_class_col[[2]]
    }
  }))
  unt_dend <- as.dendrogram(unt_hclust)
  labels_colors(unt_dend) <- unt_accs_cols
  labels_cex(unt_dend) <- 0.5
  pdf(
    paste0(
      "./results/all_public_and_all_untwist_SNP_filtered_admixture_k",
      k, "_barplot_IBS_hclust.pdf"
    ),
    width = 21, height = 7
  )
  old_par <- par(mfrow = 2:1)
  par(mar = c(3, 4.1, 4.1, 2.1))
  plot(unt_dend, xlab = "", sub = "", cex = 0.5)
  par(mar = c(5.1, 4.1, 0.5, 2.1))
  barplot(
    t(as.matrix(
      admxtr_tbl_k[, setdiff(colnames(admxtr_tbl_k), "accession")]
    )),
    col = brewer.pal(k, "Set3"), ylab = "Ancestry", border = "black",
    xaxt = "n"
    # las = 2, names.arg = admxtr_tbl_k$accession, cex.names = 0.5
  )
  dev.off()

  #' Plot JUST the dendogram for our partners:
  pdf(
    paste0(
      "./results/all_public_and_all_untwist_SNP_filtered_admixture_k",
      k, "_JUST_IBS_hclust.pdf"
    ),
    width = 21, height = 7
  )
  par(mar = c(3, 4.1, 4.1, 2.1))
  #' Invert the dendrogram, so that the tree grows from the bottom of the plot
  #' upwards, while the leaf labels are on the top. This is achieved by
  #' inverting the ylim arg values in plot and ommiting the xaxt. Then the
  #' labels are drawn manually with mtext.
  plot(
    unt_dend,
    xaxt = "n", sub = "", cex = 0.5, leaflab = "none",
    ylim = c(attr(unt_dend, "height"), 0.0)
  )
  mtext(
    labels(unt_dend),
    side = 3,
    at = seq(1, length(labels(unt_dend))),
    las = 2, cex = 0.5, col = unt_accs_cols
  )
  par(old_par)
  dev.off()

  #' Save the above dendrogam as Newick file, for further processing:

  #' Drop the tips of the non project lines, i.e. drop all public lines, but
  #' retain the topology. And finally store that tree.
  phylo_tree <- as.phylo(unt_dend)
  #' Maintain the order as in the hierarchical clustering dendrogram:
  unt_hclust$labels[unt_hclust$order]

  unt_tree <- drop.tip(
    phylo_tree,
    phylo_tree$tip.label[
      grepl("^CAMPUB_", phylo_tree$tip.label)
    ]
  )
  write.tree(
    unt_tree, paste0(
      "./results/all_public_and_all_untwist_SNP_filtered_admixture_k",
      k, "_JUST_IBS_hclust_ONLY_Untwist_Lines.newick"
    )
  )

  #' And plot the dendrogram in which only the Untwist lines appear, i.e. where
  #' the public lines have been removed from:
  fln <- paste0(
    "./results/all_public_and_all_untwist_SNP_filtered_admixture_k",
    k, "_JUST_IBS_hclust_ONLY_Untwist_Lines.pdf"
  )
  pdf(fln, width = 21, height = 7)
  par(mar = c(3, 4.1, 4.1, 2.1))
  #' Invert the dendrogram, so that the tree grows from the bottom of the plot
  #' upwards, while the leaf labels are on the top. This is achieved by
  #' inverting the ylim arg values in plot and ommiting the xaxt. Then the
  #' labels are drawn manually with mtext.
  unt_dend_no_publ_lns <- as.dendrogram(unt_tree)
  plot(
    unt_dend_no_publ_lns,
    xaxt = "n", sub = "", cex = 0.5, leaflab = "none",
    ylim = c(attr(unt_dend_no_publ_lns, "height"), 0.0)
  )
  mtext(
    labels(unt_dend_no_publ_lns),
    side = 3,
    at = seq(1, length(labels(unt_dend_no_publ_lns))),
    las = 2, cex = 1.0, col = unt_accs_cols[[1]]
  )
  par(old_par)
  dev.off()
  #' Convert to high quality JPG for publication:
  system(
    paste(
      "convert -density 600 -trim",
      fln, "-quality 100", sub("\\.pdf$", ".jpg", fln)
    )
  )
}
