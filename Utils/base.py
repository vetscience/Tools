#!/usr/bin/env python

'''
Oct 10, 2017: Pasi Korhonen, The University of Melbourne

Simplifies system calls, logs and pipe interaction.

'''
import sys, os, time
import shlex, subprocess, errno
from threading import Timer

###############################################################################
class Base:
    '''
    '''
    ###########################################################################
    def __init__(self, logHandle = subprocess.PIPE):
        '''
        '''
        self.fname = None
        self.handle = None
        self.log = logHandle


    ###########################################################################
    def ropen(self, fname):
        ''' Allow one to read data either from pipe or file
        '''
        self.handle = None
        self.fname = fname
        if fname == '-':
            self.handle = sys.stdin.readlines()
        else:
            self.handle = open(fname, 'r')
        return self.handle


    ###########################################################################
    def rclose(self):
        ''' Allows one to close the file if reading from pipe is allowed
        '''
        if self.fname != '-': self.handle.close()


    ###########################################################################
    def createDir(self, mydir):
        '''Creates a directory for the assembly if one does not exist yet.
        '''
        try:
            os.makedirs(mydir)
            #print "\nCreated directory %s" %mydir
        except OSError, e:
            #print "\nDirectory %s was already existing" %mydir
            if e.errno != errno.EEXIST:
                raise

    ###########################################################################
    def isNumber(self, myStr):
        '''
        '''
        retVal = True
        try:
            float(myStr)
        except ValueError:
            retVal = False
        return retVal


    ###########################################################################
    def logTime(self, myStr = ""):
        '''
        '''
        if myStr != "": myStr = myStr + ':'
        rt = time.localtime()
        self.log.write("\n------------------------------------------------------------\n")
        self.log.write("%s %d,%d,%d %d:%d:%d\n" %(myStr, rt.tm_year, rt.tm_mon, rt.tm_mday, rt.tm_hour, rt.tm_min, rt.tm_sec))
        self.log.write("------------------------------------------------------------\n\n")


    ###########################################################################
    def setLogHandle(self, handle = subprocess.PIPE):
        ''' Log handle should be always set because a full buffer can cease processing
        '''
        self.log = handle


    ###########################################################################
    def shell(self, myStr, doPrint = True, myStdout = False, ignoreFailure = False):
        '''Runs given command in a shell and waits for the command to finish.
        '''
        if doPrint == True:
            print >> sys.stderr, "# " + myStr # is printed as comment line which is easy to remove
        if myStdout == True:
            p = subprocess.Popen(myStr, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
        else:
            p = subprocess.Popen(myStr, stdout=self.log, stderr=subprocess.STDOUT, shell=True)
        retVal = p.wait()
        if retVal != 0 and ignoreFailure == False:
            print "FAILED (%d): %s" %(retVal, myStr)
            sys.exit(retVal)
        return p


    ###########################################################################
    def _kill_proc(self, proc, timeout):
        '''
        '''
        timeout["value"] = True
        proc.kill()


    ###########################################################################
    def run(self, cmd, timeoutSec = None, doPrint = True, myStdout = True, ignoreFailure = False):
        ''' Runs given command in a subprocess and wait for the command to finish.
            Retries 3 times if timeout is given.
        '''
        retryCnt = 0
        while retryCnt < 3:
            if doPrint == True:
                print >> sys.stderr, "# " + cmd # is printed as comment line which is easy to remove
            if myStdout == True:
                proc = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            else:
                proc = subprocess.Popen(shlex.split(cmd), stdout=self.log, stderr=subprocess.PIPE)
            if timeoutSec != None:
                timeout = {"value": False}
                timer = Timer(timeoutSec, self._kill_proc, [proc, timeout])
                timer.start()
            stdout, stderr = proc.communicate()
            if timeoutSec != None:
                timer.cancel()
            if (proc.returncode > 1 or proc.returncode < 0) and ignoreFailure == False:
                retryCnt += 1
                if retryCnt >= 3: # Tries three times
                    print >> sys.stderr, "## FAILED(%d): %s. Three failures. Exiting ..." %(proc.returncode, cmd)
                    sys.exit(proc.returncode)
                print >> sys.stderr, "## FAILED(%d): %s. Retrying ..." %(proc.returncode, cmd)
                time.sleep(120) # Wait 2 minutes before the next try
            else:
                break
        return proc
