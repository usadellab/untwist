# untwist

Usadellab's contributions to the Untwist project.

## Location on the IBG-4 cluster  
/mnt/data/achraf/sequenced_samples/runs/pipe_20210803_UNTWIST/020_SelectVariants-c-CAM_casom_CAMPUB223_54UNT-snps-DP10FORMAT-hom-maf-geno  
7d0cd0ed7184f080dcdcc3fa5905c333  NC_all_gatk_CAM_casom_CAMPUB223_54UNT_snpsonly-DP10FORMAT-hom_maf_geno_vcisnotfiltered.vcf  

##Ata 
/mnt/data/ata/CAMPUB  
UNT54-CAMPUB.merged2.vcf.gz 0dbed9a97c4891ded9fef09bcba8a1e8  
size uncompressed 19629699072 wc-c ca 19.2 GB  
uncompressed md5 cdc839d8604266162e2f1c9b70158956  

/mnt/data/ata/UNTWIST_NEW/vcfFiltered/Merge1  
UNT54.bam.vcf.merged2.gz  
has both original and reseq runs  

UNT54.raw.merged.vcf.gz  
seems to only have reseq samples  

Go to `/mnt/data/asis/untwist` to find the local clone of this repository.

##Files
achraf


## Directory structure

This project has the following directory structure:
```sh
- material
- methods
- results
```

Note that `material` and `results` are ignored by git, because they contain
sensitive data and extremely large files. You'll find the files in the local
clone.

## Population Structure Analysis

Identification of populations and assignment to them of public and Untwist
Camelina accessions is the goal of this sub-project.

### Material

#### Public data

We obtain single nucleotide polymorphism from Ashraf's previous work. The data
is delivered in VCF format and found here:
```sh
/mnt/data/achraf/sequenced_samples/runs/pipe_20210803_UNTWIST/013_gathervcfs_c-CAM_casom_CAMPUB223_54UNT/NC_all_gatk_CAM_casom_CAMPUB223_54UNT.vcf
```
Note that this data has been filtered to contain only SNPs and no insertions or
deletions (InDels).

Find a symbolic link to this public data and its index `[...].idx` in
`material`.

#### Untwist data

This is obtained as a raw variant calling result file provided by Ashraf. The
data is delivered in VCF format (gzip) and is found here:
```sh
/mnt/data/achraf/sequenced_samples/runs/pipe_20210803_UNTWIST/015_SelectVariants-UNT-check-snps-all-reseq/NC_all_gatk_UNT_check_snps_all_reseq.vcf
```

Find a symbolic link to this public data and its index `[...].idx` in
`material`.

### Methods

This section describes step by step how the above material is processed to
identify populations and assign accessions to them.

#### Merging of public and Untwist variant data

##### Exclude doubly appearing accessions

Both the above public and Untwist variant data matrices (VCF files) contain
some `UNT` accessions that need to be excluded from one file, before merging.
One example of these accessions, that appear in both files is `UNT_001`.

We thus exclude all accessions that 
- have an identifier starting with `UNT` and 
- that appear in the public VCF file
from the Untwist VCF file.

The procedure is documented and implemented in method script:
```sh
./methods/filter_Untwist_vcf_drop_UNT_accessions_present_in_public_vcf.sh
```

All to be excluded `UNT_[0-9]+` accession identifier are stored in file
`./results/NC_all_gatk_CAM_casom_CAMPUB223_54UNT_accessions_to_exclude.txt`.

#### Filtering of variant data

We use bcftools to apply the following filters:
- read coverage > 3
- sequence quality > 20
- retain only SNPs, i.e. remove InDels

##### Filter public data

The `bcftools` instructions are in file `methods/filter_public_variants.sh`.
The file was submitted to our job queue using
`qsub methods/filter_public_variants.sh`

This step produces
`results/NC_all_gatk_CAM_casom_CAMPUB223_54UNT_bcftools_filtered.vcf.gz`.

##### Filter Untwist data

Note that in this step we additionally _exclude_ all `UNT_[0-9]+` accessions
that were identified in the above step "Exclude doubly appearing accessions".

The `bcftools` instructions are in file `methods/filter_untwist_variants.sh`.
The file was submitted to our job queue using
`qsub methods/filter_untwist_variants.sh`

This step produces
`results/NC_all_gatk_UNT_check_snps_all_reseq_bcftools_filtered.vcf.gz`.

##### Merge filtered public and Untwist SNP variants

We use `bcftools merge`, find the detailed instructions in file
`methods/merge_public_and_untwist_vcfs.sh`. Submitted to our job queue using
`qsub -hold_jid <id-of-job> methods/merge_public_and_untwist_vcfs.sh` Note that
using `-hold_jid <ID of job>` the newly submitted job will only start when the
other job finished. Filtering the Untwist data was still running.

It is important to note, that we do _not_ use the `--missing-to-ref` flag,
which causes genotypes at missing sites to be interpreted as `0/0`.

This step produces `results/public_and_untwist_bcftools_filtered.vcf.gz`.

##### Filter merged SNP Variant Matrix

We want to filter the merged SNP Variant Matrix
`results/public_and_untwist_bcftools_filtered.vcf.gz` further.
Using `plink` (version 1.9) we apply the following filter criteria:
- discard SNPs that are not bi-allelic
- discard SNPs that have a minor allele frequency (MAF) <= 0.05
- discard SNPs that have '0/.' and similar VCF GT values; treat them as
  missing.

Currently, we do _not_ apply filters that
- discard SNPs that are not in Hardy-Weinberg-Equilibrium 

Detailed instructions for `plink` are in the file 
`methods/filter_merged_public_and_untwist_vcf.sh`. Submitted, awaiting
queued jobs for the previous filtering and merging with 
`qsub -hold_jid <id-of-job> methods/filter_merged_public_and_untwist_vcf.sh`.

This step produces
`results/public_and_untwist_bcftools_and_plink_filtered.[log|nosex|vcf.gz]`.

### Complete Linkage Clustering based on identity by state (IBS) distances

This clustering is carried out using `plink` (version 1.9).

See the script `./methods/complete_linkage_clustering.sh` which was submitted
to our job-queue.

This step produces the following result files:
```sh
./results/public_and_untwist_bcftools_and_plink_filtered_complete_linkage_clustering.cluster1
./results/public_and_untwist_bcftools_and_plink_filtered_complete_linkage_clustering.cluster2
./results/public_and_untwist_bcftools_and_plink_filtered_complete_linkage_clustering.cluster3
./results/public_and_untwist_bcftools_and_plink_filtered_complete_linkage_clustering.log
./results/public_and_untwist_bcftools_and_plink_filtered_complete_linkage_clustering.nosex
```

Note that the clusters are contained in file `...cluster1`, one cluster per
line separated by the cluster name a `<TAB>` and the cluster members comma
separated.

### Principal Component Analysis

We use `plink` (version 1.9) to carry out a principal component analysis of the
SNP variants.

Find the `plink` instructions in File
`./methods/principal_component_analysis.sh`. Submitted to our job-queue with
`qsub methods/principal_component_analysis.sh`.

This step produces
`./results/public_and_untwist_bcftools_and_plink_filtered_pca_matrix.*`

Note that the transposed coordinate matrix for the accessions are in file
`results/public_and_untwist_bcftools_and_plink_filtered_pca_matrix.rel` and the
row, i.e. the accession names are in file
`results/public_and_untwist_bcftools_and_plink_filtered_pca_matrix.rel.id`.

#### k-means clustering

k-means clustering was executed in `R` using the script `methods/k_means_clustering.R`.

The best number of clusters was found using the elbow and the silhouette
methods (see the respective plots).

Currently, this produces just plots, as the results hint that the original
input data needs refinement.

Scatterplots of for _k_=4 and _k_=6 were produced.

Plots generated:
```sh
results/hclust_tree.pdf
results/k_means_elbow_plot.pdf
results/k_means_scatterplot_k=4.pdf
results/k_means_scatterplot_k=6.pdf
results/k_means_silhoutte_plot.pdf
```
