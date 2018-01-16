#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

# NOTE! Assembly is there only to create a step depencendy in CWL workflow
case $key in
    -d|--datadir)
    DATADIR="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--assemblydir)
    ASSEMBLYDIR="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--assembly)
    ASSEMBLY="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--prefix)
    PREFIX="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--fofn)
    FOFN="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo DATADIR     = "${DATADIR}"
echo ASSEMBLYDIR = "${ASSEMBLYDIR}"
echo ASSEMBLY    = "${ASSEMBLY}"
echo PREFIX      = "${PREFIX}"
echo FOFN        = "${FOFN}"
#echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

# First set up the environment parameters to 4 parallel chunks running all available cpus
#pbsmrtpipe show-workflow-options -o preset.xml
cp /root/Tools/preset.xml preset.tmp
NPROC=$((`nproc`/4))
sed "s/NPROC/$NPROC/1" preset.tmp > preset.xml
rm preset.tmp

# Create RW reference data for smrtlink
rm -rf datasets
cp -r /root/smrtlink/datasets .
fasta-to-reference $ASSEMBLY /root/smrtlink/install/smrtlink-release_5.0.1.9585/bundles/smrttools/install/smrttools-release_5.0.1.9578/private/pacbio/pythonpkgs/pbcore/lib/python2.7/site-packages/pbcore/data/datasets $PREFIX

# Convert hdf5 files to subread format understood by pbsmrtpipe
python /root/Tools/Assembly/createFofn.py -d $DATADIR -f $FOFN
dataset create --force --type HdfSubreadSet baxFiles.hdfsubreadset.xml $FOFN
pbsmrtpipe pipeline-id pbsmrtpipe.pipelines.sa3_hdfsubread_to_subread --preset-xml preset.xml -e eid_hdfsubread:baxFiles.hdfsubreadset.xml

# Run quiver
pbsmrtpipe pipeline-id pbsmrtpipe.pipelines.sa3_ds_resequencing --preset-xml preset.xml -e eid_subread:tasks/pbcoretools.tasks.gather_subreadset-1/file.subreadset.xml -e eid_ref_dataset:/root/smrtlink/install/smrtlink-release_5.0.1.9585/bundles/smrttools/install/smrttools-release_5.0.1.9578/private/pacbio/pythonpkgs/pbcore/lib/python2.7/site-packages/pbcore/data/datasets/$PREFIX/referenceset.xml

# Convert created consensus FASTQ file to a FASTA file
#grep -A 1 "^@" tasks/pbcoretools.tasks.gather_fastq-1/file.fastq | sed 's/^@/>/1;s/^\-\-//1;/^$/d' > $ASSEMBLYDIR/$PREFIX.contigs.quivered.fasta
grep -A 1 "^@" tasks/pbcoretools.tasks.gather_fastq-1/file.fastq | sed 's/^@/>/1;s/^\-\-//1;/^$/d' > $PREFIX.contigs.quivered.fasta

#RUN referenceUploader -c -f /root/Assembly/reference.fasta -n "Pipeline" --ploidy haploid -s sawriter
#RUN samtools faidx /root/smrtlink/smrtanalysis/userdata/references/Pipeline/sequence/Pipeline.fasta
#RUN source /root/smrtlink/smrtanalysis/current/etc/setup.sh && fofnToSmrtpipeInput.py input.fofn > input.xml; (time smrtpipe.py --distribute --params=params.xml xml:input.xml) 2> quiver.time

#pbsmrtpipe show-task-details genomic_consensus.tasks.variantcaller
#pbsmrtpipe genomic_consensus.tasks.variantcaller

#RUN source /root/smrtlink/smrtanalysis/current/etc/setup.sh; referenceUploader -d --id "Pipeline"
#RUN zcat /root/Assembly/data/consensus.fasta.gz > /root/Assembly/reference.quivered.fa
#RUN zcat /root/Assembly/data/consensus.fastq.gz > /root/Assembly/reference.quivered.fq
#RUN rm -rf /root/Assembly/log/ /root/Assembly/data/ /root/Assembly/results/ /root/Assembly/workflow/
