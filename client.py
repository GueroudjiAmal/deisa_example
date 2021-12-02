import time
from dask_interface import Initialization
from  dask_interface import CoupleDask
import numpy as np
import pandas as pd
import yaml
import dask.array as da
from dask.distributed import performance_report, Event
from dask_ml.decomposition import IncrementalPCA
import joblib

with open(r'config.yml') as file:
    data = yaml.load(file, Loader=yaml.FullLoader)
    Sworkers = data["workers"]
scheduler_info = 'scheduler.json'
C = Initialization(Sworkers, scheduler_info)
C.client.get_versions(check=True)


arrays = C.get_data()
with performance_report(filename="dask-report.html"):
    #gt = arrays["global_t"]
    gv = arrays["global_v"]
    for k in range(gv.shape[0]):
        with joblib.parallel_backend('dask'):
            pca=IncrementalPCA(n_components=2,copy=False, svd_solver='randomized')
            pca.fit(gv[k,:,:]) 
            print([pca.explained_variance_ , pca.singular_values_])