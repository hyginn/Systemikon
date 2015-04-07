import mygene, urllib

inputfile = open('input', 'r')

x = 0

genelist = []

spec = ""

runid = ""

for line in inputfile:
        if x== 0:
                species = line.strip("\n")
        elif x== 1:
                if line == "Fetch\n":
                        #Fetch gene list and assign it to list
                        Break
                else:
                        Continue
        elif x==2:
                runid = line.strip("\n")
        genelist += [line.strip("\n")]
        x += 1
        
conversion = mg.querymany(genelist, scopes="symbol", fields="entrezgene", species=spec)

commalist = ""

x1 = 0

for gene in genelist:
        commalist += concatenate(gene, ",")

        
biocyc = "http://biodbnet.abcc.ncifcrf.gov/webServices/rest.php/biodbnetRestApi.xml?method=db2db&format=row&input=genesymbol&inputValues={!s}&outputs=biocycID&taxonId=9606".format(commalist)

openurl = urllib.urlopen(biocyc)

response = openurl.read()

outputfile = open("output", "w")

y = 0

for line in outputfile:
        if y== 0:
                line  = runid
                y += 1
        elif y == 1:
                line = species
                y += 1
        else:
                if (len(genelist) - y - 2) == 0:
                        break
                else:
                        line = concatenate(str(genelist[y-2]['symbol']), "      ", str(genelist[y-2]['entrezgene']),"        ", response[y-2], "\n")
                        y += 1
