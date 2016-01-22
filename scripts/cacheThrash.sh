# Assumption: Current date is provided as an argument
# A folder with the same name as the provided argument has to be present in ../outputFilesFolder

#!/bin/bash

configFile="../configurations/cacheThrash"

bmPath="../benchmarks/bin"

bmName="cacheThrash"

outputFile="../outputFiles/$1/outputCacheThrash" 

argumentsMeaning="<nThreads> <objectSize> <noOfIterations> <noOfRepetitions> <glibcmalloc> <wfmalloc> <hoard>" # <sequential_allocator_all_work>"

allocatorLibPath="../lib"

i=0

while read line
do
	if [ $i == 0 ]; then
		nThreadsTemp=$line
	elif [ $i == 1 ]; then
		objTemp=$line
	elif [ $i == 2 ]; then
		iterTemp=$line
	elif [ $i == 3 ]; then
		repetitionTemp=$line
	fi
	(( i++ ))
done < $configFile


IFS=' '
read -a nThreads <<< "$nThreadsTemp"
read -a obj <<< "$objTemp"	
read -a iter <<< "$iterTemp"
read -a repetition <<< "$repetitionTemp"


echo "Going to execute" $bmName "on" configFile
echo $argumentsMeaning > $outputFile


for objIndex in "${obj[@]}"
do
    for iterIndex in "${iter[@]}"
    do
    	threadIndex=1
	while [ $threadIndex -le ${nThreads[0]} ]
	do
	    c=0  # 0 => glibc malloc, 1 => wfmalloc, 2 => hoard
	    output="$threadIndex $objIndex $iterIndex $repetition"
	    while [ $c -le 2 ]
	    do
                if [ $c == 2 ]; then
                    export LD_PRELOAD="$allocatorLibPath/libhoard.so"
                else
                    unset LD_PRELOAD
                fi
	        temp="$c $threadIndex $objIndex $iterIndex $repetition"  
                result=`$bmPath/$bmName $temp`
		# to report some sort of crash
		if [ ! $result ]; then
                    result=-1
                fi
                echo "$c allocator with $threadIndex threads performing $iterIndex iterations and $repetition repetitions took $result"
		output="$output $result"
	        (( c++ ))      
	    done
            unset LD_PRELOAD
#	    work=$(( threadIndex * iterIndex ))
#            # calculate how much time sequential allocator takes to do all the work
#	    temp="0 1 $objIndex $work $repetition"
#            result=`$bmPath/$bmName $temp`
#            if [ ! $result ]; then
#                result=-1
#            fi
#	    echo "Sequential Allocator performing total work = $work took $result"
#            output="$output $result"
            echo $output >> $outputFile
    	    (( threadIndex++ ))    
	done
    done
done
    
