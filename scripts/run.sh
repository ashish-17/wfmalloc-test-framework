# this file executes everything
#!/bin/bash

if [ $1 == "clean" ];then
    make -f Makefile.libs clean
    make -f Makefile.bm clean

elif [ $1 == "build" ];then

    # makes the libraries for the allocators and copies them in ../lib
    make -f Makefile.libs  
    # makes the benchmarks
    make -f Makefile.bm 

else

    currentDate=`date +"%m-%d-%Y-%H:%M"`
    mkdir ../outputFiles/$currentDate
    echo "EXECUTING THE BENCHAMARKS"
    echo "Running LinuxScalability"
    ./linuxScalability.sh $currentDate

# to check if actually hoard is running, type printf at line 120 of the file Hoard/src/source/libhoard.cpp  

fi