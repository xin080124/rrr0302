
#include"yxAlgorithm.h"

static int BSearchR(int a[],int x,int low,int high);
static int BSearch(int a[],int key,int n);

int testSearch(yxSearch pfunc)
{
	//assert yxSearch
	int myArray[] = {1,2,3,4,6,8};
	int res = pfunc(2,myArray);

    printf("the res of binary search is %05d \n",res);
	return res;
}

int binarySearchRecursive(int targetNum,int *arr)
{
	int res = 0;
	res = BSearchR(arr,targetNum,0,5);
    return res;
} 

int binarySearchNormal(int targetNum,int *arr)
{
	int res = 0;
	res = BSearch(arr,targetNum,0,5);
    return res;
}

static int BSearchR(int a[],int x,int low,int high)
{
	int mid;
	if(low>high) return -1;
	mid=(low+high)/2;
	if(x==a[mid]) return mid;
	if(x<a[mid]) return(BSearch(a,x,low,mid-1));
	else return(BSearch(a,x,mid+1,high));
}

static int BSearch(int a[],int key,int n)
{
	int low,high,mid;
	low=0;high=n-1;
	while(low<=high) 
	{
		mid=(low+high)/2;
		if(a[mid].key==key) return mid;
		else if(a[mid].key<key) low=mid+1;
		else high=mid-1;
	}
	return -1;
}
