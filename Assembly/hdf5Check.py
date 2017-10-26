#!/usr/bin/env python

import os, sys, random, multiprocessing
import argparse, ConfigParser
from multiprocessing import Process
from Utils import Base
from os import walk

#################################################
def args():
    parser = argparse.ArgumentParser('python %prog ')
    parser.add_argument('-i', '--input', dest='cfile', help='Configfile', metavar='CONFIG', default='')
    parser.add_argument('-d', '--dir', dest='data', help='Data directory', metavar='DATADIR', default='Data')
    parser.add_argument('-r', '--res', dest='res', help='Result directory', metavar='RESDIR', default='Results')
    parser.add_argument('-T', '--threads', dest='pCnt', help='Number of parallel threads (default is half of the capacity but >= 1)', metavar='THREADS', default='0')
   
    arguments = parser.parse_args()
    if arguments.cfile == '':
        print '\nConfig file has to be given:'
        parser.print_help()
        sys.exit(1)
    return arguments

#################################################
class Dextractor(Base):
    '''
    '''
    #################################################
    def __init__(self, dataDir, pCnt):
        '''
        '''
        Base.__init__(self)
        self.wd = dataDir
        self.createDir(dataDir)
        self.pCnt = int(pCnt)


    #################################################
    def checkFileExistence(self, files):
        '''
        '''
        for item in files:
            if os.path.exists(item) == False:
                print "# FATAL ERROR: file %s, given in configuration file, does not exist. Exiting..." %item
                sys.exit(-1)


    #################################################
    def pbReads(self, readDirs):
        '''
        '''
        readsH5, readsFa, readsFq = set(), set(), set()
        for readDir in readDirs:
            #print readDir
            for (dirpath, dirnames, filenames) in walk(readDir[0], followlinks = True):
                #print dirpath, dirnames, filenames
                for filename in filenames:
                    if "bax.h5" in filename[-6:]:
                        readsH5.add("%s/%s" %(dirpath, filename))
                    if ".fasta" in filename[-6:]:
                        readsFa.add("%s/%s" %(dirpath, filename))
                    if ".fastq" in filename[-6:]:
                        readsFq.add("%s/%s" %(dirpath, filename))
        return sorted(readsH5), sorted(readsFa), sorted(readsFq)


    #################################################
    def createFastaAndFastqReads(self, resDir, readsH5, readsFa, readsFq):
        '''
        '''
        if len(readsH5) == 0:
            print >> sys.stderr, "# FATAL ERROR: cannot find PacBio reads. Exiting ..."
            sys.exit(-1)
        #if (len(readsFa) != len(readsH5) or len(readsFq) != len(readsH5)) and len(readsH5) > 0:
        with open("%s/runs.sh" %resDir, 'w') as handle:
            for read in readsH5:
                resRead = read.split("/")[-1]
                handle.write("dextract %s > %s/%s.fasta\n" %(read, resDir, resRead))
                handle.write("dextract -q %s > %s/%s.fastq\n" %(read, resDir, resRead))
        self.shell("parallel -j %d < %s/runs.sh" %(self.pCnt, resDir))


    #################################################
    def illuReads(self, pairs):
        '''
        '''
        reads = []
        for pair in pairs:
            self.checkFileExistence(pair)
            reads.append(pair)
        return reads


#################################################
def main():
    '''
    '''
    opts = args()
    config = ConfigParser.ConfigParser()
    config.read(opts.cfile)

    base.shell("rm -rf %s" %opts.res)
    base.createDir(opts.res)

    pCnt = int(opts.pCnt)
    if pCnt == 0:
        pCnt = int(float(multiprocessing.cpu_count()) / 2.0 + 0.5)

    dextractor = Dextractor(opts.data, pCnt)
    with open(opts.res + "/log.txt", "w") as logHandle:
        dextractor.setLogHandle(logHandle)
        dextractor.logTime("Start")
        # Check the existence of PacBio and Illumina reads given in config file
        readDirs = dextractor.readSection(config, "PacBioReadDirs")
        readsH5, readsFa, readsFq = dextractor.pbReads(readDirs)
        dextractor.createFastaAndFastqReads(opts.res, readsH5, readsFa, readsFq)
        readDirs = dextractor.readSection(config, "IlluminaPeReads") # Prints a warning if section for Illumina reads is not found.
        readsIllu = dextractor.illuReads(readDirs) # Stops execution if reported reads are not found.
        dextractor.logTime("End")


#################################################
if __name__ == "__main__":
    main()
