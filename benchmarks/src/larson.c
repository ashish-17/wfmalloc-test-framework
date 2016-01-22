#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#include "../../header_files/wfmalloc.h"

typedef struct _ThreadData {
    int allocatorNo;
    int nThreads;
    int minSize;
    int maxSize;
    int blocksPerThread;
    int threadId;
    char **blkp;
    long count;
} ThreadData;

int startClock;
int stopClock;

int randomNumber(int min, int max) {
    return (min + (rand() % (max - min + 1)));
}

void distribute(int i, int blocksPerThread, int minSize, int maxSize, char** blkp, int allocatorNo, int distributorId) {
    int blkSize;
    for (int i = 0 ; i < blocksPerThread; i++) {
        blkSize = randomNumber(minSize, maxSize);
	if (allocatorNo == 1) {
	    blkp[i] = (char*) wfmalloc(blkSize, distributorId);
	}
	else {
	    blkp[i] = (char*) malloc(blkSize);
	}
    }
}

void initialRoundOfAllocationFree(int numOfBlocks, int minSize, int maxSize, int allocatorNo, int threadId) {
    int blkSize, victim;
    char *blkp[numOfBlocks];
    
    for(int i = 0; i < numOfBlocks; i++) {
	blkSize = randomNumber(minSize, maxSize);
	if (allocatorNo == 1) {
	    blkp[i] = (char*) wfmalloc(blkSize, threadId);
	}
	else {
	    blkp[i] = (char*) malloc(blkSize);
	}
    }
    
    for (int i = 0; i < numOfBlocks; i++) {
        victim = randomNumber(0, numOfBlocks - i - 1);
	if (allocatorNo == 1) {
	    wffree(blkp[victim]);
	}
	else {
	    free(blkp[victim]);
	}
	blkp[victim] = blkp[numOfBlocks - i - 1];
	blkp[numOfBlocks - i - 1] = NULL;
    }		    

}

void* worker(void *data) {
    while(startClock != 1);
    
    ThreadData* threadData = (ThreadData*) data;
    int victim, blkSize;
    
    while(1) {
	victim = randomNumber(0, threadData->blocksPerThread - 1);
	if (threadData->allocatorNo == 1) {
	    wffree(threadData->blkp[victim]);
	}
	else {
	    free(threadData->blkp[victim]);
	}
        blkSize = randomNumber(threadData->minSize, threadData->maxSize);
	if (threadData->allocatorNo == 1) {
	    threadData->blkp[victim] = (char*) wfmalloc(blkSize, threadData->threadId);
	}
	else {
	    threadData->blkp[victim] = (char*) malloc(blkSize);
	}
	threadData->count++;
	if (stopClock == 1) {
	    break;
	}
    }
}


int main(int argc, char **argv) {

    // initialize the global clock variables to false
    startClock = 0;
    stopClock = 0;

    int nThreads, allocatorNo, numOfBlocks, minSize, maxSize;
    unsigned timeSlice;
    int numBlocksPerThread;
    long int totalCount = 0;

    srand(time(NULL));

    if (argc == 7) {
	allocatorNo = atoi(argv[1]);
	nThreads = atoi(argv[2]);
	numOfBlocks = atoi(argv[3]);
	minSize = atoi(argv[4]);
	maxSize = atoi(argv[5]);
	timeSlice = (unsigned)atoi(argv[6]);
    } else {
	printf("Please provide 7 arguments.  Have a nice day!\n");
    }

    ThreadData threadData[nThreads];
    pthread_t threads[nThreads];

    if (allocatorNo == 1) {
        wfinit(nThreads + 1);
	//printf("wfpool initialised\n");
    }

    // rounding down numOfBlocks to nearest multiple of nThreads
    numBlocksPerThread = numOfBlocks / nThreads;
    numOfBlocks = numBlocksPerThread * nThreads;

    char *blkp[numOfBlocks];
    initialRoundOfAllocationFree(numOfBlocks, minSize, maxSize, allocatorNo, nThreads);
    // parent (id = nThreads) allocates and distributes numOfBlocks/nThreads blocks of size betwen
    // minSize and maxSize to each thread i
    for (int i = 0; i < nThreads; i++) {
        distribute(i, numBlocksPerThread, minSize, maxSize, (blkp + (i*numBlocksPerThread)), allocatorNo, nThreads);
    }

    for (int t = 0; t < nThreads; t++) {
	threadData[t].minSize = minSize; 
        threadData[t].maxSize = maxSize;
	threadData[t].blocksPerThread = numBlocksPerThread;
	threadData[t].threadId = t;
	threadData[t].allocatorNo = allocatorNo;	
	threadData[t].nThreads = nThreads;
	threadData[t].blkp = (blkp + (t*numBlocksPerThread));
	threadData[t].count = 0;
	pthread_create((threads + t), NULL, worker, (threadData + t));
    }

    startClock = 1;
    sleep(timeSlice);
    stopClock = 1;

    for(int t = 0; t < nThreads; t++) {
	pthread_join(threads[t], NULL);
    }

    for (int t = 0; t < nThreads; t++) {
	totalCount += threadData[t].count;    
//	 printf("Thread %d count = %d\n", t, threadData[t].count);	
    }

    printf("%ld", totalCount);

}

