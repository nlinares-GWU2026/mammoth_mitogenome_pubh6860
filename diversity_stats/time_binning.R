# Time binning - Splitting into Pre-/Post-Bottleneck Groups using already established
# sample metadata. Split the ALIGNED sequences themselves into two subsets to be ready
# for diversity statistics because diversity stats are computed on actual sequence alignment,
# not column or tree data.
# Usage: Rscript --no-init-file time_binning.R <aligned_fasta> <metadata_csv> <out_rds> <out_post_fasta> <out_pre_fasta>

library(ape)

args <- commandArgs(trailingOnly = TRUE)
aln_file  <- if (length(args) >= 1) args[1] else "alignment/mammoth_aligned.fasta"
meta_csv  <- if (length(args) >= 2) args[2] else "data_aquisition/mammoth_mitogenome_accessions.csv"
out_rds   <- if (length(args) >= 3) args[3] else "diversity_stats/time_binned_alignments.rds"
out_post  <- if (length(args) >= 4) args[4] else "diversity_stats/post_bottleneck_aligned.fasta"
out_pre   <- if (length(args) >= 5) args[5] else "diversity_stats/pre_bottleneck_aligned.fasta"

# Load alignment as DNAbin object (ape's compact binary format for DNA seqs)
mammoth_dna <- read.dna(aln_file, format = "fasta")
cat("Alignment dimensions (sequences x bp):", dim(mammoth_dna), "(expect 42 x 16905)\n")

# Match each sequence to its pre-/post-bottleneck group
metadata <- read.csv(meta_csv)

# Sequence names are still in "ACCESSION.version" form -> strip version suffix to match Accession_No.
seq_accessions <- sub("\\..*$", "", rownames(mammoth_dna))
seq_groups <- metadata$Group[match(seq_accessions, metadata$Accession_No)]

# Confirm every seq matched to a group (either pre- or post- with 3 labels) - no NA entries
print(table(seq_groups, useNA = "ifany")) # Expect that 6 pre-bottleneck are undated but still classified as pre-bottleneck
stopifnot(!anyNA(seq_groups))

# Collapse 3 labels into two-level group variable
# grepl("^Post") catches the Post group; everything else (dated and undated) is Pre
seq_groups_clean <- ifelse(grepl("^Post", seq_groups), "Post-bottleneck", "Pre-bottleneck")
print(table(seq_groups_clean, useNA = "ifany"))

# Split into 2 DNAbin subsets
post_bottleneck <- mammoth_dna[seq_groups_clean == "Post-bottleneck", ]
pre_bottleneck  <- mammoth_dna[seq_groups_clean == "Pre-bottleneck", ]
cat("Post:", nrow(post_bottleneck), "sequences (expect 14); Pre:", nrow(pre_bottleneck), "sequences (expect 28)\n")
stopifnot(nrow(post_bottleneck) == 14, nrow(pre_bottleneck) == 28)

# Save FASTA files of info for diversity stats
write.dna(post_bottleneck, out_post, format = "fasta")
write.dna(pre_bottleneck, out_pre, format = "fasta")
# Save as a single RDS file so diversity stats script can load both DNAbin objs without re-parsing FASTA
saveRDS(list(post = post_bottleneck, pre = pre_bottleneck), out_rds)