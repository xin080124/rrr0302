import json
import datetime

#file_object = open("toParse/family.json","r")

def loadFont():
    #encoding not supported in 2.7
    #f = open("toParse/family.json", encoding='utf-8')
    f = open("toParse/family.json") 
    setting = json.load(f)
    family = setting['BaseSettings']['size']
    size = setting['fontSize']   
    return family

def loadFailure():
    f = open("toParse/ProductAnalyticFailureDistributionData.json")
    lines = f.readlines()

    for line in lines:
        failure = json.load(line)
        exFreq = failure['ExpectedFrequency']['Week28']
        #return exFreq
        print exFeq

def transferToDate(deltaDat):
    #today = datetime.date.today()
    today = datetime.datetime(2015,1,1)
    deltaDat = 7*deltaDat
    yesterday = today - datetime.timedelta(days=deltaDat)
    #print today
    #print yesterday  
    tomorrow = today + datetime.timedelta(days=deltaDat)
    #print tomorrow
    return tomorrow

def loadTest():
    #encoding not supported in 2.7
    #f = open("toParse/family.json", encoding='utf-8')
    f = open("toParse/test.json")
    path_out = 'weekFailure1459.csv'
    file_out = open(path_out,'w')

    test = json.load(f)
    #time = test['Timestamp']
    #print time

    exFreq = test['ExpectedFrequency']
    #print exFreq

    keys = exFreq.keys()
    #print keys

    for key in keys:
        #print key+","+str(exFreq[key])+"\n"
        freq = exFreq[key]
        key = str(key).replace('Week','')
        key = transferToDate(int(key))
        lineContent = str(key)+","+str(freq)+"\n"
        print lineContent
        #print exFreq[key]
        file_out.write(lineContent)
    file_out.close()
#t = loadFont()
#loadFailure()



loadTest()

#transferToDate(100)

#print t
