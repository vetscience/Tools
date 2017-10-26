#!/usr/bin/env python

import os, sys, random, multiprocessing
import argparse, ConfigParser
from multiprocessing import Process
from Utils import Base
from os import walk

#################################################
def args():
    parser = argparse.ArgumentParser('usage: python %prog [options] -g ref.fa')
    parser.add_argument('-i', '--input', dest='cfile', help='Configfile', metavar='CONFIG', default='')
    parser.add_argument('-d', '--dir', dest='wd', help='Working directory', metavar='DIR', default='Assembly')
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
    def __init__(self, workDir, pCnt):
        '''
        '''
        Base.__init__(self)
        self.wd = workDir
        self.createDir(workDir)
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
    def createFastaAndFastqReads(self, readsH5, readsFa, readsFq):
        '''
        '''
        retVal = False
        if len(readsH5) == 0:
            print >> sys.stderr, "# FATAL ERROR: cannot find PacBio reads. Exiting ..."
            sys.exit(-1)
        if (len(readsFa) != len(readsH5) or len(readsFq) != len(readsH5)) and len(readsH5) > 0:
            with open("%s/runs.sh" %self.wd, 'w') as handle:
                for read in readsH5:
                    handle.write("dextract %s > %s.fasta\n" %(read, read))
                    handle.write("dextract -q %s > %s.fastq\n" %(read, read))
                    retVal = True
            self.shell("parallel -j %d < %s/runs.sh" %(self.pCnt, self.wd))
        return retVal


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

    pCnt = int(opts.pCnt)
    if pCnt == 0:
        pCnt = int(float(multiprocessing.cpu_count()) / 2.0 + 0.5)

    dextractor = Dextractor(opts.wd, pCnt)
    with open(opts.wd + "/log.txt", "w") as logHandle:
        dextractor.setLogHandle(logHandle)
        dextractor.logTime("Start")

        # Check the existence of PacBio and Illumina reads given in config file
        readDirs = dextractor.readSection(config, "PacBioReadDirs")
        readsH5, readsFa, readsFq = dextractor.pbReads(readDirs)
        if dextractor.createFastaAndFastqReads(readsH5, readsFa, readsFq) == True:
            readsH5, readsFa, readsFq = dextractor.pbReads(readDirs)
        readDirs = dextractor.readSection(config, "IlluminaPeReads")
        readsIllu = dextractor.illuReads(readDirs) # Prints a warning if Illumina reads are not found.
        dextractor.logTime("End")


#################################################
if __name__ == "__main__":
    main()
