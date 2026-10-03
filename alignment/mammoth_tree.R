# Phylogenetic Tree - (HKY+G(4)+I) used to estimate maximum-likelihood tree
setwd("C:/Users/nelin/Desktop/GWU Information/GWU Fall 2026/Princip_Bioinformatics/mammoth_mitogenome_pubh6860/alignment")
library(phangorn)
# Load .rds from "mammoth_sub_model_select.R"
mt <- readRDS("mammoth_model_select_results.rds")

# Retrieve already-fitted HKY+G(4)+I model because modelTest() already fit every candidate model under max likelihood in order to score it
# phangorn stores those fitted objects internally so we can reuse the desired model instead of rebuilding from scratch
env <-attr(mt, "env")
fit_init <- eval(get("HKY+G(4)+I", env), env)

# Full ML tree search - searches for the best tree toplogy (via nearest neighbor interchange rearrangments) and 
# optimizes branch lengths and the model's own parameters (gamma shape, prop of invariant sites) together.

fit_ml <-optim.pml(fit_init, model = "HKY", optNni = TRUE, optGamma = TRUE, optINv = TRUE)
# optNni searches topology tree
# optGamma optimizes rate-variation param
# optInv optimizes proportion of invariant sites

# Extract tree and save in Newick format
mammoth_tree <- fit_ml$tree
write.tree(mammoth_tree, "mammoth_tree.nwk")

# Visualize colored by pre-/post-bottleneck groups
# Bring in metadata so the tips can be labeled by group
metadata <- read.csv("mammoth_mitogenome_accessions.csv") # Make sure in current directory
# Tip labels look like "MGXXXXXX.X (accession + version) - strop the ".version" suffix so they mamtch 
# the Accession_No column.
tip_accessions <- sub("\\..*$", "", mammoth_tree$tip.label)
tip_groups <- metadata$Group[match(tip_accessions, metadata$Accession_No)]

# Swap the long FASTA header labels for short Lab IDs
tree_for_plot <- mammoth_tree
tree_for_plot$tip.label <- metadata$Lab_ID[match(tip_accessions, metadata$Accession_No)]

# Reserve blank whitespace below lowest tip so scalebar has place to sit without overlapping
n_tips <- length(tree_for_plot$tip.label)

# Color: Post-bottleneck = Pink, Pre-bottleneck = Blue
tip_colors <- ifelse(grepl("^Post", tip_groups), "maroon", "darkblue")

# Save png
png("mammoth_tree_plot.png", width = 2000, height = 1400, res = 180)
plot(tree_for_plot, tip.color = tip_colors, cex = 0.8, no.margin = FALSE, y.lim = c(-3, n_tips +1))

add.scale.bar(x = 0, y = -2)
legend("topleft", legend = c("Post-bottleneck (Wrangel Island)", "Pre-bottleneck (Siberia)"),
       text.col = c("maroon", "darkblue"),
       bty = "n")
dev.off()

# Plot
plot(tree_for_plot, tip.color = tip_colors, cex = 0.75)
add.scale.bar(x = 0, y = -2)
legend("topright", legend = c("Post-bottleneck (Wrangel Island)", "Pre-bottleneck (Siberia)"),
       text.col = c("maroon", "darkblue"),
       bty = "n")
       
# Which samples drive any squashed branches
# node.depth.edgelength() give sthe cumulative distance from the root to every node
root_to_tip <- node.depth.edgelength(tree_for_plot)[1:n_tips]

divergence <- data.frame(
  Lab_ID = tree_for_plot$tip.label,
  root_to_tip_distance = root_to_tip
)
divergence <- merge(divergence, metadata[, c("Lab_ID", "Median_CalBP", "Group")])

# Sorted descending - most divergent at top
divergence[order(-divergence$root_to_tip_distance),]
# Matches the outlier branch group, of (GilbertM20, GilbertM21, GilbertM25, Oimyakon)


