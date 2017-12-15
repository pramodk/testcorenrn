#!/bin/bash
set -e -x

# cmake .. -DADDITIONAL_MECHPATH=$HOME/models/testcorenrn/mod
# make -j

M=$HOME/models/testcorenrn

P='mpiexec -n 6 bin/coreneuron_exec -mpi'
P='bin/coreneuron_exec'

t_end=20
t_chkpt=6

# standard spikes in $t_end ms
rm -f out[0-9].dat
$P -e $t_end -d $M/testvecplaydat --cell-permute 0
cat out[0-9].dat > temp
sortspike temp std${t_end}
diff -w $M/outvecplay.std std${t_end}

# checkpoint at $t_chkpt
rm -f out[0-9].dat
rm -f checkpoint/*
$P -e $t_chkpt -d $M/testvecplaydat --cell-permute 0 --checkpoint checkpoint
cat out[0-9].dat > temp
sortspike temp temp${t_chkpt}

# run checkpoint to $t_end
rm -f out[0-9].dat
$P -e $t_end -d $M/testvecplaydat --restore checkpoint --cell-permute 0
cat out[0-9].dat > temp
sortspike temp temp${t_chkpt}-${t_end}
cat temp${t_chkpt} temp${t_chkpt}-${t_end} > temp0-${t_end}
meld std${t_end} temp0-${t_end}
