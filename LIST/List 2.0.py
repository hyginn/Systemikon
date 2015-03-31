import urllib, xml.etree.ElementTree as ET

inputfile = open('input.txt', 'r')

x = 0

genelist = []

runID = ""

for line in inputfile:
    if x == 0:
        runID = line.strip('\n')
    elif x == 1:
        if line == "Fetch\n":
            #Fetch genes from authorative gene source.
            break
        else:
            x += 1
            continue
    elif x > 1:
        genelist += [line.strip('\n')]
    print line
    x += 1

commas = ""

y = 0

for gene in genelist:
    commas += gene + ","

normalize = "http://biodbnet.abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi?method=dbfind&inputValues={!s}&output=geneid&taxonId=9606&format=row".format(commas)

openurl = urllib.urlopen(normalize)

response = openurl.read()

print response

xml = ET.fromstring(response)

print response

print xml[0][1].text

commas2 = ""

for gene in xml.text:
    commas2 += gene[3] + ","

print commas2
    

#convert = "http://biodbnet.abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi.xml?method=db2db&format=row&input=genesymbol&inputValues=MYC,MTOR&outputs=biocycid,genesymbol&taxonId=9606".format(

#outputfile = open("output.txt", 'w')
