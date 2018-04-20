FROM ubuntu:16.04
RUN apt-get update && apt-get install -y wget perl build-essential cpio less git
WORKDIR /root
RUN wget http://www.repeatmasker.org/RepeatModeler/RepeatModeler-open-1.0.11.tar.gz
RUN wget http://www.repeatmasker.org/RepeatMasker-open-4-0-7.tar.gz
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.6.0/ncbi-blast-2.6.0+-src.tar.gz
RUN wget http://www.repeatmasker.org/isb-2.6.0+-changes-vers2.patch.gz
RUN wget http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz
RUN wget http://www.repeatmasker.org/RepeatModeler/RECON-1.08.tar.gz
RUN wget http://www.repeatmasker.org/RepeatScout-1.0.5.tar.gz
RUN wget -r ftp://ftp.ncbi.nih.gov/pub/seg/nseg/
RUN mv ftp.ncbi.nih.gov/pub/seg/nseg/ . && rm -rf ftp.ncbi.nih.gov/
RUN wget http://www.dfam.org/web_download/Release/Dfam_2.0/Dfam.hmm.gz

# Install NCBI rmblast
RUN tar xvfz ncbi-blast-2.6.0+-src.tar.gz && gunzip isb-2.6.0+-changes-vers2.patch.gz
WORKDIR ncbi-blast-2.6.0+-src
RUN patch -p1 < /root/isb-2.6.0+-changes-vers2.patch
WORKDIR c++
RUN ./configure --with-mt --prefix=/usr/local/rmblast --without-debug
RUN sed '54,55d' Makefile > Makefile.new && mv Makefile.new Makefile
RUN make -j 12 && make install

# Install HMMER
WORKDIR /root
RUN tar zxf hmmer-3.1b2-linux-intel-x86_64.tar.gz
WORKDIR hmmer-3.1b2-linux-intel-x86_64
RUN ./configure && make && make install

# Install RECON
WORKDIR /root
RUN tar zxf RECON-1.08.tar.gz
WORKDIR RECON-1.08/src
RUN make && make install
WORKDIR /root/RECON-1.08/scripts
RUN sed 's/\$path = "";/\$path = "\/root\/RECON-1.08\/bin";/1' recon.pl > recon.pl.new
RUN mv recon.pl.new recon.pl && chmod uog+x recon.pl

# Install nseg
WORKDIR /root/nseg
RUN make && mv nseg /usr/local/bin && mv nmerge /usr/local/bin

# Install RepeatScout
WORKDIR /root
RUN tar zxf RepeatScout-1.0.5.tar.gz
WORKDIR RepeatScout-1
RUN make && mv build_lmer_table /usr/local/bin && mv RepeatScout /usr/local/bin

# Install TRF
RUN wget https://tandem.bu.edu/cgi-bin/trf/trf.download.pl?fileselect=30
RUN mv trf.download.pl?fileselect=30 /usr/local/bin/trf
RUN chmod uog+x /usr/local/bin/trf

# Install RepeatMasker
WORKDIR /root
WORKDIR /root
WORKDIR /root
WORKDIR /root
RUN git clone --recursive git://github.com/vetscience/Tools
#RUN git clone -b 'v1.0.4-beta' --single-branch --depth 1 https://github.com/vetscience/Tools
RUN mv RepeatMasker-open-4-0-7.tar.gz /usr/local
WORKDIR /usr/local
RUN tar zxf RepeatMasker-open-4-0-7.tar.gz && rm -rf RepeatMasker-open-4-0-7.tar.gz
WORKDIR RepeatMasker
#RUN zcat /root/Dfam.hmm.gz > Libraries/Dfam.hmm && mv Libraries /root && ln -s /var/spool/cwl/Libraries .
RUN zcat /root/Dfam.hmm.gz > Libraries/Dfam.hmm
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatMaskerConf/DateRepeats .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatMaskerConf/DupMasker .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatMaskerConf/ProcessRepeats .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatMaskerConf/RepeatMasker .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatMaskerConf/RepeatMaskerConfig.pm .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatMaskerConf/RepeatProteinMask .
RUN cp -r /root/Tools/Cwl/repeatmodeler/RepeatMaskerConf/util .
#RUN cp /root/Tools/Cwl/repeatmodeler/inputSoundex .
#RUN perl -MCPAN -e 'install Text::Soundex' < inputSoundex

# Configuration is done everytime the RepeatMasker or RepeatModeler is started
WORKDIR /root
RUN wget http://www.repeatmasker.org/libraries/RepeatMaskerMetaData-20170127.tar.gz
RUN tar zxf RepeatMaskerMetaData-20170127.tar.gz

RUN cp Tools/Cwl/repeatmodeler/initReps.sh . && cp Tools/Cwl/repeatmodeler/repeatModeler.sh .
RUN chmod uog+x initReps.sh && chmod uog+x repeatModeler.sh
RUN cp Tools/Cwl/repeatmodeler/inputRepeatMasker .

# Install RepeatModeler
RUN cp RepeatModeler-open-1.0.11.tar.gz /usr/local
RUN cp Tools/Cwl/repeatmodeler/inputRepeatModeler .
WORKDIR /usr/local
RUN tar zxf RepeatModeler-open-1.0.11.tar.gz && mv RepeatModeler-open-1.0.11 RepeatModeler
WORKDIR RepeatModeler
RUN cp /root/Tools/Cwl/repeatmodeler/inputJson .
RUN perl -MCPAN -e 'install JSON' < inputJson
RUN cpan install LWP::UserAgent
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatModelerConf/BuildDatabase .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatModelerConf/Refiner .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatModelerConf/RepeatClassifier .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatModelerConf/RepeatModeler .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatModelerConf/RepModelConfig.pm .
RUN cp /root/Tools/Cwl/repeatmodeler/RepeatModelerConf/TRFMask . 
RUN cp -r /root/Tools/Cwl/repeatmodeler/RepeatModelerConf/util .

WORKDIR /root
ENV PATH=/usr/local/RepeatMasker:/usr/local/RepeatModeler:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV TERM=xterm
RUN chmod uog+x /root
ENTRYPOINT ["/root/repeatModeler.sh"]

