// forC.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include<string.h> 

void test(char **p);

int main()
{
	printf("hello, vc++");

	int x = 0; 
	int y = 0;
	//char str[10];
	char str[1];
	x = strlen(str);
	y = sizeof(str);

	//char str3[10];
	//str3 = "it315.org";   //error:expression must be a modifiable lvalue
		
	char *pstr;
	
	char *pchar = NULL;
	char **pp = &pchar;

	test(pp);

	return 0;
}

void test(char **p)
{
	*p = new char[100];
}

