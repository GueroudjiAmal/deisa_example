from dask_interface import Deisa
from dask.distributed import performance_report, wait 

# Scheduler file name and configuration file
scheduler_info = 'scheduler.json'
config_file = 'config.yml'

# Initialize the Deisa 
Deisa = Deisa(scheduler_info, config_file)

# Get client
client = Deisa.get_client()

# Get data descriptor as a list of Deisa arrays object
arrays = Deisa.get_deisa_arrays()
#or
# Get data descriptor as a dict of Dask array
#arrays = Deisa.get_dask_arrays()

# Select data
gt = arrays["global_t"][...]
print(gt, flush=True)

# Check contract
arrays.check_contract()

# Sign contract
arrays.validate_contract()

def Derivee(F, dx):
    """
    First Derivative
       Input: F        = function to be derivate
              dx       = step of the variable for derivative
       Output: dFdx = first derivative of F
    """
    c0 = 2. / 3.
    dFdx = c0 / dx * (F[3: - 1] - F[1: - 3] - (F[4:] - F[:- 4]) / 8.)
    return dFdx

# py-bokeh is needed if you wanna see the perf report 
with performance_report(filename="dask-report.html"):
    
    # Construct a lazy task graph 
    cpt = Derivee(gt, 1)
    
    # Submit the task graph to the scheduler
    s = client.persist(cpt, release=True)
    
    # Print the result, note that "s" is a future object, to get the result of the computation, we call `s.result()` to retreive it. 
    
    # del data
    del gt
    
    # wait until computation is done
    k = wait(s)
    print("Done")
                          
