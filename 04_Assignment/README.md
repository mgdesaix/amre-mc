Population assignment
================

For population assignment using the genotype likelihoods from the Beagle files, we used [WGSassign](https://github.com/mgdesaix/WGSassign).

For American Redstarts, we tested for assignment bias that could arise from unequal sample sizes and read depths. To test for this bias, we checked assignment accuracy of known breeding individuals from the five breeding populations we delineated with population structure. We tested three different ways of defining samples for these populations (i.e. which individuals were used to calculate allele frequency in the reference populations being assigned to):

1.  All individuals in the populations

2.  Equal sample sizes in each population

3.  Equal *effective sample sizes* in each population

For testing assignment accuracy using all individuals (*n* = 169), we performed leave-one-out assignment in WGSassign:

```sh
WGSassign --beagle ${breeding_beagle} --pop_af_IDs ${breeding_IDs} --get_reference_af --loo --out ${outname} --threads 20
```

where `breeding_beagle` was the beagle file for all 169 individuals and `breeding_IDs` was the reference population for the individual.

For the other 2 sample designs, we performed leave-one-out assignment accuracy for the individuals in the reference populations (135 and 122, respectively) and performed standard assignment of the individuals that were not part of the reference populations (34 and 47, respectively). 

```sh
WGSassign --beagle amre.135.beagle.gz --pop_af_IDs amre.135.IDs.txt --get_reference_af --loo --out amre.135 --threads 20
WGSassign --beagle amre.135.34_remainder_individuals.beagle.gz --pop_af_file amre.135.pop_af.npy --get_pop_like --out ${outname} --threads 20
```

Effective sample sizes were calculated using the following command in WGSassign:

```sh
WGSassign --beagle ${breeding_beagle} --pop_af_IDs ${breeding_IDs} --get_reference_af --ne_obs --out ${outname} --threads 20
```

### Nonbreeding individual assignment

To assign individuals from the nonbreeding range to breeding populations, we used the standard population assignment as shown above. 

Analysis of the log likelihood results are provided in the Rmarkdown script files for the different analyses we did related to population assignment

* Comparing assignment bias among different sets of reference populations ([WGSassign-equal.Rmd script](./scripts/WGSassign-equal.Rmd))

* Comparing assignment accuracy for different levels of downsampling (0.1X and 0.01X) ([WGSassign-downsampled.Rmd script](./scripts/WGSassign-downsampled.Rmd))

* Assignment consistency metric ([assignment-consistency.Rmd script](./scripts/assignment-consistency.Rmd))

