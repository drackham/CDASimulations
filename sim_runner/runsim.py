#!/usr/bin/python

from peewee import *
from sims_db import *
from argparse import ArgumentParser
import datetime
import subprocess
import os

def main(compute_box, script_path, script_filename, results_root):

  print "Checking for simulations that need to be run..."

  # check to see if there are aany simulations without a started_at date scheduled for the given compute_box
  available = Sims_tracker.select().where(Sims_tracker.started_at >> None, Sims_tracker.server == compute_box).count()x # http://peewee.readthedocs.io/en/latest/peewee/querying.html#query-operators 

  # select all un-analyzed simulations and catch if none available  
  if available > 0:
    for sim in Sims_tracker.select().where(Sims_tracker.started_at >> None, Sims_tracker.server == compute_box):
      
      # create the results directory
      results_path = results_root + "/%s" % str(sim.id)
      
      print "Creating results directory"

      if not os.path.exists(results_path):
        os.makedirs(results_path)

      args = (str(sim.id), sim.dataset, sim.model, str(sim.N), str(sim.max_cores),
              str(sim.iter), str(sim.max_cores), results_path)

      print "Message: Executing simulation " + str(sim.id)

      command = "nohup Rscript " + script_path + script_filename + \
      " %s %s %s %s %s %s %s %s" % args + "| tee " + results_path + "/log.txt"
      
      # set the started_at time and save 
      sim.started_at = datetime.datetime.now()
      sim.save()

      # Run the command
      p = subprocess.Popen(command, shell=True)
      
      # Wait for the process to finish
      os.waitpid(p.pid, 0)

      # mark completed_at time if successful
      sim.completed_at = datetime.datetime.now()
      sim.save()

      print "Message: Simulation " + str(sim.id) + " is complete!"

  else:
    # 
    print "Error: There are no available simulations to run."

# this runs the main function
if __name__ == "__main__":
  parser = ArgumentParser()

  # arguments
  parser.add_argument("-b", "--box", dest="compute_box")
  parser.add_argument("-s", "--script", dest="script_filename", help="script to execute", required=True)

  args = parser.parse_args()

  if args.compute_box == 'sir-thomas':
    script_path = '/home/dave/dev/dcmsims/'
    results_root = '/home/dave/dev/Research-Project'
  elif args.compute_box == 'hilbert':
    script_path = '/home/drackham/dev/dcmsims/'
    results_root = '/home/drackham/Research-Project'
  elif args.compute_box == 'local':
    script_path = '/Users/Dave/dev/dcmsims/'
    results_root = '/Users/Dave/Dropbox/Graduate/Dissertation/DCM-Simulation-Results/Research-Project'
   
  main(args.compute_box, script_path, args.script_filename, results_root)
