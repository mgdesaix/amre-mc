Bioinformatics
================

These steps outline how the American Redstart samples were processed, starting with the FASTQ files and ending with the identification of SNP variants.

## WGS data preprocessing: From FASTQ to BAM files

The order of operations for the preprocessing workflow is:

**1.** Trimming adapters ([get_trimmed.sh script](./scripts/get_trimmed.sh))

**2.** Mapping to reference ([get_mapped.sh script](./scripts/get_mapped.sh))

**3.** Merging BAMs ([get_merged.sh script](./scripts/get_merged.sh))

**4.** Marking and removing duplicates ([get_duplicates_removed.sh script](./scripts/get_duplicates_removed.sh))


