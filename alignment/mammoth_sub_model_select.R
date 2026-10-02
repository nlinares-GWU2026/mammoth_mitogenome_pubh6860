# Choosing Substitution Model to see which describes how these 42 mitogenomes actually evolved

setwd("C:/Users/nelin/Desktop/GWU Information/GWU Fall 2026/Princip_Bioinformatics/mammoth_mitogenome_pubh6860/alignment")
# install.packages("ape")
# install.packages("phangorn")
library(ape)
library(phangorn) # has own data structure "phyDat" separate from seqinr alignment object used in "...verify.R"
# can read the aligned FASTA file directly, no conversion needed
mammoth_phydat <- read.phyDat("mammoth_aligned.fasta", format = "fasta", type = "DNA")