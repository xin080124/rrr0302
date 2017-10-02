
#include"yxAlgorithm.h"

int testSearch(yxSearch pfunc)
{
	//assert yxSearch
	int myArray[] = {1,2,3,4,6,8};
	int res = pfunc(2,myArray);

        printf("the res of binary search is %05d \n",res);
	return res;
}

int binarySearchRecursive(int *arr)
{
    return 3;
} 

int binarySearchNormal(int *arr)
{
	return 5;
}

