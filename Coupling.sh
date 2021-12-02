#!/bin/bash

DIR=$PWD

## prescript.py  
# sys.argv[1] : global_size.height
# sys.argv[2] : parallelism.height
# sys.argv[3] : generation 
# sys.argv[4] : gmax
# sys.argv[5] : nworkers

module purge 
module load cmake/3.16.2/intel-19.0.3.199 gcc/9.2.0/gcc-4.8.5 openmpi/3.1.5/gcc-9.2.0
module load anaconda3/2021.05/gcc-9.2.0
source activate PhDEnv
module unload anaconda3/2021.05/gcc-9.2.0

echo $CONDA_PREFIX
PYTH=$CONDA_PREFIX/bin/python
echo $PYTH is used 


NWORKER=32
VERSIONS=("MPI")

for GMAX in 100
do 
    for VERSION in ${VERSIONS[*]}
    do
        case $VERSION in 
            MPI)
                PARALLELISM1=20
                PARALLELISM2=16
                ;;
            *)
                echo je ne sais pas moi ; exit
        esac
        for DATA in  3
        do
            case $DATA in 
            
                3) 
                    DATASIZE1=65560
                    DATASIZE2=65536
                    GENERATION=10
                    TIMESTEP=1
                    ;;
                    
                 4)
                    DATASIZE1=2000
                    DATASIZE2=1600
                    GENERATION=2
                    TIMESTEP=1
                    ;;

                 512)
                    DATASIZE1=262144
                    DATASIZE2=262144
                    GENERATION=20
                    TIMESTEP=350
                    ;;
                 *)
                    echo je ne sais pas moi ; exit
            esac   
            mkdir -p $WORKDIR/Step2test/$VERSION/$GMAX/$DATA/
            WORKSPACE=$(mktemp -d -p $WORKDIR/Step2test/$VERSION/$GMAX/$DATA/ Dask-run-XXX)
            cd $WORKSPACE
            cp $DIR/simulation.yml $DIR/*.py  $DIR/Script.sh $DIR/Coupling.sh  $DIR/*.c $DIR/CMakeLists.txt  .
            ${HOME}/local/bin/pdirun cmake .
            make -B simulation
            echo Running $WORKSPACE 
            $PYTH prescript.py $DATASIZE1 $DATASIZE2 $PARALLELISM1 $PARALLELISM2 $GENERATION $GMAX $NWORKER $TIMESTEP
            sbatch Script.sh 
        done
    done 
done