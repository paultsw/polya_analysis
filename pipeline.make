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
NA12878DATADIR=$(DATADIR)/na12878
ALIGNDIR=$(DATADIR)/alns
REFDIR=$(DATADIR)/references


# where to put the plots:
PLOTDIR=$(BASEDIR)/plots

# where to install the programs:
PROGDIR=$(BASEDIR)/programs

# parallel processing settings for nanopolish:
CORES=16
THREADS=8

# run `all` if called without rule:
.DEFAULT_GOAL = all

all: makedirs nanopolish minimap2 samtools download polya plots

makedirs:
	test ! -d $(DATADIR) && mkdir $(DATADIR)
	test ! -d $(ONTDATADIR) && mkdir $(ONTDATADIR)
	test ! -d $(NA12878DATADIR) && mkdir $(NA12878DATADIR)
	test ! -d $(PLOTDIR) && mkdir $(PLOTDIR)
	test ! -d $(PROGDIR) && mkdir $(PROGDIR)

# tell MAKE that the following dependencies don't generate any files:
.PHONY: all nanopolish minimap2 samtools download polya plots plots-violin plots-density plots-segmentation

# '.DELETE_ON_ERROR' is a special rule that tells MAKE to
# delete target files if this makefile ends in an error:
# '.SECONDARY' (without any dependencies) is a special rule that
# tells MAKE to avoid deleting any intermediate files.
.DELETE_ON_ERROR:
.SECONDARY:

################################################################################
#
#  Step 1: clone and compile nanopolish, minimap2, samtools, albacore.
#
#  TODO:
#    - checkout tagged nanopolish release once polya-merged is merged with master
#    - fix samtools install && build rule
#    - add albacore support
################################################################################

nanopolish:
	test ! -d nanopolish && git clone --recursive https://github.com/jts/nanopolish.git
	cd nanopolish; git checkout polya-merged; $(MAKE)

NANOPOLISH=$(BASEDIR)/nanopolish/nanopolish

MINIMAP2URL=https://github.com/lh3/minimap2/releases/download/v2.12/minimap2-2.12_x64-linux.tar.bz2

minimap2:
	curl -L $(MINIMAP2URL) > minimap2-2.12.tar.bz2
	tar -jxvf minimap2-2.12.tar.bz2

MINIMAP2=$(BASEDIR)/minimap2-2.12_x64-linux/minimap2

SAMTOOLSURL=https://github.com/samtools/samtools.git

samtools:
	git clone $(SAMTOOLSURL)
	cd samtools && make

SAMTOOLS=$(BASEDIR)/samtools/samtools

################################################################################
#
#  Step 2: download all relevant datasets and unpack fast5's.
#
#  TODO:
#    - check for existence before downloading
#    - download fastq's into $(DATADIR)/reads/{ont,na12878}
#    - download references into $(DATADIR)/references
################################################################################

download: 10xpolyA.tar.gz 15xpolyA.tar.gz 30xpolyA.tar.gz \
	  60bxpolyAb.tar.gz 60nxpolyA10xN.tar.gz 60xpolyA.tar.gz \
	  80xpolyA.tar.gz 100xpolyA.tar.gz \
	  enolase_reference.fas

10X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/10xpolyA.tar.gz
10X_TAR=$(ONTDATADIR)/10xpolyA.tar.gz
10X_DIR=$(ONTDATADIR)/10xpolyA
10xpolyA.tar.gz:
	test ! -f $(10X_TAR) && wget $(10X_URL) -O $(10X_TAR)
	mkdir $(10X_DIR)
	tar -xzf $(10X_TAR) -C $(10X_DIR)

15X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/15xpolyA.tar.gz
15X_TAR=$(ONTDATADIR)/15xpolyA.tar.gz
15X_DIR=$(ONTDATADIR)/15xpolyA
15xpolyA.tar.gz:
	test ! -f $(15X_TAR) && wget $(15X_URL) -O $(15X_TAR)
	mkdir $(15X_DIR)
	tar -xzf $(15X_TAR) -C $(15X_DIR)

30X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/30xpolyA.tar.gz
30X_TAR=$(ONTDATADIR)/30xpolyA.tar.gz
30X_DIR=$(ONTDATADIR)/30xpolyA
30xpolyA.tar.gz:
	test ! -f $(30X_TAR) && wget $(30X_URL) -O $(30X_TAR)
	mkdir $(30X_DIR)
	tar -xzf $(30X_TAR) -C $(30X_DIR)

60XB_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/60bxpolyAb.tar.gz
60XB_TAR=$(ONTDATADIR)/60bxpolyAb.tar.gz
60XB_DIR=$(ONTDATADIR)/60xpolyAb
60bxpolyAb.tar.gz:
	test ! -f $(60XB_TAR) && wget $(60XB_URL) -O $(60XB_TAR)
	mkdir $(15XB_DIR)
	tar -xzf $(60XB_TAR) -C $(60XB_DIR)

60XN_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/60nxpolyA10xN.tar.gz
60XN_TAR=$(ONTDATADIR)/60nxpolyA10xN.tar.gz
60XN_DIR=$(ONTDATADIR)/60nxpolyA10xN
60nxpolyA10xN.tar.gz:
	test ! -f $(60XN_TAR) && wget $(60XN_URL) -O $(60XN_TAR)
	mkdir $(60XN_DIR)
	tar -xzf $(60XN_TAR) -C $(60XN_DIR)

60X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/60xpolyA.tar.gz
60X_TAR=$(ONTDATADIR)/60xpolyA.tar.gz
60X_DIR=$(ONTDATADIR)/60xpolyA
60xpolyA.tar.gz:
	test ! -f $(60X_TAR) && wget $(60X_URL) -O $(60X_TAR)
	mkdir $(60X_DIR)
	tar -xzf $(60X_TAR) -C $(60X_DIR)

80X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/80xpolyA.tar.gz
80X_TAR=$(ONTDATADIR)/80xpolyA.tar.gz
80X_DIR=$(ONTDATADIR)/80xpolyA
80xpolyA.tar.gz:
	test ! -f $(80X_TAR) && wget $(80X_URL) -O $(80X_TAR)
	mkdir $(80X_DIR)
	tar -xzf $(80X_TAR) -C $(80X_DIR)

100X_URL=ftp://ftp.sra.ebi.ac.uk/vol1/ERA158/ERA1580896/oxfordnanopore_native/100xpolyA.tar.gz
100X_TAR=$(ONTDATADIR)/100xpolyA.tar.gz
100X_DIR=$(ONTDATADIR)/100xpolyA
100xpolyA.tar.gz:
	test ! -f $(100X_TAR) && wget $(100X_URL) -O $(100X_TAR)
	mkdir $(100X_DIR)
	tar -xzf $(100X_TAR) -C $(100X_DIR)

################################################################################
#
#  Step 3: basecall, align (via minimap2), index for all datasets.
#
#  TODO:
#    - debug this block
################################################################################

# TBD


################################################################################
#
#  Step 4: use nanopolish to generate all poly-A estimate files.
#
#  TODO:
#    - perform indexing: `$(NANOPOLISH) index --directory=$(DATADIR) --sequencing-summary=???`
#    - add samtools-view when samtools build rule is fixed:
#        `$(SAMTOOLS) view $(DATADIR)/alns/10xpolya.sam -o $(DATADIR)/alns/10xpolya.bam`
################################################################################

polya: 10x.polya.tsv 15x.polya.tsv 30x.polya.tsv 60x.polya.tsv 80x.polya.tsv 100x.polya.tsv

ENOLASE.REF=$(DATADIR)/enolase_reference.fas

10X.FASTQ=$(DATADIR)/10xpolyA.partial.fastq
10X.SAM=$(DATADIR)/alns/10xpolya.sam
10X.BAM=$(DATADIR)/alns/10xpolya.bam
10X.POLYA=$(DATADIR)/polyas/10x.polya.tsv
10x.polya.tsv:
	$(MINIMAP2) -a -x map-ont $(ENOLASE.REF) $(DATADIR)/10xpolyA.partial.fastq > $(10X.SAM)
	$(NANOPOLISH) polya --reads=$(10X.FASTQ) --bam=$(10X.BAM) --genome=$(ENOLASE.REF) > 10x.polya.tsv

15x.polya.tsv:
	$(MINIMAP2) -a -x map-ont # TODO
	$(NANOPOLISH) polya --reads=READS.fq --bam=ALN.bam --genome=REF.fa > 15x.polya.tsv

30x.polya.tsv:
	$(MINIMAP2) -a -x map-ont # TODO
	$(NANOPOLISH) polya --reads=READS.fq --bam=ALN.bam --genome=REF.fa > 30x.polya.tsv

60x.polya.tsv:
	$(NANOPOLISH) index # TODO
	$(MINIMAP2) -a -x map-ont # TODO
	$(NANOPOLISH) polya --reads=READS.fq --bam=ALN.bam --genome=REF.fa > 60x.polya.tsv

80x.polya.tsv:
	$(NANOPOLISH) index # TODO
	$(MINIMAP2) -a -x map-ont # TODO
	$(NANOPOLISH) polya --reads=READS.fq --bam=ALN.bam --genome=REF.fa > 80x.polya.tsv

100x.polya.tsv:
	$(NANOPOLISH) index # TODO
	$(MINIMAP2) -a -x map-ont # TODO
	$(NANOPOLISH) polya --reads=READS.fq --bam=ALN.bam --genome=REF.fa > 100x.polya.tsv


################################################################################
#
#  Step 5: run all R scripts to generate plots from output TSVs.
#
#  TODO:
#    - build python environment with fast5 library
################################################################################

RSCRIPT=Rscript # TODO: check
PYTHON=python # TODO: check

plots: pylibs plots-violin plots-density plots-segmentation

# --- install python dependencies:
pylibs:
	pip install pandas
	pip install numpy
	pip install matplotlib
	pip install seaborn
	pip install fast5 # fix: this should git-clone matei's fast5 lib

# --- comparative violin plots:
MAKE_VIOLIN=$(SCRIPTS)/make_violin.R

plots-violin: ont.estimates.violin.png debruijn.estimates.violin.png na12878.estimates.violin.png

ont.estimates.violin.png:
	$(RSCRIPT) $(MAKE_VIOLIN) <10x.tsv> <15x.tsv> <30x.tsv> <60x.tsv> <80x.tsv> <100x.tsv>

debruijn.estimates.violin.png:
	$(RSCRIPT) $(MAKE_VIOLIN) <debruijn.control.tsv> <debruijn.mettl3.tsv> <debruijn.ivt.10m6a.tsv>

na12878.estimates.violin.png:
	$(RSCRIPT) $(MAKE_VIOLIN) <na12878.plus.sirv.tsv> <na12878.no.sirv.tsv> <sirv.only.tsv>

# --- comparative density plots:
MAKE_DENSITY=$(SCRIPTS)/make_density.R

plots-density: ont.estimates.density.png debruijn.estimates.density.png na12878.estimates.density.png

ont.estimates.density.png:
	$(RSCRIPT) $(MAKE_DENSITY) <10x.tsv> <15x.tsv> <30x.tsv> <60x.tsv> <80x.tsv> <100x.tsv>

debruijn.estimates.density.png:
	$(RSCRIPT) $(MAKE_DENSITY) <debruijn.control.tsv> <debruijn.mettl3.tsv> <debruijn.ivt.10m6a.tsv>

na12878.estimates.density.png:
	$(RSCRIPT) $(MAKE_DENSITY) <na12878.plus.sirv.tsv> <na12878.no.sirv.tsv> <sirv.only.tsv>

# --- sampled segmentations from each dataset:
MAKE_SEG=$(SCRIPTS)/make_segmentation.py

plots-segmentation: ont10x.seg.png ont15x.seg.png ont30x.seg.png ont60x.seg.png ont80x.seg.png ont100x.seg.png

ont10x.seg.png:
	$(PYTHON) $(MAKE_SEG) $(10X.POLYA) <10x.readdb> --out=./ont10x.seg.png

ont15x.seg.png:
	$(PYTHON) $(MAKE_SEG) $(15X.POLYA) <15x.readdb> --out=./ont15x.seg.png

ont30x.seg.png:
	$(PYTHON) $(MAKE_SEG) $(30X.POLYA) <30x.readdb> --out=./ont30x.seg.png

ont60x.seg.png:
	$(PYTHON) $(MAKE_SEG) $(60X.POLYA) <60x.readdb> --out=./ont60x.seg.png

ont80x.seg.png:
	$(PYTHON) $(MAKE_SEG) $(80X.POLYA) <80x.readdb> --out=./ont80x.seg.png

ont100x.seg.png:
	$(PYTHON) $(MAKE_SEG) $(100X.POLYA) <100x.readdb> --out=./ont100x.seg.png
