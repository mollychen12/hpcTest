#!/bin/bash
#Divide the cores

nProcs=(2 4 8 10 16 20 32 40)

for iProcs in ${nProcs[*]};
do
 folderName=run_ncores_${iProcs}
 echo "total using core number is ${iProcs}"
 echo "prepare case ${folderName}..."
 cp -r motorBike ${folderName}
 cd ${folderName}

 #set &config the case
 sed -i "s/method.*/method scotch;/" system/decomposeParDict
 sed -i "s/numberOfSubdomains.*/numberOfSubdomains ${iProcs};/" system/decomposeParDict
 
 decomposePar >>decomp.log
 mpirun -np ${iProcs} --bind-to core -report-bindings simpleFoam -parallel>>${folderName}.log
 cd ..
 echo "Writing to log"
 times=$(grep Execution ${folderName}/${folderName}.log | tail -n 3 | cut -d " " -f 3)
 echo ${iProcs} ${times}>>ncore_exetime.log
 done
 
nThreads=(48 64 80)
for jProcs in ${nThreads[*]};
do
 folderName=run_ncores_${jProcs}
 echo "total using core number is ${jProcs}"
 echo "prepare case ${folderName}..."
 cp -r motorBike ${folderName}
 cd ${folderName}

 #set &config the case
 sed -i "s/method.*/method scotch;/" system/decomposeParDict
 sed -i "s/numberOfSubdomains.*/numberOfSubdomains ${jProcs};/" system/decomposeParDict
 
 decomposePar >>decomp.log
 mpirun -np ${jProcs} --bind-to core:overload-allowed -report-bindings simpleFoam -parallel>>${folderName}.log

 cd ..
 
 echo "Writing to log"
 times=$(grep Execution ${folderName}/${folderName}.log | tail -n 3 | cut -d " " -f 3)
 echo ${jProcs} ${times}>>ncore_exetime.log
 done
 
