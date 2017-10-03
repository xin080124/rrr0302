#ifndef YX_ALGORITHM_H

#def YX_ALGORITHM_H


#include<stdbool.h> //bool
#include<string.h> 

#include <stdio.h> // printf(),
#include <stdlib.h> // exit(), EXIT_SUCCESS
#include <pthread.h> // pthread_create(), pthread_join()
#include <semaphore.h> // sem_init()

typedef void (* yxSearch)(int targetNum, int sortedArray[]);


int binarySearchRecursive(int *arr);

int binarySearchNormal(int *arr);

int testSearch(yxSearch);

#endif