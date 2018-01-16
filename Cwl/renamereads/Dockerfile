FROM ubuntu:16.04
#RUN apt-get update && apt-get install -y perl
WORKDIR /root
COPY renamereads.sh .
RUN chmod uog+x renamereads.sh /root
ENTRYPOINT ["/root/renamereads.sh"]
