#!/bin/bash
#Divide the cores

nProcs=(2 4 8 16 32 64)
declare -i nSockets_perHost=2
declare -i nCores_perSocket=32
isSharedLoad="false"
declare -a cpu_list
str_comma=,

for iProcs in ${nProcs[*]};
do
 if test 5 = 6 #this if-clause need to be rectified
 #all procs was binding to one socket
 then
 ncore_socket0=$iProcs
 ncore_socket1=0
 str_cpu="0"
 #generate the cpu list and string cpu
 for ((icpu=1;icpu<ncore_socket0;++icpu))
 do
 cpu_list[icpu]=$icpu
 str_cpu=${str_cpu}${str_comma}${cpu_list[icpu]}
 done

 #isSharedLoad = false
 else 
 #all procs was binding to socket evenly
 #if nSockets_perHost >2 using loop given values
let ncore_socket0=iProcs/nSockets_perHost
let ncore_socket1=iProcs/nSockets_perHost
str_cpu="0"
 #generate the cpu list and string cpuls
 for((icpu=1;icpu<ncore_socket0;++icpu))
 do
 cpu_list[$icpu]=$icpu
 str_cpu=${str_cpu}${str_comma}${cpu_list[$icpu]}
 done
 
 for((icpu =0;icpu<ncore_socket1;++icpu))
 do
 index=$((icpu+nCores_perSocket))
 cpu_list[$index]=$((icpu+nCores_perSocket))
 str_cpu=${str_cpu}${str_comma}${cpu_list[$index]}
 done
 fi
 
 echo "The cpu id is ${str_cpu}"
 
 folderName=run_socket0_${ncore_socket0}_socket1_${ncore_socket1}
 echo "total using core number is ${iProcs}"
 echo "prepare case ${folderName}..."
 cp -r motorBike ${folderName}
 cd ${folderName}

 #set &config the case
 sed -i "s/method.*/method scotch;/" system/decomposeParDict
 sed -i "s/numberOfSubdomains.*/numberOfSubdomains ${iProcs};/" system/decomposeParDict
 
 decomposePar >>decomp.log
 mpirun -np ${iProcs} --cpu-list $str_cpu simpleFoam -parallel >>${folderName}.log
 cd ..
 
 echo "Writing to log"
 times=$(grep Execution ${folderName}/${folderName}.log | tail -n 3 | cut -d " " -f 3)
 echo ${ncore_socket0} ${ncore_socket1} ${times}>>ncoreSocket0_ncoreSocket1_exetime.log
 done



