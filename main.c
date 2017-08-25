#include<stdio.h>
#include<string.h> 


int main(void)
{
    //printf("hello, ubuntu again~!");
	
	//char str[10];

	int x = 0; 
    int y = 0;
	
	char str[1];

	x = strlen(str);
    y = sizeof(str);
	
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
