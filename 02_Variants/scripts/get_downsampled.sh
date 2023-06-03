#!/bin/bash
#set a job name
#SBATCH --job-name=downsampling-0.01x
#SBATCH --output=./err-out/downsampling-0.01x.%A_%a.out
#SBATCH --error=./err-out/downsampling-0.01x.%A_%a.err
################
#SBATCH --time=4:00:00
#################
# Note: 4.84G/core or task
#################
#SBATCH --array=1-148
#################

source ~/.bashrc
conda activate gatk4

set -x

bam=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $1}' downsampling-array-0.01x.txt)
# 20N002019.bam
p=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $2}' downsampling-array-0.01x.txt)
# 0.23

picard=/projects/mgdesaix@colostate.edu/programs/picard.jar

input=/home/mgdesaix@colostate.edu/scratch/AMRE/bams/xfull/${bam}
output=/home/mgdesaix@colostate.edu/scratch/AMRE/bams/x0.01/${bam}

java -jar ${picard} DownsampleSam I=${input} O=${output} P=${p} VALIDATION_STRINGENCY=SILENT
samtools index ${output}
