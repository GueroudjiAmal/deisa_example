#!/bin/bash

DIR=$PWD

### prescript.py  is used to create the configuration file that is shared betwwen the simulation and the Dask cluster
# sys.argv[1] : global_size.height
# sys.argv[2] : global_size.width
# sys.argv[3] : parallelism.height
# sys.argv[4] : parallelism.width
# sys.argv[5] : generation 
# sys.argv[6] : nworkers

ml load gcc/9.2.0/gcc-4.8.5  openmpi/4.0.2/gcc-9.2.0  cmake/3.16.2/gcc-9.2.0 
source $WORKDIR/spack/share/spack/setup-env.sh
spack env activate deisa-ruche
spack load pdiplugin-deisa
spack load pdiplugin-mpi

NWORKER=16

PARALLELISM1=4
PARALLELISM2=4

DATASIZE1=16384
DATASIZE2=16384

GENERATION=20

mkdir -p $WORKDIR/Deisa
WORKSPACE=$(mktemp -d -p $WORKDIR/Deisa/ Dask-run-XXX)
cd $WORKSPACE
cp $DIR/simulation.yml $DIR/*.py  $DIR/Script.sh $DIR/Launcher.sh  $DIR/*.c $DIR/CMakeLists.txt  .
CC=gcc CXX=g++ FC=gfortran pdirun cmake .
make -B simulation
echo Running $WORKSPACE 
`which python` prescript.py $DATASIZE1 $DATASIZE2 $PARALLELISM1 $PARALLELISM2 $GENERATION $NWORKER 
sbatch Script.sh 
