#!/bin/sh

names="deriv gf kin conc watch bbcore vecplay patstim"

for i in $names ; do
  mkdir -p test${i}dat
done

for i in $names ; do
  mpirun -n 1 ./x86_64/special -mpi -c sim_time=100 test${i}.hoc
  cat out${i}.dat | sort -k 1n,1n -k 2n,2n > out_nrn_${i}.spk
  rm out${i}.dat
done

#prepare coreneuron executable

for i in $names ; do
  if [ "${i}" = "patstim" ]
  then
          mpirun -n 1 ./x86_64/special-core -mpi -d test${i}dat -e 100 --pattern patstim.spk
  else
          mpirun -n 1 ./x86_64/special-core -mpi -d test${i}dat -e 100
  fi
  cat out.dat > out_cn_${i}.spk
  rm out.dat
done

for i in $names ; do
  DIFF=$(diff -w -q out_nrn_${i}.spk out_cn_${i}.spk)
  if [ "$DIFF" != "" ] 
  then
      echo "Test ${i} failed"
  fi
done
