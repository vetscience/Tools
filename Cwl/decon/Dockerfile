FROM ubuntu:16.04
RUN apt-get update && apt-get install -y python perl
WORKDIR /root
COPY decon.sh .
COPY convertFasta.py .
COPY fasta.py .
COPY base.py .
COPY names.dmp.gz .
COPY nodes.dmp.gz .
COPY taxtreelabel.pl .
RUN gunzip names.dmp.gz
RUN gunzip nodes.dmp.gz
RUN chmod uog+x decon.sh
RUN chmod uog+x /root
#ENV PATH=/root/centrifuge-1.0.3-beta:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENTRYPOINT ["/root/decon.sh"]
