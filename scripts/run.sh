#! /bin/bash

# this file executes everything

if [ $1 == "clean" ];then
    make -f Makefile.libs clean
    make -f Makefile.bm clean

elif [ $1 == "build" ];then

    # makes the libraries for the allocators and copies them in ../lib
    make -f Makefile.libs  
    # makes the benchmarks
    make -f Makefile.bm 

else

    currentDate=`date +"%Y-%m-%d-%H-%M"`
    mkdir ../outputFiles/$currentDate
    
    echo "EXECUTING THE BENCHAMARKS"
    
    echo "Running Linux Scalability"
    ./linuxScalability.sh $currentDate
    
    echo "Running Cache Scratch"
   ./cacheScratch.sh $currentDate

    echo "Running Cache Thrash"
    ./cacheThrash.sh $currentDate

    echo "Running Larson"
    ./larson.sh $currentDate

    echo "PLOTTING THE OUTPUT"
    gnuplot -e "outputDir='../outputFiles/$currentDate'" plot_linuxScalability.gp.sh
    gnuplot -e "outputDir='../outputFiles/$currentDate'" plot_cacheScratch.gp.sh
    gnuplot -e "outputDir='../outputFiles/$currentDate'" plot_cacheThrash.gp.sh
    gnuplot -e "outputDir='../outputFiles/$currentDate'" plot_larson.gp.sh

# to check if actually hoard is running, type printf at line 120 of the file Hoard/src/source/libhoard.cpp  

fi
