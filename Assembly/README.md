## An assembly pipeline for PacBio data
This pipeline creates an assembly from PacBio raw data using the program canu, polishes the assembly using the programs quiver and pilon and finally runs haplomerger to merge putative haplotypes. The pipeline works for diploid genomes only. Common Workflow Language (CWL) descriptions used to integrate the pipeline together.

## hdf5check.py
The script identifies all HDF5 files found nested in given data directory and extracts both FASTA and FASTQ files to given results directory. The script uses the program DEXTRACTOR v1.0p1 (https://github.com/thegenemyers/DEXTRACTOR) for extraction.

```
usage: python %prog  [-h] [-d DATADIR] [-r RESDIR] [-T THREADS]

optional arguments:
  -h, --help            show this help message and exit
  -d DATADIR, --dir DATADIR
                        Directory, in which PacBio data resides
  -r RESDIR, --res RESDIR
                        Result directory
  -T THREADS, --threads THREADS
                        Number of parallel threads (default is half of the
                        capacity but >= 1)
```

To run the script using CWL use:
```
> cwltool hdf5check.cwl hdf5check.yml
```

