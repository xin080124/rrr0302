#ifndef YX_ALGORITHM_H

#define YX_ALGORITHM_H


#include<stdbool.h> //bool
#include<string.h> 

#include <stdio.h> // printf(),
#include <stdlib.h> // exit(), EXIT_SUCCESS
#include <pthread.h> // pthread_create(), pthread_join()
#include <semaphore.h> // sem_init()

typedef int (* yxSearch)(int targetNum, int sortedArray[]);


int binarySearchRecursive(int targetNum,int *arr);

int binarySearchNormal(int targetNum,int *arr);

int testSearch(yxSearch);

#endif
