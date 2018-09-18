SHELL=/usr/bin/env bash -o pipefail

################################################################################
#
#  Step 0: set up all paths and variables; define basic routines.
#
################################################################################

# path to present working directory:
BASEDIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# location of plotting scripts:
SCRIPTS=$(BASEDIR)/scripts

# where to download the datasets, make alignments, put the output TSV files, etc:
DATADIR=$(BASEDIR)/data
ONTDATADIR=$(DATADIR)/ont
ALIGNDIR=$(DATADIR)/alns
REFDIR=$(DATADIR)/references
POLYADIR=$(DATADIR)/polyas

# where to put the plots:
PLOTDIR=$(BASEDIR)/plots

# where to install the programs:
PROGDIR=$(BASEDIR)/programs

# parallel processing settings for nanopolish:
THREADS=8

# run `all` if called without rule:
.DEFAULT_GOAL = all

all: makedirs programs download prepare_data polya plots

# construct all directories that don't alraedy come with the repo:
makedirs:
	test ! -d $(ONTDATADIR) && mkdir $(ONTDATADIR)
	test ! -d $(ALIGNDIR) && mkdir $(ALIGNDIR)
	test ! -d $(PLOTDIR) && mkdir $(PLOTDIR)
	test ! -d $(PROGDIR) && mkdir $(PROGDIR)
	test ! -d $(POLYADIR) && mkdir $(POLYADIR)

# tell MAKE that the following dependencies don't generate any files:
.PHONY: all nanopolish minimap2 samtools download polya plots pylibs plot_segmentations \
	prepare_data prep_10x prep_15x prep_30x prep_60xb prep_60xn prep_60x prep_80x prep_100x clean

# '.DELETE_ON_ERROR' is a special rule that tells MAKE to
# delete target files if this makefile ends in an error:
# '.SECONDARY' (without any dependencies) is a special rule
# that tells MAKE to avoid deleting any intermediate files.
.DELETE_ON_ERROR:
.SECONDARY:

# revert everything to its original state:
clean:
	cd $(BASEDIR) && rm -rf $(PROGDIR) $(PLOTDIR) $(ONTDATADIR) $(ALIGNDIR) $(POLYADIR)

################################################################################
#
#  Step 1: clone and compile nanopolish, minimap2, samtools.
#
################################################################################

programs: makedirs nanopolish minimap2 samtools

NANOPOLISH_URL=https://github.com/jts/nanopolish.git
NANOPOLISH_DIR=$(PROGDIR)/nanopolish
NANOPOLISH=$(NANOPOLISH_DIR)/nanopolish
nanopolish: makedirs
	test ! -f $(NANOPOLISH) && cd $(PROGDIR) && git clone --recursive $(NANOPOLISH_URL)
	cd $(NANOPOLISH_DIR) && git checkout tags/v0.10.2 && $(MAKE) && cd $(BASEDIR)

MINIMAP2_URL=https://github.com/lh3/minimap2/releases/download/v2.12/minimap2-2.12_x64-linux.tar.bz2
MINIMAP2_TAR=$(BASEDIR)/minimap2-2.12_x64-linux.tar.bz2
MINIMAP2_DIR=$(PROGDIR)/minimap2-2.12_x64-linux
MINIMAP2=$(MINIMAP2_DIR)/minimap2
minimap2: makedirs
	cd $(PROGDIR) && wget $(MINIMAP2_URL)
	cd $(PROGDIR) && tar -jxvf minimap2-2.12_x64-linux.tar.bz2 && cd $(BASEDIR)

SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
SAMTOOLS_DIR=$(PROGDIR)/samtools-1.9
SAMTOOLS_BUILD_DIR=$(SAMTOOLS_DIR)/build
SAMTOOLS=$(SAMTOOLS_BUILD_DIR)/bin/samtools
samtools: makedirs
	cd $(PROGDIR) && wget $(SAMTOOLS_URL) && tar -xjf samtools-1.9.tar.bz2
	cd $(SAMTOOLS_DIR) && mkdir $(SAMTOOLS_BUILD_DIR) && ./configure --prefix=$(SAMTOOLS_BUILD_DIR) \
	&& $(MAKE) && $(MAKE) install && cd $(BASEDIR)


################################################################################
#
#  Step 2: download all relevant datasets and unpack fast5's.
#
################################################################################

download: 10xpolyA.tar.gz 15xpolyA.tar.gz 30xpolyA.tar.gz \
	  60bxpolyAb.tar.gz 60nxpolyA10xN.tar.gz 60xpolyA.tar.gz \
	  80xpolyA.tar.gz 100xpolyA.tar.gz makedirs

10X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/10xpolyA.tar.gz
10X_TAR=$(ONTDATADIR)/10xpolyA.tar.gz
10X_DIR=$(ONTDATADIR)/10xpolyA
10xpolyA.tar.gz: makedirs
	test ! -f $(10X_TAR) && wget $(10X_URL) -O $(10X_TAR)
	tar -xzf $(10X_TAR) -C $(ONTDATADIR)

15X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/15xpolyA.tar.gz
15X_TAR=$(ONTDATADIR)/15xpolyA.tar.gz
15X_DIR=$(ONTDATADIR)/15xpolyA
15xpolyA.tar.gz: makedirs
	test ! -f $(15X_TAR) && wget $(15X_URL) -O $(15X_TAR)
	tar -xzf $(15X_TAR) -C $(ONTDATADIR)

30X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/30xpolyA.tar.gz
30X_TAR=$(ONTDATADIR)/30xpolyA.tar.gz
30X_DIR=$(ONTDATADIR)/30xpolyA
30xpolyA.tar.gz: makedirs
	test ! -f $(30X_TAR) && wget $(30X_URL) -O $(30X_TAR)
	tar -xzf $(30X_TAR) -C $(ONTDATADIR)

60XB_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/60bxpolyAb.tar.gz
60XB_TAR=$(ONTDATADIR)/60bxpolyAb.tar.gz
60XB_DIR=$(ONTDATADIR)/60bxpolyAb
60bxpolyAb.tar.gz: makedirs
	test ! -f $(60XB_TAR) && wget $(60XB_URL) -O $(60XB_TAR)
	tar -xzf $(60XB_TAR) -C $(ONTDATADIR)

60XN_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/60nxpolyA10xN.tar.gz
60XN_TAR=$(ONTDATADIR)/60nxpolyA10xN.tar.gz
60XN_DIR=$(ONTDATADIR)/60nxpolyA10xN
60nxpolyA10xN.tar.gz: makedirs
	test ! -f $(60XN_TAR) && wget $(60XN_URL) -O $(60XN_TAR)
	tar -xzf $(60XN_TAR) -C $(ONTDATADIR)

60X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/60xpolyA.tar.gz
60X_TAR=$(ONTDATADIR)/60xpolyA.tar.gz
60X_DIR=$(ONTDATADIR)/60xpolyA
60xpolyA.tar.gz: makedirs
	test ! -f $(60X_TAR) && wget $(60X_URL) -O $(60X_TAR)
	tar -xzf $(60X_TAR) -C $(ONTDATADIR)

80X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/80xpolyA.tar.gz
80X_TAR=$(ONTDATADIR)/80xpolyA.tar.gz
80X_DIR=$(ONTDATADIR)/80xpolyA
80xpolyA.tar.gz: makedirs
	test ! -f $(80X_TAR) && wget $(80X_URL) -O $(80X_TAR)
	tar -xzf $(80X_TAR) -C $(ONTDATADIR)

100X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/100xpolyA.tar.gz
100X_TAR=$(ONTDATADIR)/100xpolyA.tar.gz
100X_DIR=$(ONTDATADIR)/100xpolyA
100xpolyA.tar.gz: makedirs
	test ! -f $(100X_TAR) && wget $(100X_URL) -O $(100X_TAR)
	tar -xzf $(100X_TAR) -C $(ONTDATADIR)


################################################################################
#
#  Step 3: basecall, align (via minimap2), index for all datasets.
#
################################################################################

prepare_data: prep_10x prep_15x prep_30x prep_60xb prep_60xn prep_60x prep_80x prep_100x download programs

# modify the following `BASECALL` variable to point to your copy of `read_fast5_basecaller.py` from albacore:
BASECALL=read_fast5_basecaller.py
BASECALL_OPTS=--worker_threads=$(THREADS) -f FLO-MIN107 -k SQK-RNA001

ENOLASE.REF=$(REFDIR)/enolase_reference.fas

10X.FAST5=$(10X_DIR)/fast5/pass
10X.FASTQ.DIR=$(10X_DIR)/fastq
10X.FASTQ=$(10X.FASTQ.DIR)/10xpolyA.fastq
10X.SAM=$(ALIGNDIR)/10xpolya.sam
10X.BAM=$(ALIGNDIR)/10xpolya.bam
10X.SORTED.BAM=$(ALIGNDIR)/10xpolya.sorted.bam
10X.SEQSUMMARY=$(10X.FASTQ.DIR)/sequencing_summary.txt
prep_10x: download programs
	$(BASECALL) $(BASECALL_OPTS) -s $(10X.FASTQ.DIR) -i $(10X.FAST5)
	cat $(10X.FASTQ.DIR)/workspace/pass/*.fastq > $(10X.FASTQ)
	$(MINIMAP2) -a -x map-ont $(ENOLASE.REF) $(10X.FASTQ) > $(10X.SAM)
	$(SAMTOOLS) view -b $(10X.SAM) -o $(10X.BAM)
	cd $(ALIGNDIR) && $(SAMTOOLS) sort -T tmp -o 10xpolya.sorted.bam 10xpolya.bam && $(SAMTOOLS) index 10xpolya.sorted.bam
	cd $(10X.FASTQ.DIR) && $(NANOPOLISH) index --directory=$(10X.FAST5) --sequencing-summary=$(10X.SEQSUMMARY) 10xpolyA.fastq
	cd $(BASEDIR)

15X.FAST5=$(15X_DIR)/fast5/pass
15X.FASTQ.DIR=$(15X_DIR)/fastq
15X.FASTQ=$(15X.FASTQ.DIR)/15xpolyA.fastq
15X.SAM=$(ALIGNDIR)/15xpolya.sam
15X.BAM=$(ALIGNDIR)/15xpolya.bam
15X.SORTED.BAM=$(ALIGNDIR)/15xpolya.sorted.bam
15X.SEQSUMMARY=$(15X.FASTQ.DIR)/sequencing_summary.txt
prep_15x: download programs
	$(BASECALL) $(BASECALL_OPTS) -s $(15X.FASTQ.DIR) -i $(15X.FAST5)
	cat $(15X.FASTQ.DIR)/workspace/pass/*.fastq > $(15X.FASTQ)
	$(MINIMAP2) -a -x map-ont $(ENOLASE.REF) $(15X.FASTQ) > $(15X.SAM)
	$(SAMTOOLS) view -b $(15X.SAM) -o $(15X.BAM)
	cd $(ALIGNDIR) && $(SAMTOOLS) sort -T tmp -o 15xpolya.sorted.bam 15xpolya.bam && $(SAMTOOLS) index 15xpolya.sorted.bam
	cd $(15X.FASTQ.DIR) && $(NANOPOLISH) index --directory=$(15X.FAST5) --sequencing-summary=$(15X.SEQSUMMARY) 15xpolyA.fastq
	cd $(BASEDIR)

30X.FAST5=$(30X_DIR)/fast5/pass
30X.FASTQ.DIR=$(30X_DIR)/fastq
30X.FASTQ=$(30X.FASTQ.DIR)/30xpolyA.fastq
30X.SAM=$(ALIGNDIR)/30xpolya.sam
30X.BAM=$(ALIGNDIR)/30xpolya.bam
30X.SORTED.BAM=$(ALIGNDIR)/30xpolya.sorted.bam
30X.SEQSUMMARY=$(30X.FASTQ.DIR)/sequencing_summary.txt
prep_30x: download programs
	$(BASECALL) $(BASECALL_OPTS) -s $(30X.FASTQ.DIR) -i $(30X.FAST5)
	cat $(30X.FASTQ.DIR)/workspace/pass/*.fastq > $(30X.FASTQ)
	$(MINIMAP2) -a -x map-ont $(ENOLASE.REF) $(30X.FASTQ) > $(30X.SAM)
	$(SAMTOOLS) view -b $(30X.SAM) -o $(30X.BAM)
	cd $(ALIGNDIR) && $(SAMTOOLS) sort -T tmp -o 30xpolya.sorted.bam 30xpolya.bam && $(SAMTOOLS) index 30xpolya.sorted.bam
	cd $(30X.FASTQ.DIR) && $(NANOPOLISH) index --directory=$(30X.FAST5) --sequencing-summary=$(30X.SEQSUMMARY) 30xpolyA.fastq
	cd $(BASEDIR)

60XB.FAST5=$(60XB_DIR)/fast5/pass
60XB.FASTQ.DIR=$(60XB_DIR)/fastq
60XB.FASTQ=$(60XB.FASTQ.DIR)/60xBpolyA.fastq
60XB.SAM=$(ALIGNDIR)/60xBpolya.sam
60XB.BAM=$(ALIGNDIR)/60xBpolya.bam
60XB.SORTED.BAM=$(ALIGNDIR)/60xBpolya.sorted.bam
60XB.SEQSUMMARY=$(60XB.FASTQ.DIR)/sequencing_summary.txt
prep_60xb: download programs
	$(BASECALL) $(BASECALL_OPTS) -s $(60XB.FASTQ.DIR) -i $(60XB.FAST5)
	cat $(60XB.FASTQ.DIR)/workspace/pass/*.fastq > $(60XB.FASTQ)
	$(MINIMAP2) -a -x map-ont $(ENOLASE.REF) $(60XB.FASTQ) > $(60XB.SAM)
	$(SAMTOOLS) view -b $(60XB.SAM) -o $(60XB.BAM)
	cd $(ALIGNDIR) && $(SAMTOOLS) sort -T tmp -o 60xBpolya.sorted.bam 60xBpolya.bam && $(SAMTOOLS) index 60xBpolya.sorted.bam
	cd $(60XB.FASTQ.DIR) && $(NANOPOLISH) index --directory=$(60XB.FAST5) --sequencing-summary=$(60XB.SEQSUMMARY) 60xBpolyA.fastq
	cd $(BASEDIR)

60XN.FAST5=$(60XN_DIR)/fast5/pass
60XN.FASTQ.DIR=$(60XN_DIR)/fastq
60XN.FASTQ=$(60XN.FASTQ.DIR)/60xNpolyA.fastq
60XN.SAM=$(ALIGNDIR)/60xNpolya.sam
60XN.BAM=$(ALIGNDIR)/60xNpolya.bam
60XN.SORTED.BAM=$(ALIGNDIR)/60xNpolya.sorted.bam
60XN.SEQSUMMARY=$(60XN.FASTQ.DIR)/sequencing_summary.txt
prep_60xn: download programs
	$(BASECALL) $(BASECALL_OPTS) -s $(60XN.FASTQ.DIR) -i $(60XN.FAST5)
	cat $(60XN.FASTQ.DIR)/workspace/pass/*.fastq > $(60XN.FASTQ)
	$(MINIMAP2) -a -x map-ont $(ENOLASE.REF) $(60XN.FASTQ) > $(60XN.SAM)
	$(SAMTOOLS) view -b $(60XN.SAM) -o $(60XN.BAM)
	cd $(ALIGNDIR) && $(SAMTOOLS) sort -T tmp -o 60xNpolya.sorted.bam 60xNpolya.bam && $(SAMTOOLS) index 60xNpolya.sorted.bam
	cd $(60XN.FASTQ.DIR) && $(NANOPOLISH) index --directory=$(60XN.FAST5) --sequencing-summary=$(60XN.SEQSUMMARY) 60xNpolyA.fastq
	cd $(BASEDIR)

60X.FAST5=$(60X_DIR)/fast5/pass
60X.FASTQ.DIR=$(60X_DIR)/fastq
60X.FASTQ=$(60X.FASTQ.DIR)/60xpolyA.fastq
60X.SAM=$(ALIGNDIR)/60xpolya.sam
60X.BAM=$(ALIGNDIR)/60xpolya.bam
60X.SORTED.BAM=$(ALIGNDIR)/60xpolya.sorted.bam
60X.SEQSUMMARY=$(60X.FASTQ.DIR)/sequencing_summary.txt
prep_60x: download programs
	$(BASECALL) $(BASECALL_OPTS) -s $(60X.FASTQ.DIR) -i $(60X.FAST5)
	cat $(60X.FASTQ.DIR)/workspace/pass/*.fastq > $(60X.FASTQ)
	$(MINIMAP2) -a -x map-ont $(ENOLASE.REF) $(60X.FASTQ) > $(60X.SAM)
	$(SAMTOOLS) view -b $(60X.SAM) -o $(60X.BAM)
	cd $(ALIGNDIR) && $(SAMTOOLS) sort -T tmp -o 60xpolya.sorted.bam 60xpolya.bam && $(SAMTOOLS) index 60xpolya.sorted.bam
	cd $(60X.FASTQ.DIR) && $(NANOPOLISH) index --directory=$(60X.FAST5) --sequencing-summary=$(60X.SEQSUMMARY) 60xpolyA.fastq
	cd $(BASEDIR)

80X.FAST5=$(80X_DIR)/fast5/pass
80X.FASTQ.DIR=$(80X_DIR)/fastq
80X.FASTQ=$(80X.FASTQ.DIR)/80xpolyA.fastq
80X.SAM=$(ALIGNDIR)/80xpolya.sam
80X.BAM=$(ALIGNDIR)/80xpolya.bam
80X.SORTED.BAM=$(ALIGNDIR)/80xpolya.sorted.bam
80X.SEQSUMMARY=$(80X.FASTQ.DIR)/sequencing_summary.txt
prep_80x: download programs
	$(BASECALL) $(BASECALL_OPTS) -s $(80X.FASTQ.DIR) -i $(80X.FAST5)
	cat $(80X.FASTQ.DIR)/workspace/pass/*.fastq > $(80X.FASTQ)
	$(MINIMAP2) -a -x map-ont $(ENOLASE.REF) $(80X.FASTQ) > $(80X.SAM)
	$(SAMTOOLS) view -b $(80X.SAM) -o $(80X.BAM)
	cd $(ALIGNDIR) && $(SAMTOOLS) sort -T tmp -o 80xpolya.sorted.bam 80xpolya.bam && $(SAMTOOLS) index 80xpolya.sorted.bam
	cd $(80X.FASTQ.DIR) && $(NANOPOLISH) index --directory=$(80X.FAST5) --sequencing-summary=$(80X.SEQSUMMARY) 80xpolyA.fastq
	cd $(BASEDIR)

100X.FAST5=$(100X_DIR)/fast5/pass
100X.FASTQ.DIR=$(100X_DIR)/fastq
100X.FASTQ=$(100X.FASTQ.DIR)/100xpolyA.fastq
100X.SAM=$(ALIGNDIR)/100xpolya.sam
100X.BAM=$(ALIGNDIR)/100xpolya.bam
100X.SORTED.BAM=$(ALIGNDIR)/100xpolya.sorted.bam
100X.SEQSUMMARY=$(100X.FASTQ.DIR)/sequencing_summary.txt
prep_100x: download programs
	$(BASECALL) $(BASECALL_OPTS) -s $(100X.FASTQ.DIR) -i $(100X.FAST5)
	cat $(100X.FASTQ.DIR)/workspace/pass/*.fastq > $(100X.FASTQ)
	$(MINIMAP2) -a -x map-ont $(ENOLASE.REF) $(100X.FASTQ) > $(100X.SAM)
	$(SAMTOOLS) view -b $(100X.SAM) -o $(100X.BAM)
	cd $(ALIGNDIR) && $(SAMTOOLS) sort -T tmp -o 100xpolya.sorted.bam 100xpolya.bam && $(SAMTOOLS) index 100xpolya.sorted.bam
	cd $(100X.FASTQ.DIR) && $(NANOPOLISH) index --directory=$(100X.FAST5) --sequencing-summary=$(100X.SEQSUMMARY) 100xpolyA.fastq
	cd $(BASEDIR)


################################################################################
#
#  Step 4: use nanopolish to generate all poly-A estimate files.
#
################################################################################

polya: 10x.polya.tsv 15x.polya.tsv 30x.polya.tsv 60xB.polya.tsv 60xN.polya.tsv 60x.polya.tsv \
	80x.polya.tsv 100x.polya.tsv prepare_data

10X.POLYA=$(POLYADIR)/10x.polya.tsv
10x.polya.tsv: prepare_data
	$(NANOPOLISH) polya --threads=$(THREADS) --reads=$(10X.FASTQ) --bam=$(10X.SORTED.BAM) --genome=$(ENOLASE.REF) > $(10X.POLYA)

15X.POLYA=$(POLYADIR)/15x.polya.tsv
15x.polya.tsv: prepare_data
	$(NANOPOLISH) polya --threads=$(THREADS) --reads=$(15X.FASTQ) --bam=$(15X.SORTED.BAM) --genome=$(ENOLASE.REF) > $(15X.POLYA)

30X.POLYA=$(POLYADIR)/30x.polya.tsv
30x.polya.tsv: prepare_data
	$(NANOPOLISH) polya --threads=$(THREADS) --reads=$(30X.FASTQ) --bam=$(30X.SORTED.BAM) --genome=$(ENOLASE.REF) > $(30X.POLYA)

60XB.POLYA=$(POLYADIR)/60xB.polya.tsv
60xB.polya.tsv: prepare_data
	$(NANOPOLISH) polya --threads=$(THREADS) --reads=$(60XB.FASTQ) --bam=$(60XB.SORTED.BAM) --genome=$(ENOLASE.REF) > $(60XB.POLYA)

60XN.POLYA=$(POLYADIR)/60xN.polya.tsv
60xN.polya.tsv: prepare_data
	$(NANOPOLISH) polya --threads=$(THREADS) --reads=$(60XN.FASTQ) --bam=$(60XN.SORTED.BAM) --genome=$(ENOLASE.REF) > $(60XN.POLYA)

60X.POLYA=$(POLYADIR)/60x.polya.tsv
60x.polya.tsv: prepare_data
	$(NANOPOLISH) polya --threads=$(THREADS) --reads=$(60X.FASTQ) --bam=$(60X.SORTED.BAM) --genome=$(ENOLASE.REF) > $(60X.POLYA)

80X.POLYA=$(POLYADIR)/80x.polya.tsv
80x.polya.tsv: prepare_data
	$(NANOPOLISH) polya --threads=$(THREADS) --reads=$(80X.FASTQ) --bam=$(80X.SORTED.BAM) --genome=$(ENOLASE.REF) > $(80X.POLYA)

100X.POLYA=$(POLYADIR)/100x.polya.tsv
100x.polya.tsv: prepare_data
	$(NANOPOLISH) polya --threads=$(THREADS) --reads=$(100X.FASTQ) --bam=$(100X.SORTED.BAM) --genome=$(ENOLASE.REF) > $(100X.POLYA)


################################################################################
#
#  Step 5: run all R scripts to generate plots from output TSVs.
#
################################################################################

RSCRIPT=Rscript
PYTHON=python

plots: pylibs ont.estimates.violin.png ont.estimates.density.png plot_segmentations polya

# --- install python dependencies:
pylibs:
	pip install -r requirements.txt

ALL_POLYAS=$(10X.POLYA) $(15X.POLYA) $(30X.POLYA) $(60XB.POLYA) $(60XN.POLYA) $(60X.POLYA) $(80X.POLYA) $(100X.POLYA)

# --- comparative violin plots:
MAKE_VIOLIN=$(SCRIPTS)/make_violin.R

ont.estimates.violin.png: polya
	cd $(BASEDIR) && $(RSCRIPT) $(MAKE_VIOLIN) $(ALL_POLYAS) && mv violin.png $(PLOTDIR)

# --- comparative density plots:
MAKE_DENSITY=$(SCRIPTS)/make_density.R

ont.estimates.density.png: polya
	cd $(BASEDIR) && $(RSCRIPT) $(MAKE_DENSITY) $(ALL_POLYAS) && mv density.png $(PLOTDIR)

# --- sampled segmentations from each dataset:
MAKE_SEG=$(SCRIPTS)/make_segmentation.py

plot_segmentations: ont10x.seg.png ont15x.seg.png ont30x.seg.png ont60xB.seg.png ont60xN.seg.png \
		    ont60x.seg.png ont80x.seg.png ont100x.seg.png pylibs polya

10X.READDB=$(10X.FASTQ).index.readdb
ont10x.seg.png: pylibs polya
	$(PYTHON) $(MAKE_SEG) $(10X.POLYA) $(10X.READDB) --out=$(PLOTDIR)/ont10x.seg.png

15X.READDB=$(15X.FASTQ).index.readdb
ont15x.seg.png: pylibs polya
	$(PYTHON) $(MAKE_SEG) $(15X.POLYA) $(15X.READDB) --out=$(PLOTDIR)/ont15x.seg.png

30X.READDB=$(30X.FASTQ).index.readdb
ont30x.seg.png: pylibs polya
	$(PYTHON) $(MAKE_SEG) $(30X.POLYA) $(30X.READDB) --out=$(PLOTDIR)/ont30x.seg.png

60XB.READDB=$(60XB.FASTQ).index.readdb
ont60xB.seg.png: pylibs polya
	$(PYTHON) $(MAKE_SEG) $(60XB.POLYA) $(60XB.READDB) --out=$(PLOTDIR)/ont60xB.seg.png

60XN.READDB=$(60XN.FASTQ).index.readdb
ont60xN.seg.png: pylibs polya
	$(PYTHON) $(MAKE_SEG) $(60XN.POLYA) $(60XN.READDB) --out=$(PLOTDIR)/ont60xN.seg.png

60X.READDB=$(60X.FASTQ).index.readdb
ont60x.seg.png: pylibs polya
	$(PYTHON) $(MAKE_SEG) $(60X.POLYA) $(60X.READDB) --out=$(PLOTDIR)/ont60x.seg.png

80X.READDB=$(80X.FASTQ).index.readdb
ont80x.seg.png: pylibs polya
	$(PYTHON) $(MAKE_SEG) $(80X.POLYA) $(80X.READDB) --out=$(PLOTDIR)/ont80x.seg.png

100X.READDB=$(100X.FASTQ).index.readdb
ont100x.seg.png: pylibs polya
	$(PYTHON) $(MAKE_SEG) $(100X.POLYA) $(100X.READDB) --out=$(PLOTDIR)/ont100x.seg.png
