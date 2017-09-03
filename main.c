#include<stdio.h>
#include<string.h> 


int main(void)
{
    //printf("hello, ubuntu again~!");
	
	char str[10];

	int x = 0; 
    int y = 0;
	
	//char str[1];

	x = strlen(str);
    y = sizeof(str);
	
    int res = sum(10,15);
	printf("\n the return value is %d",res);
	

       char *pc = (char *)malloc(10);
       //assert(pc);

       printf("\n the pc value is %h",(int)pc);
	
       int z = sizeof(pc);
	
       printf("\n the pc size is %d \n",z);
	
       return 0;
}


int sum(int a, int b)
{
	int total=0;
	total = a + b;
	return total;
}
