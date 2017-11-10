#!/usr/bin/env python
'''
Oct 10, 2017: Pasi Korhonen, The University of Melbourne

A very basic FASTA file reader.

'''

from __future__ import print_function
import sys
from . import base

###############################################################################
class Fasta(base.Base):
    '''
    '''
    ###########################################################################
    def __init__(self, fname = None):
        '''
        '''
        self.fname = fname
        self.headers = []
        self.seqs = []
        self.idxs = None # Gives an option to reorder the sequences
        self.totalLen = 0 # Total length of all sequences
        if fname != None:
            self._read()
            self._check()
            self.idxs = [i for i in xrange(len(self.headers))]


    ###########################################################################
    def cnt(self):
        ''' Returns the number of sequences
        '''
        return len(self.headers)


    ###########################################################################
    def header(self, i):
        '''
        '''
        return self.headers[self.idxs[i]]


    ###########################################################################
    def seq(self, i):
        '''
        '''
        return self.seqs[self.idxs[i]]


    ###########################################################################    
    def __repr__(self):
        '''
        '''
        for i in xrange(len(self.headers)):
            print(">%s" %self.header(i))
            print(self.seq(i))


    ###########################################################################    
    def _read(self):
        '''
        '''
        with open(self.fname) as handle:
            cnt, seq, found = 0, "", False
            for line in handle:
                line = line.strip()
                if len(line) > 0:
                    if line[0] == '>':
                        if found == True:
                            self.seqs.append(seq)
                            self.totalLen += len(seq)
                        self.headers.append(line[1::])
                        seq = ""
                        found = True
                    else:
                        seq += line
                    cnt += 1
            if found == True:
                self.seqs.append(seq)
                self.totalLen += len(seq)


    ###########################################################################    
    def _check(self):
        '''
        '''
        if len(self.headers) != len(self.seqs):
            print("## WARNING! Fasta: header count (%d) != sequence count (%d)" %(len(self.headers), len(self.seqs)), file=sys.stderr)
        
