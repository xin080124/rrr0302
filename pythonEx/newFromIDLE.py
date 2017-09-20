file_object = open("moviestest.txt","r")

path_out = 'result.txt'

file_out = open(path_out,'w')
lines = file_object.readlines()
lineContent = ''
i=0
for line in lines:
    line = line.replace('\n','')
    i = i+1
    
    #print(('\n i = %d ')%(i))
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
        xmlLine = "<"+tag+">" + line +  "</"+tag+">\n"
        lineContent += xmlLine
    # lineContent = lineContent.replace('\n',' ')
        
    if i==9:
        lineContent+="</book>\n"
        print(lineContent)
        file_out.write(lineContent) 
        lineContent = "<book>\n"
        #xmlLine 
        i=0
# file_out.write("hehe "+lineContent)
print ("\nsuccess")
#this is a stream operation, or the next file_object
#will get nothing
file_object.close()
file_out.close()
