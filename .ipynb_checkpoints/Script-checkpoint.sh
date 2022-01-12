#!/bin/bash

#SBATCH -J dask-cluster
#SBATCH -A dask_coupling
#SBATCH --time=01:00:00
#SBATCH --nodes=4
#SBATCH --partition=cpu_med
#SBATCH --exclusive

NDASK=3                           # Total number of nodes allocated for dask cluster
NSIMU=$(($SLURM_NNODES - $NDASK)) # Number of nodes allocated for the simulation 
NWORKER=$(($NDASK - 1))           # Number of nodes allocated for the Dask Worker 
NPROC=2                          # Total number of processes
NPROCPNODE=2                     # Number of processes per node
NWORKERPNODE=2                   # Number of Dask workers per node

SCHEFILE=scheduler.json

source $WORKDIR/spack/share/spack/setup-env.sh
spack load pdiplugin-deisa
spack load pdiplugin-mpi
spack load py-bokeh 

# Launch Dask Scheduler in a 1 Node and save the connection information in $SCHEFILE
echo launching Scheduler 
srun --relative=0  --cpu-bind=verbose --ntasks=1 --nodes=1 -l \
    --output=scheduler.log \
    dask-scheduler \
    --interface ib0 \
    --scheduler-file=$SCHEFILE   &

# Wait for the SCHEFILE to be created 
while ! [ -f $SCHEFILE ]; do
    sleep 3
    echo -n .
done

# Connect the client to the Dask scheduler
echo Connect Master Client  
`which python` client.py &
client_pid=$!

# Launch Dask workers in the rest of the allocated nodes 
echo Scheduler booted, Client connected, launching workers 
srun --relative=1  --nodes=$NWORKER  --cpu-bind=verbose  -l \
     --output=worker-%t.log \
     dask-worker \
     --interface ib0 \
     --local-directory /tmp \
     --nprocs $NWORKERPNODE \
     --scheduler-file=${SCHEFILE} &
     
# Launch the simulation code
echo Running Simulation 
pdirun srun --relative=$NDASK --nodes=$NSIMU --ntasks=$NPROC --ntasks-per-node=$NPROCPNODE  -l ./simulation  &

# Wait for the client process to be finished 
wait $client_pid


