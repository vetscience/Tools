#!/bin/bash

# Stop and remove all running instances of mysql dockers
docker stop SqlDocker
docker rm SqlDocker
docker images | grep mysql | awk '{print $3}' | while read line; do docker rmi -f $line; done

# 1: Run orthomcl without mysql
cwltool ../orthomcl.cwl orthomcl1.yml 2> res1.txt
export RES1=`grep "FAILED" res1.txt`
if [ "$RES1" == "FAILED (1): mysql -h 172.17.0.2 -P3306 --protocol tcp --user=root --password=password < Results/version.sql" ]; then echo "1: ok"; else echo "1: nok"; fi;
#if [ "$RES1" == "FAILED (1): mysql -h 172.17.0.2 -P3306 --protocol tcp --user=root --password=password < Results/dropDb.sql" ]; then echo "1: ok"; else echo "1: nok"; fi;

# 2: Start mysql server version < 5.7.6: Fails in docker because perl dbi calls the user with non-defined ip address 172.17.0.3
docker run --name SqlDocker -e MYSQL_ROOT_PASSWORD=password -d mysql:5.6.37
cwltool ../orthomcl.cwl orthomcl1.yml 2> res2.txt
export RES2=`grep "FAILED" res2.txt`
if [ "$RES2" == "FAILED (1): mysql -h 172.17.0.2 -P3306 --protocol tcp --user=root --password=password < Results/version.sql" ]; then echo "2: ok"; else echo "2: nok"; fi;
#if [ "$RES2" == "FAILED (2): orthomclInstallSchema Results/orthomcl.config" ]; then echo "2: ok"; else echo "2: nok"; fi;
docker stop SqlDocker
docker rm SqlDocker
docker images | grep mysql | awk '{print $3}' | while read line; do docker rmi -f $line; done

# 3: Start mysql server version > 5.7.6
docker run --name SqlDocker -e MYSQL_ROOT_PASSWORD=password -d mysql:5.7.19
cwltool ../orthomcl.cwl orthomcl1.yml
export RES3=`diff Results/groups.txt ../Test/groups1.txt`
if [ "$RES3" == "" ]; then echo "3: ok"; else echo "3: nok"; fi;
docker stop SqlDocker
docker rm SqlDocker
docker images | grep mysql | awk '{print $3}' | while read line; do docker rmi -f $line; done

# 4: Start mysql server version 8.x.x. Fail because used commands in orthomclLoadBlast is no longer supported in this version
docker run --name SqlDocker -e MYSQL_ROOT_PASSWORD=password -d mysql:8.0.3
cwltool ../orthomcl.cwl orthomcl1.yml 2> res4.txt
export RES4=`grep "FAILED" res4.txt`
if [ "$RES4" == "FAILED (1): mysql -h 172.17.0.2 -P3306 --protocol tcp --user=root --password=password < Results/version.sql" ]; then echo "4: ok"; else echo "4: nok"; fi;
#if [ "$RES4" == "FAILED (2): orthomclLoadBlast Results/orthomcl.config Results/similarSequences.txt" ]; then echo "4: ok"; else echo "4: nok"; fi;
docker stop SqlDocker
docker rm SqlDocker
docker images | grep mysql | awk '{print $3}' | while read line; do docker rmi -f $line; done

