# untwist

Usadellab's contributions to the Untwist project.

## Population Structure Analysis

Identification of populations and assignment to them of public and Untwist
Camelina accessions is the goal of this sub-project.

### Material

#### Public data

We obtain single nucleotide polymorphism from Ashraf's previous work. The data
is delivered in VCF format and found here:
```sh
/mnt/data/achraf/sequenced_samples/runs/pipe_20210803_UNTWIST/015_SelectVariants-c-CAMPUB223_SNPS/NC_all_gatk_CAMPUB223_snpsonly.vcf
```
Note that this data has been filtered to contain only SNPs and no insertions or
deletions (InDels).

Find a symbolic link to this public data in `material`.

#### Untwist data

This is obtained as a raw variant calling result file provided by Ata Ul
Haleem. The data is delivered in VCF format (gzip) and is found here:
```sh
/mnt/sftpdata/sftpuntwist/home/sftpuntwist/UNT_Ata/VcfDataOctopus/UNT54.raw.merged.vcf.gz
```
Note that this data still needs to be filtered to remove InDels.

Find a copy of the file in material. `/mnt/sftpdata` is not available on the
compute nodes, so we need the original here.

### Methods

This section describes step by step how the above material is processed to
identify populations and assign accessions to them.

#### Filtering of variant data

We use bcftools to apply the following filters:
- read coverage > 3
- sequence quality > 20
- retain only SNPs, i.e. remove InDels

##### Filter public data

The `bcftools` instructions are in file `methods/filter_public_variants.sh`.
The file was submitted to our job queue using
`qsub methods/filter_public_variants.sh`

This step produces `results/NC_all_gatk_CAMPUB223_snpsonly_bcftools_filtered.vcf.gz`.

##### Filter Untwist data

The `bcftools` instructions are in file `methods/filter_untwist_variants.sh`.
The file was submitted to our job queue using
`qsub methods/filter_untwist_variants.sh`

This step produces `results/UNT54.raw.merge_bcftools_filtered.vcf.gz`.

##### Merge filtered public and Untwist SNP variants

We use `bcftools merge`, find the detailed instructions in file
`methods/merge_public_and_untwist_vcfs.sh`. Submitted to our job queue using
`qsub -hold_jid 9947675 methods/merge_public_and_untwist_vcfs.sh` Note that
using `-hold_jid <ID of job>` the newly submitted job will only start when the
other job finished. Filtering the Untwist data was still running.

It is important to note, that we use the `--missing-to-ref` flag, which causes
genotypes at missing sites to be interpreted as `0/0`.

This step produces `results/public_and_untwist_bcftools_filtered.vcf.gz`.

##### Filter merged SNP Variant Matrix

We want to filter the merged SNP Variant Matrix
`results/public_and_untwist_bcftools_filtered.vcf.gz` further.
Using `plink` (version 1.9) we apply the following filter criteria:
- discard SNPs that are not in Hardy-Weinberg-Equilibrium 
- discard SNPs that are not bi-allelic
- discard SNPs that have a minor allele frequency (MAF) <= 0.05
- discard SNPs that have '0/.' and similar VCF GT values; treat them as
  missing.

Detailed instructions for `plink` are in the file 
`methods/filter_merged_public_and_untwist_vcf.sh`. Submitted, awaiting
queued jobs for the previous filtering and merging with 
`qsub -hold_jid 9947679 methods/filter_merged_public_and_untwist_vcf.sh`.
