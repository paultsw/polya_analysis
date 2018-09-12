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

The pipeline requires the albacore basecaller, version `` or above; set the `BASECALL` variable
in the makefile to the location of your `read_fast5_basecaller.py` file as appropriate. Albacore
is (as of pixel time) closed source but may be downloaded via the ONT community website.

Then, run
```
make --file=full_pipeline.make
```
to download all datasets and code and generate all relevant files.

Notes
-----
* It can take a long time to download and untar the fast5 files (a few hours to a full workday). Plan accordingly,
  and monitor progress with (e.g.) a `watch ls -lah` on the appropriate directories.

Citations
---------
(TBD)