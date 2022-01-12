#!/bin/bash

DIR=$PWD

### prescript.py  is used to create the configuration file that is shared betwwen the simulation and the Dask cluster
# sys.argv[1] : global_size.height
# sys.argv[2] : global_size.width
# sys.argv[3] : parallelism.height
# sys.argv[4] : parallelism.width
# sys.argv[5] : generation 
# sys.argv[6] : nworkers

source $WORKDIR/spack/share/spack/setup-env.sh
spack load cmake@3.22.1
spack load pdiplugin-deisa
spack load pdiplugin-mpi

NWORKER=2

PARALLELISM1=2
PARALLELISM2=1

DATASIZE1=100000
DATASIZE2=80000

GENERATION=5

mkdir -p $WORKDIR/Deisa
WORKSPACE=$(mktemp -d -p $WORKDIR/Deisa/ Dask-run-XXX)
cd $WORKSPACE
cp $DIR/simulation.yml $DIR/*.py  $DIR/Script.sh $DIR/Coupling.sh  $DIR/*.c $DIR/CMakeLists.txt  .
pdirun cmake .
make -B simulation
echo Running $WORKSPACE 
`which python` prescript.py $DATASIZE1 $DATASIZE2 $PARALLELISM1 $PARALLELISM2 $GENERATION $NWORKER 
sbatch Script.sh 
