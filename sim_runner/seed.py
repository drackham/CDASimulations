#!/usr/bin/python

from sims_db import *
import datetime


db.connect()
db.create_tables([Sims_tracker])

Sims_tracker.create(id=-2, type='local test', dataset='R_DINA_SimpleQ.500', model='R-DINA-Non-Hierarchical.jags',
                          N=500, max_cores=1, iter=100, chains=1, server='local')

Sims_tracker.create(id=-1, type='sir-thomas test', dataset='R_DINA_SimpleQ.500', model='R-DINA-Non-Hierarchical.jags',
                          N=50, max_cores=1, iter=100, chains=1, server='sir-thomas')

########################### Low noise sims ###########################
Sims_tracker.create(id=1, type='Low noise 50', dataset='R_DINA_SimpleQ_LN.50', model='R-DINA-Non-Hierarchical.jags',
                          N=50, max_cores=4, iter=20000, chains=4, server=None)

Sims_tracker.create(id=2, type='Low noise 200', dataset='R_DINA_SimpleQ_LN.200', model='R-DINA-Non-Hierarchical.jags',
                          N=200, max_cores=4, iter=20000, chains=4, server=None)

Sims_tracker.create(id=3, type='Low noise 1000', dataset='R_DINA_SimpleQ_LN.1000', model='R-DINA-Non-Hierarchical.jags',
                          N=1000, max_cores=4, iter=20000, chains=4, server=None)

########################### High noise sims ###########################
Sims_tracker.create(id=4, type='High noise 50', dataset='R_DINA_SimpleQ_HN.50', model='R-DINA-Non-Hierarchical.jags',
                          N=50, max_cores=4, iter=20000, chains=4, server=None)

Sims_tracker.create(id=5, type='High noise 200', dataset='R_DINA_SimpleQ_HN.200', model='R-DINA-Non-Hierarchical.jags',
                          N=200, max_cores=4, iter=20000, chains=4, server=None)

Sims_tracker.create(id=6, type='High noise 1000', dataset='R_DINA_SimpleQ_HN.1000', model='R-DINA-Non-Hierarchical.jags',
                          N=1000, max_cores=4, iter=20000, chains=4, server=None)

########################### Uninformative sims ###########################
Sims_tracker.create(id=7, type='Uninformative 50', dataset='R_DINA_SimpleQ_UnInform.50', model='R-DINA-Non-Hierarchical.jags',
                          N=50, max_cores=4, iter=20000, chains=4, server=None)

Sims_tracker.create(id=8, type='Uninformative 200', dataset='R_DINA_SimpleQ_UnInform.200', model='R-DINA-Non-Hierarchical.jags',
                          N=200, max_cores=4, iter=20000, chains=4, server=None)

Sims_tracker.create(id=9, type='Uninformative 1000', dataset='R_DINA_SimpleQ_UnInform.1000', model='R-DINA-Non-Hierarchical.jags',
                          N=1000, max_cores=4, iter=20000, chains=4, server=None)
