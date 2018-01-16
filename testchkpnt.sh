#!/bin/bash
set -e -x

name=testpatstim
name=testwatch
name=testvecplay
name=testbbcore

M=$HOME/models/testcorenrn

t_end=100
t_chkpt=30

CP=1

# nrnivmodl modcore
# nrniv -python  $name.hoc
# sortspike out0.dat ${name}dat/spk1.std
# cmake .. -DADDITIONAL_MECHPATH=$M/modcore -DCMAKE_BUILD_TYPE=DEBUG
# make -j

P='mpiexec -n 6 bin/coreneuron_exec -mpi'
P='bin/coreneuron_exec'

spargs="-d $M/${name}dat"
if test $name = "testpatstim" ; then
  spargs="-d $M/${name}dat --pattern $M/patstim.spk"
fi

# standard spikes in $t_end ms
rm -rf out*.dat
$P -e $t_end $spargs --cell-permute $CP
cat out*.dat > temp
sortspike temp std${t_end}
diff -w $M/${name}dat/spk1.std std${t_end}

# checkpoint at $t_chkpt
rm -rf out*.dat
rm -rf checkpoint/*
$P -e $t_chkpt $spargs --cell-permute $CP --checkpoint checkpoint
cat out*.dat > temp
sortspike temp temp${t_chkpt}

# run checkpoint to $t_end
rm -rf out*.dat
$P -e $t_end $spargs --restore checkpoint --cell-permute $CP
cat out*.dat > temp
sortspike temp temp${t_chkpt}-${t_end}
cat temp${t_chkpt} temp${t_chkpt}-${t_end} > temp0-${t_end}
meld std${t_end} temp0-${t_end}
