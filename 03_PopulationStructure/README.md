Population structure
================

Principal components analysis (PCA) and individual admixture proportions were calculated using [PCAngsd](https://github.com/Rosemeis/pcangsd).

To perform PCA, we produced covariance values from PCAngsd using the following commands:

```
pcangsd -b amre.beagle.gz -t 24 -o amre.pcangsd.out
```

The covariance values were then imported into R where we performed eigendecomposition with the `eigen()` function.

Admixture proportions were calculated by specifying different numbers of eigenvectors to use, which determine the different number of *k* groups for admixture:

```
for i in {1..6}
  do pcangsd -b amre.beagle.gz -t 24 -o amre.pcangsd.${i}.out -e ${i} --admix
```

We plotted the posterior probabilities from the admixture output to create maps for the breeding populations. Details for creating such maps can be found at [Make a genoscape map](https://github.com/eriqande/make-a-BGP-map).

### Pairwise Fst between populations

Getting the per-site [FST from ANGSD](http://www.popgen.dk/angsd/index.php/Fst) involves a series of steps:

1.  Get allele frequency file (`-dosaf 1`) for each population (remember to specify `-sites`). An example can be found in the [get-saf.sh](./slurm/get-saf.sh)

2. Get the 2d site frequency spectrum from each pairwise comparison. 

3. Get the FST using the site allele frequencies and the 2dSFS as a prior. I run the last 2 steps together in the [get-fst.sh](./cripts/get-fst.sh)
