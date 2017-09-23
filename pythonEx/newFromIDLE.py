#file_object = open("moviestest.txt","r")
file_object = open("course_books_Jeffrey_p.csv","r")

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
