#!/usr/bin/python

from peewee import *
from playhouse.sqlite_ext import SqliteExtDatabase
import datetime

db = SqliteExtDatabase('sims.db')

# db model
class BaseModel(Model):
    class Meta:
        database = db

# sim_tracker table schema
class Sims_tracker(BaseModel):
    id = IntegerField(unique=True)
    type = CharField()
    dataset = CharField()
    model = CharField()
    N = IntegerField()
    max_cores = IntegerField()
    iter = IntegerField()
    chains = IntegerField()
    started_at = DateTimeField(null=True, default=None)
    server = CharField(default='sir-thomas', null=True)
    completed_at = DateTimeField(null=True, default=None)
    analyzed = IntegerField(default = 0) # SQLite does not support bool
    notes = BlobField(null=True)

    created_at = DateTimeField(default = datetime.datetime.now())
    deleted_at = DateTimeField(null=True)