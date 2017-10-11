#!/usr/bin/env python

'''
Oct 10, 2017: Pasi Korhonen, The University of Melbourne

Simplifies running orthoMCL with a wrapper and pre-checks the known
formatting issues with FASTA headers to avoid failure in later stages of the run.


'''

import os, sys, optparse, getpass
from multiprocessing import Process, Pipe
from Utils import Base, Fasta

#################################################
def options():
    parser = optparse.OptionParser('usage: %prog -i "proteins1.fa proteins2.fa ... proteinsN.fa" -l "lab1 lab2 ... labN" -p "1 3 ... 1" -e 1e-5 -s 0.6')
    parser.add_option('-d', '--dir', dest='wd', help='Working directory', metavar='DIR', default='TmpOrthoMcl')
    parser.add_option('-i', '--filenames', dest='filenames', help='Names of the files of species containing the proteins', metavar='FILES', default='')
    parser.add_option('-l', '--labels', dest='labs', help="Labels for each species", metavar='LABELS', default='')
    parser.add_option('-p', '--positions', dest='positions', help="Default positions of unique identifier in FASTA header separated by |. Default position is 1 for all.", metavar='POSITIONS', default='')
    parser.add_option('-T', '--threads', dest='pCnt', help='Number of parallel threads (default 24)', metavar='THREADS', default='24')
    parser.add_option('-e', '--evalue', dest='evalue', help="E-value used at blast. Default is 1e-5. Use 1e-X format only!", metavar='EVALUE', default='1e-5')
    parser.add_option('-s', '--similarity', dest='sim', help="Required similarity (0 .. 1). Default if 0.5", metavar='SIM', default='0.5')
    parser.add_option('-m', '--minlen', dest='minlen', help="Allowed minimum lenght of a protein. Default is 20.", metavar='MINLEN', default='20')
    parser.add_option('-b', '--noblast', dest='skipBlast', action='store_true', help="Skip BLAST", default=False)
    options, args = parser.parse_args()
    if options.filenames == '' or options.labs == '':
        parser.print_help()
        print '\nE.g.: orthoMcl -i "proteome1.fa proteome2.fa" -l "Tax Tvi" -p "4 4" -e 1e-5 -s 0.5'
        print "Results will be found in %s/Results directory in groups.txt file." %options.wd
        print "Note! The labels must be exactly 3 characters long and preferrably start with an upper case character."
        sys.exit(-1)
    return options


#################################################
def checkResidue(fastaFile):
    '''
    '''
    retVal = "nucleotides"
    try:
        limit = 100
        fasta = Fasta(fastaFile)
        for i in xrange(fasta.cnt()):
            if i > limit: break
            seq = fasta.seq(i).upper()
            for item in seq:
                if item not in ['A', 'T', 'C', 'G', 'N']:
                    retVal = "amino acids"
                    break
    except IOError:
        print >> sys.stderr, "### Fatal error: file %s not found. Exiting..." %fastaFile
        sys.exit(-1)
    return retVal


#################################################
def checkUniqueIds(fastaFile):
    '''
    '''
    fasta = Fasta(fastaFile)
    if fasta.cnt() != len(set(fasta.headers)):
        print >> sys.stderr, "### Fatal error: FASTA sequence identifiers are not unique in %s. Exiting..." %fastaFile
        print >> sys.stderr, "### Probably position for this file is given wrong..."
        sys.exit(-1)


#################################################
def createOrthoMclConfigFile(wd, userName, eValue, similarity):
    '''
    '''
    eValue = eValue.split('e')[1]
    similarity = int(float(similarity) * 100.0)
    handle = open("%s/orthomcl.config" %wd, 'w')
    handle.write("# this config assumes a mysql database named 'orthomcl'.  adjust according\n")
    handle.write("# to your situation.\n")
    handle.write("dbVendor=mysql\n")
    handle.write("dbConnectString=dbi:mysql:ortho%s\n" %userName)
    handle.write("dbLogin=ortho%s\n" %userName)
    handle.write("dbPassword=password\n")
    handle.write("similarSequencesTable=SimilarSequences\n")
    handle.write("orthologTable=Ortholog\n")
    handle.write("inParalogTable=InParalog\n")
    handle.write("coOrthologTable=CoOrtholog\n")
    handle.write("interTaxonMatchView=InterTaxonMatch\n")
    handle.write("percentMatchCutoff=%d\n" %similarity)
    handle.write("evalueExponentCutoff=%s\n" %eValue)
    handle.write("oracleIndexTblSpc=NONE\n")
    handle.close()


#################################################
def createMySqlScripts(wd, userName):
    '''
    '''
    handle = open("%s/createDb.sql" %wd, 'w')
    handle.write("CREATE USER IF NOT EXISTS 'ortho%s'@'localhost' IDENTIFIED BY 'password';\n" %userName)
    handle.write("CREATE DATABASE ortho%s;\n" %userName)
    handle.write("GRANT SELECT,INSERT,UPDATE,DELETE,CREATE VIEW,CREATE,INDEX,DROP on ortho%s.* TO ortho%s@localhost;\n" %(userName, userName))
    handle.close()
    handle = open("%s/dropDb.sql" %wd, 'w')
    handle.write("drop database if exists ortho%s;\n" %userName)
    handle.close()


#################################################
def callShell(base, cmdStr, dummy = None):
    '''
    '''
    base.shell(cmdStr)


#################################################
def main():
    '''
    '''
    opts = options() # files contains exactly two PE files

    pCnt = int(opts.pCnt)
    eValue = opts.evalue
    similarity = opts.sim
    minlen = opts.minlen
    files = opts.filenames.split()
    labels = opts.labs.split()
    if len(labels) != len(set(labels)):
        print >> sys.stderr, "### Fatal error: duplicate labels found. Exiting..."
        sys.exit(-1)
    if len(files) != len(set(files)):
        print >> sys.stderr, "### Fatal error: duplicate fasta file names found. Exiting..."
        sys.exit(-1)
    positions = None
    if opts.positions != "":
        positions = opts.positions.split()
    if positions == None:
        positions = []
        for i in xrange(len(files)):
            positions.append("1")
    if len(files) != len(labels):
        print >> sys.stderr, "### Fatal error: number of files does not match with the number of labels. Exiting..."
        sys.exit(-1)
    if len(positions) != len(labels):
        print >> sys.stderr, "### Fatal error: number of labels does not match with the number of positions of the ids. Exiting..."
        sys.exit(-1)
    for lab in labels:
        if len(lab) != 3:
            print >> sys.stderr, "### Fatal error: labels have to be exactly three characters long. Exiting..."
            sys.exit(-1)

    base = Base()
    wd = "%s/Results" %opts.wd
    wdFasta = "%s/Fasta" %wd
    wdAdds = "%s/Adds" %wd
    base.createDir(wd)
    logHandle = open("%s/log.txt" %wd, 'w')
    base.setLogHandle(logHandle)
    base.createDir(wdFasta)
    userName = getpass.getuser()
    createOrthoMclConfigFile(wd, userName, eValue, similarity)
    createMySqlScripts(wd, userName)

    requiredMolType = "amino acids"
    for myFile in files:
        molType = checkResidue(myFile)
        if requiredMolType != molType:
            print >> sys.stderr, "### Fatal error: files have to all be amino acids. Exiting..."
            print >> sys.stderr, "### File %s failed and was %s." %(myFile, molType)
            sys.exit(-1)

    base.shell("rm -f %s/*.fasta" %wd)
    base.shell("rm -f %s/*.fasta" %wdFasta)

    for i in xrange(len(files)):
        myLab, myFile, myPos = labels[i], files[i], positions[i]
        if myFile == "%s.fasta" %myLab:
            print >> sys.stderr, "### Fatal error: orthoMCL produces same filenames that you already have. Please rename your fasta files e.g. to .fa instead of .fasta. Exiting..."
            sys.exit(-1)
        base.shell("orthomclAdjustFasta %s %s %s" %(myLab, myFile, myPos))
        checkUniqueIds("%s.fasta" %myLab)
        base.shell("mv -f %s.fasta %s" %(myLab, wdFasta))

    if opts.skipBlast == False:
        base.shell("orthomclFilterFasta %s %s 20" %(wdFasta, minlen))
        base.shell("mv -f poorProteins.* %s" %wd)

    # Blast all against all
    if opts.skipBlast == False:
        base.shell("makeblastdb -in goodProteins.fasta -dbtype prot")
        base.shell("cp goodProteins.fasta %s/" %wd)
    blastEvalue = eValue
    if float(blastEvalue) < 1e-5: blastEvalue = "1e-5"
    if opts.skipBlast == False:
        base.shell("blastp -db goodProteins.fasta -query goodProteins.fasta -outfmt 6 -evalue %s -num_threads %d > %s/goodProteins.blast" %(blastEvalue, pCnt, wd))
    base.shell("""awk '{if ($11<=%s) print $0}' %s/goodProteins.blast | grep -v "^#" > %s/filtered.blast""" %(eValue, wd, wd))
    #base.shell("mv -f goodProteins.* %s" %wd)

    base.shell("orthomclBlastParser %s/filtered.blast %s > %s/similarSequences.txt" %(wd, wdFasta, wd))
    # Prepare database
    base.shell("mysql --user=root --password=password < %s/dropDb.sql" %wd)
    base.shell("mysql --user=root --password=password < %s/createDb.sql" %wd)
    base.shell("orthomclInstallSchema %s/orthomcl.config" %wd)
    base.shell("orthomclLoadBlast %s/orthomcl.config %s/similarSequences.txt" %(wd, wd))
    # Identify potential orthologs
    base.shell("orthomclPairs %s/orthomcl.config %s/orthomclPairs.log cleanup=no" %(wd, wd))
    base.shell("rm -rf pairs")
    base.shell("rm -rf %s/pairs" %wd)
    base.shell("orthomclDumpPairsFiles %s/orthomcl.config" %wd)
    base.shell("mv -f pairs %s" %wd)
    # Group the orthologs
    base.shell("mcl mclInput --abc -I 2.0 -o mclOutput")
    base.shell("orthomclMclToGroups OWN_ 1 < mclOutput > %s/groups.txt" %wd)
    base.shell("mv -f mclInput %s" %wd)
    base.shell("mv -f mclOutput %s" %wd) 
    logHandle.close()
       

#################################################
if __name__ == "__main__":
    main()
