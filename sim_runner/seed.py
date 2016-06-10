#!/usr/bin/python

from sims_db import *
import datetime


db.connect()
db.create_tables([Sims_tracker])

# seed = Sims_tracker.create(id=1, data='R_DINA_SimpleQ.500', model='R-DINA-Non-Hierarchical.jags',
#                           N=100, max_cores=1, iter=100, chains=1, results_path = 'foo/bar', 
#                           created_at = datetime.datetime.now())

Sims_tracker.create(id=1, type='Low noise 50', dataset='R_DINA_SimpleQ.500', model='R-DINA-Non-Hierarchical.jags',
                          N=50, max_cores=1, iter=100, chains=1, server='sir-thomas')

Sims_tracker.create(id=2, type='Low Noise 500', dataset='R_DINA_SimpleQ.500', model='R-DINA-Non-Hierarchical.jags',
                          N=500, max_cores=1, iter=100, chains=1, server='sir-thomas')