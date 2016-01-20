# Assumption: Current date is provided as an argument
# A folder with the same name as the provided argument has to be present in ../outputFilesFolder

#!/bin/bash

configFile="../configurations/linuxScalability"

bmPath="../benchmarks/bin"

bmName="linuxScalability"

outputFile="../outputFiles/$1/outputLinuxScalability" 

argumentsMeaning="<nThreads> <objectSize> <noOfIterations> <glibcmalloc> <wfmalloc> <hoard> <sequential_allocator_all_work>"

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
	fi
	(( i++ ))
done < $configFile


IFS=' '
read -a nThreads <<< "$nThreadsTemp"
read -a obj <<< "$objTemp"	
read -a iter <<< "$iterTemp"


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
	    output="$threadIndex $objIndex $iterIndex"
	    while [ $c -le 2 ]
	    do
                if [ $c == 2 ]; then
                    export LD_PRELOAD="$allocatorLibPath/libhoard.so"
                else
                    unset LD_PRELOAD
                fi
	        temp="$c $threadIndex $objIndex $iterIndex"  
                result=`$bmPath/$bmName $temp`
		# to report some sort of crash
		if [ ! $result ]; then
                    result=-1
                fi
                echo "$c allocator with $threadIndex threads performing $iterIndex iterations took $result"
		output="$output $result"
	        (( c++ ))      
	    done
            unset LD_PRELOAD
	    work=$(( threadIndex * iterIndex ))
            # calculate how much time sequential allocator takes to do all the work
	    temp="0 1 $objIndex $work"
            result=`$bmPath/$bmName $temp`
            if [ ! $result ]; then
                result=-1
            fi
	    echo "Sequential Allocator performing total work = $work took $result"
            output="$output $result"
            echo $output >> $outputFile
    	    (( threadIndex++ ))    
	done
    done
done
    
