# Diversity Statistics by Group
# To quantify genetic diversity in the post-bottleneck and pre-bottleneck groups using: Nucleotide Diversity (pi), Segregating Sites (S), and Haplotype Diversity (Hd)
# Calculated with ape and R rather than a population genetics package so every number is traceable to a line of code
# Usage: Rscript --no-init-file diversity_statistics.R <binned_rds> <out_csv> <out_pairwise_csv>

library(ape)

args <- commandArgs(trailingOnly = TRUE)
in_rds       <- if (length(args) >= 1) args[1] else "diversity_stats/time_binned_alignments.rds"
out_csv      <- if (length(args) >= 2) args[2] else "diversity_stats/diversity_stats_by_group.csv"
out_pairwise <- if (length(args) >= 3) args[3] else "diversity_stats/diversity_pairwise_deletion.csv"

# Load both group alignments from `time_binning.R`
binned <- readRDS(in_rds)
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
callable <- apply(all_chars, 2, function(col) all(col %in% c("a", "c", "g", "t")))

# How many of the 16,905 alignment columns persist through filtering?
cat("Callable sites:", sum(callable), "of", length(callable), "(expect 11153)\n")
cat("Proportion callable:", mean(callable), "(expect 0.6597456)\n")

# Converts the 14 post and pre seqs into a text matrix where each row is a sample and each column is a genomic base
# Trims the columns of this matrix keeping only those columns where callable = TRUE
post_sites <- as.character(post)[, callable]
pre_sites <- as.character(pre)[, callable]

##### FUNCTION FOR ALL 3 DIVERSITY STATS #####
diversity_stats <- function(char_mat) {
  n <- nrow(char_mat)
  
  # Nucleotide Diversity (pi): avg pairwise difference per site
  pair_dist <- dist.dna(as.DNAbin(char_mat), model = "raw") # Returns for every pair of sequences, the proportion of sites that differ
  pi <- mean(as.vector(pair_dist)) # Mean of those values
  
  # Segregating sites (S): columns containing more than one distinct base
  S <- sum(apply(char_mat, 2, function(col) length(unique(col)) > 1)) # Scans through matrix col by col for each col counts how many UNIQUE dna bases exist
  # If more than one distinct letter = segregating site
  
  # Haplotypes: sequences that are identical across every kept site are the SAME HAPLOTYPE.
  hap_ids <- apply(char_mat, 1, paste, collapse = "")
  # Glues all letters in each individual sample's row together to form a single long DNA string for each sample
  hap_counts <- table(hap_ids)
  # Counts how many times each unique seq string appears in sample group
  n_hap <- length(hap_counts) # Total number of distinct unique seq variations (haplotypes) present in the group
  
  # Haplotype diversity (Nei & Tajima): 1 minus the sum of squared haplotype frequencies,
  # with an n/(n-1) small-sample correction
  p <- as.numeric(hap_counts) / n # Calculates the proportion of each haplotype in the group by dividing its count by total number of sequences
  Hd <- (n / (n - 1)) * (1 - sum(p^2)) # Nei and Tajima formula to calculate Haplotype diversity
  
  # Packages all calculated statistics into single dataframe which finishes the function
  data.frame(n_seqs = n,
             sites_used = ncol(char_mat),
             pi = pi,
             segregating_sites = S,
             n_haplotypes = n_hap,
             hap_diversity = Hd)
}

# Results (per group)
results <- rbind(Post = diversity_stats(post_sites),
                 Pre = diversity_stats(pre_sites))
print(results)

write.csv(results, out_csv)

# Pairwise deletion sensitivity check
# Instead of above approach which threw away the COLUMN in seq alignment if even one sample is missing a base (risk of discarding good data)
# pairwise deletion only ignores missing bases on a pair by pair basis (different pairs of samples are compared across slightly different lengths/regions of genome but use more data)
pi_post_pairwise <- mean(as.vector(dist.dna(post, model = "raw", pairwise.deletion = TRUE))) # Nucleotide distances for pre and post and averages for pi.
pi_pre_pairwise <- mean(as.vector(dist.dna(pre, model = "raw", pairwise.deletion = TRUE)))
pairwise <- data.frame(group = c("Post", "Pre"), pi_pairwise_deletion = c(pi_post_pairwise, pi_pre_pairwise))
print(pairwise)
write.csv(pairwise, out_pairwise, row.names = FALSE)