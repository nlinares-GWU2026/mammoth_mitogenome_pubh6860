library(seqinr)

setwd("C:/Users/nelin/Desktop/GWU Information/GWU Fall 2026/Princip_Bioinformatics/mammoth_mitogenome_pubh6860/alignment")
aln <- read.alignment("mammoth_aligned.fasta", format = "fasta")

length(aln$seq)
lengths <- sapply(aln$seq, nchar)
lengths[1]
all(lengths == lengths[1])
