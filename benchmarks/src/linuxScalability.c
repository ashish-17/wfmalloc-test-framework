#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "../../header_files/wfmalloc.h"

typedef struct _ThreadData {
    int allocatorNo;
    int nThreads;
    int objSize;
    int iterations;
    int repetitions;
    int threadId;
} ThreadData;

void* worker(void* data) {
    ThreadData *threadData = (ThreadData*) data;
    char *ptr[threadData->iterations];
    
    for (int i = 0; i < threadData->iterations; i++) {
        ptr[i] = malloc(threadData->objSize);
    }

    for (int i = 0; i < threadData->iterations; i++) {
	free(ptr[i]);
    }
    return NULL;
}

void* workerWaitFreePool(void* data) {
    ThreadData *threadData = (ThreadData*) data;
    char *ptr[threadData->iterations];
    
    for (int i = 0; i < threadData->iterations; i++) {
        ptr[i] = wfmalloc(threadData->objSize, threadData->threadId);
    }

    for (int i = 0; i < threadData->iterations; i++) {
        wffree(ptr[i]);
    }   
    return NULL;
}



int main(int argc, char* argv[]) {
    
    int allocatorNo, nThreads, objSize, iterations;
    struct timeval start, end;

    if (argc == 5) {
	allocatorNo = atoi(argv[1]);
	nThreads = atoi(argv[2]);
	objSize = atoi(argv[3]);
	iterations = atoi(argv[4]);
    } else {
	printf("Please provide 5 arguments.  Have a nice day!\n");
    }

    ThreadData threadData[nThreads];
    pthread_t threads[nThreads];

    if (allocatorNo == 1) {
        wfinit(nThreads);
    }

    gettimeofday (&start, NULL);
    for (int t = 0; t < nThreads; t++) {
	threadData[t].allocatorNo = allocatorNo;
	threadData[t].nThreads = nThreads;
	threadData[t].objSize = objSize;
	threadData[t].iterations = iterations;
	threadData[t].threadId = t;
	if (allocatorNo == 1) {
	    pthread_create((threads + t), NULL, workerWaitFreePool, (threadData + t));
	}
	else {
	    pthread_create((threads + t), NULL, worker, (threadData + t));
	}

    }

    for(int t = 0; t < nThreads; t++) {
        pthread_join(threads[t], NULL);
    }

    gettimeofday (&end, NULL);
    long int timeTaken = ((end.tv_sec * 1000000 + end.tv_usec) - (start.tv_sec * 1000000 + start.tv_usec ));
    printf("%ld", timeTaken);
}
