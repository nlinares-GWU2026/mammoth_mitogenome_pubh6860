# Time binning - Splitting into Pre-/Post-Bottleneck Groups using already established
# sample metadata. Split the ALIGNED sequences themselves into two subsets to be ready 
# for diversity statistics because diversity stats are computed on actual sequence alignment,
# not column or tree data.

library(ape)

# Load alignment as DNAbin object (ape's compact binary format for DNA seqs)
mammoth_dna <- read.dna("mammoth_aligned.fasta", format = "fasta")
dim(mammoth_dna) # Confirmed 42 sequences, 16,905 BP each

# Match each sequence to its pre-/post-bottleneck group
metadata <- read.csv("mammoth_mitogenome_accessions.csv")

# Sequence names are still in "ACCESSION.version" form -> strip version suffix to match Accession_No.
seq_accessions <- sub("\\..*$", "", rownames(mammoth_dna))
seq_groups <- metadata$Group[match(seq_accessions, metadata$Accession_No)]

# Confirm every seq matched to a group (either pre- or post- with 3 labels) with counts of 14 and 28 - no NA entries
table(seq_groups, useNA = "ifany") # Expect that 6 pre-bottleneck are undated but still classified as pre-bottleneck

# Collapse 3 labels into two-level group variable
# grepl("^Pre") catches both dated and undated
seq_groups_clean <- ifelse(grepl("^Post", seq_groups), "Post-bottleneck", "Pre-bottleneck")

table(seq_groups_clean, useNA = "ifany")

# Split into 2 DNAbin subsets
post_bottleneck <- mammoth_dna[seq_groups_clean == "Post-bottleneck", ]
pre_bottleneck <- mammoth_dna[seq_groups_clean == "Pre-bottleneck", ]
#Confirm the split matches 
dim(post_bottleneck)
dim(pre_bottleneck)

# Save FASTA files of info for diversity stats
write.dna(post_bottleneck, "post_bottleneck_aligned.fasta", format = "fasta")
write.dna(pre_bottleneck, "pre_bottleneck_aligned.fasta", format = "fasta")
# Save as a single RDS file so diversity stats script can load both DNAbin objs without re-parsing FASTA
saveRDS(list(post = post_bottleneck, pre = pre_bottleneck), "time_binned_alignments.rds")