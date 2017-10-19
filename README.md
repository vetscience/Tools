## Bioinformatic tools for workflows
This repository contains integrated tools and workflows to simplify common bioinformatic tasks.
To ease the integration of these tools into a workflow, Common Workflow Language (CWL) descriptions are given.

## orthoMcl.py
The script offers a user friendly python wrapper for OrthoMCL pipeline (https://github.com/stajichlab/OrthoMCL). The script orthoMcl.py runs either stand-alone or using CWL orthomcl.cwl description found in Cwl directory. CWL description pulls pakorhon/orthomcl:1.0.0-beta docker container. The script is dependent on MySQL database and currently runs either with MySQL container mysql:5.7.19 when using CWL or server installation of 5.6.29 when executed stand-alone.
```
Usage: orthoMcl.py -i residues1.fa,residues2.fa,...,residuesN.fa -l LB1,LB2,...,LBN -p 1,1,...,1 -e 1e-5 -s 0.5

Options:
  -h, --help            show this help message and exit
  -a IPADDRESS, --ip=IPADDRESS
                        MySQL server IP address
  -d DIR, --dir=DIR     The directory, in which the FASTA files for the analysis are copied to
  -i FILES, --filenames=FILES
                        Proteome, CDS or transcript FASTA files of species (separated by commas)
  -l LABELS, --labels=LABELS
                        Respective labels for proteomes following the order of FASTA files (separated by commas)
  -p POSITIONS, --positions=POSITIONS
                        Position of a unique identifier in FASTA header separated by |. Default position is 1 (separated by commas).
  -T THREADS, --threads=THREADS
                        Number of parallel threads (default is half or the capacity but >= 1)
  -e EVALUE, --evalue=EVALUE
                        E-value for BLAST run. Default is 1e-5. Use always E-value <= 1e-5 and 1e-X
                        format only!
  -s SIM, --similarity=SIM
                        Required similarity (0 .. 1) in mcl algorithm. Default if 0.5
  -m MINLEN, --minlen=MINLEN
                        Required minimum lenght of a sequence. Default is 20.
  -b, --noblast         Skip BLAST (used to rerun mcl using different E-value and similarity settings)
  -n, --nucl            The residues in sequences represent nucleotides instead of proteins

E.g.: orthoMcl -i proteome1.fa,proteome2.fa -l Tax,Tvi -p 4,4 -e 1e-5
Results will be found in 'Results' directory in groups.txt file.
Note! The labels must be exactly 3 characters long.
```

To run the script using CWL use:
```
> cwltool orthomcl.cwl orthomcl.yml
```

You have to recreate the yml file for each run and embed the IP address of MySQL server e.g. using the commands found in Cwl/run.sh:
```
> export MYSQLIP=`docker inspect SqlDocker | grep '"IPAddress"' | head -1 | awk '{print $2}' | sed 's/"//g;s/,//1'`
> echo $MYSQLIP
> sed "s/127.0.0.1/$MYSQLIP/1" orthomcl.template.yml > orthomcl.yml
```

The script has been tested with MySQL v5.6.29 when run stand-alone and v5.7.19 when run using MySQL container and orthomcl.cwl
IP address for MySQL server is introduced in argumens to enable the use of same code in stand-alone and CWL runs.
Without this requirement, socket would be used in stand-alone implementation.
