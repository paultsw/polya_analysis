"""
Compute summary statistics on qc-passing poly(A) estimates.

Usage: point this script at a directory containing the `nanopolish polya` estimates TSV file for
the ONT poly(A) datasets and run, e.g.:

$ python compute_statistics.py ./data/polyas

Note that the directory of poly(A) estimate TSV files must have names exactly matching those
in the pipeline: 10x.polya.tsv, 15x.polya.tsv, (...), 100x.polya.tsv.
"""
import numpy as np
import pandas as pd
import scipy.stats as stats
import argparse
import os


def mad(arr):
    """Compute median absolute deviation."""
    return np.median(np.abs(arr - np.median(arr)))


def percent_within_mad(arr, expected, mult):
    """Compute percent of arr that falls within (exp - mult * mad, exp + mult * mad)."""
    lower = expected - mult * mad(arr)
    upper = expected + mult * mad(arr)
    return 100. * (float(((lower < arr) & (arr < upper)).sum()) / float(arr.shape[0]))


def percent_within_stdv(arr, expected, mult):
    """Compute percent of arr that falls within (exp - mult * stdv, exp + mult * stdv)."""
    lower = expected - mult * np.std(arr)
    upper = expected + mult * np.std(arr)
    return 100. * (float(((lower < arr) & (arr < upper)).sum()) / float(arr.shape[0]))


def summary_statistics(arr, expected):
    """
    Compute mean, median, mode, standard deviation, median absolute deviation of the datasets.
    
    Compute percentage of the array that falls within 2 stdv and 2 MAD of the expected value.
    """
    return {
        'count': arr.shape[0],
        'mean': np.mean(arr),
        'median': np.median(arr),
        'mode': stats.mode(arr)[0][0],
        'stdv': np.std(arr),
        'mad': mad(arr),
        'percent_within_2mad_of_expected': percent_within_mad(arr, expected, 2.),
        'percent_within_2stdv_of_expected': percent_within_stdv(arr, expected, 2.)
    }


def summarize(polyas_dir):
    """
    Read each file into a dataframe, filter-in for QC tag set to 'PASS', and compute summary statistics.

    Print a table containing statistics across all datasets to standard output.

    Note: all filenames must exactly match their expected names (e.g. "10x.polya.tsv" must contain estimates
    for the 10xA control dataset).
    """
    df10x = pd.read_csv(os.path.join(polyas_dir,"10x.polya.tsv"), sep='\t')
    df15x = pd.read_csv(os.path.join(polyas_dir,"15x.polya.tsv"), sep='\t')
    df30x = pd.read_csv(os.path.join(polyas_dir,"30x.polya.tsv"), sep='\t')
    df60x = pd.read_csv(os.path.join(polyas_dir,"60x.polya.tsv"), sep='\t')
    df60xN = pd.read_csv(os.path.join(polyas_dir,"60xN.polya.tsv"), sep='\t')
    df80x = pd.read_csv(os.path.join(polyas_dir,"80x.polya.tsv"), sep='\t')
    df100x = pd.read_csv(os.path.join(polyas_dir,"100x.polya.tsv"), sep='\t')
    
    print(pd.DataFrame({
        '10x.polya.tsv': summary_statistics(df10x[df10x['qc_tag'] == 'PASS']['polya_length'].values, 10.),
        '15x.polya.tsv': summary_statistics(df15x[df15x['qc_tag'] == 'PASS']['polya_length'].values, 15.),
        '30x.polya.tsv': summary_statistics(df30x[df30x['qc_tag'] == 'PASS']['polya_length'].values, 30.),
        '60x.polya.tsv': summary_statistics(df60x[df60x['qc_tag'] == 'PASS']['polya_length'].values, 60.),
        '60xN.polya.tsv': summary_statistics(df60xN[df60xN['qc_tag'] == 'PASS']['polya_length'].values, 60.),
        '80x.polya.tsv': summary_statistics(df80x[df80x['qc_tag'] == 'PASS']['polya_length'].values, 80.),
        '100x.polya.tsv': summary_statistics(df100x[df100x['qc_tag'] == 'PASS']['polya_length'].values, 100.),
    }).round(2).to_csv())


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Compute summary statistics across poly(A) output TSVs.")
    parser.add_argument("polyas_dir", help="Path to directory of poly(A) TSVs.")
    args = parser.parse_args()
    assert os.path.exists(args.polyas_dir), "[compute_statistics.py] directory does not exist: {}".format(args.polyas_dir)
    summarize(args.polyas_dir)
