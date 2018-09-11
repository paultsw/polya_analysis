"""
Plot a random segmentation from a dataset.

Usage:
  $ python polya.out.tsv reads.fastq.readdb.index
"""
import fast5
import pandas as pd
import numpy as np
import argparse
import os
from random import choice

# plotting libraries:
import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
import seaborn as sns


def main(args):
    """Filter-in PASS-ing segmentations and plot a random segmented read to file."""
    # load dataframes:
    polya = pd.read_csv(args.polya_tsv, sep='\t')
    readdb = pd.read_csv(args.readdb, sep='\t', header=None, names=['readname','location'])

    # get a random read, its segmentation, and its location:
    read_id, l_start, a_start, p_start, t_start  = choice(polya[polya['qc_tag'] == 'PASS'][[
        'readname', 'leader_start', 'adapter_start', 'polya_start', 'transcript_start']].as_matrix())
    read_path = readdb[readdb['readname'] == read_id].as_matrix()[0][1]

    # load fast5 file:
    signal = np.array(fast5.File(read_path).get_raw_samples())

    # make segmentation plot:
    plt.figure(figsize=(18,6))
    plt.plot(signal)
    plt.axvspan(0, max(l_start-1,1), color='cyan', alpha=0.35) # START
    plt.axvspan(l_start, a_start-1, color='yellow', alpha=0.35) # LEADER
    plt.axvspan(a_start, p_start-1, color='red', alpha=0.35) # ADAPTER
    plt.axvspan(p_start, t_start-1, color='green', alpha=0.35) # POLYA
    plt.axvspan(t_start, signal.shape[0], color='blue', alpha=0.35) # TRANSCRIPT
    plt.xlim(0, signal.shape[0])
    plt.title("Segmentation: {}".format(read_id))
    plt.xlabel("Sample Index (3' to 5')")
    plt.ylabel("Current (pA)")
    if (args.out is None):
        plt.savefig("segmentation.{}.png".format(read_id))
    else:
        plt.savefig(args.out)
    
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Plot a random passing segmentation from ")
    parser.add_argument("polya_tsv", help="Output TSV of `nanopolish polya {...}`")
    parser.add_argument("readdb", help="ReadDB index file from `nanopolish index {...}`")
    parser.add_argument("--out", default=None, help="Where to put the output file. [./segmentation.<READ_ID>.png]")
    args = parser.parse_args()
    assert(os.path.exists(args.polya_tsv)), "[ERR] {} does not exist".format(args.polya_tsv)
    assert(os.path.exists(args.readdb)), "[ERR] {} does not exist".format(args.readdb)
    main(args)
