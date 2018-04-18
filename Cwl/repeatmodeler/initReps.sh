#!/bin/bash
cd /root/Libraries
mkdir /var/spool/cwl/Libraries
#cp RepeatPeps.readme /var/spool/cwl/Libraries
#cp RepeatPeps.lib /var/spool/cwl/Libraries
#cp RepeatAnnotationData.pm /var/spool/cwl/Libraries
#cp Dfam.hmm /var/spool/cwl/Libraries
#cp taxonomy.dat /var/spool/cwl/Libraries
#cp RMRBMeta.embl /var/spool/cwl/Libraries
#cp README.meta /var/spool/cwl/Libraries
#cp DfamConsensus.embl /var/spool/cwl/Libraries
cp RepeatPeps.readme /var/spool/cwl
cp RepeatPeps.lib /var/spool/cwl
cp RepeatAnnotationData.pm /var/spool/cwl
cp Dfam.hmm /var/spool/cwl
cp taxonomy.dat /var/spool/cwl
cp RMRBMeta.embl /var/spool/cwl
cp README.meta /var/spool/cwl
cp DfamConsensus.embl /var/spool/cwl
# This copy circumvents the issue encountered with CWL InitialWorkDir and udocker
#find /var/lib/cwl -name RMRBSeqs.embl -exec cp {} /var/spool/cwl/Libraries \;
find /var/lib/cwl -name RMRBSeqs.embl -exec cp {} /var/spool/cwl \;
#cp /var/spool/cwl/RepBaseLibrary/RMRBSeqs.embl /var/spool/cwl/Libraries
cd /usr/local/RepeatMasker
perl configure < /root/inputRepeatMasker
cd /usr/local/RepeatModeler
perl configure < /root/inputRepeatModeler
