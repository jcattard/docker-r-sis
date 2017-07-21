#!/bin/bash

# INPUT
# $1 path to initial paramaters set
# $2 path to initial state
# $3 path to csv output
# $4 path to all state save
# $5 nbr of step to do
# $6 start time
# $7 nbr simulation

# set number of parallel computations
parallel=4

# clean workdir
rm p_* x_p_* y_* xnew_* &> /dev/null
# split input files
split -l2 $1 p_
split -l2 $2 x_p_

# compute parallel simulations
NPROC=0
for i in $(ls p_*)
do
    echo "running rscript with $i"
    Rscript /home/user01/sis.R -p $i -x x_$i -y y_$i -X xnew_$i -n $5 -i $6 &> /dev/null &
    NPROC=$(($NPROC+1))
    if [ "$NPROC" -ge $parallel ]
    then
	wait
	NPROC=0
    fi
done
wait

# merge observations
cat y_* > $3
# merge new states
cat xnew_* > $4
