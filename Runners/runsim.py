#!/usr/bin/python

import subprocess
import pipes
import os
import getpass
import sys, getopt

def main(argv):
  user = getpass.getuser()
  id = ''

# parse the command line parameters
  try:
      opts, args = getopt.getopt(argv,"id",["id="])  # command line parameters defined here, for more see http://www.tutorialspoint.com/python/python_command_line_arguments.htm
  except getopt.GetoptError:
      print 'Usage: runsim.py [-uid=1234]'
      print ""
      sys.exit(2)
  for opt, arg in opts:
      if opt == '-h':  # show help
          print 'Usage: runsim.py [-uid=1234]'
          print " -id  Simulation ID"
          sys.exit()
      elif opt in ("-id", "--id"):
          id = arg
      
  #debug
  print 'user is %s'%user
  print 'id is %s'%id
  sys.exit(0)

# this runs the main function
if __name__ == "__main__":
   main(sys.argv[1:])

#cmd = 'ssh -f dave@192.168.200' "'nohup runSim"