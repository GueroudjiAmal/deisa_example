#!/bin/bash

#SBATCH -J dask-cluster
#SBATCH -A dask_coupling
#SBATCH --time=01:00:00
#SBATCH --nodes=11
#SBATCH --partition=cpu_med
#SBATCH --exclusive

echo SLURM_JOB_NODELIST :  $SLURM_JOB_NODELIST 

NDASK=5
NSIMU=$(($SLURM_NNODES - $NDASK))
NWORKER=$(($NDASK - 1))
NPROC=36
NPROCPNODE=6
NWORKERPNODE=10

SCHEFILE=scheduler.json

#source ~/.bashrc

module purge 
module load cmake/3.16.2/intel-19.0.3.199 gcc/9.2.0/gcc-4.8.5 openmpi/3.1.5/gcc-9.2.0
module load anaconda3/2021.05/gcc-9.2.0
source activate PhDEnv
module unload anaconda3/2021.05/gcc-9.2.0
echo $CONDA_PREFIX
PYTH=$CONDA_PREFIX/bin/python
echo $PYTH is used 

srun --nodes=11 -l free
srun  --nodes=11 -l rm -rf /tmp/*dask*
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gpfs/workdir/gueroudjia/.conda/envs/PhDEnv/lib/
env
echo launching Scheduler 
# Launch Dask Scheduler in a 1 Node and save the connection information in $SCHEFILE
srun --relative=0  --cpu-bind=verbose --ntasks=1 --nodes=1 -l \
    --output=scheduler.log \
    $PYTH `which dask-scheduler` \
    --interface ib0 \
    --scheduler-file=$SCHEFILE   &

while ! [ -f $SCHEFILE ]; do
    sleep 3
    echo -n .
done

echo Connect Master Client  
$PYTH client.py &
client_pid=$!

echo Scheduler booted, launching workers 

# Launch Dask workers in the rest of the allocated nodes 
srun --relative=1  --nodes=$NWORKER  --cpu-bind=verbose  -l \
     --output=worker-%t.log \
     $PYTH `which dask-worker` \
     --interface ib0 \
     --local-directory /tmp \
     --nprocs $NWORKERPNODE \
     --scheduler-file=${SCHEFILE} &
     
     
# Run the OpenMP-MPI executable
echo Running Simulation 


${HOME}/local/bin/pdirun srun --relative=$NDASK --nodes=$NSIMU --ntasks=$NPROC --ntasks-per-node=$NPROCPNODE  -l ./simulation  &

wait $client_pid

#Cleaning

#$PYTH postscript.py

