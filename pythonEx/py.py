#############################################
#debug ok code:
##file_object = open("readLineByPy.txt","r")
file_object = open("moviestest.txt","r")

path_out = 'result.txt'

file_out = open(path_out,'w')
lines = file_object.readlines()
lineContent = ''
i=0
for line in lines:
    i = i+1
    print(('\n i = %d ')%(i))
    line = line.replace('product/productId:','')
    line = line.replace('review/userId:','] [')
    line = line.replace('review/profileName:','] [')
    line = line.replace('review/helpfulness:',' ] [ ')
    line = line.replace('review/score:','] [')
    line = line.replace('review/time:','] [')
    line = line.replace('review/summary:',' ] [ ')
    line = line.replace('review/text:',' ] [ ')
    
    lineContent += line
    lineContent = lineContent.replace('\n',' ')
    print(lineContent)
    if i==9:
        file_out.write("hehe "+lineContent+'\n') 
        lineContent = ''
        i=0
file_out.write("hehe "+lineContent)
print ("\nsuccess")
#this is a stream operation, or the next file_object
#will get nothing
file_object.close()
file_out.close()




#############################################
#debug ok code:
import time
num = int(input('how many groups \n'))
guessWord = []
correct = []

#def list, num+10 is to make guessWord index legal
for i in range(0,num+10):
	guessWord.append(0)
	correct.append(0)
wordNum = 5

guessWord[0] = ['as','long','as','you','love','me']
guessWord[1] = ['trick','or','trade','if','halloween','dont']
guessWord[2] = ['we','will','rock','cindarella','dusty','celler']

flag = 'n'

for i in range(0,num):
    start = time.time()
    print(('\n i = %d \n')%(i))
    for k in range(0,wordNum):
##        print((' k = %d ')%(k))
        print(('i=%d k=%d.%s \n')%(i,k,guessWord[i][k]))

        flag = input('please answer, if right input y, press anykey to skip')
        end = time.time()
        sec = end - start

        if(110<=sec<=120):
            print('10 sec left')
        if(sec>=120):
            print('time elapse, game over')
            break

        print(('kkk=%d \n')%(k))

        if(flag=='y'):
            correct[i] = correct[i]+1
            continue
        else:
            continue

    str_temp = ('i=%d right number:%d') %(i,correct[i])
    print(str_temp)      

##############################################
#debug ok code:

print(" I love coding ")

import random

bot = int(input('set range bottom\n'))
top = int(input('Set range top\n'))
rand = random.randint(bot,top)
print ('Random number in ['+str(bot)+','+str(top)+']generated!')
num = int(input('###Guess the number###\n'))
cnt = 1

while(num!=rand):
    if(num<rand):
        print('*_* Lower than the answer')
    else:
        print('T_T Higher than the answer')
    num = int(input('###Guess the number###\n'))
    cnt = cnt+1

print('^_^ You get the answer with [%d] times'%cnt)

#############################################

# print(" I love coding ")
# temp = input("How are you today?")
# guess = int(temp)
# if guess == 0:
# 	print("Oh, sorry")
# else:
# 	print("very well")



# def my_abs(x):
# 	if x>=0:
# 		return x
# 	else:
# 		return -x

# my_abs(50)





# help(abs)

# abs(100)
