
#include"yxAlgorithm.h"

static int BSearchR(int a[],int x,int low,int high);
static int BSearch(int a[],int key,int n);

int testSearch(yxSearch pfunc)
{
	//assert yxSearch
	int myArray[] = {1,2,3,4,6,8};
	int res = pfunc(4,myArray);

    printf("\n the res of binary search is %05d \n",res);
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
	res = BSearch(arr,targetNum,6);
    return res;
}

int insertSearch(int targetNum,int n,int *arr)
{
	int res = 0;
	res = interpolationSearch(arr, n, targetNum);
    return res;
}

static int interpolationSearch(int arr[], int n, int x)
{
	// Find indexes of two corners
    int lo = 0, hi = (n - 1);
 
    // Since array is sorted, an element present
    // in array must be in range defined by corner
    while (lo <= hi && x >= arr[lo] && x <= arr[hi])
    {
        // Probing the position with keeping
        // uniform distribution in mind.
        int pos = lo + (((double)(hi-lo) /
              (arr[hi]-arr[lo]))*(x - arr[lo]));
 
        // Condition of target found
        if (arr[pos] == x)
            return pos;
 
        // If x is larger, x is in upper part
        if (arr[pos] < x)
            lo = pos + 1;
 
        // If x is smaller, x is in lower part
        else
            hi = pos - 1;
    }
    return -1;

}

static int BSearchR(int a[],int x,int low,int high)
{
    printf("\n BSearchR low = %d high = %d \n",low,high);

	int mid;
	if(low>high) return -1;
	mid=(low+high)/2;
	if(x==a[mid]) return mid;
	if(x<a[mid]) return(BSearchR(a,x,low,mid-1));
	else return(BSearchR(a,x,mid+1,high));
}
	
static int BSearch(int a[],int key,int n)
{
	int low,high,mid;
	low=0;high=n-1;
	while(low<=high) 
	{
		mid=(low+high)/2;
		if(a[mid]==key) return mid;
		else if(a[mid]<key) low=mid+1;
		else high=mid-1;
            printf("\n BSearch low = %d high = %d \n",low,high);
	}
	return -1;
}
