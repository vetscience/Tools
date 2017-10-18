DB#!/bin/bash
rm -rf Results
python ../orthoMcl.py -d Data -i bxinjiang.pts.fa -l BXI -p 1 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30
export RES1=`diff Results/groups.txt groups1.txt`
if [ "$RES1" == "" ]; then echo "1: ok"; else echo "1: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fa -l BXI -p 2 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30 2> res2.txt
export RES2=`grep "Fatal" res2.txt`
if [ "$RES2" == "### Fatal error: FASTA sequence identifiers are not unique in BXI.fasta. Exiting..." ]; then echo "2: ok"; else echo "2: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fa -l BXI -p 1 -T 24 -a 128.0.0.1 -e 1e-5 -s 0.5 -m 30 > res3.txt
export RES3=`grep "FAILED" res3.txt`
if [ "$RES3" == "FAILED (1): mysql -h 128.0.0.1 -P 3306 --protocol tcp --user=root --password=password < Results/dropDb.sql" ]; then echo "3: ok"; else echo "3: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fa -l BXI -p 1 -T 24 -a 127.0.0.1 -e 1e-30 -s 0.5 -m 30
export RES4=`diff Results/groups.txt groups4.txt`
if [ "$RES4" == "" ]; then echo "4: ok"; else echo "4: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fa -l BXI -p 1 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.9 -m 30
export RES5=`diff Results/groups.txt groups5.txt`
if [ "$RES5" == "" ]; then echo "5: ok"; else echo "5: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fa -l BXI -p 1 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 100
export RES6=`diff Results/groups.txt groups6.txt`
if [ "$RES6" == "" ]; then echo "6: ok"; else echo "6: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fa -l BXI -p 1 -T -1 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30 > res7.txt
export RES7=`grep "FAILED" res7.txt`
if [ "$RES7" == "FAILED (1): blastp -db goodProteins.fasta -query goodProteins.fasta -outfmt 6 -evalue 1e-5 -num_threads -1 > Results/goodProteins.blast" ]; then echo "7: ok"; else echo "7: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fasta -l BXI -p 1 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30 2> res8.txt
export RES8=`grep "Fatal" res8.txt`
if [ "$RES8" == "### Fatal error: file Data/bxinjiang.pts.fasta not found. Exiting..." ]; then echo "8: ok"; else echo "8: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.cds.fa -l BXI -p 2 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30 2> res9.txt
export RES9=`grep "Fatal" res9.txt`
if [ "$RES9" == "### Fatal error: files have to all be amino acids. Exiting..." ]; then echo "9: ok"; else echo "9: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.cds.fa -l BXI -p 1 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30 -n
export RES10=`diff Results/groups.txt groups10.txt`
if [ "$RES10" == "" ]; then echo "10: ok"; else echo "10: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fa -l BXI -p 1 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30 -n 2> res11.txt
export RES11=`grep "Fatal" res11.txt`
if [ "$RES11" == "### Fatal error: files have to all be nucleotides. Exiting..." ]; then echo "11: ok"; else echo "11: nok"; fi;


python ../orthoMcl.py -d Data -i bxinjiang.pts.fa,blintan.pts.fa -l BXI,BLI -p 1,1 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30
export RES12=`diff Results/groups.txt groups12.txt`
if [ "$RES12" == "" ]; then echo "12: ok"; else echo "12: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fasta,blintan.pts.fa -l BXI,BLI -p 1,1 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30 2> res13.txt
export RES13=`grep "Fatal" res13.txt`
if [ "$RES13" == "### Fatal error: file Data/bxinjiang.pts.fasta not found. Exiting..." ]; then echo "13: ok"; else echo "13: nok"; fi;
python ../orthoMcl.py -d Data -i bxinjiang.pts.fa,blintan.pts.not.unique.fa -l BXI,BLI -p 1,2 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30 2> res14.txt
export RES14=`grep "Fatal" res14.txt`
if [ "$RES14" == "### Fatal error: FASTA sequence identifiers are not unique in BLI.fasta. Exiting..." ]; then echo "14: ok"; else echo "14: nok"; fi;

python ../orthoMcl.py -d Data -i bxinjiang.pts.too.long.fa -l BXI -p 1 -T 24 -a 127.0.0.1 -e 1e-5 -s 0.5 -m 30 2> res15.txt
export RES15=`grep "Fatal" res15.txt`
if [ "$RES15" == "### Fatal error: FASTA sequence identifier BXI|bxinjiang_757_1s_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx is too long in BXI.fasta. Exiting..." ]; then echo "15: ok"; else echo "15: nok"; fi;
