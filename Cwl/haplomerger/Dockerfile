FROM ubuntu:16.04
RUN apt-get update && apt-get install -y wget perl python parallel git
WORKDIR /root
RUN wget https://github.com/mapleforest/HaploMerger2/releases/download/HaploMerger2_20161205/HaploMerger2_20161205.tar.gz
RUN tar xvfz HaploMerger2_20161205.tar.gz
RUN git clone -b 'v1.0.4-beta' --single-branch --depth 1 https://github.com/vetscience/Tools
RUN cp Tools/Cwl/haplomerger/base.py . && cp Tools/Cwl/haplomerger/fasta.py . && cp Tools/Cwl/haplomerger/haploMerger.py .
ENV HAPLOMERGER_DIR=/root/HaploMerger2_20161205
ENV PATH=/var/spool/cwl/workDir/bin:/root/HaploMerger2_20161205/lastz_1.02.00_unbuntu64bit:/root/HaploMerger2_20161205/chainNet_jksrc20100603_ubuntu64bit:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN chmod uog+x /root && chmod uog+x /root/haploMerger.py
ENTRYPOINT ["/root/haploMerger.py"]
