# Untwist

Population genetics of the _Camelina sativa_ lines studied in the "Untwist"
project.

## Data and Code Availability

All code is contained in this git repository. Because the material (data) is
contained in large files these cannot be included. Please write to the authors
with affiliation to the Forschungszentrum Jülich (FZJ) to obtain the data
files. For FZJ researches please look at the file
`./material/data_and_code_availability.txt` for the physical directory in which
to find the local copy of this repository _including_ the material (data)
files.

## Directory structure

This project has the following directory structure:
```sh
- material
- methods
- results
```

Note that most files in the directories `material` and `results` are ignored by
git, because they contain sensitive data and/or extremely large files.
You'll find the files in the local clone, i.e. in the above directory on our
IBG-4 cluster (see section [Data and Code
Availability](#data-and-code-availability)).

## Population Structure Analysis

In this section you find how we identified populations and assigned _Camelina
sativa_ lines studied in the Untwist research project to them. The respective
genomes were either generated within the Untwist research project or extracted
from [1] (see [References](#references)).

### Material

#### Merged public and Untwist resequencing genomic variant data ("Ata's data")

##### The variant matrix (VCF)

In this population genetics analysis we used variants identified by the
sequencing group. Those variants were filtered. We use only single nucleotide
polymorphisms (SNPs) in the form of a variant matrix (VCF file). It is
generated from two VCF input files, which have been generated and provided by
the sequencing sub-group.

The step-by-step generation is described in methods. The final VCF matrix used
by all analysis is `./results/all_public_and_all_untwist_SNP_filtered.vcf.gz`.

Two variant matrices are used that were generated for (a) public _Camelina
sativa_ lines (see reference [1]) and (b) lines generated within the Untwist
research project. The files are in the FZJ's _local_ material directory and are
available upon request. See `material/data_and_code_availability.txt` for
details on their respective storage locations.
```
(a) NC_all_gatk_CAM_casom_CAMPUB223_54UNT.vcf
(b) NC_all_gatk_UNT_check_all_reseq.vcf
```

Find a list of all _Camelina sativa_ lines used in this population genetics
analysis in the file `./material/untwist_lines_accessions.txt`. Note that at
the time of carrying out the population genetics analysis a few lines were
still underoing sequencing and thus are not present.

### Methods

This section describes step by step how the above material is processed to
identify populations and assign accessions to them.

#### Pipeline

To reproduce the results of this project execute the methods scripts as listed
in `./job_queue.txt`. Find below the list reproduced with additional indication
of which scripts can be executed in parallel - see number in square brackets
for this information:
* [1] `methods/filter_public_variants.sh`
* [1] `methods/filter_untwist_variants.sh`
* [2] `methods/merge_and_filter_public_and_untwist_vcfs.sh`
* [3] `methods/filter_out_SNPs_with_exceeding_heterzygosity.sh`
* [4] `methods/filter_out_LD_correlated_SNPs.sh`
* [5] `methods/principal_component_analysis.sh`
* [5] `methods/generate_IBS_and_allele_count_distances.sh`
* [5] `methods/generate_admixture_bed_input.sh`
* [5] `methods/complete_linkage_clustering.sh`
* [5] `methods/calculate_Fst.sh`
* [6] `methods/k_means_clustering.R`
* [6] `methods/ibs_allele_cnt_distance_clustering.R`
* [6] `methods/admixture_k3.sh`
* [6] `methods/admixture_k4.sh`
* [6] `methods/admixture_k5.sh`
* [6] `methods/admixture_k6.sh`
* [6] `methods/admixture_k7.sh`
* [6] `methods/admixture_k8.sh`
* [6] `methods/admixture_k9.sh`
* [6] `methods/admixture_k10.sh`
* [7] `methods/admixture_plots.R`

#### Generation of the variant matrix (VCF file)

See materials for the two input VCF matrix files provided by the sequencing subgroup.

##### Filtering out low quality SNPs and other variants

The input variant matrices are filtered, so that the resulting variant matrices
(VCF files) contain only desired _Camelina sativa_ lines.

For details see scripts:

- `methods/filter_public_variants.sh`
- `methods/filter_untwist_variants.sh`

##### Merge public (see reference [1]) and Untwist variant matrices and filter the result

The results of the two above filtering steps are merged into a single variant
matrix (VCF file) and the resulting variant matrix is filtered again.

The following statements are true for all retained variants:
- all variants are SNPs
- all SNPs are bi-allelic
- all SNPs have less than 10% of the genotypes with missing data
- all SNPs have a mapping depth of at least 3
- all SNPs have read quality score of at least 20
- all SNPs have at least minor allele frequency of 0.05

See script `./methods/merge_and_filter_public_and_untwist_vcfs.sh` for details.

This produces the variant matrix file:
`./results/all_public_and_all_untwist_SNP_filtered_NOT_LD_pruned.vcf.gz`
that holds **2,306,926 SNPs**.

##### Filtering out sites with high heterozygosity

Sites where more than 50% of the samples (accessions) are heterozygous are
excluded from the variant matrix (VCF file) by this filtering step.

We use `vcffilterjs` to carry out this filtering. See script 
```
./methods/filter_out_SNPs_with_exceeding_heterzygosity.sh
```
This step produces the VCF file
`./results/all_public_and_all_untwist_SNP_filtered_heterozygosity_NOT_LD_pruned.vcf.gz`
which contains **1,286,444 SNPs**.

##### Filtering out correlated SNPs

Linkage disequilibrium (LD) is a population-based parameter that describes the
degree to which an allele of one genetic variant is inherited or correlated
with an allele of a nearby genetic variant within a given population (Bush and
Moore, 2012).

Such linked SNPs can bias population structure analyses. Thus we need to filter
out SNPs that are highly correlated.

See script `./methods/filter_out_LD_correlated_SNPs.sh` for details on how
`bcftools` (version 1.9) was used to filter out SNPs correlated to other
positions with an `r^2 > 0.7` within a window of size 1,000 bp.

After filtering **340,696 SNPs** remained. The result is stored in file
`./results/all_public_and_all_untwist_SNP_filtered.vcf.gz`.

#### Complete Linkage Clustering based on identity by state (IBS) distances

See the script `./methods/complete_linkage_clustering.sh` which was
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

#### Identity by state (IBS) distance based hierarchical clustering

IBS is a standard distance measure between two accessions. We use `plink`
(version 1.9) to compute the square distance matrix. This is done in script
`methods/generate_IBS_and_allele_count_distances.sh`, which was submitted to
our job-queue using `qsub`.

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

The hierarchical clustering and visualization is done with the R-script
`./methods/ibs_allele_cnt_distance_clustering.R`. It produces these
results:
```
./results/hclust_on_1_min_IBS_tree.pdf
./results/hclust_on_allele_cnts_tree.pdf
```

Note that the respective dendrograms are stored in Newick format in the
following files:
```
./results/hclust_on_1_min_IBS_tree.newick
./results/hclust_on_allele_cnts_tree.newick
```

#### Principal Component Analysis

We use `plink` (version 1.9) to carry out a principal component analysis of the
SNP variants.

Find the `plink` instructions in File
`./methods/principal_component_analysis.sh`. Submitted to our job-queue
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

##### Plot the PCA results

We use R to generate a scatterplot to visualize the results of the SNP based
principal component analysis. Use the R-script
`./methods/visualize_pca_results.R` for this. The resulting plot is stored in
`./results/principal_component_scatterplot.pdf`.

###### Convert plots to JPG for the publication

Upon request we convert the PCA plot to JPG for publication using the following
command:
```sh
convert -density 600 -trim \
  results/principal_component_scatterplot.pdf \
  -quality 100 results/principal_component_scatterplot.jpg
```

##### k-means clustering

k-means clustering was executed in `R` using the script
`methods/k_means_clustering.R`.

The best number of clusters was found using the elbow and the silhouette
methods (see the respective plots).

Currently, this produces just plots, as the results hint that the original
input data needs refinement.

Tables listing the `Accession` identifiers in the first column and the cluster
number that accession belongs to in the second have been saved to:
```
./results/k_means_result_k=3.tsv
[...]
./results/k_means_result_k=10.tsv
```

#### ADMIXTURE analysis

ADMIXTURE identifies the proportions of each accession's genome belonging to a
certain sub-population. The number of populations has to be defined as an input
parameter. 

##### Prepare input for ADMIXTURE

ADMIXTURE requires a certain input format (a `bed` file). Using `plink` it can
be produced from the input variant matrix in `VCF` format.

The script to do this conversion is
`./methods/generate_admixture_bed_input.sh`. It was submitted to our job-queue
with the standard `qsub` command.

##### Run ADMIXTURE for different assumed numbers of populations (_k_)

For each _k_ there is a single ADMIXTURE script that was submitted to our
job-queue using `qsub`. All of these scripts are identical, except the _k_
parameter.

We used values `3,4,...,10` for _k_.

See, for example, `./methods/admixture_k3.sh`, which produces the results:
```
./results/all_public_and_all_untwist_SNP_filtered.3.P
./results/all_public_and_all_untwist_SNP_filtered.3.Q
./results/all_public_and_all_untwist_SNP_filtered_admixture_k3.out
./results/all_public_and_all_untwist_SNP_filtered_admixture_k3.cv.error
```
Note, that the above four result files are created for each _k_. The ones
listed above are for _k_=3.

##### Plot ADMIXTURE results

See script `./methods/admixture_plots.R`. It produces the following plots:
```
results/all_public_and_all_untwist_SNP_filtered_admixture_k3_barplot_IBS_hclust.pdf
results/all_public_and_all_untwist_SNP_filtered_admixture_k4_barplot_IBS_hclust.pdf
results/all_public_and_all_untwist_SNP_filtered_admixture_k5_barplot_IBS_hclust.pdf
results/all_public_and_all_untwist_SNP_filtered_admixture_k6_barplot_IBS_hclust.pdf
[...]
```
Note that in each of these plots a hierarchical clustering tree is aligned with
a typical Admixture barplot.

The ADMIXTURE results are saved as tables, where the first column is the
accession identifier and the later columns hold the respective accession
genomes' percentage coming from the column ancestor population:
```
results/all_public_and_all_untwist_SNP_filtered_admixture_k3_result_table.tsv
results/all_public_and_all_untwist_SNP_filtered_admixture_k4_result_table.tsv
results/all_public_and_all_untwist_SNP_filtered_admixture_k5_result_table.tsv
results/all_public_and_all_untwist_SNP_filtered_admixture_k6_result_table.tsv
[...]
```

The script generates a scatter plot of the cross validation error (y-axis)
depending on the assumed number of populations _k_ (x-axis):
`./results/all_public_and_all_untwist_SNP_filtered_admixture_cv_error_scatter_plot.pdf`

###### Provide the dendrograms in Newick format

The above script `./methods/admixture_plots.R` produces two trees (dendrograms)
as output per paramater value for `k`. These dendrograms have been requested
for further figures for the publication. The first dendrogram includes _all_
lines analyzed in this project, the second only the Untwist lines. The leaves
are sorted to match the admixture clusters. As topology identity is concerned
they are _all_ identical.

For _k_ = 8 the resulting respective dendrograms are:
- `./results/all_public_and_all_untwist_SNP_filtered_admixture_k8_JUST_IBS_hclust.newick` and
- `./results/all_public_and_all_untwist_SNP_filtered_admixture_k8_JUST_IBS_hclust_ONLY_Untwist_Lines.newick`

###### Convert plots to JPG for the publication

Upon request we convert the above `*admixture_k*_barplot_IBS_hclust.pdf` to JPG
using the following command:
```sh
convert -density 600 -trim \
  results/all_public_and_all_untwist_SNP_filtered_admixture_k8_barplot_IBS_hclust.pdf \
  -quality 100 results/all_public_and_all_untwist_SNP_filtered_admixture_k8_barplot_IBS_hclust.jpg
```

#### Calculate the F-statistics

F-statistics and their calculation has been well defined in "Weir BS, Cockerham
CC (1984) Estimating F-statistics for the analysis of population structure".
vcftools implement this method.

We want to infer whether the genetic variability of the Untwist lines matches
the variability of the public lines.

In order to achieve this, we calculate the F-statistics using vcftools.

See file `./methods/calculate_Fst.sh` for details. The job creates the output
file `./results/mean_Fst.txt`.

## References

[1] Li, H., Hu, X., Lovell, J. T., Grabowski, P. P., Mamidi, S., Chen, C.,
Amirebrahimi, M., Kahanda, I., Mumey, B., Barry, K., Kudrna, D., Schmutz, J.,
Lachowiec, J., & Lu, C. (2021). Genetic dissection of natural variation in
oilseed traits of camelina by whole-genome resequencing and QTL mapping. The
Plant Genome, 14(2), e20110. https://doi.org/10.1002/tpg2.20110
