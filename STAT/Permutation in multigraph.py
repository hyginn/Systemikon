import networkx as nx
import numpy as np
import math as math
import random

#Input the local path of text file and input how many swapping you like to do
x=raw_input("Please enter the input text path(example:F:/study/university life/BIOINFO/bcb420/testfile.txt):")
y=input("Please enter a number indicates how many swapping you like to do:")


#read the file using network x and save it in Python dictionary
fh=open(x,"r")
n=nx.read_weighted_edgelist(fh,nodetype=int)

#Now we have the list of nodes and edges let's do swapping, t,i,j and counter are control options here
t=0

counter=0
while t<y:
    #random generating a number to decide which swapping we are doing
    #And select 3 edges from the database
    z=random.uniform(0.0,1.0)
    
    i=0
    j=0
    
#  control method which if the program cant find a possible swapping set for too long the program will stop
    if counter>y*150:
        break
    
    

    

    #swapping method 1
    if z<0.5:
        
        
        while True:
                #find two edges that fits the profile
                a=random.randint(0,len(n.edges())-1)
                b=random.randint(0,len(n.edges())-1)
                e1=n.edges()[a]
                e2=n.edges()[b]
                #Copy the weight
                e1w=n[e1[0]][e1[1]]['weight']
                e2w=n[e2[0]][e2[1]]['weight']
                
                j=j+1
                #Control option
                if j>y*10:
                    break
                
                
                
            
                elif (e1[0],e2[1]) not in n.edges() and (e2[1],e1[0]) not in n.edges():
                    
                    if (e2[0],e1[1]) not in n.edges() and (e1[1],e2[0]) not in n.edges():
                        
                        if e1[0]!=e2[1] and e2[0]!=e1[1]:
                            
                        
                    
                
                
                            
                            n.add_edge(e1[0],e2[1],weight=e1w)
                            print n.edges()
                            
                            n.add_edge(e2[0],e1[1],weight=e2w)
                            print n.edges()
                            n.remove_edge(e1[0],e1[1])
                            print n.edges()
                            n.remove_edge(e2[0],e2[1])
                            
                            
                           
                           
                            print n.edges()
                            break
                            
                    
                
                counter=counter+1    
                
                

    #Second swapping method 
    else:
        i=0

        while True:
            
            
            c=random.randint(0,len(n.edges())-1)
            e3=n.edges()[c]
            e3w=n[e3[0]][e3[1]]['weight']
            d=random.choice(n.nodes())
            counter=counter+1
            i=i+1
            
            
##            print e3
##            print (e3[0],d)

#begin next swap if the program can't find any matched edges
            if i>y*10:
                break
                
            print i

            if (e3[0],d) in n.edges() or (d,e3[0]) in n.edges():
                e4w=n[e3[0]][d]['weight']
##                print (e3[0],d),(d,e3[0])
                
                
                e=random.choice(n.nodes())
##                print (e3[1],e)
                if (e3[1],e) in n.edges() or (e,e3[1])in n.edges():
                    e5w=n[e3[1]][e]['weight']
                    if d!=e and d!=e3[1] and e!=e3[0] and (e3[0],e) not in n.edges() and (e3[1],d) not in n.edges():
                        
                        
##                      swapping edges
                        n.add_edge(e3[0],e,weight=e4w)
                        n.add_edge(e3[1],d,weight=e5w)
                        n.remove_edge(e3[0],d)
                        n.remove_edge(e3[1],e)
                        break
                        
                        
                        

                        
                        
                        

    t=t+1
    

#Output the lists
nx.write_edgelist(n,'outputfile.edgelist',data=True)


                
