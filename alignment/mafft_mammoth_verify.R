library(seqinr)

aln <- read.alignment("mammoth_aligned.fasta", format = "fasta")

length(aln$seq)
lengths <- sapply(aln$seq, nchar)
lengths[1]
all(lengths == lengths[1])