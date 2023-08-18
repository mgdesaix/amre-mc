#!/bin/bash
#set a job name
#SBATCH --job-name=collectWgsmetrics
#SBATCH --output=./err-out/collectWgsmetrics.%A_%a.out
#SBATCH --error=./err-out/collectWgsmetrics.%A_%a.err
################
#SBATCH --time=24:00:00
#################
# Note: 4.84G/core or task
#################
#SBATCH --array=1-330
#################

source ~/.bashrc

### Mapping
conda activate gatk4
module load jdk
picard=/projects/mgdesaix@colostate.edu/programs/picard.jar
reference=/projects/mgdesaix@colostate.edu/reference/YWAR/YWAR.fa

bam=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $1}' all-bams.txt)
# ex. 04N9003.bam
sample=$(echo ${bam} | cut -f1 -d.)
# ex. 04N9003

java -jar ${picard} CollectWgsMetrics I=./full/${bam} O=./depth-summary/wgsmetrics/${sample}.wgsmetrics.txt VALIDATION_STRINGENCY=S\
ILENT R=${reference}

depth=$(awk 'NR == 8 {print $2}' ./depth-summary/wgsmetrics/${sample}.wgsmetrics.txt)
echo ${sample} ${depth} >> ./depth-summary/full-330ind-depth-summary.txt
