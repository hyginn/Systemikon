library(igraph)
#READ the txt file into R data frame and make it graph
g<-read.graph("F:/study/university life/BIOINFO/bcb420/testfile2.txt",format="ncol")

#set how many swap you like to do
y<-10000
#Now we have the list of nodes and edges let's do swapping, t,i,j and counter are control options here
t<-0
counter<-0

#swapping main loop
while(t<y){
  s<-get.edgelist(g)
  #random generating a number to decide which swapping we are doing
  #And select 3 edges from the edgelist
  z=runif(1,0.0,1.0)
  #control option for both method in case loop runs forever
  print(z)
  #randomly choose an edge first
  a=sample(1:(length(s[,1])),1)
  x1=s[a,][1]
  y1=s[a,][2]
  # delete chosen vetices from the dataframe so that they will not be chosen agian
  l<-delete.vertices(g,which(V(g)$name==x1))
  l<-delete.vertices(g,which(V(g)$name==y1))
  c<-get.edgelist(l)
  i=0
  j=0
  #  control method which if the program cant find a possible swapping set for too long the program will stop
  if(counter>y*150){
    break
  }
  
  #swapping method 1
  if(z<0.5){
    j=0
    #find another edges that fits the profile
    while(TRUE){
      b=sample(1:(length(c[,1])),1)
      #set strings for this newly chosen edge

      x2=c[b,][1]
      y2=c[b,][2]
      #weight of those two edges are
      e1w=E(g)$weight[a]
      e2w=E(l)$weight[b]
      j=j+1
      print(x1)
      print(y1)
      print(x2)
      print(y2)
      #if control option is satisified, exit loop
      if(j>(y*10)){
        break
      }
      
      #check condition in order to start swapping loops
      if(g[x1,y2]==0 & g[x2,y1]==0){
        
        if(x1 != y2 & x2!=y1){
          
          #add edges into the graph and delete original edges
          g<-add.edges(g,c(x1,y2),attr=list(weight=e1w))
          
          
          
          g<-add.edges(g,c(x2,y1),attr=list(weight=e2w))
          g<-delete.edges(g,E(g,P=c(x1,y1)))
          g<-delete.edges(g,E(g,P=c(x2,y2)))
          
          break
        }
      }
    }
  }
  counter=counter+1
  
  #swapping method no.2 - local swap
  if(z>=0.5){
    i=0
    while(TRUE){
      a=sample(1:(length(s[,1])),1)
      x1=s[a,][1]
      y1=s[a,][2]
      v1=as.vector(E(g)[from(y1)])
      v1<-v1[v1!=a]
      b=v1[sample(1:(length(v1)),1)]
      
      #select second edge so that x2=y1 and y2=the other node in second edge
      x2=y1
      
      y2=s[b,][s[b,]!=x2]
      e2w=E(g)$weight[b]
      
      v2=as.vector(E(g)[from(y2)])
      v2<-v2[v2!=a]
      c=v2[sample(1:(length(v2)),1)]
      
      #select third edge in the same way as above
      x3=y2
      y3=s[c,][s[c,]!=x3&s[c,]!=y1]
      e3w=E(g)$weight[c]
      
      print(x1)
      print(y1)
      print(y2)
      print(y3)
      
      
      
      counter=counter+1
      i=i+1
      
      #control opition,if loop run too many times,exit loop
      if(i>y*10){
        break
      }
      #make sure no identical edges are chosen 
      if(identical(y3,character(0))==TRUE){
        next
       
      }
      #check if intended edges are already in the edgelist
      else if(g[x3,x1]==0 & g[x2,y3]==0){
        
        
        
          #sawpping edges and delete origianl edges
          if(x1!=y3 & x1!=y2 & y3!=x2){
            if(g[x3,e]==0 & g[y3,d]==0){
              g<-add.edges(g,c(x3,x1),attr=list(weight=e1w))
              g<-add.edges(g,c(y3,y1),attr=list(weight=e3w))
              
              g<-delete.edges(g,E(g,P=c(x1,y1)))
              g<-delete.edges(g,E(g,P=c(x3,y3)))
              break
            }
          }
          
        }
      
    }
  }
  
  
  
  
  
  t<-t+1
  print(t)
}

