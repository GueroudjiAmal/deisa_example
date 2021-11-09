import time
from dask_interface import Initialization
from  dask_interface import CoupleDask
import numpy as np
import pandas as pd
import yaml
import dask.array as da
from dask.distributed import performance_report

with open(r'config.yml') as file:
    data = yaml.load(file, Loader=yaml.FullLoader)
    Sworkers = data["workers"]
scheduler_info = 'scheduler.json'
C = Initialization(Sworkers, scheduler_info)
C.client.get_versions(check=True)

arrays = C.get_data()
with performance_report(filename="dask-report.html"):
    gt = arrays["global_t"]
    gv = arrays["global_v"]
    print(gt)
    print(gv)
    deux = 2*gv.mean() + (gv.max() - gt.min())/2
    deux.visualize(filename='deux.svg')
    d = deux.compute()
    print(d)
    
    em = da.empty(shape=gt.shape, chunks=gt.chunks)
    em2 = da.empty(shape=gv.shape, chunks=gv.chunks)
    print("em ", em)
    print("em2 ",em2)
    deuxm = 2*em2.mean() + (em2.max() - em.min())/2
    deuxm.visualize(filename='deuxmm.svg')