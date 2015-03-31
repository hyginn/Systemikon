import urllib2, json

inputfile = open('input.txt', 'r')

x = 0

genelist = []

runID = ""

for line in inputfile:
    if x == 0:
        runID = line.strip('\n')
    elif x == 1:
        if line == "Genome\n":
            #genomefile = open('HumanGenome.txt', 'r')
            #for gene in genomefile:
                #genelist += [line.strip('\n')]
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

normalize = "http://biodbnet.abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi.json?method=dbfind&inputValues={!s}&output=geneid&taxonId=9606&format=row".format(commas)

text = urllib2.urlopen(normalize).read()

text = json.loads(text)

print text

#xml = ET.fromstring(text)

#print text[0]["Gene ID"]

commas2 = ""

for gene in text:
    commas2 += gene["Gene ID"] + ","

print commas2
    

convert = "http://biodbnet.abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi.json?method=db2db&format=row&input=genesymbol&inputValues={!s}&outputs=biocycid,genesymbol&taxonId=9606".format(commas2)

conversions = urllib2.urlopen(convert).read()

conversions = json.loads(conversions)

#print conversions

finallist = ""

for gene in conversions:
    finallist += (gene["BioCyc ID"] + "  " + gene["Gene Symbol"] + "\n")

with open("output.txt", 'w') as thefile:
    thefile.write(finallist)
