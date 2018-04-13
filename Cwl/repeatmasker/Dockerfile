FROM ubuntu:16.04
RUN apt-get update && apt-get install -y wget perl build-essential cpio less git

# Install NCBI rmblast
WORKDIR /root
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.6.0/ncbi-blast-2.6.0+-src.tar.gz
RUN wget http://www.repeatmasker.org/isb-2.6.0+-changes-vers2.patch.gz
RUN tar xvfz ncbi-blast-2.6.0+-src.tar.gz && gunzip isb-2.6.0+-changes-vers2.patch.gz
WORKDIR ncbi-blast-2.6.0+-src
RUN patch -p1 < /root/isb-2.6.0+-changes-vers2.patch
WORKDIR c++
RUN ./configure --with-mt --prefix=/usr/local/rmblast --without-debug
RUN sed '54,55d' Makefile > Makefile.new && mv Makefile.new Makefile
RUN make -j 4 && make install
WORKDIR /root
RUN rm -rf ncbi-blast-2.6.0+-src* isb-2.6.0+-changes-vers2.patch

# Install HMMER
#WORKDIR /root
#RUN wget http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz
#RUN tar zxf hmmer-3.1b2-linux-intel-x86_64.tar.gz
#WORKDIR hmmer-3.1b2-linux-intel-x86_64
#RUN ./configure && make && make install
#WORKDIR /root
#RUN rm -rf hmmer-3.1b2-linux-intel-x86_64*
RUN wget http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz
RUN tar zxf hmmer-3.1b2-linux-intel-x86_64.tar.gz && cp hmmer-3.1b2-linux-intel-x86_64/binaries/* /usr/local/bin
RUN rm -rf hmmer-3.1b2-linux-intel-x86_64*

# Install RECON
RUN wget http://www.repeatmasker.org/RepeatModeler/RECON-1.08.tar.gz
RUN tar zxf RECON-1.08.tar.gz && rm RECON-1.08.tar.gz
WORKDIR RECON-1.08/src
RUN make && make install
WORKDIR /root/RECON-1.08/scripts
RUN sed 's/\$path = "";/\$path = "\/root\/RECON-1.08\/bin";/1' recon.pl > recon.pl.new
RUN mv recon.pl.new recon.pl && chmod uog+x recon.pl

# Install nseg
WORKDIR /root
RUN wget -r ftp://ftp.ncbi.nih.gov/pub/seg/nseg/
WORKDIR /root/ftp.ncbi.nih.gov/pub/seg/nseg/
RUN make && mv nseg /usr/local/bin && mv nmerge /usr/local/bin
WORKDIR /root
RUN rm -rf ftp.ncbi.nih.gov

# Install RepeatScout
RUN wget http://www.repeatmasker.org/RepeatScout-1.0.5.tar.gz
RUN tar zxf RepeatScout-1.0.5.tar.gz
WORKDIR RepeatScout-1
RUN make && mv build_lmer_table /usr/local/bin && mv RepeatScout /usr/local/bin
WORKDIR /root
RUN rm -rf RepeatScout-1*

# Install TRF
RUN wget https://tandem.bu.edu/cgi-bin/trf/trf.download.pl?fileselect=30
RUN mv trf.download.pl?fileselect=30 /usr/local/bin/trf
RUN chmod uog+x /usr/local/bin/trf

# Install RepeatMasker
WORKDIR /root
RUN git clone -b 'v1.0.4-beta' --single-branch --depth 1 https://github.com/vetscience/Tools
RUN mv RepeatMasker-open-4-0-7.tar.gz /usr/local
WORKDIR /usr/local
RUN wget http://www.repeatmasker.org/RepeatMasker-open-4-0-7.tar.gz
RUN tar zxf RepeatMasker-open-4-0-7.tar.gz && rm -rf RepeatMasker-open-4-0-7.tar.gz
WORKDIR RepeatMasker
RUN wget http://www.dfam.org/web_download/Release/Dfam_2.0/Dfam.hmm.gz
RUN zcat Dfam.hmm.gz > Libraries/Dfam.hmm && mv Libraries /root && ln -s /var/spool/cwl/Libraries .
RUN rm Dfam.hmm.gz
RUN cp /root/Tools/Cwl/repeatmasker/RepeatMaskerConf/DateRepeats .
RUN cp /root/Tools/Cwl/repeatmasker/RepeatMaskerConf/DupMasker .
RUN cp /root/Tools/Cwl/repeatmasker/RepeatMaskerConf/ProcessRepeats .
RUN cp /root/Tools/Cwl/repeatmasker/RepeatMaskerConf/RepeatMasker .
RUN cp /root/Tools/Cwl/repeatmasker/RepeatMaskerConf/RepeatMaskerConfig.pm .
RUN cp /root/Tools/Cwl/repeatmasker/RepeatMaskerConf/RepeatProteinMask .
RUN cp -r /root/Tools/Cwl/repeatmasker/RepeatMaskerConf/util .
RUN cp /root/Tools/Cwl/repeatmasker/inputSoundex .
RUN perl -MCPAN -e 'install Text::Soundex' < inputSoundex

# Data configuration
WORKDIR /root
RUN wget http://www.repeatmasker.org/libraries/RepeatMaskerMetaData-20170127.tar.gz
RUN tar zxf RepeatMaskerMetaData-20170127.tar.gz && rm -rf RepeatMaskerMetaData-20170127.tar.gz

RUN cp Tools/Cwl/repeatmasker/initReps.sh . && cp Tools/Cwl/repeatmasker/repeatMasker.sh .
RUN chmod uog+x initReps.sh && chmod uog+x repeatMasker.sh
RUN cp Tools/Cwl/repeatmasker/inputRepeatMasker .

WORKDIR /root
ENV PATH=/usr/local/RepeatMasker:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV TERM=xterm
RUN chmod uog+x /root
ENTRYPOINT ["/root/repeatMasker.sh"]
