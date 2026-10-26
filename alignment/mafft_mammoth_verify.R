# Verify the MAFFT alginment: 42 sequences, all the same length.
# Usage: Rscript mafft_mammoth_verify.R <aligned_fasta>

library(seqinr)

args <- commandArgs(trailingOnly = TRUE)
# Use the given path, or fall back to the default so you can still run this by hand
aln_file <- if (length(args) >= 1) args[1] else "alignment/mammoth_aligned.fasta"

aln <- read.alignment(aln_file, format = "fasta")

cat("Number of sequences:", length(aln$seq), "\n")
lengths <- sapply(aln$seq, nchar)
cat("Length of first sequence:", lengths[1], "\n")
cat("All sequences equal length:", all(lengths == lengths[1]), "\n")
