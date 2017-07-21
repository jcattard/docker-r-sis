#!/bin/bash

# INPUT
# $1 path to initial paramaters set
# $2 path to csv output
# $3 number of parallel (deprecated)

# set number of parallel computations
if [ -z "$3" ]
then
    parallel=4
else
    parallel=$3
fi

# clean workdir
rm p_* y_* &> /dev/null

# split input file
split -l2 $1 p_

# compute parallel simulations
NPROC=0
for i in $(ls p_*)
do
    echo "running rscript with $i"
    Rscript /home/user01/sis.R -p $i -y y_$i &> /dev/null &
    NPROC=$(($NPROC+1))
    if [ "$NPROC" -ge $parallel ]
    then
	wait
	NPROC=0
    fi
done
wait

# merge observations
cat y_* > $2
