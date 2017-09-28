#include<stdio.h>
#include<string.h> 

#include <stdio.h> // printf(),
#include <stdlib.h> // exit(), EXIT_SUCCESS
#include <pthread.h> // pthread_create(), pthread_join()
#include <semaphore.h> // sem_init()

int testCharPointer();
int testHeapAddress();
int testUserInput();

int testThread();
int sum(int a, int b);


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
	
    //testHeapAddress();
	
    //testCharPointer();
    
    //testUserInput();

    testThread();
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
    char *str7 = "abc";
    //char str7[] = "abc";
    //char *str8 = "abc";    
    printf("\n str7 = 0x%x \n",(int)str7);   
    //printf("str8 = 0x%x \n",(int)str8);   

    //*str7 = "z"; 

    //printf("str8 = %s \n",str8);   

    return 0;
}

int testHeapAddress()
{
    char *pc = (char *)malloc(10);
    //assert(pc);

    printf("\n the pc value is %h",(int)pc);
    int z = sizeof(pc); 
    printf("\n the pc size is %d \n",z);

    return 0;
}

int testUserInput()
{
    int input;
    scanf("%d", &input);
    printf("\n the user input is %d",input);
    //fgets();
    return 0;
}

sem_t binSem;

void* helloWorld(void* arg);

void* helloWorld(void* arg) {
    while(1) {
        printf("Hello World wait semaphore,value is %d \n",binSem);    

        // Wait semaphore
            sem_wait(&binSem);
    printf("Hello World get semaphore,value is %d \n",binSem);
    }
}

int testThread()
{
    // Result for System call
    int res = 0;

    // Initialize semaphore
    res = sem_init(&binSem, 0, 0);
    if (res) {
    printf("Semaphore initialization failed!!/n");
    exit(EXIT_FAILURE);
    }
    printf("Semaphore initialization success!! value is %d \n",binSem);
    
    // Create thread
    pthread_t thdHelloWorld;
    res = pthread_create(&thdHelloWorld, NULL, helloWorld, NULL);
    if (res) {
        printf("Thread creation failed!!/n");
        exit(EXIT_FAILURE);
    }

    //char input[10];
    //char* input;
    int input;

        

    while(1) {
        // Post semaphore
        sem_post(&binSem);
    
        printf("In main, sleep several seconds. sem is %d \n",binSem);
        //sleep(1);
        scanf("%d",&input);
        printf("The user has input %d.\n",input);
    
    
    }

    // Wait for thread synchronization
    void *threadResult;
    res = pthread_join(thdHelloWorld, &threadResult);
    if (res) {
        printf("Thread join failed!!\n");
        exit(EXIT_FAILURE);
    }

    exit(EXIT_SUCCESS);
	
}
