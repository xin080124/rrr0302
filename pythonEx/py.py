
####################create sql from csf file#######################################
#file_object = open("moviestest.txt","r")
file_object = open("toParse/course_books_Jeffrey_p.csv","r")

path_out = 'result0923.txt'

file_out = open(path_out,'w')
lines = file_object.readlines()

for line in lines:
        x = line.split(',')
        #print x[0]
        #print x[1]
        #print x[2]
        #lineContent = lineContent.replace('\n',' ')
        x[1] = "\""+x[1]+"\""
        x[2] = "\""+x[2]+"\""
        x[3] = "\""+x[3]+"\""
        sql = "INSERT INTO books0923 (book_id,book_name,author_name,yeartime) VALUES (NULL,"+x[1]+","+x[2]+","+x[3]+")"
        sql = sql.replace(';','&')
        sql = sql.replace('\n','')
        sql = sql+";"
        print sql
# file_out.write("hehe "+lineContent)
print ("\nsuccess")
#this is a stream operation, or the next file_object
#will get nothing
file_object.close()
file_out.close()

#print in python
strHello = "the length of (%s) is %d" %('Hello World',len('Hello World'))
print strHello

####################create json in python#############################################
file_object = open("moviestest.txt","r")

path_out = 'result.txt'

file_out = open(path_out,'w')
lines = file_object.readlines()
lineContent = ''
i=0
for line in lines:
    line = line.replace('\n','')
    i = i+1
    print(('\n i = %d ')%(i))
    tag = 'hehe'
    if i == 2:
        tag = 'id'
    elif  i==3:
        tag ='title'
    elif  i==4:
        tag ='category'
    elif  i==5:
        tag ='desc'
    elif  i==6:
        tag ='popularity'
    elif  i==7:
        tag ='onsale'
    elif  i==8:
        tag ='price'
    else:
        tag ='end'

    if i != 1 and i != 9:
        jsonLine = "\""+tag+"\":\"" + line + "\","
        lineContent += jsonLine
    # lineContent = lineContent.replace('\n',' ')
        print(lineContent)
    if i==9:
        file_out.write("'{ "+lineContent+"},'+\n") 
        lineContent = ''
        i=0
# file_out.write("hehe "+lineContent)
print ("\nsuccess")
#this is a stream operation, or the next file_object
#will get nothing
file_object.close()
file_out.close()

####################################################################################

from cassandra.cluster import Cluster
cluster = Cluster(['127.0.0.1'])
session = cluster.connect()
session.execute("create KEYSPACE test_cassandra WITH replication = {'class':'SimpleStrategy', 'replication_factor': 2};")
session.execute("use test_cassandra")
session.execute("create table users(id int, name text, primary key(id));")
session.execute("insert into users(id, name) values(1, 'I loving fish!');")
session.execute("insert into users(id, name) values(2, 'Zhang zhipeng');")

# session = cluster.connect("test_cassandra")
# rows = session.execute("select * from users;")

#####################################################
import pycassa
import time
batch_size = 100
con = pycassa.ConnectionPool('History',server_list=["127.0.0.1:9042"]
cf = pycassa.ColumnFamily(con,cfName)
cf.insert('row_key',{'col_name':'col_val'})

def pycassa_connect
():
    return pycassa.connectionPool('History',server_list=["127.0.0.1:9042"])
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
