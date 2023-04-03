# untwist

Usadellab's contributions to the Untwist project.

## Project location on the IBG-4 cluster

Go to `/mnt/data/asis/untwist` to find the local clone of this repository.

## Directory structure

This project has the following directory structure:
```sh
- material
- methods
- results
```

Note that `material` and `results` are ignored by git, because they contain
sensitive data and extremely large files. You'll find the files in the local
clone, i.e. in the above directory on our IBG-4 cluster.

## Population Structure Analysis

Identification of populations and assignment to them of public and Untwist
Camelina accessions is the goal of this sub-project.

### Material

#### Raw data 

Can not be changed nor moved,
in `/mnt/archive/sequencing/illumina`

- `20210803_UNTWIST`
- `20211115_Untwist_check`
- `2022_02_12_Csativa_UNTWIST_reseq`

Notes:

- UNTWIST original run; we detected a likely mix-up
- UNTWIST check (`new` and `old`) material sent to a different provider:
  - `old` in the Untwist accession identifier means same DNA sample
  - `new` in the Untwist accession identifier means new DNA extraction 

`2022_02_12_Csativa_UNTWIST_reseq` the resequencing data which does not
comprise all some as some original data made sense.

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

#### Merged public and untwist resequencing data ("Ata's data")

This Variant matrix (VCF) was generated by Ata Ul Haleem. Find his
documentation on GitHub [here](https://github.com/usadellab/Lab_Book_Ata).

The crucial script used iteratively, commenting in and out lines, to generate
the result can be found on the cluster:
`/mnt/data/ata/UNTWIST_NEW/UNT_PUBLICATION_RICHARD/RichardAnalysis.sh`
A copy has been placed into methods:
`./methods/RichardAnalysis.sh`

The result of this merging of public and _resequenced_ Untwist accessions
single nucleotide polymorphism variants has been copied to
`./results/all_public_and_all_untwist_SNP_filtered.vcf.gz`.

This variant matrix is analyzed in parallel to the above merging of public and
Untwist data.

# WARNING
::bangbang::
# only file all_public_and_all_untwist_SNP_filtered.vcf.gz
# seems to ever be  used 
# whether it is correct or not and pruned or not is unclear
# 3.April 2023: based on checking MAF 0.05 and missing 0.1 was used. This was checked by filtering in Tassel and SNPReleate using these setting resulting in no filtering
## branch from here to R SNPrelate

##### Untwist lines not present in Ata's data

Ata's script uses a list of Untwist accessions to be kept when filtering with
`bcftools`. This list is used to find which Untwist lines are missing variant
data. A list of all Untwist lines has been provided by Björn Usadel
(`./material/unt_lines.md`).

Generate a list that can be compared with the above list of all Untwist lines:
```sh
cd /mnt/data/ata/UNTWIST_NEW/UNT_PUBLICATION_RICHARD
sed -e 's/_//' -e 's/_\S\+$//' -e 's/0\+//' UNTWISTsamples.txt | sort > /mnt/data/asis/untwist/material/unt_lines_in_Atas_VCF.md
```

Then build the set difference:
```sh
comm -3 <(sort material/unt_lines.md) material/unt_lines_in_Atas_VCF.md
```
The above command produces the result of five Untwist lines not present in the
variant data:
```
UNT36
UNT41
UNT48
UNT49
UNT51
```

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

#### For Ata's data

See the script `./methods/complete_linkage_clustering_for_ata.sh` which was
submitted to our job-queue.

This step produces the following result files:
```sh
./results/all_public_and_all_untwist_SNP_filtered_complete_linkage_clustering.cluster1
./results/all_public_and_all_untwist_SNP_filtered_complete_linkage_clustering.cluster2
./results/all_public_and_all_untwist_SNP_filtered_complete_linkage_clustering.cluster3
./results/all_public_and_all_untwist_SNP_filtered_complete_linkage_clustering.log
./results/all_public_and_all_untwist_SNP_filtered_complete_linkage_clustering.nosex
```

Note that the clusters are contained in file `...cluster1`, one cluster per
line separated by the cluster name a `<TAB>` and the cluster members comma
separated.

### Identity by state (IBS) distance based clustering

IBS is a standard distance measure between two accessions. We use `plink`
(version 1.9) to compute the square distance matrix. This is done in script
`methods/generate_IBS_and_allele_count_distances.sh`, which was submitted to
our job-queue using `qsub`.

_Note_ that this analysis currently is only done for Ata's data (see section
`material` for details).

This step produces:
```
./results/all_public_and_all_untwist_SNP_filtered.mdist
./results/all_public_and_all_untwist_SNP_filtered.mdist.id
./results/all_public_and_all_untwist_SNP_filtered.dist
./results/all_public_and_all_untwist_SNP_filtered.dist.id
```

Note, that the `[...].dist` files contain the allele count based distance and
row names (`[...].dist.id`) information. The `[...].mdist` and `[...].mdist.id`
files contain the same but for IBS distances.

The clustering and visualization is done with the R-script
`./methods/ibs_allele_cnt_distance_clustering_for_ata.R`. It produces these
results:
```
./results/hclust_on_1_min_IBS_tree_for_ata.pdf
./results/hclust_on_allele_cnts_tree_for_ata.pdf
```

Note that the respective dendrograms are stored in Newick format in the
following files:
```
./results/hclust_on_1_min_IBS_tree_for_ata.newick
./results/hclust_on_allele_cnts_tree_for_ata.newick
```

### Principal Component Analysis

We use `plink` (version 1.9) to carry out a principal component analysis of the
SNP variants.

Find the `plink` instructions in File
`./methods/principal_component_analysis.sh`. Submitted to our job-queue with
`qsub methods/principal_component_analysis.sh`.

This step produces:
```
./results/public_and_untwist_bcftools_and_plink_filtered_pca.eigenval
./results/public_and_untwist_bcftools_and_plink_filtered_pca.eigenvec
./results/public_and_untwist_bcftools_and_plink_filtered_pca.eigenvec.var
./results/public_and_untwist_bcftools_and_plink_filtered_pca.log
./results/public_and_untwist_bcftools_and_plink_filtered_pca.nosex
./results/public_and_untwist_bcftools_and_plink_filtered_pca.rel
./results/public_and_untwist_bcftools_and_plink_filtered_pca.rel.id
```

Note that the matrix accession eigenvectors is stored in 
`results/public_and_untwist_bcftools_and_plink_filtered_pca.eigenvec`.

#### PCA for Ata's data

We use `plink` (version 1.9) to carry out a principal component analysis of the
SNP variants.

Find the `plink` instructions in File
`./methods/principal_component_analysis_for_ata.sh`. Submitted to our job-queue
with `qsub`.

This step produces:
```
./results/all_public_and_all_untwist_SNP_filtered_pca.eigenval
./results/all_public_and_all_untwist_SNP_filtered_pca.eigenvec
./results/all_public_and_all_untwist_SNP_filtered_pca.eigenvec.var
./results/all_public_and_all_untwist_SNP_filtered_pca.log
./results/all_public_and_all_untwist_SNP_filtered_pca.nosex
./results/all_public_and_all_untwist_SNP_filtered_pca.rel
./results/all_public_and_all_untwist_SNP_filtered_pca.rel.id
```

Note that the matrix accession eigenvectors is stored in 
`./results/all_public_and_all_untwist_SNP_filtered_pca.eigenvec`.

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

##### k-means clustering for Ata's data

A copy of the above R-script was created
`./methods/k_means_clustering_for_ata.R` and adjusted so it worked on Ata's
data.

Tables listing the `Accession` identifiers in the first column and the cluster
number that accession belongs to in the second have been saved to:
```
./results/k_means_result_k=3_for_ata.tsv
./results/k_means_result_k=9_for_ata.tsv
```

### ADMIXTURE analysis

ADMIXTURE identifies the proportions of each accession's genome belonging to a
certain sub-population. The number of populations has to be defined as an input
parameter. 

_Note_ that this analysis currently is only done for Ata's data (see section
material).

#### Prepare input for ADMIXTURE

ADMIXTURE requires a certain input format (a `bed` file). Using `plink` it can
be produced from the input variant matrix in `VCF` format.

The script to do this conversion is
`./methods/generate_admixture_bed_input.sh`. It was submitted to our job-queue
with the standard `qsub` command.

#### Run ADMIXTURE for different assumed numbers of populations (_k_)

For each _k_ there is a single ADMIXTURE script that was submitted to our
job-queue using `qsub`. All of these scripts are identical, except the _k_
parameter.

We used values 3,4,5, and 6 for _k_.

See, for example, `./methods/admixture_k3.sh`, which produces the results:
```
./results/all_public_and_all_untwist_SNP_filtered.3.P
./results/all_public_and_all_untwist_SNP_filtered.3.Q
./results/all_public_and_all_untwist_SNP_filtered_admixture_k3.out
./results/all_public_and_all_untwist_SNP_filtered_admixture_k3.cv.error
```
Note, that the above four result files are created for each _k_. The ones
listed above are for _k_=3.

#### Plot ADMIXTURE results

See script `./methods/admixture_plots.R`. It produces the following plots:
```
results/all_public_and_all_untwist_SNP_filtered_admixture_k3_barplot_IBS_hclust.pdf
results/all_public_and_all_untwist_SNP_filtered_admixture_k4_barplot_IBS_hclust.pdf
results/all_public_and_all_untwist_SNP_filtered_admixture_k5_barplot_IBS_hclust.pdf
results/all_public_and_all_untwist_SNP_filtered_admixture_k6_barplot_IBS_hclust.pdf
```
Note that in each of these plots a hierarchical clustering tree is aligned with
a typical Admixture barplot.

The ADMIXTURE results are saved as tables, where the first column is the
accession identifier and the later columns hold the respective accession
genomes' percentage coming from the column ancestra population:
```
results/all_public_and_all_untwist_SNP_filtered_admixture_k3_result_table.tsv
results/all_public_and_all_untwist_SNP_filtered_admixture_k4_result_table.tsv
results/all_public_and_all_untwist_SNP_filtered_admixture_k5_result_table.tsv
results/all_public_and_all_untwist_SNP_filtered_admixture_k6_result_table.tsv
```

The script generates a scattter plot of the cross validation error (y-axis)
depending on the assumed number of populations _k_ (x-axis):
`./results/all_public_and_all_untwist_SNP_filtered_admixture_cv_error_scatter_plot.pdf`

# checking both trees versus knowledge
UNT29 CAM25  in Ata (UNT29,CAM111),CAM29 in other missing  
UNT34 = UNT49 =Calena CAM134 correct in both  
UNT38 Cs028/CAM57 in full tree but UNT25 is closest to CAM57 in both   ::x:: 
UNT50 CAM147 confirmed in both  
UNT52 CAM156 confirmed in both  
UNT53 CAM159 confirmed n both (note CAMPUB!)  
UNT54 CAM165 confirmed in both  
UNT55 CAM167 confirmed in Ata ::x:: only not in the other!  
UNT56 CAM232 confirmed in Ata ::x:: only not in the other!  
UNT57 CAM278 conformed in Ata close in other  
UNT59 C233 : nt CS233 in other ---- very far; is this the same nomenclature  


