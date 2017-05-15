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
