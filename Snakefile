# =============================================================================
# Snakefile - Woolly mammoth mitogenome diversity pipeline
# Question: did mitochondrial diversity drop after Wrangel Island isolation?
#
# Run from the repository's top folder, inside the conda environment:
#     conda activate mammoth-project
#     snakemake --cores 4            # run whatever is out of date
#     snakemake -n -p                # dry run: show what WOULD run + the commands
#     snakemake --cores 4 --forceall # rebuild everything from scratch
# =============================================================================

RSCRIPT = "Rscript --no-init-file"   # --no-init-file keeps renv (.Rprofile) out of pipeline runs

ACC  = "data_aquisition/accessions.txt"
META = "data_aquisition/mammoth_mitogenome_accessions.csv"
RAW  = "data_aquisition/mammoth_mitogenomes.fasta"
ALN  = "alignment/mammoth_aligned.fasta"

# ---- The final products the paper depends on -------------------------------
rule all:
    input:
        "alignment/alignment_check.txt",
        "model_and_tree/mammoth_model_select_sorted_results.csv",
        "model_and_tree/mammoth_tree.nwk",
        "model_and_tree/mammoth_tree_plot.pdf",
        "diversity_stats/diversity_stats_by_group.csv",
        "diversity_stats/diversity_pairwise_deletion.csv",
        "diversity_stats/permutation_test_results.csv",
        "diversity_stats/subsample_results.csv",
        "diversity_stats/permutation_test_all.pdf",

# ---- Step 1: download the 42 mitogenomes from GenBank (NCBI E-utilities) ---
rule fetch_sequences:
    input:  ACC
    output: RAW
    log:    "logs/fetch_sequences.log"
    shell:
        """
        curl -sS "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=$(paste -sd, {input})&rettype=fasta&retmode=text" -o {output} 2> {log}
        test "$(grep -c '>' {output})" -eq 42   # fail loudly unless exactly 42 records came back
        """

# ---- Step 2: multiple sequence alignment (MAFFT 7.525, --auto) -------------
rule align:
    input:  RAW
    output: ALN
    log:    "logs/align.log"
    shell:  "mafft --auto {input} > {output} 2> {log}"

# ---- Step 2b: check 42 sequences, all the same length ----------------------
rule verify_alignment:
    input:  ALN
    output: "alignment/alignment_check.txt"
    log:    "logs/verify_alignment.log"
    shell:  "{RSCRIPT} alignment/mafft_mammoth_verify.R {input} > {output} 2> {log}"

# ---- Step 3: substitution model selection (modelTest; slow) ----------------
rule model_select:
    input:  ALN
    output:
        rds = "model_and_tree/mammoth_model_select_results.rds",
        csv = "model_and_tree/mammoth_model_select_sorted_results.csv",
    log:    "logs/model_select.log"
    shell:
        "{RSCRIPT} model_and_tree/mammoth_sub_model_select.R {input} {output.rds} {output.csv} > {log} 2>&1"

# ---- Step 4: maximum-likelihood tree under the chosen model ----------------
rule tree:
    input:
        rds  = "model_and_tree/mammoth_model_select_results.rds",
        meta = META,
    output:
        nwk = "model_and_tree/mammoth_tree.nwk",
        pdf = "model_and_tree/mammoth_tree_plot.pdf",
    log:    "logs/tree.log"
    shell:
        "{RSCRIPT} model_and_tree/mammoth_tree.R {input.rds} {input.meta} {output.nwk} {output.pdf} > {log} 2>&1"

# ---- Step 5: split the alignment into Pre- and Post-isolation groups -------
rule time_bin:
    input:
        aln  = ALN,
        meta = META,
    output:
        rds  = "diversity_stats/time_binned_alignments.rds",
        post = "diversity_stats/post_bottleneck_aligned.fasta",
        pre  = "diversity_stats/pre_bottleneck_aligned.fasta",
    log:    "logs/time_bin.log"
    shell:
        "{RSCRIPT} diversity_stats/time_binning.R {input.aln} {input.meta} {output.rds} {output.post} {output.pre} > {log} 2>&1"

# ---- Step 6: nucleotide diversity, segregating sites, haplotype diversity --
rule diversity_stats:
    input:  "diversity_stats/time_binned_alignments.rds"
    output:
        csv      = "diversity_stats/diversity_stats_by_group.csv",
        pairwise = "diversity_stats/diversity_pairwise_deletion.csv",
    log:    "logs/diversity_stats.log"
    shell:
        "{RSCRIPT} diversity_stats/diversity_statistics.R {input} {output.csv} {output.pairwise} > {log} 2>&1"

# ---- Step 7: permutation test and rarefaction (seed 2026) ------------------
rule hypothesis_test:
    input:  "diversity_stats/time_binned_alignments.rds"
    output:
        tests  = "diversity_stats/permutation_test_results.csv",
        subs   = "diversity_stats/subsample_results.csv",
        pdf    = "diversity_stats/permutation_test_all.pdf",
    log:    "logs/hypothesis_test.log"
    shell:
        "{RSCRIPT} diversity_stats/hypothesis_test.R {input} {output.tests} {output.subs} {output.pdf} > {log} 2>&1"
