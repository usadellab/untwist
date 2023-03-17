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

##### Filter Untwist data

The `bcftools` instructions are in file `methods/filter_untwist_variants.sh`.
The file was submitted to our job queue using
`qsub methods/filter_untwist_variants.sh`

