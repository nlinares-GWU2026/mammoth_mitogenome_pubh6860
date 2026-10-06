setwd("C:/Users/nelin/OneDrive/Desktop/Grad School/GWU FALL 2026/Princip_Bioinformatics/mammoth_mitogenome_pubh6860/diversity_stats")

# Diversity Statistics by Group
# To quantify genetic diversity in the post-bottleneck and pre-bottleneck groups using: Nucleotide Diversity (pi), Segregating Sites (S), and Haplotype Diversity (Hd)
# Calculated with ape and R rather than a population genetics package so every number is traceable to a line of code

library(ape)

# Load both group alignments from `time_binning.R`
binned <- readRDS("time_binned_alignments.rds")
post <- binned$post # 14
pre <- binned$pre # 28

# Choose sites the groups will be compared on
# Because alignment contains gaps and N's, keep only alignment columns where ALL 42 seqs have a real base.
# Using same set of columns for both groups is necessesary because using trimmed lengths would be comparing different stretches of genome
all_dna <- rbind(post, pre) # Stacking into single matrix with 42 seqs 
all_chars <- as.character(all_dna) # Matrix of single letters 
# Scans through matrix column by column (2 = apply cross columns) to filter clean data by:
# Checking if every base in that single column is a real, unambiguous char
# Returns TRUE only if every single one of the 42 samples has a real base
# Stores as a true/false vector
callable <- apply(all_chars, 2, function(col) all(col %in% c ("a", "c", "g", "t")))

# How many of the 16,905 alignment columns persist through filtering?
sum(callable) # 11,153 so 5752 were excluded 
mean(callable) # Proportion:0.6597456

# Converts the 14 post and pre seqs into a text matrix where each row is a sample and each column is a genomic base
# Trims the columns of this matrix keeping only those columns whre callable = TRUE 
post_sites <- as.character(post)[, callable]
pre_sites <- as.character(pre)[, callable]

##### FUNCTION FOR ALL 3 DIVERSITY STATS #####
diversity_stats <- function(char_mat) {
  n <- row(char_mat)
  
  # Nucleotide Diversity (pi): avg pairwise difference per site
  pair_dist <- dist.dna(as.DNAbin(char_mat), model = "raw") # Returns for every pair of sequences, the proportion of sites that differ 
  pi <- mean(as.vector(pair_dist)) # Mean of those values
  
  # Segregating sites (S): columns containing more than one distinct base. 
}