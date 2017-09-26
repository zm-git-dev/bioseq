#
#########################
#This version uses Hisat2
#########################
#
#1, align reads to genome with hisat2 and save aligns to bam file with samtools. 
#2, optional, concatnate multiple files if they belong to one sample.
#3, sort .bam files
#4, deduplicate with picard.
#5, get genes counts file with featureCounts. use annotation file here.


#0.2 Rename (shorten) fastq file names if needed.
rename 's/_S.*gz/.fastq.gz/' *.fastq.gz
#eg, C75_S1_R1_001_.fastq.gz to C75.fastq.gz

#1 hisat2
for i in *.fastq.gz; do hisat2 -p 6 -x /path/to/hisat2/index/ -U $i | samtools view -bh -o ${i%.fastq.gz}.bam -; done #note: piping to samtolls reqires version 1.15 or above. The last "-" (dash) may be ommitted.

#2 concatnate
samtools cat -o RW04.bam RW04?.bam

#3 sort
for i in *.bam; do samtools sort -@ 6 -o ${i%.bam}.sorted.bam $i; done

#4 deduplicate
#picard
for i in *.sorted.bam; do java -jar ~/tools/picard-2.10.5/picard.jar MarkDuplicates I=$i O=${i%.sorted.bam}.dedup.bam M=${i%.sorted.bam}.dedup.txt REMOVE_DUPLICATES=true; done
#or samtools
for i in *.sorted.bam; do samtools rmdup -s $i ${i%.sorted.bam}.rmdup.bam; done

#5 FeatureCounts
featureCounts --primary -T 8 -a /path/to/genes.gtf -o featurecounts.results.csv *dup.bam


###### one line command for all:

rename 's/_S.*gz/.fastq.gz/' *.fastq.gz && for i in *.fastq.gz; do hisat2 -p 6 -x /path/to/hisat2/index/ -U $i | samtools view -bh -o ${i%.fastq.gz}.bam -;samtools sort -@ 6 -o ${i%.fastq.gz}.sorted.bam ${i%.fastq.gz}.bam;rm ${i%.fastq.gz}.bam; samtools rmdup -s ${i%.fastq.gz}.sorted.bam ${i%.fastq.gz}.rmdup.bam;rm ${i%.fastq.gz}.sorted.bam; done && featureCounts --primary -T 8 -a /path/to/genes.gtf -o featurecounts.results.csv *dup.bam