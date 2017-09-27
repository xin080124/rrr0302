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

void testInput();

char* getReverse(char str[]);

//void Hannoi(int n);
void Hannoi(int n, char source, char dest, char temp);

void testMalloc();

void testNew();

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
	
	//testVirtual = getInstance(input);
	//testVirtual->showCallOrder();

	//swapCharByArray();
	testInput();

	getReverse("abcde");

	//Hannoi(3);
	Hannoi(3, 'A', 'C', 'B');

	testMalloc();

	testNew();

	return 0;
}

void Hannoi(int n, char source, char dest, char temp)
{
	if (n > 1)
    {
		Hannoi(n - 1, source , temp, dest);
		printf("\n %c --- %c",source, dest);
		Hannoi(n - 1, temp, dest, source);
    }
	else
	{
		printf("\n %c --- %c", source, dest);
	}
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

void testInput()
{
	int inputNum;
	printf("Please input a number: ");
	scanf("%d", &inputNum);
	printf("\n the input is %d", inputNum);

	char inputStr[20];
	printf("\n\n Please input a string: ");
	//if the user input a string which is too long, 
	//this may cause crash, echo:
	//Run-Time Check Failure #2 - Stack around the variable 'inputNum' was corrupted.
    scanf("%s", inputStr);
	printf("the input is %s", inputStr);
}
typedef struct {
	char* name;
	int data;
}yxStruct;

void testMalloc() {
	//malloc for str
	yxStruct yx;
	yx.name = "love";
	printf("\n before, yx.name = %s", yx.name);
	int len = strlen(yx.name);
	char * dest = (char*)malloc(len + 1);
	yx.name = dest;
	printf("\n after, yx.name = %s", yx.name);
	int *myArray = (int*)malloc(sizeof(int) * 10);
	yx.data = *myArray;
	printf("\n after, yx.data = %d", yx.data);

	yxStruct *yxcopy = (yxStruct*)malloc(sizeof(yxStruct));
	//the following printf statement will cause read overflow exception
	//as the there is no "\0" in the block, so the pc can't know where to stop.
	//printf("\n before yxcopy.name = %s, yxcopy.data = %d", yxcopy->name, yxcopy->data);
	yxcopy->name = "yx";
	printf("\n before yxcopy.name = %s, yxcopy.data = %d", yxcopy->name, yxcopy->data);

	yxStruct *yxArray = (yxStruct *)malloc(sizeof(yxStruct)*10);
	memset(yxArray, '\0', sizeof(yxStruct)*10);
	memcpy(yxcopy, yxArray, sizeof(yxStruct));
	printf("\n after yxcopy.name = %s, yxcopy.data = %d", yxcopy->data, yxcopy->data);

	free(dest);
	dest = NULL;
	free(yxArray);
	yxArray = NULL;
}

void testNew()
{
	const int NUM = 3;

	T* p1 = new T[NUM];
	cout << hex << p1 << endl;
    delete[] p1;
	//delete p1;   //without "[]",the program will throw a exception when execute this

	T* p2 = new T[NUM];
	cout << p2 << endl;
	delete[] p2;
}


char* getReverse(char str[]) {
	
	static int i = 0;
	static int times = 0;
	static char rev[100];

	times++;
	printf("\n getReverse enter %d", times);


	if (*str) {
		getReverse(str + 1);
		rev[i++] = *str;
	}

	printf("\n return %d", times);

	return rev;
}

/*
void swapCharByArray()
{
char iStr[20];
printf("Please enter the 1st string");
get_s(iStr);

printf("The 1st string is %s", iStr);
}
*/

