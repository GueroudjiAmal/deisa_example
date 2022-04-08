import yaml
from dask_interface import Initialization
import dask
import dask.array as da
from dask.distributed import performance_report

# Get configuration
with open(r'config.yml') as file:
    data = yaml.load(file, Loader=yaml.FullLoader)
    Sworkers = data["workers"]

# Scheduler file name 
scheduler_info = 'scheduler.json'

# Initialize the Deisa Adaptor 
Adaptor = Initialization(Sworkers, scheduler_info)

# Check if client version is compatible with scheduler version
Adaptor.client.get_versions(check=True)

# Get data descriptor as a dict of Dask arrays
arrays = Adaptor.get_data()

#Derivee@virginie

def Derivee(F, dx, periodic=0):
    """
    First Derivative
       Input: F        = function to be derivate
              dx       = step of the variable for derivative
              periodic = 1 if F is periodic
       Output: dFdx = first derivative of F
    """
    nx   = len(F)
    #dFdx = 0. * F
    c0 = 2. / 3.
    dFdx = c0 / dx * (F[3:nx - 1] - F[1:nx - 3] - (F[4:nx] - F[0:nx - 4]) / 8.)
    c1 = 4. / 3.
    c2 = 25. / 12.
    c3 = 5. / 6.
    """
    if (periodic == 0):
        dFdx[0]      = (-F[4] / 4. + c1 * F[3] - 3. * F[2] + 4. * F[1] - c2 * F[0]) / dx
        dFdx[1]      = (F[4] / 12. - F[3] / 2. + F[2] / c0 - c3 *  F[1] - F[0] / 4.) / dx
        dFdx[nx - 1] = (F[nx - 5] / 4. - c1 * F[nx - 4] + 3. * F[nx - 3] - 4. * F[nx - 2] + c2 * F[nx - 1]) / dx
        dFdx[nx - 2] = (F[nx - 1] / 4. + c3 * F[nx - 2] - F[nx - 3] / c0 + F[nx - 4] / 2. - F[nx - 5] / 12.) / dx
    else:
        dFdx[0]      = c0 / dx * (F[1] - F[nx - 1] - (F[2] - F[nx - 2]) / 8.)
        dFdx[1]      = c0 / dx * (F[2] - F[0] - (F[3] - F[nx - 1]) / 8.)
        dFdx[nx - 1] = c0 / dx * (F[0] - F[nx - 2] - (F[1] - F[nx - 3]) / 8.)
        dFdx[nx - 2] = c0 / dx * (F[nx - 1] - F[nx - 3] - (F[0] - F[nx - 4]) / 8.)
    """
    return dFdx
# py-bokeh is needed if you wanna see the perf report 
with performance_report(filename="dask-report.html"):
    # Get the Dask array global_t
    gt = arrays["global_t"]
    
    print(gt.chunks)
    # Construct a lazy task graph 
    cpt = Derivee(gt, 1)
    # Submit the task graph to the scheduler
    s = Adaptor.client.compute(cpt, release=True)
    # Print the result, note that "s" is a future object, to get the result of the computation, we call `s.result()` to retreive it.  
    print(s.result())
                          
