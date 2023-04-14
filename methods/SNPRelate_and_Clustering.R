require(ape)
require(cluster)

#' Set working directory
setwd("D:/SCIEBO_2/00_Institut IBG-4/05_Projects/01_Running Projects/UNTWIST_F_ASIS/Papers/PCA_KMEANS_FINAL")


#' The following clusters the accessions based on 1-IBS distances
#' --------------------------------------------------------------

#' Load distance matrix:
unt_1_min_ibs_mtrx <- read.table(
  "all_public_and_all_untwist_SNP_filtered.mdist",
  stringsAsFactors = FALSE
)
#' Read and set the row (accession) identifier. Clean them, because PLINK had
#' to duplicate them, see plink --double-id
unt_accession_names <- sub(
  "\\t\\S+$", "",
  readLines(
    "all_public_and_all_untwist_SNP_filtered.mdist.id"
  )
)
rownames(unt_1_min_ibs_mtrx) <- unt_accession_names

#' hclust
unt_hclust <- hclust(as.dist(unt_1_min_ibs_mtrx), method = "average")
#' Save a newick tree of the hclust result:
write.tree(
  as.phylo(unt_hclust),
  "./results/hclust_on_1_min_IBS_tree.newick"
)
#' Plot the hclust result
cu<-cutree(unt_hclust, k = 3) 
pdf("./results/hclust_on_1_min_IBS_tree.pdf", width = 21, height = 7)

plot(unt_hclust, cex = 0.5)
rect.hclust(unt_hclust,k=3, border=c("red","blue","yellow"))
x11()

#tassel direct
tassel_direct <- read.table(
  "tassel_direct.txt",
  stringsAsFactors = FALSE, header=FALSE, row.names=1
)
colnames(tassel_direct) <-rownames(tassel_direct)

#tassel filtered
tassel_filtered <- read.table(
  "Tassel_direct_filtered_thinned1k.txt",
  stringsAsFactors = FALSE, header=FALSE, row.names=1
)
colnames(tassel_filtered) <-rownames(tassel_filtered)


tassel_hclust <- hclust(as.dist(tassel_direct), method = "average")
tassel_filtered_hclust <- hclust(as.dist(tassel_filtered), method = "average")

plot(tassel_hclust, cex = 0.5)
rect.hclust(tassel_hclust,k=3, border=c("red","blue","yellow"))

x11()
plot(tassel_filtered_hclust,cex =0.5)
rect.hclust(tassel_hclust,k=3, border=c("red","blue","yellow"))



library(dendextend)


cor_cophenetic(tassel_hclust, unt_hclust)
#0.93
cor_cophenetic(tassel_hclust, unt_hclust, method = "spearman")
#0.84
cor_cophenetic(tassel_hclust, tassel_filtered_hclust, method = "spearman")
#0.77


k3_unt<-cutree(unt_hclust, k = 3) 
k3_tassel<-cutree(tassel_hclust, k = 3) 
k3_tassel_filtered<-cutree(tassel_filtered_hclusthclust, k = 3)
table(k3_unt,k3_tassel)



k6_unt<-cutree(unt_hclust, k = 6) 
k6_tassel<-cutree(tassel_hclust, k = 6) 
k6_tassel_filtered<-cutree(tassel_filtered_hclust, k = 6)
table(k6_unt,k6_tassel)


#########################
##
# 
#   End of comparison
#
#
########################

#########################
##
# 
#   start SNPRelate
#
#
########################


library(SNPRelate)
#commented as file has been produced
#vcf.fn <- "all_public_and_all_untwist_SNP_filtered.vcf.gz"
#snpgdsVCF2GDS(vcf.fn, "test.gds", method="biallelic.only")

genofile <- snpgdsOpen("test.gds")
snpset <- snpgdsLDpruning(genofile, ld.threshold=0.2)

# not used ibd calcultaion
#ibd <- snpgdsIBDMoM(genofile, maf=0.05, missing.rate=0.05, num.thread=2,  autosome.only=FALSE)
ibs <- snpgdsIBS(genofile, num.thread=2,  autosome.only=FALSE)


ibs<-snpgdsIBS(genofile, num.thread=2,  autosome.only=FALSE)
ibs.hc <- snpgdsHCluster(ibs)
rv <- snpgdsCutTree(ibs.hc)
tanglegram(as.dendrogram(unt_hclust), rv$dendrogram)
#looks perfect

repl<-gsub("CAMPUB_","C_",ibs$sample.id )
repl<-gsub("_\\D+$","",repl )
repl<-gsub("UNT_","U_",repl )
ibs$sample.id<-repl

#we run this again to have clear data
ibs.hc <- snpgdsHCluster(ibs)
rv <- snpgdsCutTree(ibs.hc)
#produces Figure XX1
plot(rv$dendrogram, main="UNTWIST")  

#produces Figure XX1 Alternative
library(circlize)
par(cex=0.5)
plot(rv$dendrogram,  main="UNTWIST",cex=0.2)
circlize_dendrogram(rv$dendrogram)

par(cex=1)
cor_cophenetic(as.dendrogram(tassel_hclust), rv$dendrogram, method = "spearman")
cor_cophenetic(as.dendrogram(unt_hclust), rv$dendrogram, method = "spearman")
cor_cophenetic(as.dendrogram(unt_hclust), rv$dendrogram)
tanglegram(as.dendrogram(unt_hclust), rv$dendrogram)
cor_cophenetic(tassel_hclust, tassel_filtered_hclust, method = "spearman")



pca <- snpgdsPCA(genofile,  num.thread=2, autosome.only=FALSE)
pc.percent <- round(pca$varprop*100,2)
head(round(pc.percent, 2))

tab <- data.frame(sample.id = pca$sample.id,
    EV1 = pca$eigenvect[,1],    # the first eigenvector
    EV2 = pca$eigenvect[,2],    # the second eigenvector
    stringsAsFactors = FALSE)
head(tab)


tab$sample.id 
repl<-gsub("CAMPUB_","C_",tab$sample.id )
repl<-gsub("_\\D+$","",repl )
repl<-gsub("UNT_","U_",repl )
tab$sample.id <-repl

#check if colinear only TRUEs allowed
tab$sample.id == rv$sample.id

#set character size
ce<-rep(0.5,223)
#and larger for UNT
ce[ grep("U_",repl)]<-0.9


#u40 U29 should be green
#produces Figure XX2
plot(tab$EV1, tab$EV2, xlab=paste("EV 1",pc.percent[1]), 
ylab=paste("EV 2",pc.percent[2]),pch="",col=rv$samp.group)
text(tab$EV1, tab$EV2, repl ,cex=ce,col=c("black","red","green")[as.integer(rv$samp.group)])


cor_cophenetic(tassel_hclust, tassel_filtered_hclust, method = "spearman")



#############
####LD pruning not used
#
snpset <- snpgdsLDpruning(genofile, ld.threshold=0.4, autosome.only=FALSE)
snp.id <- unlist(unname(snpset))
x11()
#try with LD pruning
ibs.hc.f <- snpgdsHCluster(snpgdsIBS(genofile, num.thread=2, snp.id=snp.id , autosome.only=FALSE))
rv.f <- snpgdsCutTree(ibs.hc.f)

##########

