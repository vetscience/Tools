#!/usr/bin/env python3

'''
Oct 26, 2017: Pasi Korhonen, The University of Melbourne

Wrapper for trimmomatic to support multiple read libraries in command line interface
given result directory


'''
from __future__ import print_function
import os, sys, random, argparse, multiprocessing
from multiprocessing import Process
from os import walk, path
from Utils import base

#################################################
def args():
    parser = argparse.ArgumentParser('python %prog ')
    parser.add_argument('-1', '--readsPe1', dest='readsPe1', help='Reads PE1 libraries (separated by commas)', metavar='READSPE1', default='')
    parser.add_argument('-2', '--readsPe2', dest='readsPe2', help='Reads PE2 libraries (separated by commas)', metavar='READSPE2', default='')
    parser.add_argument('-P', '--phredspe', dest='phredPe', help='Phred values for PE libraries (default for all libraries is PHRED value 33)', metavar='PHREDSPE', default='')
    parser.add_argument('-s', '--readsSe', dest='readsSe', help='Reads SE libraries (separated by commas)', metavar='READSSE', default='')
    parser.add_argument('-S', '--phredsse', dest='phredSe', help='Phred values for SE libraries (default for all libraries is PHRED value 33)', metavar='PHREDSSE', default='')
    parser.add_argument('-a', '--adapters', dest='adapters', help='FASTA file containing the adapter sequences', metavar='ADAPTERS', default='')
    parser.add_argument('-l', '--leading', dest='leading', help='Required PHRED quality for leading nucleotides', metavar='LCNT', default='25')
    parser.add_argument('-t', '--trailing', dest='trailing', help='Required PHRED quality for trailing nucleotides', metavar='TCNT', default='25')
    parser.add_argument('-c', '--crop', dest='crop', help='Number of nucleotides to keep (from start)', metavar='CROP', default='')
    parser.add_argument('-H', '--headcrop', dest='headCrop', help='Number of nucleotides to remove (from start)', metavar='HEADCROP', default='')
    parser.add_argument('-m', '--minlen', dest='minLen', help='Minimum length of resulting reads to keep', metavar='MINLEN', default='40')
    parser.add_argument('-C', '--clip', dest='clip', help='Adapter clipping: X:Y:Z, in which X=seed mismatch cnt, Y=palindrome read alignment accuracy, Z=accuracy of any adapter)', metavar='CLIP', default='2:30:10')
    parser.add_argument('-w', '--window', dest='window', help='Sliding window: X:Y, in which X=size, Y=required quality', metavar='WINDOW', default='4:25')
    parser.add_argument('-L', '--log', dest='log', help='Log file', metavar='LOGFILE', default='trim.log')
    parser.add_argument('-T', '--threads', dest='pCnt', help='Number of parallel threads (default is half of the capacity but >= 1)', metavar='THREADS', default='0')
    return parser.parse_args()


#################################################
class Trimmomatic(base.Base):
    '''
    '''
    #############################################
    def __init__(self):
        '''
        '''
        base.Base.__init__(self)
        self.setLogHandle(open("log.txt", "w"))


    #############################################
    def processAndThreadCnts(self, pCnt, runCnt):
        '''
        '''
        processCnt, threadCnt = 1, pCnt
        if pCnt % 4 == 0 and runCnt >= 4:
            processCnt, threadCnt = 4, pCnt / 4
        elif pCnt % 2 == 0 and runCnt >= 2:
            processCnt, threadCnt = 2, pCnt / 2
        elif pCnt % 2 == 1:
            pCnt -= 1
            if pCnt % 4 == 0 and runCnt >= 4:
                processCnt, threadCnt = 4, pCnt / 4
            elif pCnt % 2 == 0 and runCnt >= 2:
                processCnt, threadCnt = 2, pCnt / 2
        return int(processCnt), int(threadCnt)


    #############################################
    def checkFileExistence(self, readFiles):
        '''
        '''
        missing = []
        for myFile in readFiles:
            if path.isfile(myFile) != True:
                missing.append(myFile)
        return missing


#################################################
def main():
    '''
    '''
    opts = args()

    trimmomatic = Trimmomatic()
    trimmomatic.logTime("Start")

    readsPe1, readsPe2 = opts.readsPe1.strip().split(','), opts.readsPe2.strip().split(',')
    if readsPe1[0] == '': readsPe1 = []
    if readsPe2[0] == '': readsPe2 = []
    phredPe = ['33' for i in range(len(readsPe1))]
    if len(phredPe) > 0:
        if opts.phredPe != '':
            phredPe = opts.phredPe.strip().split(',')
        for phred in phredPe:
            if phred not in ['33', '64']:
                print("# FATAL! Given phred value %s for PE reads does not match the allowed 33 or 64. Exiting ..." % (phred), file=sys.stderr) 
                sys.exit(-1)
        if len(readsPe1) != len(phredPe):
            print("# FATAL! Length of given PHRED list differs from the number of PE read libraries. Exiting ...", file=sys.stderr) 
            sys.exit(-1)
    readsSe = opts.readsSe.strip().split(',')
    if readsSe[0] == '': readsSe = []
    phredSe = ['33' for i in range(len(readsSe))]
    if len(phredSe) > 0:
        if opts.phredSe != '':
            phredSe = opts.phredSe.strip().split(',')
        for phred in phredSe:
            if phred not in ['33', '64']:
                print("# FATAL! Given phred value %s for SE reads does not match the allowed 33 or 64. Exiting ..." % (phred), file=sys.stderr) 
                sys.exit(-1)
        if len(readsSe) != len(phredSe):
            print("# FATAL! Length of given PHRED list differs from the number of SE read libraries. Exiting ...", file=sys.stderr)
            sys.exit(-1)
    if len(readsPe1) == 0 and len(readsSe) == 0:
        print("# FATAL! No read libraries given. Exiting ...", file=sys.stderr)
        sys.exit(-1)

    readFiles = trimmomatic.checkFileExistence(readsPe1)
    readFiles += trimmomatic.checkFileExistence(readsPe2)
    readFiles += trimmomatic.checkFileExistence(readsSe)
    if len(readFiles) > 0:
        print('## Following read files are not found. Exiting ...', file=sys.stderr)
        for readFile in readFiles:
            print('# %s' %(readFile), file=sys.stderr)
        sys.exit(-1)
    adapterFile = opts.adapters
    if path.isfile(adapterFile) != True:
        print('## Adapter file %s does not exist. Exiting ...' %adapterFile, file=sys.stderr)
        sys.exit(-1)
    leading, trailing = opts.leading, opts.trailing
    cropStr, headCropStr = '', ''
    if opts.crop != '':
        cropStr = opts.crop
    if opts.headCrop != '':
        headCropStr = opts.headCrop
    minLen = opts.minLen
    clipVals = opts.clip
    windowVals = opts.window
    logFile = opts.log

    pCnt = int(opts.pCnt)
    if pCnt == 0:
        pCnt = int(float(multiprocessing.cpu_count()) / 2.0 + 0.5)
    pCnt, threadCnt = trimmomatic.processAndThreadCnts(pCnt, len(readsPe1) + len(readsSe))

    # Convert hdf5 reads to FASTA and FASTQ formats into the given result directory
    with open("runs.sh", 'w') as handle:
        for i in range(len(readsPe1)):
            fName1, fName2 = readsPe1[i], readsPe2[i]
            fNameRes1 = "%s/res.%s" %('/'.join(fName1.split("/")[:-1]), fName1.split("/")[-1])
            fNameRes2 = "%s/res.%s" %('/'.join(fName2.split("/")[:-1]), fName2.split("/")[-1])
            fNameUnpaired1 = "%s/res.unpaired.%s" %('/'.join(fName1.split("/")[:-1]), fName1.split("/")[-1])
            fNameUnpaired2 = "%s/res.unpaired.%s" %('/'.join(fName2.split("/")[:-1]), fName2.split("/")[-1])
            handle.write("trimmomatic PE -phred%s -threads %s %s %s %s %s %s %s ILLUMINACLIP:%s:%s LEADING:%s TRAILING:%s SLIDINGWINDOW:%s MINLEN:%s %s %s -trimlog %s\n" %(phredPe[i], threadCnt, fName1, fName2, fNameRes1, fNameRes2, fNameUnpaired1, fNameUnpaired2, adapterFile, clipVals, leading, trailing, windowVals, minLen, cropStr, headCropStr, logFile))
        for i in range(len(readsSe)):
            fName = readsSe[i]
            fNameUnpaired = "%s/res.unpaired.%s" %('/'.join(fName.split("/")[:-1]), fName.split("/")[-1])
            handle.write("trimmomatic SE -phred%s -threads %s %s %s ILLUMINACLIP:%s:%s LEADING:%s TRAILING:%s SLIDINGWINDOW:%s MINLEN:%s %s %s -trimlog %s\n" %(phredSe[i], threadCnt, fName, fNameUnpaired, adapterFile, clipVals, leading, trailing, windowVals, minLen, cropStr, headCropStr, logFile))

    trimmomatic.shell("parallel -j %d < runs.sh" %pCnt)
    trimmomatic.logTime("End")
    trimmomatic.closeLogHandle()


#################################################
if __name__ == "__main__":
    main()
