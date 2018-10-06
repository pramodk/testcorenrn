#!/bin/sh

names="deriv gf kin conc watch bbcore vecplay patstim"

set -e

for i in $names ; do
    mpirun -n 1 special -mpi -c sim_time=100 -c coreneuron=0 test${i}.hoc
    cat out.dat | sort -k 1n,1n -k 2n,2n > out_nrn_${i}.spk && rm out.dat
    mpirun -n 1 special -mpi -c sim_time=100 -c coreneuron=1 test${i}.hoc
    mv out.dat out_cnrn_${i}.spk
    diff -w -q out_nrn_${i}.spk out_cnrn_${i}.spk
    rm -f out*.spk
done
