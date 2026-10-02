# AI USAGE LOG
Claude had access to my initial sources, project idea, project guidelines, and goals in initial  chat.
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
 
# ---- 4. Visualize the tree, colored by pre-/post-bottleneck group ----
# Bring in the sample metadata so we can label tips by group.
metadata <- read.csv("mammoth_mitogenome_accessions.csv")
 
# Tip labels look like "MG334270.1" (accession + version) — strip
# the ".version" suffix so they match the Accession_No column.
tip_accessions <- sub("\\..*$", "", mammoth_tree$tip.label)
tip_groups <- metadata$Group[match(tip_accessions, metadata$Accession_No)]
 
# Color tips: post-bottleneck (Wrangel) in red, pre-bottleneck in blue
tip_colors <- ifelse(grepl("^Post", tip_groups), "firebrick", "steelblue")
 
plot(mammoth_tree,
     tip.color = tip_colors,
     cex = 0.6,
     no.margin = TRUE)
legend("topleft",
       legend = c("Post-bottleneck (Wrangel Island)", "Pre-bottleneck (Siberia)"),
       text.col = c("firebrick", "steelblue"),
       bty = "n")
 
# ---- 5. What to look for (sanity check before moving on) ----
# - Do the 14 post-bottleneck tips cluster tightly together near
#   the tips of the tree, consistent with a recent founder effect?
# - Are the 28 pre-bottleneck tips more spread out across deeper
#   branches, reflecting greater ancestral diversity?
# - Is any single tip sitting on a dramatically longer branch than
#   the rest? That can indicate a mislabeled sample, contamination,
#   or a leftover alignment issue worth investigating before Part 4.
 

```
Run that top to bottom — expect the `optim.pml()` line to take a few minutes given the dataset size. Once the plot renders, send it over (or describe what you're seeing) and we'll check it against those sanity-check criteria before moving on.

- **Verification:**