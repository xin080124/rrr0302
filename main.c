#include<stdio.h>
#include<string.h> 



int testCharPointer();

int main(void)
{
    //printf("hello, ubuntu again~!");
	
    char str[10];
    //char str[1];

    int x = 0; 
    int y = 0;
	
    x = strlen(str);
    y = sizeof(str);
	
    int res = sum(10,15);
    printf("\n the return value is %d",res);
	

    char *pc = (char *)malloc(10);
       //assert(pc);

       printf("\n the pc value is %h",(int)pc);
	
       int z = sizeof(pc);
	
       printf("\n the pc size is %d \n",z);
	
    testCharPointer();
    
    return 0;
}

int testSize()
{
    return 0;
}


int sum(int a, int b)
{
	int total=0;
	total = a + b;
	return total;
}

int testCharPointer()
{
    //use *str7,then *str7 = "z" will cause crash
    //but use str7[], it is ok    
    //char *str7 = "abc";
    char str7[] = "abc";
    //char *str8 = "abc";    
 
    printf("\n str7 = 0x%x \n",(int)str7);   
    //printf("str8 = 0x%x \n",(int)str8);   

    *str7 = "z"; 

    //printf("str8 = %s \n",str8);   

    return 0;
}
