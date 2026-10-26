# Hypothesis Testing - Is Post-bottleneck Diversity Lower?
# Question: Is genetic diversity in the post-bottleneck (Wrangel Island)
# group lower than in the pre-bottleneck (Siberia) group by more than chance would prove?

# H0: Pre- and Post-bottleneck have the same nucleotide diversity (pi),
# suggesting the group labels carry no information about diversity.
# H1: Post-bottleneck pi is lower than Pre-bottleneck pi (one-sided because the founder effect
# hypothesis predicts a direction, so I test that direction).

# Three Analyses
# 1. Permutation test on the difference in pi (all 42 samples)
# 2. The same test with the deeply divergent ancient clade removed (GilbertM20, GilbertM21, GilbertM25 and Oimyakon)
# 3. Subsampling: compare Post-bottleneck against random 14-sample draws from the Pre-bottleneck
# to deal with the 14-vs-28 sample size mismatch

# Usage: Rscript --no-init-file hypothesis_test.R <binned_rds> <out_tests_csv> <out_subsample_csv> <out_pdf>

library(ape)

args <- commandArgs(trailingOnly = TRUE)
in_rds        <- if (length(args) >= 1) args[1] else "diversity_stats/time_binned_alignments.rds"
out_tests     <- if (length(args) >= 2) args[2] else "diversity_stats/permutation_test_results.csv"
out_subsample <- if (length(args) >= 3) args[3] else "diversity_stats/subsample_results.csv"
out_pdf       <- if (length(args) >= 4) args[4] else "diversity_stats/permutation_test_all.pdf"

### Rebuild the shared site set (Same filter as diversity statistics step)
binned <- readRDS(in_rds)
post <- binned$post
pre <- binned$pre

# Stacks all 42 DNA sequences into one matrix, checks every column position, and keeps only
# 11,153 columns where every single sequence has a real & known DNA letter and removes any column with missing data
all_dna <- rbind(post, pre)
all_chars <- as.character(all_dna)
callable <- apply(all_chars, 2, function(col) all(col %in% c("a", "c", "g", "t")))
sites <- all_chars[, callable] # 42 samples x 11,153 sites
cat("Sites used:", ncol(sites), "(expect 11153)\n")

# One label per row of `sites` (rbind put Post-bottleneck rows first, then Pre-bottleneck)
group <- c(rep("Post", nrow(post)), rep("Pre", nrow(pre))) # Vector of text labels to keep track of which mammoth belongs to which time period

### Pairwise distance matrix, computed ONCE
# Every test below needs pi for many different subsets of samples.
# pi for a group is just the average of the pairwise distances among
# its members, so instead of recomputing distances thousands of times,
# calculate the full 42 x 42 matrix once and take averages of pieces of it.
D <- as.matrix(dist.dna(as.DNAbin(sites), model = "raw")) # Raw pairwise genetic difference between every pair of mammoths

# Helper function that takes list of sample index numbers, extracts their pairwise distance grid from D,
# isolates the lower triangle (to avoid comparing samples to themselves or counting pairs twice), and
# averages values to compute nucleotide diversity (pi)
mean_pairwise <- function(idx) {
  sub <- D[idx, idx]
  mean(sub[lower.tri(sub)]) # Each pair counted once
}

post_rows <- which(group == "Post")
pre_rows <- which(group == "Pre")

# Sanity check: Should match Diversity Stats results table
# (Post = 0.0001034561, Pre = 0.0049454034)
cat("Post pi:", mean_pairwise(post_rows), "(expect 0.0001034561)\n")
cat("Pre pi:", mean_pairwise(pre_rows), "(expect 0.0049454034)\n")

### Reusable permutation test
# If group labels did not matter, shuffling them at random would produce differences in pi
# about as large as the one I actually observed. So: shuffle the Pre/Post labels keeping the same group sizes,
# recompute the difference in pi, repeat many times, and see how often chance alone matches or beats the real
# difference. That fraction is the p-value.

# Function for permutation testing (real and observed difference in diversity)
perm_test <- function(keep, n_perm = 10000) {
  g <- group[keep]
  obs <- mean_pairwise(keep[g == "Pre"]) - mean_pairwise(keep[g == "Post"])
  # 10k simulations where it randomly shuffles Pre and Post labels across samples and re-calculates the diversity difference each time to build a null distribution
  # (by chance)
  null <- replicate(n_perm, {
    shuffled <- sample(g)
    mean_pairwise(keep[shuffled == "Pre"]) - mean_pairwise(keep[shuffled == "Post"])
  })
  
  # "+1" counts the real arrangement as one of the possibilities, so the p-value can never be reported as exactly zero.
  # Calculates p-value by counting how many shuffled iterations produced a difference as large or larger than the real observed diff
  p <- (sum(null >= obs) + 1) / (n_perm + 1)
  list(observed = obs, null = null, p = p)
}

### Analysis 1: Permutation test on all 42 samples
set.seed(2026)
res_all <- perm_test(seq_len(nrow(sites))) # perm test on all 42
cat("\nAnalysis 1 (all 42) observed Pre - Post pi:", res_all$observed, "(expect 0.004841947)\n")
cat("Analysis 1 p-value:", res_all$p, "(expect 9.999e-05)\n")

# Plot null distribution with the observed difference marked
pdf(out_pdf, width = 7, height = 5)
hist(res_all$null, breaks = 50,
     xlim = c(min(res_all$null), res_all$observed * 1.1),
     main = "Permutation test: difference in pi (Pre - Post)",
     xlab = "Difference in nucleotide diversity under shuffled labels")
abline(v = res_all$observed, col = "firebrick", lwd = 2)
legend("topleft", legend = "Observed difference", col = "firebrick", lwd = 2, bty = "n")
dev.off()

### Analysis 2: Remove deeply divergent ancient clade (same permutation test)
# GilbertM20, GilbertM21, GilbertM25, Oimyakon sit on a very long branch in the tree and inflate the
# Pre's group's pi. If the result only held because of them, it would be weaker evidence. Match them
# by accession number (stripping the ".version" suffix)
acc <- sub("\\..*$", "", rownames(sites))
outlier_acc <- c("EU153450", "EU153451", "EU153453", "MG334282")

keep_trim <- which(!acc %in% outlier_acc) # Filters out the 4 samples
cat("\nSamples kept after removing ancient clade:", length(keep_trim), "(expect 38 = 14 + 24)\n")

# Pre-bottleneck pi without ancient clade recalculated
cat("Pre pi without ancient clade:", mean_pairwise(keep_trim[group[keep_trim] == "Pre"]), "(expect 0.001623986)\n")

# Rerun the 10k permutation test on the trimmed dataset to check if
# drop in diversity still holds
set.seed(2026)
res_trim <- perm_test(keep_trim)
cat("Analysis 2 observed difference:", res_trim$observed, "(expect 0.00152053)\n")
cat("Analysis 2 p-value:", res_trim$p, "(expect 9.999e-05)\n")

### Analysis 3: Subsampling (fixing the 14-vs-28 mismatch)
# Segregating sites (S) and haplotype count (Hd) grow with sample size, so 28 Pre samples
# cannot be fairly compared with 14 Post samples. So repeatedly draw 14 random Pre samples,
# compute each statistic, and see where the real Post value falls in that distribution
# Only variable columns matter so isolate only sequence columns that vary within Pre group
pre_sites <- sites[pre_rows, ]
pre_var <- pre_sites[, apply(pre_sites, 2, function(col) length(unique(col)) > 1)]
cat("\nVariable sites within Pre:", ncol(pre_var), "\n")

n_post <- length(post_rows)

set.seed(2026)
subsample <- t(replicate(10000, {
  pick <- sample(length(pre_rows), n_post) # 14 of the 28 Pre-bottleneck samples
  sub <- pre_var[pick, , drop = FALSE]
  c(pi = mean_pairwise(pre_rows[pick]),
    S = sum(apply(sub, 2, function(col) length(unique(col)) > 1)),
    n_haplotypes = nrow(unique(sub)))
}))

# Observed Post-bottleneck values, computed the same way
post_sites <- sites[post_rows, ]
post_obs <- c(pi = mean_pairwise(post_rows),
              S  = sum(apply(post_sites, 2, function(col) length(unique(col)) > 1)),
              n_haplotypes = nrow(unique(post_sites)))

# Summary table comparing observed Post values against the sub-sampled 14-mammoth Pre-bottle distributions
# (median, 95% confidence bounds, and proportion of times sub-sampled Pre was lower than or equal to Post-bottle)
subsample_summary <- data.frame(
  statistic = colnames(subsample),
  post_observed = as.numeric(post_obs[colnames(subsample)]),
  pre14_median = apply(subsample, 2, median),
  pre14_lower95 = apply(subsample, 2, quantile, probs = 0.025),
  pre14_upper95 = apply(subsample, 2, quantile, probs = 0.975),
  prop_pre14_le_post = sapply(colnames(subsample), function(s) mean(subsample[, s] <= post_obs[s])),
  row.names = NULL
)
print(subsample_summary)

### Save analysis 2 and 3
test_summary <- data.frame(
  analysis = c("All 42 samples", "Without ancient clade (n = 38)"),
  observed_diff_pi = c(res_all$observed, res_trim$observed),
  p_value_one_sided = c(res_all$p, res_trim$p)
)
print(test_summary)

write.csv(test_summary, out_tests, row.names = FALSE)
write.csv(subsample_summary, out_subsample, row.names = FALSE)