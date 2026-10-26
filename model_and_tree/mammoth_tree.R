# Phylogenetic Tree - (HKY+G(4)+I) used to estimate maximum-likelihood tree
# Usage: Rscript --no-init-file mammoth_tree.R <model_rds> <metadata_csv> <out_nwk> <out_pdf>
library(phangorn)

args <- commandArgs(trailingOnly = TRUE)
rds_file <- if (length(args) >= 1) args[1] else "model_and_tree/mammoth_model_select_results.rds"
meta_csv <- if (length(args) >= 2) args[2] else "data_aquisition/mammoth_mitogenome_accessions.csv"
out_nwk  <- if (length(args) >= 3) args[3] else "model_and_tree/mammoth_tree.nwk"
out_pdf  <- if (length(args) >= 4) args[4] else "model_and_tree/mammoth_tree_plot.pdf"

# Load .rds from "mammoth_sub_model_select.R"
mt <- readRDS(rds_file)

# Retrieve already-fitted HKY+G(4)+I model because modelTest() already fit every candidate model under max likelihood in order to score it
# phangorn stores those fitted objects internally so we can reuse the desired model instead of rebuilding from scratch
env <- attr(mt, "env")
fit_init <- eval(get("HKY+G(4)+I", env), env)

# Full ML tree search - searches for the best tree topology (via nearest neighbor interchange rearrangements) and
# optimizes branch lengths and the model's own parameters (gamma shape, prop of invariant sites) together.
fit_ml <- optim.pml(fit_init, model = "HKY", optNni = TRUE, optGamma = TRUE, optInv = TRUE)
# optNni searches topology tree
# optGamma optimizes rate-variation param
# optInv optimizes proportion of invariant sites (note capital I, lowercase nv)

# Report the fitted model for the Methods/Results sections
cat("\n==== Final fitted model ====\n")
print(fit_ml)
cat("logLik:", fit_ml$logLik, "\n")
cat("Gamma shape:", fit_ml$shape, "\n")
cat("Proportion invariant sites:", fit_ml$inv, "\n")

# Extract tree and save in Newick format
mammoth_tree <- fit_ml$tree
write.tree(mammoth_tree, out_nwk)

# Visualize colored by pre-/post-bottleneck groups
# Bring in metadata so the tips can be labeled by group
metadata <- read.csv(meta_csv)
# Tip labels look like "MGXXXXXX.X" (accession + version) - strip the ".version" suffix so they match
# the Accession_No column.
tip_accessions <- sub("\\..*$", "", mammoth_tree$tip.label)
tip_groups <- metadata$Group[match(tip_accessions, metadata$Accession_No)]

# Swap the long FASTA header labels for short Lab IDs
tree_for_plot <- mammoth_tree
tree_for_plot$tip.label <- metadata$Lab_ID[match(tip_accessions, metadata$Accession_No)]

# Reserve blank whitespace below lowest tip so scalebar has place to sit without overlapping
n_tips <- length(tree_for_plot$tip.label)

# Color: Post-bottleneck = maroon, Pre-bottleneck = dark blue
tip_colors <- ifelse(grepl("^Post", tip_groups), "maroon", "darkblue")

# Save the plot as a PDF (vector graphics, no manual export needed)
pdf(out_pdf, width = 11, height = 8)
plot(tree_for_plot, tip.color = tip_colors, cex = 0.8, no.margin = FALSE, y.lim = c(-3, n_tips + 1))
add.scale.bar(x = 0, y = -2)
legend("topleft", legend = c("Post-bottleneck (Wrangel Island)", "Pre-bottleneck (Siberia)"),
       text.col = c("maroon", "darkblue"),
       bty = "n")
dev.off()

# Which samples drive any squashed branches
# node.depth.edgelength() gives the cumulative distance from the root to every node
root_to_tip <- node.depth.edgelength(tree_for_plot)[1:n_tips]

divergence <- data.frame(
  Lab_ID = tree_for_plot$tip.label,
  root_to_tip_distance = root_to_tip
)
divergence <- merge(divergence, metadata[, c("Lab_ID", "Median_CalBP", "Group")], by = "Lab_ID")

# Sorted descending - most divergent at top
cat("\n==== Root-to-tip distances (largest first) ====\n")
print(head(divergence[order(-divergence$root_to_tip_distance), ], 8))
# Expect the outlier group (GilbertM20, GilbertM21, GilbertM25, Oimyakon) at the top