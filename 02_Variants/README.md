Downsampling and identifying variants
================

After getting analysis-ready BAM files from low-coverage sequencing data, then I make heavy use of the software [ANGSD](http://www.popgen.dk/angsd/index.php/ANGSD) (Analysis of Next Generation Sequencing Data). [ANGSD](http://www.popgen.dk/angsd/index.php/ANGSD) is a software that was specifically developed to analyze low-coverage sequencing data, and notably has many methods designed for accounting for genotype uncertainty. 

One aspect that is different when working with low-coverage data is the file types of the variant information. Typically you don't work with the standard variant call format (VCF) files that are commonplace with called genotypes. Unfortunately, what this means, is you don't have access to all the handy VCF handling software (ex. bcftools) that you may be used to. Fortunately, ANGSD is fairly straightforward with it's ability to produce different file formats for the different analyses needed in the subsequent steps. Just make sure to take note of what file type is needed for the different analyses. For a great tutorial on understanding different analyses and the process of getting the different kinds of genotype likelihood files, check out [lcwgs-guide-tutorial](https://github.com/nt246/lcwgs-guide-tutorial) on github, and their [paper](https://onlinelibrary.wiley.com/doi/10.1111/mec.16077).

The software used here:

- ANGSD (ver 0.940)

- NgsRelate (ver 2)

- PCangsd

### Identify related individuals

One of the first things I do with the data is to check if I have related individuals that may bias certain subsequent analyses (e.g. population structure). With low-coverage data, [NgsRelate](https://github.com/ANGSD/NgsRelate) is your friend. They provide examples of how to get the necessary genotype likelihood file format of *.glf.gz* from ANGSD, and also produce a file from the allele frequency data that is a single column of allele frequencies.

**Note:** NgsRelate documentation provides example code to remove the header (`sed 1d`) and extract the fifth column (`cut -f5`) from the `mafs.gz` output file from ANGSD to get one of the files needed for NgsRelate input...but like all file manipulation examples it's always good to double-check if the example code still matches the file type needed. For example, I've needed to change the `cut -f` column in the past. So double-check the `.mafs.gz` file to make sure you're doing what's needed, ex. `zcat your_file.mafs.gz | head` to look at the first few lines.

Unless I have reason to believe individuals from my different sample sites may be related, I tend to speed this analysis up by breaking it into a job array of running NgsRelate for *each* sampling location, thus reducing how many individual pair-wise comparisons there are. This in-turn requires producing a `.glf.gz` file separately for each population/sampling location. So if I get a population glf file (pop1.glf.gz), say with 10 individuals, and the associated allele frequency file (pop1.freq), then all I run is:

```
./ngsrelate -g pop1.glf.gz -n 10 -f pop1.freq -O pop1.relatedness
```

There are many outputs given, and for the American Redstart data, I looked at the *rab pairwise relatedness* from [Hedrick et al. 2015](https://academic.oup.com/jhered/article/106/1/20/2961876) and KING from [Waples et al. 2019](https://onlinelibrary.wiley.com/doi/full/10.1111/mec.14954). I considered related individuals as `KING > 0.08` and `rab > 0.25`. 


### Identifying variants

I produced a filtered Beagle file from ANGSD:

```
# 325 individuals unrelated all
# thus 50% missing is 163 ind
# average of 1.5x coverage, thus min is 163 * 1.5, max is 2*1.5*325
angsd -b ${input_bams} -out ${outdir}/${outname} -gl 2 -domajorminor 1 \
 -snp_pval 1e-6 -domaf 1 -minmaf 0.05 -doGlf 2 -baq 1 \
 -ref ${reference} -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -trim 0 -C 50 \
  -minMapQ 30 -minQ 33 -minInd 163 -setMinDepth 240 -setMaxDepth 975 -doCounts 1 -nThreads 24
```

Details on filtering options can be found on the [ANGSD site](http://www.popgen.dk/angsd/index.php/Input). Some filtering recommendations for low-coverage data can be found in a batch effects paper by [Lou et al. 2022](https://onlinelibrary.wiley.com/doi/full/10.1111/1755-0998.13559). I've found the recommendation in the paper of stringently filtering mapping quality (`-minMapQ 30`) and base quality (`-minQ 33`) to help some with mild library effects (that become apparent in a PCA). 


**Note:** From here on, a key feature of ANGSD when running analyses back on the BAM files is to only reference these specific SNPs with the *-sites* and *-rf* parameters. But this can be problematic due to some old bugs in ANGSD. Though this feature does seem to work well with ANGSD 0.940 (previously, I needed to download ANGSD 0.939 manually, not through Conda). It also seems to work best when used with the *-rf* parameter for specifying the chromosomes/scaffolds of interest.

**Another note:** I also sometimes find myself with a list of SNPs and an already prepared Beagle file that I want to subset by the list of SNPs. I could do the step previously mentioned and use "-sites" with ANGSD, but this goes back to the BAM files and is slow and could take days. Another way to quickly subset Beagle files that I like to do is to use an awk command in bash. The magically fast way to do that is:

```
awk 'NR==FNR{c[$1]++;next};c[$1]' ${snps} <(zcat ${input}.beagle.gz) | gzip > ${output}.beagle.gz
```

where `${snps}` is a file with a single column of the `scaffold_position` format of SNP position in the beagle file (i.e. "scaffold"_"position"), and the other input is just your plain old gzipped beagle file. Run this code and then you get a new beagle file that only has the SNPs specified in the snps file. I find this super handy!

### Depth variation and down sampling

I have found that working with different DNA sources such as feathers and blood can result in high variation of sequencing depth. This can then skew different population genetic analyses, especially population structure. Some related issues are addressed in [Lou et al. 2022](https://doi.org/10.1111/1755-0998.13559), in which they also recommend down sampling as a technique to deal with depth in variation.

For example, for the American Redstart data, the mean depth across all individuals was 1.5x however when examining by population, it is apparent that population means range as much as 0.5x - 3x. Sequencing depth was calculated using the `CollectWgsMetrics` tool from [GATK](https://gatk.broadinstitute.org/hc/en-us/articles/360037269351-CollectWgsMetrics-Picard-). We used the MEAN_COVERAGE [output from this function](https://broadinstitute.github.io/picard/picard-metric-definitions.html#CollectWgsMetrics.WgsMetrics) which provides genomic coverage of an individual, excluding reads that do not pass quality filters. An example script is provide ([get_depth.sh](./scripts/get_depth.sh)).

<img src="./img/amre-populationALL-coverageDepth-plain.png" alt="Depth-plot" width="600"/>

The effect of this was apparent in PCAs in which individuals from BC1 with high coverage, as well as some other higher coverage individuals, skewed different principal component axes. I found that downsampling the higher coverage individuals to 2x resolved the principal components analysis nicely. To downsample, there were two main steps:

**Step 1)** Specify the proportion of the bam file depth I'm down sampling (i.e. if I have a 2x coverage individual and want to downsample to 1x, I specify 1/2=0.5). I do this in R ([depth-summary.Rmd](./scripts/depth-summary.Rmd)) and output a file to read for job arrays on Slurm. In that example script and the output, I calculate the downsampling for 3 different thresholds: 0.5x, 1.0x, 2.0x. The output from this is the [downsampling-array-full.txt](./scripts/downsampling-array-full.txt) that I use as input into step 2

**Step 2)** Downsample with GATK/Picard's [DownsampleSam function](https://gatk.broadinstitute.org/hc/en-us/articles/360037056792-DownsampleSam-Picard-). I provide an example job script for down sampling: [get_downsampling.sh](./scripts/get_downsampled.sh). This creates new bam files randomly downsampled to your specified value.

As a reminder, to use the newly down-sampled BAM files with the variants of interest already identified, you'll need to use ANGSD "-sites" function as described above.

### Final set of variants

After the initial assessment of individual relatedness and depth variation, the final set of variants were called from the downsampled BAM files, which had an average depth of 1.4X.

