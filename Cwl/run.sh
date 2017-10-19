#!/bin/bash
# Builds docker image, start mysql docker server and runs an example
docker stop SqlDocker
docker rm SqlDocker
docker images | grep -E "orthomcl|mysql" | awk '{print $3}' | while read line; do docker rmi -f $line; done
docker images | grep none | awk '{print $3}' | while read line; do docker rmi -f $line; done
docker build -t orthomcl orthomcl
docker run --name SqlDocker -e MYSQL_ROOT_PASSWORD=password -d mysql:5.7.19
export MYSQLIP=`docker inspect SqlDocker | grep '"IPAddress"' | head -1 | awk '{print $2}' | sed 's/"//g;s/,//1'`
echo $MYSQLIP
sed "s/127.0.0.1/$MYSQLIP/1" orthomcl.template.yml > orthomcl.yml
cwltool orthomcl.cwl orthomcl.yml
# Direct docker command is not tested
docker run  -v /home/pakorhon/Images/Test/Data:/root/Tools/Data --user=510:1001 orthomcl /root/Tools/orthoMcl -d /root/Tools/Data -i bxinjiang.pts.fa -l BXI -T 24 -a 172.17.0.4
