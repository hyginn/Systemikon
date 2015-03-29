#import the data
n<-read.table("C:/Users/Richard/Documents/size.csv")
factor=1.0
#Introduce numerical noise to the system
for (i in 1:length(n[,1])){
  n[,1][i]=jitter(n[,1][i],factor=factor)
  
}
write.table(l,file="numerical perturbation.csv",sep=",")

#import the data
n<-read.table("C:/Users/Richard/Documents/size.csv")
#decide how much items to take out in the list,in here 10%
f=round(0.1*(length(n[,1])))
o<-n[,1]
remove<-sample(o,f)
l<-o[!o%in%remove]
write.table(l,file="remove perturbation.csv",sep=",")