# Choosing Substitution Model to see which describes how these 42 mitogenomes actually evolved
# Usage: Rscript --no-init-file mammoth_sub_model_select.R <aligned_fasta> <out_rds>

# install.packages("ape")
# install.packages("phangorn")
library(ape)
library(phangorn) # has own data structure "phyDat" separate from seqinr alignment object used in "...verify.R"
# can read the aligned FASTA file directly, no conversion needed

args <-commandArgs(trailingOnly = TRUE)
aln_file <- if (length(args) >= 1) args[1] else "alignment/mammoth_aligned.fasta"
out_rds  <- if (length(args) >= 2) args[2] else "model_and_tree/mammoth_model_select_results.rds"
out_csv  <- if (length(args) >= 3) args[3] else "model_and_tree/mammoth_model_select_sorted_results.csv"

# Can read the aligned FASTA file directly, no conversion needed
mammoth_phydat <- read.phyDat(aln_file, format = "fasta", type = "DNA")

# Checking that every sequence came through the phyDat conversion
cat("Sequence in phy Dat object:", length(mammoth_phydat), "(expect 42)\n")



### Model Testing 
# Fitting series of substitution models to the alignment, from the simplest 
# to the more complex but realistic ones with unequal base freqs, ts/tv bias, and rate variation across sites
mt <- modelTest(mammoth_phydat)
# Save result
saveRDS(mt, out_rds)

### ID the best fitting model
# Sort by AIC first, since mitochondrial DNA has almost always real rate variation and real invariant sites
# and due to the large dataset, the BIC's harsh penalty would exclude those biological features and count them 
# as statistical noise. Building a tree off of a model that assumes a more simple model than reality can risk underestimating 
# genetic divergence between more distantly related samples. If AIC and BIC match, then extra confidence, if not, then sorting by 
# AIC was because of the above justification. 
sorted <- mt[order(mt$AIC), ]
print(head(sorted, 10))
cat("Best model by AIC:", sorted$Model[1], "\n")
cat("Best model by BIC:", mt$Model[which.min(mt$BIC)], "\n")
write.csv(sorted, file = out_csv, row.names = FALSE)