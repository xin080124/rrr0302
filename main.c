#include<stdio.h>
#include<string.h> 

#include <stdio.h> // printf(),
#include <stdlib.h> // exit(), EXIT_SUCCESS
#include <pthread.h> // pthread_create(), pthread_join()
#include <semaphore.h> // sem_init()

int testCharPointer();
int testHeapAddress();
int testUserInput();

int testSemaphoreInThread();
int sum(int a, int b);

int global_a = 10;
int testIntArray();

int testMutexInThread();


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
	
    testCharPointer();
    
    //testUserInput();

    //testSemaphoreInThread();

    testIntArray();
	
	testMutexInThread();

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

int testIntArray()
{
    //{1,2,3} is different from "abc"
    //if we use (gdb) disas testIntArray, we can see that {1,2,3} is stored in stack frame. not beside the global variable
    //not readonly
    //so its value can be changed.
    //although we don't have a particular space to store num7
    //the compiler substitute all the num7 symbol with the address in stack, so that *num7 + =5 still make sense.
    //however, num7 is yet not a lvalue
    //so it can't be the operand for any operation.
    //this limit is the same with string array name
    //and, in fact, all of the arrays of any type.  
    
    //so, for any type of array
    //you can do whatever you like to its content
    //however, no operation is allowed for the array name
    //it can be seen as a pointer when you access to its content
    //but you can't access itself like you access a pointer
    //this is the difference
    int num7[] = {1,2,3};
    num7[0]+=1;
    *num7 += 5;
    //num7 ++;  //illegal

    printf("\n num7[0] is set to %d",num7[0]);
    return 0;
}

int testCharPointer()
{
    //use *str7,then *str7 = "z" will cause crash
    //but use str7[], it is ok    
    //char *str7 = "abc";
    char str7[] = "abc";

    //if we use char *str8 = "abc"
    //and then use printf("%s",str8) to show str8, 
    //the system will print out "abc", but not the "abc"'s address we expected
    //however, if we use (gdb) print str8
    //it would show both the "abc" and where this "abc" is stored
    //just like this:
    //$2 = 0x8048a49 "abc"

    //and the gloable variable int global_a is stored in this adress
    //again we see it by typing cmd in gdb
    //(gdb)print &global_a
    //$4 = (int*) 0x804a034 
   
    //and we also can see the stack address by info frame cmd
    //which give out a result like this:
    //stack level 0, frame at 0xbffff2c
    //compare $2 and $4, and stack frame address
    //we can see clearly that the "abc" 's address is closer to global_a, so that the const string is not stored in stack
    //that is also why pointers point to the same constant variable has the same value

    //however, (gdb)print str7 will not give out an address value
    //because str7 is the name of array, it is not a left-value
    //the compiler just ignore this symbol and does not allocate any space to stroe it.

    //so although str7 and str8 are both set with "abc", they are totally different in memory.
     
    char *str8 = "abc";    
    printf("\n str7 = 0x%x \n",(int)str7);   
    printf("str8 = 0x%x \n",(int)str8);   

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

int testSemaphoreInThread()
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

pthread_mutex_t lock;

void* mutexWorld(void* arg);

void* mutexWorld(void* arg) {
    while(1) {
        printf("Hello World wait lock \n");    

        // Wait lock
        pthread_mutex_lock(&lock);
        printf("Hello World get lock \n");
        pthread_mutex_unlock(&lock);
	}
}

int testMutexInThread()
{
    int res = 0;

    pthread_mutex_init(&lock, NULL);
    
    // Create thread
    pthread_t theMutexWorld;
    res = pthread_create(&theMutexWorld, NULL, mutexWorld, NULL);
    if (res) {
        printf("Thread creation failed!!/n");
        exit(EXIT_FAILURE);
    }

    int input;

    while(1) {
        pthread_mutex_lock(&lock);
        
		scanf("%d",&input);
        printf("The user has input %d.\n",input);
    
	    pthread_mutex_unlock(&lock);    
    }

    // Wait for thread synchronization
    void *threadResult;
    res = pthread_join(theMutexWorld, &threadResult);
    if (res) {
        printf("Thread join failed!!\n");
        exit(EXIT_FAILURE);
    }

    exit(EXIT_SUCCESS);
	
}


