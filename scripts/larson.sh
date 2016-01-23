# Assumption: Current date is provided as an argument
# A folder with the same name as the provided argument has to be present in ../outputFilesFolder

#!/bin/bash

configFile="../configurations/larson"

bmPath="../benchmarks/bin"

bmName="larson"

outputFile="../outputFiles/$1/outputLarson" 

argumentsMeaning="<nThreads> <numBlocks> <minObjectSize> <maxObjectSize> <timeSlice> <glibcmalloc> <wfmalloc> <hoard> <jemalloc>"

allocatorLibPath="../lib"

i=0

while read line
do
	if [ $i == 0 ]; then
		nThreadsTemp=$line
	elif [ $i == 1 ]; then
		nBlocksTemp=$line
	elif [ $i == 2 ]; then
		minObjSizeTemp=$line
	elif [ $i == 3 ]; then
		maxObjSizeTemp=$line
	elif [ $i == 4 ]; then
		timeSliceTemp=$line
	fi
	(( i++ ))
done < $configFile


IFS=' '
read -a nThreads <<< "$nThreadsTemp"
read -a nBlocks <<< "$nBlocksTemp"	
read -a minObjSize <<< "$minObjSizeTemp"
read -a maxObjSize <<< "$maxObjSizeTemp"
read -a timeSlice <<< "$timeSliceTemp"


echo "Going to execute" $bmName "on" configFile
echo $argumentsMeaning > $outputFile


for nBlocksIndex in "${nBlocks[@]}"
do
    for minObjSizeIndex in "${minObjSize[@]}"
    do
	for maxObjSizeIndex in "${maxObjSize[@]}"
	do
    	    for timeSliceIndex in "${timeSlice[@]}"
	    do
		threadIndex=1
		while [ $threadIndex -le ${nThreads[0]} ]
		do
	    	    c=0  # 0 => glibc malloc, 1 => wfmalloc, 2 => hoard
	    	    output="$threadIndex $nBlocksIndex $minObjSizeIndex $maxObjSizeIndex $timeSliceIndex"
	    	    while [ $c -le 3 ]
	    	    do
                	if [ $c == 2 ]; then
                    	    export LD_PRELOAD="$allocatorLibPath/libhoard.so"
		        elif [ $c == 3 ]; then
                            export LD_PRELOAD="$allocatorLibPath/libjemalloc.so"
		        else
                    	    unset LD_PRELOAD
                	fi
	        	temp="$c $threadIndex $nBlocksIndex $minObjSizeIndex $maxObjSizeIndex $timeSliceIndex"  
                	result=`$bmPath/$bmName $temp`
			# to report some sort of crash
			if [ ! $result ]; then
                    	    result=-1
                	fi
                	echo "$c allocator with threads = $threadIndex, nBlocks = $nBlocksIndex, minObjSize = $minObjSizeIndex, maxObjSize = $maxObjSizeIndex, timeSlice = $timeSliceIndex gave throughput = $result"
			output="$output $result"
	        	(( c++ ))      
	    	    done
            	    unset LD_PRELOAD
#	    	    work=$(( threadIndex * iterIndex ))
#            	    # calculate how much time sequential allocator takes to do all the work
#	    	    temp="0 1 $objIndex $work"
#            	    result=`$bmPath/$bmName $temp`
#            	    if [ ! $result ]; then
#                	result=-1
#            	    fi
#	    	    echo "Sequential Allocator performing total work = $work took $result"
#            	    output="$output $result"
            	    echo $output >> $outputFile
    	    	    (( threadIndex++ ))    
		done
    	    done
	done
    done
done
    
