#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

# NOTE! Assembly is there only to create a step depencendy in CWL workflow
case $key in
    -U|--trimmed-reads)
    TRIMMEDREADS="$2"
    shift # past argument
    shift # past value
    ;;
    -S|--classification-file)
    CLASSIFICATION="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--taxons)
    TAXONS="$2"
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

echo TRIMMEDREADS   = "${TRIMMEDREADS}"
echo CLASSIFICATION = "${CLASSIFICATION}"
echo TAXONS         = "${TAXONS}"
#echo "Number files in SEARCH PATH with EXTENSION:" $(ls -1 "${SEARCHPATH}"/*."${EXTENSION}" | wc -l)
if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

# First rename the trimmed reads to enable unique identification
#awk '{print $1""$4}' $TRIMMEDREADS | sed 's/id=/_read_/1' > rn_$TRIMMEDREADS
#centrifuge -f -x $DATABASE --min-hitlen $MINHITLEN -U RN_$TRIMMEDREADS --report-file $REPORT -S $CLASSIFICATION -p $THREADS
awk 'NR>1{if ($6>=200) print $0"\t"$3}' $CLASSIFICATION > classification.converted
# Bacteria, viruses, fungi and mammals
touch taxon.ids
for taxon in  ${TAXONS//,/ };
do
perl /root/taxtreelabel.pl classification.converted $taxon && awk '{print $1}' in_tree.txt | sort | uniq >> taxon.ids
done
# Rename the contaminated reads back to original names
sort taxon.ids | uniq | awk -F"_read_" '{print "id="$2}' > contaminated.read.ids.unique

zcat $TRIMMEDREADS > trimmed.fasta
grep ">" trimmed.fasta | sed 's/>//1' > trimmedReads.ids
fgrep -w -f contaminated.read.ids.unique trimmedReads.ids > contaminated.read.ids.orig
fgrep -v -w -f contaminated.read.ids.orig trimmedReads.ids > trimmedReads.ids.decon
#python ~/Codebase/grepf.py -f contaminated.read.ids.orig -i cele.trimmedReads.fasta | fgrep -A 1 -w -f contaminated.read.ids.unique - > contaminatedReads.fa
python /root/convertFasta.py -i trimmed.fasta | fgrep -A 1 -w -f contaminated.read.ids.unique | gzip > contaminatedReads.fa.gz
python /root/convertFasta.py -i trimmed.fasta | fgrep -A 1 -w -f trimmedReads.ids.decon | gzip > trimmedReads.decon.fa.gz
