#!/bin/bash

DIR=$PWD

### prescript.py  is used to create the configuration file that is shared betwwen the simulation and the Dask cluster
# sys.argv[1] : global_size.height
# sys.argv[2] : parallelism.height
# sys.argv[3] : generation 
# sys.argv[4] : gmax
# sys.argv[5] : nworkers

source $WORKDIR/spack/share/spack/setup-env.sh
spack load cmake@3.22.1
spack load pdiplugin-deisa
spack load pdiplugin-mpi

NWORKER=4

PARALLELISM1=2
PARALLELISM2=1

#DATASIZE1=133120
#DATASIZE2=122880

DATASIZE1=100000
DATASIZE2=80000

#DATASIZE1=66560
#DATASIZE2=61440

GENERATION=10

mkdir -p $WORKDIR/Deisa
WORKSPACE=$(mktemp -d -p $WORKDIR/Deisa/ Dask-run-XXX)
cd $WORKSPACE
cp $DIR/simulation.yml $DIR/*.py  $DIR/Script.sh $DIR/Coupling.sh  $DIR/*.c $DIR/CMakeLists.txt  .
pdirun cmake .
make -B simulation
echo Running $WORKSPACE 
`which python` prescript.py $DATASIZE1 $DATASIZE2 $PARALLELISM1 $PARALLELISM2 $GENERATION $NWORKER 
sbatch Script.sh 