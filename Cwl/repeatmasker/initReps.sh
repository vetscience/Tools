#!/bin/bash
cd /root/Libraries
mkdir /var/spool/cwl/Libraries
cp RepeatPeps.readme /var/spool/cwl/Libraries
cp RepeatPeps.lib /var/spool/cwl/Libraries
cp RepeatAnnotationData.pm /var/spool/cwl/Libraries
cp Dfam.hmm /var/spool/cwl/Libraries
cp taxonomy.dat /var/spool/cwl/Libraries
cp RMRBMeta.embl /var/spool/cwl/Libraries
cp README.meta /var/spool/cwl/Libraries
cp DfamConsensus.embl /var/spool/cwl/Libraries
cp /var/spool/cwl/RepBaseLibrary/RMRBSeqs.embl /var/spool/cwl/Libraries
cd /usr/local/RepeatMasker
perl configure < /root/inputRepeatMasker