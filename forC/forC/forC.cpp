// forC.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include<string.h> 

#include<stdio.h> 
#include<conio.h> 

#include "forCPP.h"

void test(char **p);
void showTheSizeOfBlock();
void switchChars(char *str, int step);
void memcpyChars(char *str, int step);

void *getInstance(int userInput);


int main()
{
	printf("hello, vc++");

	int x = 0; 
	int y = 0;
	char str[10];
	//char str[1];
	x = strlen(str);
	y = sizeof(str);

	//char str3[10];
	//str3 = "it315.org";   //error:expression must be a modifiable lvalue
		
	char *pstr;
	
	char *pchar = NULL;
	char **pp = &pchar;

    test(pp);

	char *p12 = NULL;
	int s12 = sizeof(p12);

	char *p121 = new char[100];
	int s121 = sizeof(p121);

	//showTheSizeOfBlock();

	char *swc = "abcde";
	switchChars(swc, 2);

	char *mcc = "abcdefghi";
	memcpyChars(mcc, 2);

	//withCC base;
	//base.showCallOrder();

	subCC sub;
	sub.showCallOrder();


	void *testVirtual = NULL;
	int input;
	scanf("%d", &input);
	
	printf("the input is %d", input);
	
	//testVirtual = getInstance(input);
	//testVirtual->showCallOrder();
	
	return 0;
}

void test(char **p)
{
	*p = new char[100];
}

void showTheSizeOfBlock()
{
	unsigned char *p1;
	unsigned long *p2;

	p1 = (unsigned char *)0x801000;
	p2 = (unsigned long *)0x810000;

	unsigned char *pa1 = p1 + 5;
	unsigned long *pa2 = p2 + 1;

	printf("pa2 = %d", (int)pa2);
}

#define MAX_LEN 100

void switchChars(char *str, int step)
{
	int len = strlen(str);
	char dest[MAX_LEN];
	memset(dest, 0, len+1);
	printf("len = %d", len);

	strcpy(dest, str + len - step);
	strcpy(dest + step, str);
	
	memset(dest+len, 0, 1);


	printf("res = %s", dest);
}

void *getInstance(int userInput)
{
	void *p;
	if (userInput == 0)
		p = new withCC;
	else
		p = new subCC;

	return p;
}

void memcpyChars(char *str, int step)
{
	int len = strlen(str);
	char dest[MAX_LEN];
	memset(dest, 0, len + 1);
	printf("len = %d", len);

	//strcpy(dest, str + len - step);
	//strcpy(dest + step, str);

	memcpy(dest, str + len - step, step);
	memcpy(dest + step, str, len-step);
	
	memset(dest + len, 0, 1);

	printf("res = %s", dest);
}
