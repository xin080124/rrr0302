#include<stdio.h>

int main(void)
{
    //printf("hello, ubuntu again~!");
    int res = sum(10,15);
	printf(" the return value is %d",res);
	
	return 0;
}


int sum(int a, int b)
{
	int total=0;
	total = a + b;
	return total;
}
