# AI USAGE LOG
Claude had access to my initial sources, accessions,aligned data, project idea, project guidelines, and goals in initial  chat.
- **Tool:**
- **What I was doing:**
- **What I asked (verbatim):**
- **Exact output (verbatim):**
- **Verification:**
## Entry 1
- **Tool:** Claude (Sonnet 5)
- **What I was doing:** Finding the accession numbers for hte mammoth mitogenome samples.
- **What I asked (verbatim):** "Where will the data for the mammoth's come from? Which study's accession numbers should I use to build the dataset for this project?" 
- **Exact output (verbatim):** 
The dataset you want already exists, ready-made for this exact comparison — you don't need to assemble one from scratch across multiple papers.

**The study:** Pečnerová et al. 2017, *Evolution Letters* — "Mitogenome evolution in the last surviving woolly mammoth population reveals neutral and functional consequences of small population size." This is literally the paper built around the pre/post Wrangel Island bottleneck design we've been discussing: it generated mitogenomes specifically to compare mammoths from before and after the isolation event. It's open access (also on PMC), so no paywall issues.

**The database:** GenBank (NCBI's Nucleotide database) — not the SRA. Ancient DNA raw sequencing reads live in the SRA/ENA, but what you actually need for alignment and phylogenetics is the *assembled mitogenome sequences*, which is what GenBank holds.

**The accession numbers:** the paper deposited its newly generated mitogenomes under **GenBank accession codes MG334264–MG334285** (22 sequences). That range covers the new sequencing the authors did; the full dataset the paper analyzed (21 mitogenomes total, comparing Pleistocene Siberian vs. Holocene Wrangel) also incorporates some previously published sequences from earlier papers (e.g., Palkopoulou et al. 2015), so the complete accession list — matched to each sample's radiocarbon date — lives in the paper's **Supplementary Table S1**, not in the abstract.Want me to pull the actual Table S1 from the paper and put together the working accession list with dates for you, so you have it ready to hand in with Research Project Assignment #1?
- **What I asked next (verbatim):** (pasted the Table 1 link from Pečnerová et al. 2017: https://academic.oup.com/view-large/401719320?login=false) "Can you create an accession number CSV from this table? 
- **Exact output (verbatim):** 
Got it — full accession table this time, columns and all. This fills in exactly what was missing before. A couple of things worth flagging before I hand you the organized version:

**The corrected split (with real accession numbers):**

**Post-bottleneck (Holocene Wrangel Island, <10,000 cal BP)** — 14 samples, accessions **MG334264–MG334270 and MG334274–MG334281** (not a clean consecutive block — they're interleaved with pre-bottleneck accessions).

**Pre-bottleneck (Late Pleistocene, >10,000 cal BP)** — 28 samples, pulling from several different papers' accessions: `MG334271–MG334273`, `MG334275`, `MG334282–MG334285` (this study), plus previously published sequences — `DQ188829` (Krause et al. 2006), `EU153444–EU153458` (Gilbert et al. 2007/2008), `EU155210` (Poinar et al. 2006), `DQ316067` (Rogaev et al. 2006), and `KX027489`/`KX027495` (Enk et al. 2016).

**A genuinely interesting wrinkle for your discussion section:** two samples — **L410** (14,408 cal BP) and **E470** (41,632 cal BP) — were physically found *on* Wrangel Island but predate the isolation event by thousands of years (back when Wrangel was still just high ground within the connected Beringian landscape, not yet a cut-off island). Their haplotypes are labeled **W9** and **W8** — distinct from the small handful of haplotypes (mostly **W1** and **W4**) that dominate the true post-isolation population. That's a nice concrete illustration of the founder effect in your own data: genetic diversity among "Wrangel-area" mammoths before isolation, collapsing to just a couple of haplotypes after isolation. I've grouped these two with the pre-bottleneck set by date, not by location, since date/isolation status is the biologically meaningful variable here.

**One data-quality note:** six samples (GilbertM1, GilbertM5, GilbertM20, GilbertM21, Rogaev, 2002/472) have only bounded or missing calibrated dates (e.g., ">58,000"). They're unambiguously pre-bottleneck, but you'll want to decide how to handle them if you do anything with continuous date regression rather than just categorical pre/post binning.This gives you 42 accession numbers total, sorted and grouped, ready to feed into a GenBank batch download (NCBI's Batch Entrez tool takes a plain list of accession numbers and returns FASTA for all of them at once — that'll save you from pulling 42 sequences one at a time).

- **Verification:** I opened the CSV and compared it to the Table 1 and information from Pečnerová et al. 2017. 

## Entry 2
- **Tool:** Claude (Sonnet 5)
- **What I was doing:** Grabbing the data from CLI.
- **What I asked (verbatim):** "How can I aquire the data through CLI?"
- **Exact output (verbatim):** 
Let's do it. Since we already have the accession list built (from that CSV), the actual pull from GenBank is a short, scriptable step — no need to type 42 accession numbers by hand anywhere.Good — 42 accessions extracted cleanly. Here's the plan:One heads-up before you run it: these are full mitogenomes (~16.5 kb each × 42 sequences), so the download is a few MB — not huge, but give it a moment. Also, if you ever scale this workflow up to hundreds of sequences, NCBI asks that you either space out requests or register a free API key to raise the rate limit — not a concern at 42, just worth knowing for later.

1
Set up your working folder
Put accessions.txt (attached above) in the same folder where you'll work — e.g. open your WSL2/Ubuntu terminal and cd into a project folder like ~/mammoth-project/data/. Having the accession list as a plain file (one ID per line) means you never retype accession numbers by hand, and the whole pull is reproducible if you need to rerun it.
2
Fetch all 42 sequences in one request
NCBI's E-utilities let you fetch sequences straight from the command line with curl (already installed in WSL2 and Git Bash — no extra setup needed). Run this single command: curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=$(paste -sd, accessions.txt)&rettype=fasta&retmode=text" -o mammoth_mitogenomes.fasta What's happening: $(paste -sd, accessions.txt) takes your 42 accession numbers (one per line) and joins them into one comma-separated string, which gets dropped straight into the URL. db=nucleotide tells NCBI which database to search, rettype=fasta&retmode=text says 'give me plain FASTA text back', and -o saves the output to a file instead of printing it to your screen.
3
Verify the download
Check that you actually got 42 sequences back and that nothing silently failed: grep -c ">" mammoth_mitogenomes.fasta This should print 42 (each FASTA record starts with a '>' header line, so counting '>' lines counts sequences). If you get a smaller number, open the file and check for an error message from NCBI near the top — usually means one accession was mistyped or the request got rate-limited.
4
Spot-check the headers
Take a quick look at the first couple of headers to confirm they match what you expect: head -4 mammoth_mitogenomes.fasta You should see lines like '>MG334270.1 Mammuthus primigenius mitochondrion...' followed by sequence data.
5
Keep it as one combined FASTA for now
Resist the urge to split this into separate 'pre-bottleneck.fasta' and 'post-bottleneck.fasta' files right now. Your alignment step (Part 2) needs all 42 sequences aligned together in one multiple sequence alignment, so the columns stay homologous across both groups. You'll use the Group column from mammoth_mitogenome_accessions.csv to split things out later, after alignment — not before.

Let me know once you've run it and gotten your `mammoth_mitogenomes.fasta` — next up would be Part 2: alignment (MAFFT is the standard tool for mitogenome-scale multiple sequence alignment and handles this size easily).
- **Verification:** I ran commands and verified that the FASTA file was downloaded onto my computer. 

## Entry 3
- **Tool:** (Claude Sonnet 5)
- **What I was doing:** Running alignment with MAFFT.
- **What I asked (verbatim):** Can you help me align my FASTA sequences with MAFFT in WSL2/Ubuntu?"
- **Exact output (verbatim):**
Alignment. With 42 full mitogenomes (~16.5kb each), the standard tool for this is **MAFFT** — it's fast even at genomic scale, handles the N's in your sequences without complaint, and installs cleanly through conda into the WSL2 environment you're already using.

Install MAFFT
In your WSL2/Ubuntu terminal (with your base conda environment active, same as before): conda install -c bioconda -c conda-forge mafft Then confirm it installed correctly: mafft --version This only needs to happen once — MAFFT will be available in every terminal session after this.
2
Run the alignment
From the same folder as your mammoth_mitogenomes.fasta: mafft --auto mammoth_mitogenomes.fasta > mammoth_aligned.fasta --auto tells MAFFT to pick the best alignment strategy for you based on how many sequences you have and how long they are, rather than you having to choose between its several algorithms manually. For 42 sequences at ~16.5kb each, this will likely select a fast, appropriate method automatically — expect this to take anywhere from a few seconds to a couple of minutes, not hours.
3
Confirm nothing was dropped
Quick sanity check that the output is complete before moving on: grep -c ">" mammoth_aligned.fasta This should still say 42 — alignment doesn't add or remove sequences, it just inserts gap characters (-) so everything lines up to the same length.
4
Load and verify in R
This is where it's worth switching to R (seqinr), both to properly verify the alignment and to set up the object you'll reuse in Part 3 for diversity statistics: library(seqinr) aln <- read.alignment("mammoth_aligned.fasta", format = "fasta") length(aln$seq) # should be 42 lengths <- sapply(aln$seq, nchar) lengths[1] # the alignment length (with gaps) all(lengths == lengths[1]) # TRUE confirms every sequence is now padded to the same length If that last line returns TRUE, your alignment is structurally sound and ready for the next step.
5
Commit the alignment
Since you're keeping the full working history on GitHub, add mammoth_aligned.fasta (and the mafft command you ran, maybe as a comment in your script or a short README note) to your next commit — that way anyone reproducing this later can see exactly what alignment step produced the file, not just the result.

One thing to flag before you run it: with 14 of your 42 sequences being "partial genome" ancient DNA (lots of N's, possibly different coverage spans), don't be surprised if the resulting alignment has a fair number of gap columns, especially near the edges. That's expected and not a sign anything went wrong — it's just what aligning degraded ancient samples against more complete ones looks like. Worth a sentence about it in your eventual Methods section.

Let me know how the run goes.

Then, load and verify in R
```r
library(seqinr)
aln <- read.alignment("mammoth_aligned.fasta", format = "fasta")

length(aln$seq)
lengths <- sapply(aln$seq, nchar)
lengths[1]
all(lengths == lengths[1])
```
length(aln$seq) should be 42. The last line should return TRUE — confirming every sequence is now padded to the same alignment length.
- **What I asked next:** I pasted the output from `mammoth_aligned.fasta` and from the R script `mafft_mammoth_verify.R`.
- **Exact output (verbatim):** 
This confirms exactly what alignment is supposed to do to your raw file — here's the concrete picture from your actual data:

**Before alignment:** your 42 sequences were all different lengths — anywhere from about 16,243 real bases (P009) up to 16,842 (the Rogaev sample, DQ316067) — because ancient DNA sequencing rarely recovers the exact same stretch of the mitochondrial genome from every specimen. Some are missing chunks at the ends, some have gaps in low-coverage regions.

**What MAFFT did:** it lined all 42 sequences up against each other by homologous position (i.e., "this base in sequence A corresponds to this base in sequence B") and inserted gap characters (`-`) wherever a given sequence is missing something that other sequences have at that position. That's why every sequence in your aligned file is now exactly **16,905 characters long** — that total includes both real bases and inserted gaps.

So concretely:
- DQ316067 (your most complete sequence, 16,842 real bases) only needed 63 gap characters added to reach 16,905.
- P009 (16,243 real bases) needed 662 gaps added — it was missing the most, relative to the others.

**Important: nothing about the original sequences themselves changed.** No bases were edited, deleted, or guessed at. Alignment doesn't fill in missing data — it just tells you *where* the missing data is relative to everything else, by padding with gaps so every sequence occupies the same coordinate system. Your original `mammoth_mitogenomes.fasta` file is completely untouched; `mammoth_aligned.fasta` is a new, separate file sitting alongside it.

- **Verification:** I successfully ran the MAFFT alignment and produced the FASTA as well as successfully verified the output in R. 

## Entry 4
- **Tool:** Claude (Sonnet 5)
- **What I was doing:** Choosing a model substitution.
- **What I asked (verbatim):** "Can you help me write a script using ape and phangorn in R that tests substitution models for my dataset? 
- **Exact output (verbatim):**
One addition worth noting: I added a `saveRDS(mt, "model_test_results.rds")` line that wasn't in the original walkthrough — since `modelTest()` can take several minutes, this saves the result to disk so you (or anyone reproducing the project) never has to rerun that slow step just to look at the output again. You can reload it anytime with `mt <- readRDS("model_test_results.rds")`.

```r
# =============================================================
# Part 3, Step A: Substitution Model Testing
# Mammoth mitogenome project — PUBH 6860
# =============================================================
# Goal: before building a phylogenetic tree, figure out which
# substitution model best describes how these 42 mitogenomes
# actually evolved — rather than assuming or guessing one.
 
# ---- 1. Install required packages (one-time only) ----
# ape handles general phylogenetics file formats and tree objects.
# phangorn is the package that does model testing and tree-building.
install.packages(c("ape", "phangorn"))
 
# ---- 2. Load the alignment into phangorn's format ----
library(phangorn)
 
# phangorn has its own data structure (phyDat), separate from the
# seqinr alignment object used in Part 2 — but it can read the
# aligned FASTA file directly, so no manual conversion is needed.
mammoth_phydat <- read.phyDat("mammoth_aligned.fasta",
                               format = "fasta",
                               type = "DNA")
 
# Sanity check: should print 42 — confirms every sequence came
# through the conversion.
length(mammoth_phydat)
 
# ---- 3. Run model testing ----
# This fits a whole series of candidate substitution models to the
# alignment — from the simplest (every mutation equally likely) up
# through more realistic ones (unequal base frequencies,
# transition/transversion bias, rate variation across sites) — and
# scores how well each one explains the data.
#
# NOTE: with 42 sequences at ~16,900 bp each, this can take several
# minutes to finish. That's expected, not a sign anything's wrong.
mt <- modelTest(mammoth_phydat)
 
# Save the results to disk so this slow step never has to be rerun
# just to look at the output again later.
saveRDS(mt, "model_test_results.rds")
 
# ---- 4. Identify the best-fitting model ----
# Sort by AIC: a statistic that rewards good fit but penalizes
# unnecessary complexity — lower AIC is better. The top row is the
# model we'll carry into Step B (building the tree).
mt[order(mt$AIC), ]
``` 
Run this top to bottom in your R console, and paste the sorted AIC table here once it finishes.
- **Verification:** Typed out the script myself, verified the output, inspected the results manually, researched the meaining of the output of the tests of both AIC (and subversions), the winning model of HKY+G(4)+I, and BIC and came to a logical conclusion of what model I would pick.

## Entry 5
- **Tool:** Claude (Sonnet 5)
- **What I was doing:** From the model selection of HKY+G(4)+I, building a phylogeny tree.
- **What I asked (verbatim):** "Based off the results from the substitution model selection, I am going to choose HKY+G(4)+I, AIC and AICc's winning model. Mitochondrial DNA has rate variation and I would not want to exclude real genetic divergence with the bias that BIC would use. BIC chose the more simple HKY+I which is the simpler model. Can you help me write a script to construct a phylogeny tree using phangorn and build a plot?" (attached the results `mammoth_model_select_results.rds` and the sorted csv `mammoth_model_select_sorted_results.csv`).
- **Exact output (verbatim):** 
Good catch on landing on HKY+G(4)+I — that matches what AIC and AICc both say is your best model. I actually ran that check against your full results table, and here's the real finding:

| Criterion | Best model |
|---|---|
| AIC | **HKY+G(4)+I** |
| AICc | **HKY+G(4)+I** |
| BIC | **HKY+I** (no gamma) |

**AIC and BIC actually disagree** — and it's exactly the pattern we talked about. BIC's harsher penalty on a large alignment (your ~16,900 sites) pushed it to drop the rate-variation parameter (the `+G(4)` term) entirely and settle for the simpler model. The difference between the two models is just one parameter (87 vs. 86), but BIC decided that one extra parameter wasn't "worth" its cost under such a steep per-parameter penalty.

**What to do with this:** go with **HKY+G(4)+I** (AIC's pick) for building your tree — mitochondrial DNA reliably does have real rate variation across sites, so there's good biological reason to trust AIC's answer over BIC's more conservative one here, consistent with what we discussed. 

Glad that landed well — alright, Step B: building the actual tree.

Quick concept before the script: we're not refitting the model from scratch. `modelTest()` already fit every candidate model under maximum likelihood just to score it, so phangorn kept those fitted results internally — we just pull out the one for HKY+G(4)+I and refine it further by searching for the best tree *topology* (not just branch lengths) using something called nearest-neighbor interchange rearrangements, which basically tries small rearrangements of the tree and keeps whichever improves the likelihood. Then we visualize it colored by your pre-/post-bottleneck groups, which doubles as the sanity check we talked about back when we first discussed why this step matters.
```r
04 tree building · R
# =============================================================
# Part 3, Step B: Building the Phylogenetic Tree
# Mammoth mitogenome project — PUBH 6860
# =============================================================
# Goal: use the best-fit substitution model (HKY+G(4)+I) from
# Step A to estimate a maximum-likelihood phylogenetic tree, then
# visualize it labeled by pre-/post-bottleneck group as a sanity
# check before moving on to diversity statistics (Part 5).
 
library(phangorn)
 
# ---- 1. Reload model testing results (if starting a new session) ----
mt <- readRDS("model_test_results.rds")
 
# ---- 2. Retrieve the already-fitted HKY+G(4)+I model ----
# modelTest() already fit every candidate model under maximum
# likelihood in order to score it — phangorn stores those fitted
# objects internally, so we reuse the one we want instead of
# rebuilding it from scratch.
env <- attr(mt, "env")
fit_init <- eval(get("HKY+G(4)+I", env), env)
 
# ---- 3. Refine: full ML tree search ----
# This searches for the best tree topology (via nearest-neighbor
# interchange rearrangements) and optimizes branch lengths and the
# model's own parameters (gamma shape, proportion of invariant
# sites) together.
#
# NOTE: with 42 taxa and a ~16,900 bp alignment, this step can take
# a while to run — let it finish.
fit_ml <- optim.pml(fit_init,
                     model    = "HKY",
                     optNni   = TRUE,   # search tree topology
                     optGamma = TRUE,   # optimize rate-variation parameter
                     optInv   = TRUE)   # optimize proportion of invariant sites
 
# Inspect the final fitted model (log-likelihood, parameter estimates)
fit_ml
 
# Extract the tree itself
mammoth_tree <- fit_ml$tree
 
# Save the tree in standard Newick format, so this slow step never
# has to be rerun just to reuse the tree later
write.tree(mammoth_tree, "mammoth_tree.nwk")
 
#  ---- 4. Visualize the tree, colored by pre-/post-bottleneck group ----
# Bring in the sample metadata so we can label tips by group.
metadata <- read.csv("mammoth_mitogenome_accessions.csv")
 
# Tip labels look like "MG334270.1" (accession + version) — strip
# the ".version" suffix so they match the Accession_No column.
tip_accessions <- sub("\\..*$", "", mammoth_tree$tip.label)
tip_groups <- metadata$Group[match(tip_accessions, metadata$Accession_No)]
 
# Color tips: post-bottleneck (Wrangel) in red, pre-bottleneck in blue
tip_colors <- ifelse(grepl("^Post", tip_groups), "firebrick", "steelblue")
 
# Swap the long FASTA header labels for short Lab IDs. The full
# headers (e.g. "MG334272.1 Mammuthus primigenius isolate L158
# mitochondrion, partial genome") eat up most of the plot's width,
# which is what was squashing the branch lengths visually — ape
# shrinks the tree to make room for whatever text it has to fit.
tree_for_plot <- mammoth_tree
tree_for_plot$tip.label <- metadata$Lab_ID[match(tip_accessions, metadata$Accession_No)]
 
# Reserve blank space below the lowest tip so the scale bar has
# somewhere to sit without overlapping a tip's branch line (this is
# what caused the "2002/472" tip to look struck-through before —
# the scale bar's default position happened to land right on it).
n_tips <- length(tree_for_plot$tip.label)
 
# Save a wide, high-resolution version to a file — a bigger canvas
# gives branch-length differences more pixels to actually show up in,
# rather than relying on RStudio's small default plot pane.
png("mammoth_tree_plot.png", width = 2000, height = 1400, res = 180)
plot(tree_for_plot, tip.color = tip_colors, cex = 0.8, no.margin = FALSE,
     y.lim = c(-3, n_tips + 1))
# A scale bar is the rigorous way to compare branch lengths — it
# shows exactly what a given branch length means in substitutions
# per site, rather than relying on eyeballing pixel distances.
# x = 0 anchors it at the root; y = -2 drops it into the blank
# margin we just reserved, below every tip.
add.scale.bar(x = 0, y = -2)
legend("topleft",
       legend = c("Post-bottleneck (Wrangel Island)", "Pre-bottleneck (Siberia)"),
       text.col = c("firebrick", "steelblue"),
       bty = "n")
dev.off()
 
# Also show it in your R session's plot pane
plot(tree_for_plot, tip.color = tip_colors, cex = 0.8,
     y.lim = c(-3, n_tips + 1))
add.scale.bar(x = 0, y = -2)
legend("topleft",
       legend = c("Post-bottleneck (Wrangel Island)", "Pre-bottleneck (Siberia)"),
       text.col = c("firebrick", "steelblue"),
       bty = "n")
 
# ---- 5. Diagnose: which samples are driving the squashed branches? ----
# When most branches look crammed near zero, it's usually because one
# branch (or clade) is far more divergent than everything else, and
# the plot has to scale its whole x-axis to fit that one branch —
# compressing all the "normal" variation into a tiny sliver of space.
#
# node.depth.edgelength() gives the cumulative distance from the root
# to every node. For tips, that's the total branch length separating
# each sample from the root — the most reliable way to spot an
# outlier, since the "long branch" might be an internal branch shared
# by several tips rather than any single tip's own terminal branch.
root_to_tip <- node.depth.edgelength(tree_for_plot)[1:n_tips]
 
divergence <- data.frame(
  Lab_ID = tree_for_plot$tip.label,
  root_to_tip_distance = root_to_tip
)
divergence <- merge(divergence, metadata[, c("Lab_ID", "Median_CalBP", "Group")],
                     by = "Lab_ID")
 
# Sorted descending — the most divergent samples float to the top
divergence[order(-divergence$root_to_tip_distance), ]
```
Run that top to bottom — expect the `optim.pml()` line to take a few minutes given the dataset size. Once the plot renders, send it over (or describe what you're seeing) and we'll check it against those sanity-check criteria before moving on.
- **Verification:** I typed out and edited the code as I needed it. This code was causing issues for me and did not need all the extra steps Claude included. I edited the plot to fit what I found looked readable and clear. I also investigated the placement of P011 (pre-bottleneck) and noted the probability of its placement among the post-bottleneck group being due to its radiocarbon date and P011 having some of the most gaps in its sequence. 

## Entry 6
- **Tool:** Claude (Sonnet 5)
- **What I was doing:** Despite the metadata CSV labeling each sample as Pre- or Post- bottleneck, the diversity statistics needs the actual aligned sequences split into groups. So I needed to upload the aligned files and run diversity statistics with the 14 post-bottleneck and teh 28 pre-bottleneck. 
- **What I asked (verbatim):** "Can you help me write a script that time-bins the aligned samples into pre- and post-bottle neck groups (referencing metadata `mammoth_mitogenome_accessions.cv`) and save into a FASTA file for both for downstream diversity statistics? I plan on computing nucleotide diversity (pi), segregating sites (S), and haplotype diversity (Hd).
- **Exact output (verbatim):**
```r
05 time binning · R
# =============================================================
# Part 4: Time-Binning — Splitting Samples into Pre-/Post-Bottleneck Groups
# Mammoth mitogenome project — PUBH 6860
# =============================================================
# Goal: using the group assignments already established in the
# sample metadata, split the ALIGNED sequences themselves into two
# subsets — post-bottleneck (Wrangel Island) and pre-bottleneck
# (Siberia) — ready for the diversity statistics in Part 5.
#
# This is a separate, necessary step even though the group labels
# already exist in your metadata CSV: diversity statistics are
# computed on the actual sequence alignment, not on a spreadsheet
# column or the tree.
 
library(ape)
 
# ---- 1. Load the alignment as a DNAbin object ----
# DNAbin is ape's compact binary format for DNA sequences, and it's
# what population-genetics functions in Part 5 (e.g., from the pegas
# package) expect as input.
mammoth_dna <- read.dna("mammoth_aligned.fasta", format = "fasta")
 
# Sanity check: should report 42 sequences, 16,905 bp each
dim(mammoth_dna)
 
# ---- 2. Match each sequence to its pre-/post-bottleneck group ----
metadata <- read.csv("mammoth_mitogenome_accessions.csv")
 
# Sequence names are still in "ACCESSION.version" form (e.g.
# "MG334270.1") — strip the version suffix to match Accession_No.
seq_accessions <- sub("\\..*$", "", rownames(mammoth_dna))
seq_groups <- metadata$Group[match(seq_accessions, metadata$Accession_No)]
 
# Confirm every sequence matched to a group. Expect THREE labels, not
# two: "Post-bottleneck" (14), "Pre-bottleneck" (22), and
# "Pre-bottleneck (undated)" (6). The 6 undated samples are still
# pre-bottleneck — "undated" only means the source table gave no
# precise calibrated date for them (just a minimum age, or no date at
# all). The thing to check is that there are no NA entries: an NA
# would mean an accession in your alignment didn't match anything in
# the metadata CSV, which would be worth tracking down.
table(seq_groups, useNA = "ifany")
 
# Collapse the three labels into a clean two-level group variable.
# grepl("^Pre") catches both "Pre-bottleneck" and "Pre-bottleneck
# (undated)", so the 22 + 6 samples combine into one group of 28.
seq_groups_clean <- ifelse(grepl("^Post", seq_groups),
                           "Post-bottleneck", "Pre-bottleneck")
 
# Should now show exactly 14 Post and 28 Pre
table(seq_groups_clean, useNA = "ifany")
 
# ---- 3. Split into two DNAbin subsets ----
post_bottleneck <- mammoth_dna[seq_groups_clean == "Post-bottleneck", ]
pre_bottleneck  <- mammoth_dna[seq_groups_clean == "Pre-bottleneck", ]
 
# Confirm the split matches expectations: 14 post, 28 pre
dim(post_bottleneck)
dim(pre_bottleneck)
 
# ---- 4. Save both subsets for use in Part 5 ----
# As FASTA, in case you want to inspect them directly or use them in
# another tool later:
write.dna(post_bottleneck, "post_bottleneck_aligned.fasta", format = "fasta")
write.dna(pre_bottleneck, "pre_bottleneck_aligned.fasta", format = "fasta")
 
# And as a single RDS file, so Part 5 can load both DNAbin objects
# directly without re-parsing FASTA files each time:
saveRDS(list(post = post_bottleneck, pre = pre_bottleneck),
        "time_binned_alignments.rds")
 
```
- **Verification:** I ran the script and inspected the output. The numbers were as I expected with the post-bottleneck containing 14 seqs and the pre-bottleneck containing 28 and both having 16905 nucleotides. Every seq matched to a group. 

## Entry 7
- **Tool:** Claude (Sonnet 5.5)
- **What I was doing:** Running diversity statistics.
- **What I asked (verbatim):** "Can you help me write a script that measures these 3 diversity statistics on the `time_binned_alignments.rds` from the previous script using the same packages `ape` and `pegas`: 1) Nucleotide diversity - average fraction of sites where they differ (pi), 2) Segregating sites - number of alignment positions that vary within the group (S), and 3) Haplotype diversity - probability that two randomly chosen seqs are different haplotypes? Keep in mind when designing the script that the alignment of my sequences has gaps and N's so the diversity statistics should be run on those columns with a real base. 
- **Exact output (verbatim):**
### Part 5: diversity statistics

This is the step that puts numbers on what the tree showed visually. I've put the script above in `06_diversity_stats.R`. It computes three standard measures for each group:

- **Nucleotide diversity (π):** pick any two sequences in a group, and π is the average fraction of sites where they differ. It is the main measure here.
- **Segregating sites (S):** the number of alignment positions that vary at all within the group.
- **Haplotype diversity (Hd):** the probability that two randomly chosen sequences are different haplotypes. A haplotype is a unique version of the sequence.

**The design decision to understand:** your alignment has gaps and N's, mostly in the partial-genome ancient samples. A gap or N means "we don't know this base." It does not mean the base is different, so those positions can't count as differences. The script keeps only columns where all 42 sequences have a real base, and it uses those same columns for both groups. If each group were trimmed separately, they would be measured over different stretches of the genome, and a diversity difference could just reflect which sites survived. Section 5 of the script re-checks π using pairwise deletion, the opposite approach. If both methods tell the same story, your result doesn't depend on how missing data was handled.
```r

06 diversity stats · R
# =============================================================
# Part 5: Diversity Statistics by Group
# Mammoth mitogenome project — PUBH 6860
# =============================================================
# Goal: quantify genetic diversity in the post-bottleneck (Wrangel
# Island) and pre-bottleneck (Siberia) groups, using the three
# standard measures:
#   - Nucleotide diversity (pi): the average proportion of sites at
#     which two randomly chosen sequences differ.
#   - Segregating sites (S): how many alignment positions vary at all.
#   - Haplotype diversity (Hd): the probability that two randomly
#     chosen sequences are different haplotypes.
#
# These are calculated by hand with ape + base R (rather than a
# population-genetics package) so every number is traceable to a
# line of code, and so no new package needs adding to renv.
 
library(ape)
 
# ---- 1. Load the two group alignments from Part 4 ----
binned <- readRDS("time_binned_alignments.rds")
post <- binned$post   # 14 sequences
pre  <- binned$pre    # 28 sequences
 
# ---- 2. Choose the sites every group will be compared on ----
# The alignment contains gaps (-) and Ns (unknown bases), mostly in
# the partial-genome ancient samples. A gap or N is "we don't know,"
# not "this base is different," so those positions can't be counted
# as differences.
#
# Approach: keep only alignment columns where ALL 42 sequences have
# a real base (A, C, G, or T). Using the same set of columns for both
# groups matters — if each group were trimmed separately, they'd be
# measured over different stretches of the genome, and a difference
# in diversity could just reflect which sites were kept.
all_dna   <- rbind(post, pre)
all_chars <- as.character(all_dna)     # matrix of single letters
 
callable <- apply(all_chars, 2, function(col) all(col %in% c("a", "c", "g", "t")))
 
# How many of the 16,905 alignment columns survive?
sum(callable)
mean(callable)   # as a proportion
 
post_sites <- as.character(post)[, callable]
pre_sites  <- as.character(pre)[, callable]
 
# ---- 3. A function that computes all three statistics ----
diversity_stats <- function(char_mat) {
  n <- nrow(char_mat)
 
  # Nucleotide diversity (pi): average pairwise difference per site.
  # dist.dna(model = "raw") returns, for every pair of sequences, the
  # proportion of sites that differ; pi is the mean of those values.
  pair_dist <- dist.dna(as.DNAbin(char_mat), model = "raw")
  pi <- mean(as.vector(pair_dist))
 
  # Segregating sites (S): columns containing more than one distinct base.
  S <- sum(apply(char_mat, 2, function(col) length(unique(col)) > 1))
 
  # Haplotypes: sequences that are identical across every kept site
  # are the same haplotype. Paste each row into one long string and
  # count the distinct strings.
  hap_ids    <- apply(char_mat, 1, paste, collapse = "")
  hap_counts <- table(hap_ids)
  n_hap      <- length(hap_counts)
 
  # Haplotype diversity (Nei & Tajima): 1 minus the sum of squared
  # haplotype frequencies, with an n/(n-1) small-sample correction.
  p  <- as.numeric(hap_counts) / n
  Hd <- (n / (n - 1)) * (1 - sum(p^2))
 
  data.frame(n_seqs           = n,
             sites_used       = ncol(char_mat),
             pi               = pi,
             segregating_sites = S,
             n_haplotypes     = n_hap,
             hap_diversity    = Hd)
}
 
# ---- 4. Run it on each group and save the results ----
results <- rbind(Post = diversity_stats(post_sites),
                 Pre  = diversity_stats(pre_sites))
results
 
write.csv(results, "diversity_stats_by_group.csv")
 
# ---- 5. Optional sensitivity check: pairwise deletion ----
# Section 2 threw away every column where ANY sample had a gap or N.
# Pairwise deletion is the opposite extreme: for each pair of
# sequences, use every site where BOTH have a real base. If pi tells
# the same story under both approaches, the result doesn't depend on
# how missing data was handled.
pi_post_pairwise <- mean(as.vector(dist.dna(post, model = "raw", pairwise.deletion = TRUE)))
pi_pre_pairwise  <- mean(as.vector(dist.dna(pre,  model = "raw", pairwise.deletion = TRUE)))
c(Post = pi_post_pairwise, Pre = pi_pre_pairwise)
```

### What you should see

Your R output should match these numbers. If it doesn't, tell me, because that would point to a bug in one of the two.

| | Post (Wrangel) | Pre (Siberia) |
|---|---|---|
| Sequences | 14 | 28 |
| Sites used | 11,153 (of 16,905) | 11,153 |
| π | ~0.0001 | ~0.0050 |
| Segregating sites | 6 | 300 |
| Haplotypes | 7 | 27 |
| Hd | ~0.82 | ~0.997 |

Two cross-checks give me confidence in the logic. The haplotype counts match the published labels from your Table 1: the Wrangel samples carry W1–W7 (7 haplotypes), and the pre-bottleneck samples have 27 distinct labels (S1–S25, with two samples sharing S9, plus W8 and W9). Independent calculations agree with the paper's own haplotype assignments.

The difference in π is large, about 50-fold, which is the founder-effect signature your project is testing for.

### Caveats to keep in mind

- **Sample sizes differ (14 vs. 28).** S and the haplotype count tend to grow with sample size, so they are not a fair comparison on their own. π and Hd are less sensitive, and this can be adressed directly by repeatedly drawing random sets of 14 from the 28 pre-bottleneck samples.
- **The pre-bottleneck group is a mix.** It spans roughly 12,000 to 60,000+ years and includes the deeply divergent ancient clade from your tree. That clade inflates the group's π. Redoing the calculation without those four samples would show how much they contribute.
- **Complete deletion drops 34% of sites** (5,752 columns), because the partial genomes are missing different regions. This is the reason for the pairwise-deletion check in Section 5.
- **Hd for the pre group is nearly 1** because almost every sequence is unique. It can't rise much higher, so it tells you less than π does.

Run the script and send me the `results` table and the pairwise-deletion output. Then we can compare them with the preview.
- **Verification:** I typed out the script, found the Nei and Tajima paper with the haplotype frequency calculation, verified it, and added it to my sources. Then visually inspected the results compared to the output that Claude independently decided to run. The numbers matched. There is a significant gap between the pi of the pre-bottle neck and the post-bottle neck (Pre / Post is 50x higher in pre wth complete deletion and 11x higher in pre with pairwise deletion) in both the complete deletion and the pairwise deletion methods. I decided to keep complete deletion was chosen as the primary analysis with the pairwise analysis being a sensitivity check. 
```r
# Complete deletion
    n_seqs sites_used           pi segregating_sites n_haplotypes hap_diversity
Post     14      11153 0.0001034561                 6            7     0.8241758
Pre      28      11153 0.0049454034               300           27     0.9973545

# Pairwise deletion
        Post          Pre 
0.0004051837 0.0045286179 
```

## Entry 8 
- **Tool:** Claude (Sonnet 5.5)
- **What I was doing:** Running hypothesis test
- **What I asked (verbatim):** "I decided to keep complete deletion was chosen as the primary analysis with the pairwise analysis being a sensitivity check. Can you help me write a script that answers this Hypothesis 'H0: Pre-bottleneck and Post-bottleneck have the same nucleotide diversity (pi), so the group labels carry no information. H1: Post-bottleneck pi is lower than Pre-bottleneck pi.' I would like to run a permutation test on all samples since the samples are related to each other so a t-test would not work. I also want to run that same test without the 3 ancient indviduals (GilbertM20, GilbertM21, and GilbertM25) so I can check that the result doesn't depend on the ancient divergent clade inflating the Pre-bottleneck pi. Finally can you add a test that compares the Post-bottleneck against a large (10,000) amount of random draws of 14 samples from the Pre-bottleneck so the 14 vs. 18 mismatch is accounted for? This would affect segregating sites and haplotype counts.  
- **Exact output (verbatim):**
```r
07 hypothesis tests · R
# =============================================================
# Part 6: Hypothesis Testing — Is Post-Bottleneck Diversity Lower?
# Mammoth mitogenome project — PUBH 6860
# =============================================================
# Question: is genetic diversity in the post-bottleneck (Wrangel
# Island) group lower than in the pre-bottleneck (Siberia) group by
# more than chance would produce?
#
#   H0: Pre and Post have the same nucleotide diversity (pi); the
#       group labels carry no information about diversity.
#   H1: Post pi < Pre pi (one-sided — the founder-effect hypothesis
#       predicts a direction, so we test that direction).
#
# Three analyses:
#   A. Permutation test on the difference in pi (all 42 samples)
#   B. The same test with the deeply divergent ancient clade removed
#   C. Rarefaction: compare Post against random 14-sample draws from
#      Pre, to deal with the 14-vs-28 sample size mismatch
 
library(ape)
 
# ---- 1. Rebuild the shared site set (same filter as Part 5) ----
binned <- readRDS("time_binned_alignments.rds")
post <- binned$post
pre  <- binned$pre
 
all_dna   <- rbind(post, pre)
all_chars <- as.character(all_dna)
callable  <- apply(all_chars, 2, function(col) all(col %in% c("a", "c", "g", "t")))
sites     <- all_chars[, callable]          # 42 samples x 11,153 sites
 
# One label per row of `sites` (rbind put Post rows first, then Pre)
group <- c(rep("Post", nrow(post)), rep("Pre", nrow(pre)))
 
# ---- 2. Pairwise distance matrix, computed ONCE ----
# Every test below needs pi for many different subsets of samples.
# pi for a group is just the average of the pairwise distances among
# its members — so instead of recomputing distances thousands of
# times, calculate the full 42 x 42 matrix once and take averages of
# pieces of it.
D <- as.matrix(dist.dna(as.DNAbin(sites), model = "raw"))
 
mean_pairwise <- function(idx) {
  sub <- D[idx, idx]
  mean(sub[lower.tri(sub)])      # each pair counted once
}
 
post_rows <- which(group == "Post")
pre_rows  <- which(group == "Pre")
 
# Sanity check: these should match your Part 5 results table
# (Post 0.0001034561, Pre 0.0049454034)
mean_pairwise(post_rows)
mean_pairwise(pre_rows)
 
# ---- 3. A reusable permutation test ----
# Logic: if group labels didn't matter, shuffling them at random
# would produce differences in pi about as large as the one we
# actually observed. So: shuffle the Pre/Post labels (keeping the
# same group sizes), recompute the difference in pi, repeat many
# times, and see how often chance alone matches or beats the real
# difference. That fraction is the p-value.
perm_test <- function(keep, n_perm = 10000) {
  g   <- group[keep]
  obs <- mean_pairwise(keep[g == "Pre"]) - mean_pairwise(keep[g == "Post"])
 
  null <- replicate(n_perm, {
    shuffled <- sample(g)
    mean_pairwise(keep[shuffled == "Pre"]) - mean_pairwise(keep[shuffled == "Post"])
  })
 
  # "+1" counts the real arrangement as one of the possibilities, so
  # the p-value can never be reported as exactly zero.
  p <- (sum(null >= obs) + 1) / (n_perm + 1)
  list(observed = obs, null = null, p = p)
}
 
# ---- 4. Analysis A: all 42 samples ----
set.seed(2026)                       # makes the shuffles reproducible
res_all <- perm_test(seq_len(nrow(sites)))
res_all$observed                     # Pre pi minus Post pi
res_all$p
 
# Plot the null distribution with the observed difference marked.
# (Saved as PDF — it has been the format that works reliably.)
pdf("permutation_test_all.pdf", width = 7, height = 5)
hist(res_all$null, breaks = 50,
     xlim = c(min(res_all$null), res_all$observed * 1.1),
     main = "Permutation test: difference in pi (Pre - Post)",
     xlab = "Difference in nucleotide diversity under shuffled labels")
abline(v = res_all$observed, col = "firebrick", lwd = 2)
legend("topright", legend = "Observed difference", col = "firebrick", lwd = 2, bty = "n")
dev.off()
 
# ---- 5. Analysis B: remove the deeply divergent ancient clade ----
# GilbertM20, GilbertM21, GilbertM25 and Oimyakon sit on a very long
# branch in the tree and inflate the Pre group's pi. If the result
# only held because of them, it would be much weaker evidence. Match
# them by accession number (stripping the ".version" suffix).
acc <- sub("\\..*$", "", rownames(sites))
outlier_acc <- c("EU153450", "EU153451", "EU153453", "MG334282")
 
keep_trim <- which(!acc %in% outlier_acc)
length(keep_trim)                    # should be 38 (14 Post + 24 Pre)
 
# Pre-bottleneck pi without the ancient clade
mean_pairwise(keep_trim[group[keep_trim] == "Pre"])
 
set.seed(2026)
res_trim <- perm_test(keep_trim)
res_trim$observed
res_trim$p
 
# ---- 6. Analysis C: rarefaction (fixing the 14-vs-28 mismatch) ----
# S and the haplotype count grow with sample size, so 28 Pre samples
# can't be fairly compared with 14 Post samples on those. Fix:
# repeatedly draw 14 random Pre samples, compute each statistic, and
# see where the real Post value falls in that distribution.
#
# Speed trick: a column that doesn't vary within the full Pre group
# can't vary in any subsample, so only the variable columns matter.
pre_sites <- sites[pre_rows, ]
pre_var   <- pre_sites[, apply(pre_sites, 2, function(col) length(unique(col)) > 1)]
ncol(pre_var)                        # number of variable sites within Pre
 
n_post <- length(post_rows)
 
set.seed(2026)
rare <- t(replicate(10000, {
  pick <- sample(length(pre_rows), n_post)          # 14 of the 28 Pre samples
  sub  <- pre_var[pick, , drop = FALSE]
  c(pi = mean_pairwise(pre_rows[pick]),
    S  = sum(apply(sub, 2, function(col) length(unique(col)) > 1)),
    n_haplotypes = nrow(unique(sub)))
}))
 
# The observed Post values, computed the same way
post_sites <- sites[post_rows, ]
post_obs <- c(pi = mean_pairwise(post_rows),
              S  = sum(apply(post_sites, 2, function(col) length(unique(col)) > 1)),
              n_haplotypes = nrow(unique(post_sites)))
 
rare_summary <- data.frame(
  statistic          = colnames(rare),
  post_observed      = as.numeric(post_obs[colnames(rare)]),
  pre14_median       = apply(rare, 2, median),
  pre14_lower95      = apply(rare, 2, quantile, probs = 0.025),
  pre14_upper95      = apply(rare, 2, quantile, probs = 0.975),
  prop_pre14_le_post = sapply(colnames(rare), function(s) mean(rare[, s] <= post_obs[s])),
  row.names = NULL
)
rare_summary
 
# ---- 7. Save everything ----
test_summary <- data.frame(
  analysis = c("All 42 samples", "Without ancient clade (n = 38)"),
  observed_diff_pi = c(res_all$observed, res_trim$observed),
  p_value_one_sided = c(res_all$p, res_trim$p)
)
test_summary
 
write.csv(test_summary, "permutation_test_results.csv", row.names = FALSE)
write.csv(rare_summary, "rarefaction_results.csv", row.names = FALSE)
```

### The hypothesis test

You now have the descriptive numbers, and this step asks whether the gap between them is bigger than chance would produce. The script is `07_hypothesis_tests.R`, above.

**The hypotheses**
- H0: Pre and Post have the same nucleotide diversity, so the group labels carry no information.
- H1: Post π is lower than Pre π. The test is one-sided because the founder-effect hypothesis predicts a direction.

**Why a permutation test.** The 42 samples aren't independent, random draws from a bell curve. They are related to each other and share ancestry, so a t-test's assumptions don't hold. A permutation test avoids those assumptions with a simple idea: if the labels didn't matter, you could shuffle "Post" and "Pre" among the 42 sequences, keep the group sizes at 14 and 28, and get a difference in π about as large as the real one. The script reshuffles 10,000 times and counts how often chance matches or beats what you actually observed. That fraction is the p-value.

The script runs three analyses:

| | What it does | Why it's there |
|---|---|---|
| **A** | Permutation test on all 42 samples | The main test |
| **B** | Same test without GilbertM20, GilbertM21, GilbertM25 and Oimyakon | Checks that the result doesn't depend on the ancient divergent clade, which inflates Pre π |
| **C** | Compares Post against 10,000 random draws of 14 samples from Pre | Fixes the 14-vs-28 mismatch, which matters for S and haplotype counts |

The script computes the full 42 × 42 distance matrix once and takes averages of pieces of it. That is why 10,000 shuffles run in seconds instead of hours.

### What you should see

I can't run R here, so I replicated the same logic in Python on your alignment. Your values should be close. The shuffles are random, so the exact numbers will differ a little, but the pattern should hold.

| Analysis | Result |
|---|---|
| A. All 42 | Difference in π ≈ 0.00484, p ≈ 0.0001 |
| B. Without ancient clade | Pre π drops to ≈ 0.00162, difference ≈ 0.00152, p ≈ 0.0001 |
| C. Rarefaction, π | Pre-14 median ≈ 0.0051, 95% range ≈ 0.0016–0.0074, Post = 0.0001 |
| C. Rarefaction, S | Pre-14 median ≈ 237, Post = 6 |
| C. Rarefaction, haplotypes | Pre-14 almost always 13–14, Post = 7 |

**Reading the p-value:** with 10,000 shuffles, the smallest value the method can report is 1/10,001 ≈ 0.0001. That means no shuffle reached your observed difference. In your write-up, say "p < 0.0001" and avoid "p = 0".

**Reading Analysis B:** the ancient clade contributes about two-thirds of Pre diversity (π falls from 0.0050 to 0.0016 without it). The Post group is still about 15 times less diverse than the trimmed Pre group, and the result is still significant. So the conclusion doesn't hinge on those four samples.

**Reading Analysis C:** in all 10,000 random draws of 14 Pre samples, none had π, segregating sites, or haplotype counts as low as Post's. The sample size mismatch doesn't explain the result.

Run the script and send me the console output for `test_summary` and `rare_summary`. 
- **Verification:** I typed up the script, compared my results against Claude's independently run python script.

## Entry 9:
- **Tool:** Claude (Sonnet 5.5)
- **What I was doing:** Implementing Snakemake
- **What I asked (verbatim):** (attached repository) "Would Snakemake or Nextflow be able to be implemented into this project? If so, could you help me implement it? Which edits to scripts and the repo need to be made?" 
- **Exact output (verbatim):**
Yes, this can be implemented, and I'd use **Snakemake**, not Nextflow. I wrote a draft Snakefile for your repo and dry-run checked it. A dry run only confirms the steps chain together correctly. I haven't run the real analysis through it, because R and MAFFT aren't installed in my workspace.

### Why Snakemake
- **Your pipeline is a short, straight line.** Seven steps pass files to the next one, which is what Snakemake is built for.
- **It fits your tools.** It's Python-based, so it works with the conda setup you already use in WSL. Nextflow needs Java and its own Groovy-style language, and that's overkill here.
- **It matches your proposal.** The proposal commits to a Snakemake *or* Nextflow wrapper, so Snakemake satisfies it.

### What the draft does
The Snakefile has eight rules, one per pipeline step, plus a final `all` target: download, align, verify the alignment, model selection, tree, time-binning, diversity statistics and the permutation test. Snakemake works out the order from each rule's inputs and outputs, and it only re-runs steps whose inputs changed. That means the slow `modelTest` step won't repeat unless the alignment changes. The pipeline graph shows the structure.

### What has to change in your repo first
The Snakefile is not drop-in, because your scripts were written to run by hand in RStudio. These are the changes:
1. **Remove the hardcoded `setwd("C:/Users/nelin/...")` lines.** They are in four scripts: `mafft_mammoth_verify.R`, `mammoth_sub_model_select.R`, `mammoth_tree.R` and `diversity_statistics.R`. They would fail on any machine but yours, and on Snakemake they fail outright.
2. **Let each script take its file paths as arguments** (`commandArgs`) instead of reading fixed filenames. That is roughly three lines per script, and it also removes the duplicate copies of `mammoth_aligned.fasta` and the accessions CSV that currently sit in several folders.
3. **Add the R packages to `environment.yml`.** It currently lists only `mafft`. It needs `r-base`, `r-ape`, `r-phangorn` and `r-seqinr`, so conda can build the whole environment. You'll have to decide what to do with `renv`. Keeping both is redundant, but removing it is your call.
4. **Fix the `optINv` typo** in `mammoth_tree.R`. R is case-sensitive, so the invariant-sites option is probably being ignored. That means the tree's invariant-site parameter may not have been optimized, so re-run the tree and check whether the tree and the numbers I gave you for the paper change.

### The check that matters
After the refactor, run the Snakemake pipeline from scratch and confirm the outputs match your committed results (π, S, haplotype counts, and the p-value, since the seed is fixed at 2026). That's your proof the wrapper didn't change the science.

I'd suggest doing the refactor one script at a time, with a terminal walkthrough for each. Do you want to start with step 1, removing `setwd` and adding arguments to the first script?

- **What I asked next:** "Yes"

### Step 1: Make a safe branch and save a "before" snapshot

**Why:** Refactoring means editing scripts that already produced your results. Before touching anything, we do two things:
1. Work on a **branch**, so `main` keeps your finished, working analysis.
2. Record a **checksum** of every result file. A checksum is a fingerprint of a file, so if the Snakemake run later produces a file with the same fingerprint, it's byte-for-byte identical. That's our proof the wrapper didn't change the science.

Run these in **WSL (Ubuntu)**, in your mammoth repo folder:

```bash
cd "/mnt/c/Users/nelin/Desktop/GWU Information/GWU Fall 2026/Princip_Bioinformatics/mammoth_mitogenome_pubh6860"
git status
```

`git status` should say your working tree is clean. If it lists changes, commit them first. If your repo lives in the OneDrive path from `diversity_statistics.R`, `cd` there instead.

```bash
git checkout -b snakemake-workflow
```

This creates the branch and switches to it.

```bash
mkdir -p docs
sha256sum alignment/mammoth_aligned.fasta \
          model_and_tree/mammoth_model_select_sorted_results.csv \
          model_and_tree/mammoth_tree.nwk \
          diversity_stats/diversity_stats_by_group.csv \
          diversity_stats/permutation_test_results.csv \
          diversity_stats/subsample_results.csv \
          > docs/results_checksums_before_snakemake.txt
cat docs/results_checksums_before_snakemake.txt
```

You should see 6 lines, each a long hex string followed by a file name.

**Expect some mismatches later, and that's fine.** The tree depends on the `optINv` typo, so `mammoth_tree.nwk` will probably change once we fix it. MAFFT output can also differ slightly between versions. The diversity and permutation files should match exactly, because the seed is fixed. We'll explain any difference when it happens, not hide it.

```bash
git add docs/results_checksums_before_snakemake.txt
git commit -m "Add checksums of results before Snakemake refactor"
```

### Step 2: Refactor the first script (`mafft_mammoth_verify.R`)

This is the smallest script, so it's the best place to learn the pattern.

**Why it needs to change.** Right now it has two problems:
- `setwd("C:/Users/nelin/...")` only exists on your computer. Anyone else, or Snakemake in a clean environment, would get an error.
- The file name `mammoth_aligned.fasta` is typed into the script. Snakemake needs to *tell* the script which file to read.

**The pattern.** R can accept arguments from the command line with `commandArgs()`. When Snakemake runs `Rscript alignment/mafft_mammoth_verify.R alignment/mammoth_aligned.fasta`, the script receives that path itself.

Replace the whole file with this:

```r
# Verify the MAFFT alignment: 42 sequences, all the same length.
# Usage: Rscript mafft_mammoth_verify.R <aligned_fasta>
library(seqinr)

args <- commandArgs(trailingOnly = TRUE)
# Use the given path, or fall back to the default so you can still run this by hand
aln_file <- if (length(args) >= 1) args[1] else "alignment/mammoth_aligned.fasta"

aln <- read.alignment(aln_file, format = "fasta")

cat("Number of sequences:", length(aln$seq), "\n")
lengths <- sapply(aln$seq, nchar)
cat("Length of first sequence:", lengths[1], "\n")
cat("All sequences equal length:", all(lengths == lengths[1]), "\n")
```

What changed and why:
- **`setwd` is gone.** The script now takes paths from wherever you run it, which is the repo's top folder. That's also how Snakemake runs it.
- **`commandArgs(trailingOnly = TRUE)`** collects only the arguments you typed after the script name.
- **The fallback path** keeps the script usable by hand from the repo root.
- **`cat()` replaces bare expressions.** In RStudio, typing `length(aln$seq)` prints the result. In a script run by `Rscript`, it prints nothing. `cat()` makes the output appear, and Snakemake saves it into `alignment/alignment_check.txt`.

### Step 3: Test it from the terminal

```bash
conda install -c conda-forge r-seqinr    # skip if R and seqinr already work in WSL
Rscript alignment/mafft_mammoth_verify.R alignment/mammoth_aligned.fasta
```

**Expected output:**
```
Number of sequences: 42
Length of first sequence: 16905
All sequences equal length: TRUE
```

Those are the same three numbers you checked originally (42, 16905, TRUE). If you get an error such as `Rscript: command not found`, paste it and we'll fix it. R may only be installed on the Windows side, and I'd rather sort that out now than later.

```bash
git add alignment/mafft_mammoth_verify.R
git commit -m "Make verify script path-independent (commandArgs, no setwd)"
```

Paste the Step 1 output (the six checksum lines) and the Step 3 output when you have them. If both look right, we'll refactor `mammoth_sub_model_select.R` next, which has the same pattern plus two output files.
- **What I asked next:** (pasted the output)
- **Exact output (verbatim):**
It passed with the three expected lines, so the verify script now runs from the terminal with no `setwd`, and conda supplies R, the packages and Snakemake.

**One thing to note for the paper:** conda gave you R **4.5.3**, while your original analysis ran in Windows R **4.6.1**. The Snakemake run will use 4.5.3, so it may differ in a decimal place from your original results. That's why we compare against the checksums. If a result differs, we'll find out whether it's R, a package version or a real problem, and the Methods will say which R version produced the final numbers.

### Step 4: Commit what's working
```bash
git add environment.yml alignment/mafft_mammoth_verify.R
git commit -m "Add R, R packages and snakemake to conda env; path-independent verify script"
```

### Step 5: Refactor `mammoth_sub_model_select.R`
This is the same pattern as before, with three changes:
- The input file is passed in.
- There are **two** outputs, so there are three arguments in total: the aligned FASTA, the `.rds` file and the `.csv` file.
- The best model is printed with `cat()`, so Snakemake's log records it.

Your comments and logic stay intact. Replace the whole file with this:

```r
# Choosing Substitution Model to see which describes how these 42 mitogenomes actually evolved
# Usage: Rscript --no-init-file mammoth_sub_model_select.R <aligned_fasta> <out_rds> <out_csv>

library(ape)
library(phangorn) # has own data structure "phyDat" separate from seqinr alignment object used in "...verify.R"

args <- commandArgs(trailingOnly = TRUE)
aln_file <- if (length(args) >= 1) args[1] else "alignment/mammoth_aligned.fasta"
out_rds  <- if (length(args) >= 2) args[2] else "model_and_tree/mammoth_model_select_results.rds"
out_csv  <- if (length(args) >= 3) args[3] else "model_and_tree/mammoth_model_select_sorted_results.csv"

# can read the aligned FASTA file directly, no conversion needed
mammoth_phydat <- read.phyDat(aln_file, format = "fasta", type = "DNA")

# Checking that every sequence came through the phyDat conversion
cat("Sequences in phyDat object:", length(mammoth_phydat), "(expect 42)\n")

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
```

What changed and why:
- **Three paths come from `args`**, each with a fallback so you can still run it by hand from the repo's top folder.
- **`print(head(sorted, 10))`** is used because bare expressions don't print under `Rscript`.
- **The two `cat("Best model...")` lines** put your AIC and BIC choices in the log. The AIC line is the one the tree depends on.

### Step 6: Run it
This re-runs `modelTest` from scratch, which took several minutes the first time. It overwrites your committed `.rds` and `.csv` on this branch, which is intended, because git will then show us any difference.

```bash
Rscript --no-init-file model_and_tree/mammoth_sub_model_select.R \
  alignment/mammoth_aligned.fasta \
  model_and_tree/mammoth_model_select_results.rds \
  model_and_tree/mammoth_model_select_sorted_results.csv
```

The backslashes just split one long command over several lines. Wait for the prompt to come back, and expect these last lines:
```
Best model by AIC: HKY+G(4)+I
Best model by BIC: HKY+I
```

### Step 7: Compare to your original results
```bash
git diff --stat
git diff model_and_tree/mammoth_model_select_sorted_results.csv | head -30
```

- **No diff on the CSV:** the new run reproduced your original model table exactly. This is the best case.
- **Tiny differences in the last digits of logLik or AIC:** these are normal when R or package versions differ. Check that the model ranking and the winner are the same.
- **A different winning model:** this would matter, so paste it and we'll investigate before going further.
- The **`.rds` will always show as changed**, because it stores an R environment that differs byte-for-byte on every save. Ignore it and compare the CSV.

```bash
git add model_and_tree/mammoth_sub_model_select.R
git commit -m "Make model selection script path-independent"
```

Don't commit the regenerated `.rds` and `.csv` yet; we'll decide that after you paste the comparison. Please send the last 15 lines of the console output and the `git diff` result.
- **What I asked next:** (pasted the output)
- **Exact output (verbatim):**
Both winning models are the same as your original run, which is the most important check. The model table itself isn't confirmed yet, because the diff we have is incomplete:

- **Same winners:** AIC picks HKY+G(4)+I and BIC picks HKY+I, exactly as in your committed results. Your original AIC for HKY+G(4)+I was 53211.25, logLik −26518.627, which also matches what's in my notes.
- **The diff is incomplete.** `head -30` cut it off after the first 30 lines, so we saw only the old rows (the `-` lines) and none of the new ones (`+`). I can't yet say whether any numbers changed.
- **All 93 rows show as changed**, even though the winning models match. That usually means the line endings changed, not the numbers. Windows R writes CSVs with Windows-style line endings and Linux R writes Unix-style ones, so every line looks different to git while the content is identical. We'll test that below.
- **`.rds` changed** (305066 → 303941 bytes). That's expected, as explained earlier.
- **`diff --stat` vs `git diff --stat`.** The first one was plain `diff` (a different command), so it errored. It's an easy slip, and the `git diff --stat` you ran after it worked.

### Step 7b: Test whether only line endings changed
```bash
git diff --ignore-cr-at-eol --stat -- model_and_tree/mammoth_model_select_sorted_results.csv
```

- **Prints nothing:** the content is identical and only line endings differ. This is a perfect reproduction.
- **Prints a line or two:** some numbers differ. Go to the next command.

### Step 7c: If numbers differ, measure by how much
```bash
git show HEAD:model_and_tree/mammoth_model_select_sorted_results.csv > /tmp/old_model.csv
Rscript --no-init-file -e 'o <- read.csv("/tmp/old_model.csv"); n <- read.csv("model_and_tree/mammoth_model_select_sorted_results.csv"); cat("same ranking:", identical(o$Model, n$Model), "\n"); m <- merge(o, n, by = "Model"); cat("max abs AIC diff:", max(abs(m$AIC.x - m$AIC.y)), "\n"); cat("max abs logLik diff:", max(abs(m$logLik.x - m$logLik.y)), "\n")'
```

Run both; 7c is only needed if 7b prints something. What I'm looking for:
- `same ranking: TRUE` means all 92 models are in the same order.
- Differences below about 0.01 in AIC and logLik are rounding-level and fine. Anything larger we should investigate.

### Step 8: Commit
Once 7b or 7c looks fine, commit only the script and keep the regenerated results:

```bash
git add model_and_tree/mammoth_sub_model_select.R model_and_tree/mammoth_model_select_sorted_results.csv model_and_tree/mammoth_model_select_results.rds
git commit -m "Refactor model selection script; re-run under conda R 4.5.3 reproduces AIC/BIC winners"
```

Your `AI_USAGE.md` and `notes.md` changes are separate, so commit them on their own:

```bash
git add AI_USAGE.md notes.md
git commit -m "Update AI usage log and notes"
```

If 7b prints nothing, send me just that, and next we'll refactor the tree script. That one also contains the `optINv` typo, so we'll be able to see exactly what that typo did.
- **What I asked next:** (pasted the output)
- **Exact output (verbatim):**
The blank screen with `(END)` is Git's pager (a viewer called `less`). It opens whenever Git prints output. Here the output was empty, which is the "prints nothing" result I was hoping for.

**That means the CSV content is identical.** Once line endings are ignored, there is no difference between your original Windows run and the new conda R 4.5.3 run. All 92 model scores match, and the model-selection step reproduced exactly.

### Step 7d: Leave the pager
Press **`q`** to get your prompt back. It's the same key for any `less` screen.

Optionally, you can stop Git from using the pager for short outputs:
```bash
git config --global core.pager "less -FRX"
```
The `-F` flag makes `less` exit on its own when the output fits on one screen, so you won't get stuck on blank screens like this one.

### Step 8: Commit
Run the commit from last time:

```bash
git add model_and_tree/mammoth_sub_model_select.R model_and_tree/mammoth_model_select_sorted_results.csv model_and_tree/mammoth_model_select_results.rds
git commit -m "Refactor model selection script; re-run under conda R 4.5.3 reproduces AIC/BIC winners"
git add AI_USAGE.md notes.md
git commit -m "Update AI usage log and notes"
```

Then check that you're clean:
```bash
git status
git log --oneline -5
```

`git status` should say `nothing to commit, working tree clean`. Paste the `git log` lines if you want me to check them.

**One thing to decide before the next step:** the CSV now has Unix line endings instead of Windows ones. That's harmless, but if you ever edit these files on Windows again, git may warn about line endings. It won't affect results, and I'll fold a one-line `.gitattributes` fix into a later step.

### Next: the tree script
This is the most interesting one, for three reasons:
1. It has **two** `setwd` lines (one points to a different folder, so it's a leftover).
2. It makes the plot and writes `mammoth_tree.nwk`.
3. It contains the **`optINv` typo**. R is case-sensitive, so R probably ignored that option. Fixing it may change the tree and the log-likelihood.

I'll send the refactored version once you've confirmed the commits went through. Before running it, please paste what the original tree run printed for `fit_ml`, if you still have it. It lists logLik, the gamma shape, the proportion of invariant sites and kappa. If you don't have it, don't worry: the new run will produce it, and we'll compare it with the committed tree.
-**What I asked next:** (pasted the output of `fit_ml` results with and without the typo)
- **Exact output (verbatim):**
The typo had almost no effect, and your two paste-ins show why.

### What the typo did
| | Before (`optINv`, ignored) | After (`optInv`, working) |
|---|---|---|
| Log-likelihood | −26516.92 | **−26516.91** |
| NNI topology moves | 6, then 0 | 6, then 0 |
| "optimize invariant sites" step | missing | present |

- **The only difference is 0.01 log-likelihood units.** The invariant-sites proportion was already optimized inside `modelTest`, so the starting model was nearly final.
- **The topology search made the same 6 moves.** The tree is very likely the same, but we'll confirm that by comparing it directly after the run, not assume it.
- **Use the corrected value in the paper.** Report log-likelihood −26516.91 (HKY+G(4)+I, optimized topology). In the Methods, say that all parameters were optimized together.
- **Your pasted output shows only the optimization trace.** I still need the fitted values (kappa, gamma shape, invariant-site proportion). The new script will print them.
- **I looked at what you pushed** (commit `2782ff8`, "beginning to implement snakemake"). It contains your `AI_USAGE.md` and `notes.md` updates, but no script or Snakefile changes yet. The `optINv` typo is still in the pushed `mammoth_tree.R`, which fits what you said about fixing it only in the console.

### Step 9: Refactor `mammoth_tree.R`
Changes from the original script:
- **`setwd` is gone** (this script had one).
- **Four arguments** now: the model-selection `.rds`, the metadata CSV, the output `.nwk` and the output `.pdf`.
- **`optInv` is fixed.**
- **The plot goes straight to a PDF.** You saved your PDFs by hand because PNG export was unreliable, and a script can't do that by hand.
- **The on-screen `plot()` is removed.** Under `Rscript` it would create a stray `Rplots.pdf` file.
- **The fitted parameters are printed** to the log.

Replace the whole file with this:

```r
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
```

### Step 10: Run it
This re-runs the tree search, which took a while before, so let it finish:

```bash
Rscript --no-init-file model_and_tree/mammoth_tree.R \
  model_and_tree/mammoth_model_select_results.rds \
  data_aquisition/mammoth_mitogenome_accessions.csv \
  model_and_tree/mammoth_tree.nwk \
  model_and_tree/mammoth_tree_plot.pdf 2>&1 | tail -40
```

The `2>&1 | tail -40` shows only the last 40 lines, which include the fitted model and the divergence table. I expect the top four tips to be GilbertM20, GilbertM21, GilbertM25 and Oimyakon.

### Step 11: Is it the same tree as before?
```bash
git show HEAD:model_and_tree/mammoth_tree.nwk > /tmp/old_tree.nwk
Rscript --no-init-file -e 'library(phangorn); o <- read.tree("/tmp/old_tree.nwk"); n <- read.tree("model_and_tree/mammoth_tree.nwk"); cat("Robinson-Foulds distance:", RF.dist(o, n), "\n")'
```

The **Robinson-Foulds distance** counts how many splits in the tree differ between two trees.
- **`0`** means the same topology: the typo fix didn't change the tree's shape.
- **A positive number** means some branches rearranged. Send me the value and we'll look at which ones.

Then commit:
```bash
git add model_and_tree/mammoth_tree.R model_and_tree/mammoth_tree.nwk model_and_tree/mammoth_tree_plot.pdf
git commit -m "Refactor tree script; fix optInv typo; write plot to PDF"
```

Please paste the last 40 lines from Step 10 and the Step 11 result. Next, `time_binning.R`, then the statistics and test scripts, and then we wire it all into the Snakefile.
- **What I asked next:** (pasted the output of terminal)
- **Exact output (verbatim):**
The tree script works, and the results look biologically sensible. One result needs a closer look before we commit the new tree: **the topology isn't identical to your original.**

### What worked
- **The outlier group is correct.** The top four root-to-tip distances are Oimyakon, GilbertM21, GilbertM25 and GilbertM20, matching your original analysis. Rogaev and P011 come next, at about 0.003 and 0.002, far below those four.
- **Fitted parameters** for the Methods (HKY+G(4)+I, topology and parameters optimized together):
  - log-likelihood −26516.91
  - gamma shape α = 0.99
  - proportion of invariant sites = 0.852
  - phangorn's rate matrix gives transitions about 52× the rate of each transversion type (κ ≈ 51.9)
  - base frequencies: A 0.330, C 0.252, G 0.131, T 0.287
- **Report α and the invariant proportion together, and don't interpret them separately.** The two are statistically correlated in models with both terms: a high invariant fraction can trade off against the gamma shape. For your question, the point is that the tree model accounts for rate variation, so I'd say that and nothing more.

### What needs a look
The Robinson-Foulds distance is **6**. The maximum possible for 42 taxa is 78, so it's about 8%, which is small. It means 3 splits in each tree differ, probably a few small local rearrangements. We don't know why yet. There are two likely causes:
1. **The `optInv` fix.** Log-likelihood moved by only 0.01, but a tiny change can flip a near-tied rearrangement.
2. **A different R or package version.** Conda gave you R 4.5.3 and Linux builds, while the original ran on Windows R 4.6.1.

The most likely explanation is that these are **unresolved relationships**. Many Wrangel mammoths share identical mitochondrial haplotypes (W1 appears in four samples, for instance). When sequences are identical, the tree has no data to decide their order, so different software runs can resolve them differently. That would not be a scientific problem. But we should test it, not assume it.

### Step 12: Which tips moved, and do the trees fit equally well?
This code does two things. It prints the differing splits, then re-fits your old topology under the same model and compares log-likelihoods. If the old tree scores within about 1–2 log-likelihood units of the new tree, the data cannot distinguish them. This takes a few minutes.

```bash
Rscript --no-init-file -e '
suppressMessages(library(phangorn))
o <- read.tree("/tmp/old_tree.nwk"); n <- read.tree("model_and_tree/mammoth_tree.nwk")
cat("\n--- Splits that differ between old and new tree ---\n")
comparePhylo(o, n, plot = FALSE, force.rooted = FALSE)
aln <- read.phyDat("alignment/mammoth_aligned.fasta", format = "fasta", type = "DNA")
fit_o <- pml(o, aln, model = "HKY", k = 4, shape = 0.99, inv = 0.85)
fit_o <- optim.pml(fit_o, model = "HKY", optGamma = TRUE, optInv = TRUE, optEdge = TRUE)
cat("\nOld topology logLik:", fit_o$logLik, "\nNew topology logLik: -26516.91\n")
' 2>&1 | tail -40
```

How to read it:
- **Old topology logLik close to −26516.91** (within about 1–2): the trees are equally supported by the data, so the difference doesn't matter. We keep the new tree and note this in the Methods.
- **Old topology clearly better, by more than 3 or so:** the new search is stuck in a worse spot, and we'd investigate.
- **The tip list from `comparePhylo`:** if the moving tips are the identical Wrangel haplotypes (W1, W4 and so on), that confirms they're unresolved. If a pre-bottleneck sample like P011 moves in or out of the Wrangel group, tell me, because that would matter for your story.

### Housekeeping
- **Don't add `mammoth_tree_plot.png`** (it shows as untracked). It's an old leftover, and the script now writes a PDF. You can delete it, or leave it untracked.
- **Commit only the script for now:**
  ```bash
  git add model_and_tree/mammoth_tree.R
  git commit -m "Refactor tree script: path-independent, optInv fixed, PDF output"
  ```
- **Hold the new `.nwk` and `.pdf`** until the Step 12 result is in. Then we commit them together with a note explaining the difference.

Paste the Step 12 output and we'll decide about the tree. After that we refactor `time_binning.R`, which should be quick.
- **What I asked next:** (pasted output of result that showed error label mismatch and showed that 37 splits are common with Robinson-Foulds value of 6 which means mostly identical)
- **Exact output (verbatim):** 
Two things happened.

**1. The error is a label mismatch, not a problem with your trees.** Your alignment's sequence names are the full FASTA headers (accession plus description), but the labels read back from the saved Newick file are written differently, for example with spaces swapped for underscores. `pml()` needs the two to match exactly. The fix is to relabel the tree tips by accession number, which is the same trick your own scripts use.

**2. `comparePhylo` did give us one useful number.** It reported **37 splits in common**, out of 40, so each tree has 3 splits the other lacks. That fits the Robinson-Foulds value of 6 and confirms the trees are 92% identical in structure. It didn't print *which* splits differ, so the new script below does.

### Step 12 (retry)
Save the script to a temporary file first. A multi-line script inside quotes breaks easily in the terminal:

```bash
cat > /tmp/tree_compare.R <<'EOF'
suppressMessages(library(phangorn))
acc <- function(x) sub("[ _.].*$", "", x)   # accession = text before first space, underscore or dot

meta <- read.csv("data_aquisition/mammoth_mitogenome_accessions.csv")
o <- read.tree("/tmp/old_tree.nwk")
n <- read.tree("model_and_tree/mammoth_tree.nwk")
aln <- read.phyDat("alignment/mammoth_aligned.fasta", format = "fasta", type = "DNA")

# Relabel tips of both trees to exactly match the alignment's sequence names
fix <- function(tr) {
  tr$tip.label <- names(aln)[match(acc(tr$tip.label), acc(names(aln)))]
  stopifnot(!anyNA(tr$tip.label))
  tr
}
o <- fix(o); n <- fix(n)

# Which groups of tips differ? Root both trees on the same tip so splits are comparable
lab <- function(x) meta$Lab_ID[match(acc(x), meta$Accession_No)]
clades <- function(tr) {
  tr <- root(tr, outgroup = names(aln)[1], resolve.root = TRUE)
  pp <- prop.part(tr)
  sapply(pp, function(ix) paste(sort(lab(attr(pp, "labels")[ix])), collapse = ", "))
}
co <- clades(o); cn <- clades(n)
cat("\n--- Groups present only in the OLD tree ---\n"); print(setdiff(co, cn))
cat("\n--- Groups present only in the NEW tree ---\n"); print(setdiff(cn, co))

# Likelihood of the old topology under the same model
fit_o <- pml(o, aln, model = "HKY", k = 4, shape = 0.99, inv = 0.85)
fit_o <- optim.pml(fit_o, model = "HKY", optGamma = TRUE, optInv = TRUE, optEdge = TRUE)
cat("\nOld topology logLik:", fit_o$logLik, "\nNew topology logLik: -26516.91\n")
EOF
Rscript --no-init-file /tmp/tree_compare.R 2>&1 | tail -40
```

`cat > file <<'EOF' ... EOF` writes everything between the two `EOF` lines into the file. The quotes around `'EOF'` stop the terminal from interpreting the contents.

**What you'll see:**
- **Two lists of tip groups**, one per tree. Compare them. If the differing groups are Wrangel samples that share haplotypes (several W1 or W4 samples), that's the "identical sequences, arbitrary order" explanation. If a group involves P011 or other pre-bottleneck samples, tell me, because that matters for your story.
- **Two log-likelihoods.** If the old topology scores within about 1–2 units of −26516.91, the data can't tell the trees apart.

### Housekeeping
Your last `git add` staged `mammoth_tree.R`, but a commit is still needed:

```bash
git commit -m "Refactor tree script: path-independent, optInv fixed, PDF output"
```

Paste the output and we'll decide about the new tree files.
- **What I asked next:** 
The two trees fit the data equally well, so the topology difference doesn't matter for your results. Here is what the output shows.

### What the comparison says
- **Likelihoods:** the old topology scores −26516.90 and the new one −26516.91. A 0.01 difference is well inside optimization noise, so the data can't tell them apart. For comparison, I'd only start to worry at about 2 or more.
- **Which tips differ:** nearly all the differing groups involve the same two sets of samples.
  - **Wrangel samples** shuffling their branching order among themselves: M26, M28, L468, E460, L386 and L459. Wrangel mammoths share a few haplotypes and differ at only 6 sites in total, so there is little data to fix their order.
  - **Four Siberian samples** swapping close neighbors: Krause, L164, GilbertM13 and GilbertM15 (the `{Krause, L164}` and `{GilbertM13, GilbertM15, Krause}` groups).
- **P011 is absent from every list.** As far as these lists show, its position relative to the Wrangel group didn't change. This matches what you noticed earlier, so your decision to keep it as pre-bottleneck still stands.
- **Why it doesn't affect your main results:** π, S and haplotype diversity are computed from the *alignment*, not the tree. The tree is a sanity check and a figure.

### Step 13: Commit the new tree
Since the pipeline will regenerate this tree anyway, I recommend committing the new one so the repo and the Snakemake output agree. Use the new PDF in your paper's figure as well, so the figure matches the repo.

```bash
git add model_and_tree/mammoth_tree.nwk model_and_tree/mammoth_tree_plot.pdf
git commit -m "Regenerate tree under conda R 4.5.3 with optInv fixed (logLik -26516.91; RF=6 vs previous, equal likelihood)"
```

Then open the new PDF and check the same things as before: the Wrangel samples cluster together and the four outliers sit on long branches. Tell me if anything looks different.

Your first commit (`a20d3b5`) did go through. The second `git commit` in your paste said "nothing to commit", which is harmless since it was already done.

### Step 14: Refactor `time_binning.R`
This script is simple. The changes are the same pattern as before, with five arguments: the aligned FASTA, the metadata CSV and three output files.

Replace the file with:

```r
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
```

Two additions: `stopifnot()` checks stop the pipeline loudly if a sample goes missing or the 14/28 split is wrong, which fits your "42 in, 42 out" validation plan.

### Step 15: Run it and compare to the original
```bash
git show HEAD:diversity_stats/time_binned_alignments.rds > /tmp/old_binned.rds
Rscript --no-init-file diversity_stats/time_binning.R \
  alignment/mammoth_aligned.fasta \
  data_aquisition/mammoth_mitogenome_accessions.csv \
  diversity_stats/time_binned_alignments.rds \
  diversity_stats/post_bottleneck_aligned.fasta \
  diversity_stats/pre_bottleneck_aligned.fasta
Rscript --no-init-file -e 'cat("RDS identical to original:", identical(readRDS("/tmp/old_binned.rds"), readRDS("diversity_stats/time_binned_alignments.rds")), "\n")'
git diff --ignore-cr-at-eol --stat -- diversity_stats/*.fasta
```

Expected: the table shows 14 / 22 / 6 and 14 / 28, then `RDS identical to original: TRUE`, and the last command prints nothing (the FASTA files are unchanged apart from line endings). If it's different, paste it.

Then commit the script:
```bash
git add diversity_stats/time_binning.R
git commit -m "Refactor time binning script: path-independent with sanity checks"
```

If this passes, the last two scripts (diversity statistics and the hypothesis test) are the long ones, and after them we write the real Snakefile.
- **What I asked next:** (pasted the output, everything passed)
- **Exact output (verbatim):** 
 Every check passed: 42 × 16,905, the 14 / 22 / 6 split, the RDS **identical** to your original (`TRUE`), the FASTA diff empty, and the commit is in. The time-binning step reproduces your original files exactly.

### Step 16: Refactor `diversity_statistics.R`
This is the script that produces your headline numbers (π, S, Hd), so it matters most that it reproduces exactly.

Changes:
- **`setwd` is removed.** This one pointed at your OneDrive folder, a different path from the others.
- **There are three arguments:** the binned `.rds`, the main output CSV and a new second CSV.
- **The pairwise-deletion check is now saved** to that second CSV. Before, it only printed to the console, and you cite those numbers in the paper (Post 0.000405, Pre 0.004529). Saving it means the pipeline produces them too.
- **Printing uses `print()` and `cat()`,** since bare expressions print nothing under `Rscript`.

All the calculation logic is exactly as you wrote it. Replace the file with this:

```r
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
```

### Step 17: Run it and compare to your original
```bash
Rscript --no-init-file diversity_stats/diversity_statistics.R \
  diversity_stats/time_binned_alignments.rds \
  diversity_stats/diversity_stats_by_group.csv \
  diversity_stats/diversity_pairwise_deletion.csv
git diff --ignore-cr-at-eol -- diversity_stats/diversity_stats_by_group.csv
```

Expected:
- **Callable sites:** `11153 of 16905` and `0.6597456`.
- **Results table:** Post π = 0.0001034561, S = 6, 7 haplotypes, Hd = 0.8242; Pre π = 0.0049454034, S = 300, 27 haplotypes, Hd = 0.9974.
- **Pairwise deletion:** Post 0.0004051837, Pre 0.0045286179.
- **The `git diff` on the CSV prints nothing,** meaning it matches your committed original exactly. Press `q` if the pager appears.

Then commit:
```bash
git add diversity_stats/diversity_statistics.R diversity_stats/diversity_pairwise_deletion.csv
git commit -m "Refactor diversity statistics script; save pairwise-deletion check to CSV"
```

If your numbers match the ones above, send me the output and we'll do the last script, `hypothesis_test.R`. It's the longest one, with the three `set.seed(2026)` calls, so we'll go carefully to be sure the permutation results come out identical.
- **What I asked next:** (pasted output and all numbers matched)
- **Exact output (verbatim):** 
Your numbers match the originals exactly, and the CSV diff was empty, so the diversity statistics reproduce. Hd = 0.8241758 and 0.9973545 round to the 0.8242 and 0.9974 in your results.

### Step 18: Refactor `hypothesis_test.R`
This is the last analysis script, and the most important one to reproduce exactly. I've kept all three `set.seed(2026)` calls and the order of every random operation exactly as you wrote them. The numbers can only match if the random draws happen in the same order.

Changes:
- **Four arguments:** the binned `.rds`, then the two output CSVs and the PDF.
- **Bare expressions are wrapped in `print()` or `cat()`,** since `Rscript` prints nothing otherwise.
- **The commented-out `setwd` is removed.**

Replace the file with:

```r
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
```

One note on `set.seed(2026)`: R's random-number generator is the same in 4.5.3 and 4.6.1, so a fixed seed should give identical draws. The permutation p-values sit at the minimum possible value (about 0.0001) and are insensitive to the draws. The subsample medians and intervals are the numbers that would show any difference.

## Step 19: Run it and compare
It runs 10,000 shuffles three times, so give it a few minutes:

```bash
Rscript --no-init-file diversity_stats/hypothesis_test.R \
  diversity_stats/time_binned_alignments.rds \
  diversity_stats/permutation_test_results.csv \
  diversity_stats/subsample_results.csv \
  diversity_stats/permutation_test_all.pdf
git diff --ignore-cr-at-eol -- diversity_stats/permutation_test_results.csv diversity_stats/subsample_results.csv
```

Each printed value has an "(expect …)" tag next to it, so you can eyeball the match. The two CSV diffs should print nothing. The PDF will show as modified regardless, because PDFs contain a creation timestamp. That's fine.

Then commit:
```bash
git add diversity_stats/hypothesis_test.R
git commit -m "Refactor hypothesis test script: path-independent, same seeds and RNG order"
```

If everything matches, all seven scripts are refactored and verified. The last step is the real **Snakefile**, where we link them together and run the whole pipeline from a clean start.
- **Verification:**