# AI USAGE LOG
Claude had access to my initial sources, project idea, project guidelines, and goals in initial  chat.

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


