# Choosing Substitution Model to see which describes how these 42 mitogenomes actually evolved

setwd("C:/Users/nelin/Desktop/GWU Information/GWU Fall 2026/Princip_Bioinformatics/mammoth_mitogenome_pubh6860/model_and_tree")
# install.packages("ape")
# install.packages("phangorn")
library(ape)
library(phangorn) # has own data structure "phyDat" separate from seqinr alignment object used in "...verify.R"
# can read the aligned FASTA file directly, no conversion needed
mammoth_phydat <- read.phyDat("mammoth_aligned.fasta", format = "fasta", type = "DNA")

# Checking that every sequence came through the phyDat conversion
length(mammoth_phydat) # 42 confirmed



### Model Testing 
# Fitting series of substitution models to the alignment, from the simplest 
# to the more complex but realistic ones with unequal base freqs, ts/tv bias, and rate variation across sites
mt <- modelTest(mammoth_phydat)
# Save result
saveRDS(mt, "mammoth_model_select_results.rds")

### ID the best fitting model
# Sort by AIC first, since mitochondrial DNA has almost always real rate variation and real invariant sites
# and due to the large dataset, the BIC's harsh penalty would exclude those biological features and count them 
# as statistical noise. Building a tree off of a model that assumes a more simple model than reality can risk underestimating 
# genetic divergence between more distantly related samples. If AIC and BIC match, then extra confidence, if not, then sorting by 
# AIC was because of the above justification. 
mt[order(mt$AIC),]
write.csv(mt[order(mt$AIC), ], file = "mammoth_model_select_sorted_results.csv", row.names = FALSE)
