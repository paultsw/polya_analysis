Direct RNA Polyadenylation Analysis
===================================

Running The Pipeline
--------------------
Create a new virtual environment (python 2.7 recommended) and activate, either with `virtualenv`:
```
$ virtualenv polya-env
$ source polya-env/bin/activate
```
or conda:
```
$ conda create --name polya-env
$ source activate polya-env
```

The pipeline requires the albacore basecaller (we used version 2.3.3); set the `BASECALL` variable
in the makefile to the location of your `read_fast5_basecaller.py` file as appropriate. Albacore
is (as of pixel time) closed source but may be downloaded via the ONT community website.

Then, run
```
make -f pipeline.make
```
to download all datasets and code and generate all relevant files.

Notes
-----
* It can take a long time to download and untar the fast5 files (a few hours to a full workday). Plan accordingly,
  and monitor progress with (e.g.) a `watch ls -lah` on the appropriate directories.

* This pipeline must be run on a server with an internet connection (to download the datasets from the European
  Nucleotide Archive). We recommend creating a fresh virtual environment and installing ONT's Albacore basecaller
  within that virtual environment before running the makefile pipeline. We recommend a server with 8 cores and
  at least 20GB of memory per core. We assume `R`, `Rscript`, and `python` are accessible from the command line
  and that the `ggplot2` R package is pre-installed. We tested our pipeline with `python 3.4.6`, `R 3.4.4`, and
  `ggplot2 v2.2.1`.

* There is an additional dataset, `60xbpolyAb`, which is commented out and excluded from the pipeline by default.
  This dataset is a second run of the `60xpolyA` library and has nearly identical distributions/densities. It can
  easily be downloaded and included in the analysis by uncommenting the lines where appropriate.

Citations
---------
_Nanopore native RNA sequencing of a human poly(A) transcriptome_, Rachael E Workman, Alison Tang, Paul S. Tang, Miten Jain, John R Tyson, Philip C Zuzarte, Timothy Gilpatrick, Roham Razaghi, Joshua Quick, Norah Sadowski, Nadine Holmes, Jaqueline Goes de Jesus, Karen Jones, Terrance P Snutch, Nicholas James Loman, Benedict Paten, Matthew W Loose, Jared T Simpson, Hugh E. Olsen, Angela N Brooks, Mark Akeson, Winston Timp, bioRxiv: `https://www.biorxiv.org/content/early/2018/11/09/459529`