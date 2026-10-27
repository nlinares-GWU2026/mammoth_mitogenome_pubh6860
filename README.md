# Loss of mitochondrial diversity in woolly mammoths after isolation on Wrangel Island

A reproducible workflow that takes 42 public woolly mammoth (*Mammuthus primigenius*) mitochondrial genomes from GenBank to a statistical test of whether mitochondrial diversity was lower in the Wrangel Island population (isolated about 10,000 years ago) than in earlier mainlaind populaitons. 

The claim is limited to **diversity loss after isolation**. The analysis does not test wether that loss caused extinction. 

Course project from PUBH 6860 (Principles of Bioinformatics) and PUBH 6954 (Applied Computing in Health Data Science). George Washington University, Fall 2026. 

## Question and hypothesis

- **H0:** pre- and post-isolation groups have the same nucleotide diversity (π).
- **H1:** post-isolation π is lower than pre-isolation π (one-sided, because a founder effect predcits direction).

## Data

42 mitogenomes listed in Table 1 of Pečnerová et al. (2017), downloaded from GenBank (NCBI Nucleotide) with E-utilities. Accessions and radiocarbon metadata are in `data_acquisition/`. 

| Group | n | Definition |
|---|---|---|
|Post-isolation | 14 | Wrangel Island, younger than 10,000 calibrated years BP |
| Pre-isolation | 28 | 22 dated samples + 6 with bounded or missing dates | 

Samples are grouped by **date and published haplotype, not by location**: two Wrangel Island finds (L410, E470) predate the island's isolation and are counted as pre-isolation. 

> Pečnerová P, Palkopoulou E, Wheat CW, et al. (2017) Mitogenome evolution in the last surviving woolly mammoth population reveals neutral and functional consequences of small population size. *Evolution Letters* 1(6):292–303. https://doi.org/10.1002/evl3.33

## Quick Start

Requires Linux, macOS, or Windows with WSL2 (Ubuntu), and conda or mamba. 

```bash
git clone https://github.com/nlinares-GWU2026/mammoth_mitogenome_pubh6860.git
cd mammoth_mitogenome_pubh6860
mamba env create -f environment.yml
conda activate mammoth-project
snakemake --cores 4
```

Run all commands from the repository's top folder. Useful variants:

```bash
snakemake -n -p                 # dry run: show what would run the exact commands
snakemake --cores 4 --forceall  # rebuild everything from scratch, including the GenBank download
```

A full rebuild took about 40 seconds on author's laptop; the model-selection step varies from under a minute to a few minutes between runs. 

## The workflow

| Step | Rule | Script / Tool | Main Output | 
|---|---|---|---|
| 1 | `fetch_sequences` | `curl` + NCBI E-utilities | `data_aquisition/mammoth_mitogenomes.fasta` |
| 2 | `align` | MAFFT `--auto` | `alignment/mammoth_aligned.fasta` |
| 2b | `verify_alignment` | `alignment/mafft_mammoth_verify.R` | `alignment/alignment_check.txt` |
| 3 | `model_select` | `model_and_tree/mammoth_sub_model_select.R` | `mammoth_model_select_sorted_results.csv` |
| 4 | `tree` | `model_and_tree/mammoth_tree.R` | `mammoth_tree.nwk`, `mammoth_tree_plot.pdf` |
| 5 | `time_bin` | `diversity_stats/time_binning.R` | `time_binned_alignments.rds`, pre/post FASTA |
| 6 | `diversity_stats` | `diversity_stats/diversity_statistics.R` | `diversity_stats_by_group.csv` |
| 7 | `hypothesis_test` | `diversity_stats/hypothesis_test.R` | `permutation_test_results.csv`, `subsample_results.csv` | 

Each rule writes its console output to `logs/<rule>.log`. Built-in checks stop the pipeleine if the download does not return exactly 42 records, if the alignment is not 42 sequences of equal length, or if the group split is not 14 + 28. 

## Methods in brief

- **Alignment:** MAFFT 7.525, `--auto`; 42 sequences x 16,905 columns. 
- **Model selection:** `phangorn::modelTest`. AIC selects HKY+G(4)+I; BIC selects the simpler HKY+I. HKY+G(4)+I is kept because mitochondrial DNA varies in rate across sites, and it is the simplest model among the top AIC group (all within about 1.2 AIC units). 
- **Tree:** maximum likelihood with `phangorn::optim.pml` (topology, branch lengths, gamma shape and invariant sites optimized together). Used for quality control and visualization only. 
- **Diversity statistics** (hand-computed with `ape` and base R): nucleotide diversity (π), segregating sites (S), and haplotype diversity (Hd, Nei and Tajima with the n/(n-1) correction).
- **Missing data:** columns with a gap or N in any of the 42 sequences are removed (11,153 of 16,905 sites kept, 66%). Pairwise deletion is reported as a sensitivity check. 
- **Test:** permutation test on the difference in π (10,000 label shuffles, seed 2026, one-sided, p = (count + 1) / (shuffles + 1)). Sensitivity analyses: (a) excluding the deeply divergent ancient clade (GilbertM20, GilbertM21, GilbertM25, Oimyakon) and (b) rarefaciton, comparing the 14 post-isolation samples with 10,000 random 14-sample draws from the pre-isolation group. 

## Key Results

| | Post-isolation (n = 14) | Pre-isolation (n = 28) |
|---|---|---|
| Nucleotide diversity (π) | 0.000103 | 0.00495 | 
| Segregating sites (S) | 6 | 300 | 
| Haplotypes | 7 | 27 | 
| Haplotype diversity (Hd) | 0.824 | 0.997 | 

- Permutation test, all 42 samples: p = 9.999e-05 (the smallest value possible with 10,000 shuffles). 
- Without the ancient clade (n = 38): pre-isolation π = 0.00162; difference in π = 0.00152; p = 9.999e-05.
- Rarefaction: none of 10,000 random 14-sample pre-isolation draws had π, S, or haplotype as low as the post-isolation group. 
- Pairwise deletion π: post 0.000405, pre 0.00453.

Full output: `diversity_stats/`.

## Reproducibility notes

- Everything computed from the alignment (the alignment itself, group split, π, S, Hd, permutation test, rarefaction) reproduced exactly across repeated full rebuilds.
- The model-selection table varies by about 0.4 AIC between identical runs (phangorn's optimizer); the top five models and their order were identical in every run, and the final tree fit (log-likelihood −26516.91, gamma shape 0.990, invariant sites 0.852) was unchanged.
- Tree branch lengths can differ in the last decimal places between runs; the topology was unchanged.
- The pipeline runs R with `--no-init-file`, so `renv` is not used for pipeline runs. `renv.lock` and `Project.Rproj` are kept for interactive work in RStudio on Windows. `environment.yml` is the source of truth for the pipeline.

## Software
 
R 4.5.3, ape 5.8.1, phangorn 2.12.1, seqinr 4.2.44, MAFFT 7.525, Snakemake 9.27.1 (see `environment.yml`).

## Repository layout

```
Snakefile                   - workflow definition
environment.yml             - conda environment (pipeline)
renv.lock, Project.Rproj    - R environment for RStudio on Windows
data_acquisition/           - accession list, metadata, downloaded FASTA, source table (PDF)
alignment/                  - aligned FASTA and alignment check
model_and_tree/             - model selection, ML tree, tree plot
diversity_stats/            - binned alignments, diversity statistics, permutation tests
logs/                       - console output of each step
docs/                       - project proposal and earlier checksums
notes.md                    - running project notes
AI_USAGE.md                 - log of every generative-AI use, with verification
```

## Limitations

- Mitochondrial DNA is a single, maternally inherited locus, so results describe mitochondrial lineages, not genome-wide diversity.
- Sample sizes are small and unequal (14 vs 28); six pre-isolation samples lack precise dates. 
- 22 of the 42 GenBank records are labelled "partial genome"; the complete-deletion filter keeps only sites present in all 42 sequences. 
- The analysis shows diversity was lower after isolation. It does not show this is caused by the population's extinction. 

## Generative AI use
Claude (Anthropic, model Sonnet 5.5) was used for specific, checkable tasks. Every use, the prompt, the output, and how it was verified (including where it was wrong) are logged in `AI_USAGE.md`.