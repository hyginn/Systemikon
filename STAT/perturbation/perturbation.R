#import the data
n<-read.table("F:/study/university life/BIOINFO/bcb420/dataforRui.csv",sep=",")
factor=1.0
#Introduce numerical noise to the system
for (i in 1:length(n[,1])){
  n[,3][i]=jitter(n[,3][i],factor=factor)
  n[,4][i]=jitter(n[,4][i],factor=factor)
  n[,5][i]=jitter(n[,5][i],factor=factor)
  n[,6][i]=jitter(n[,6][i],factor=factor)
  
}
write.table(n,file="numerical perturbation.csv",sep=",")

#import the data
n<-read.table("C:/Users/Richard/Documents/size.csv")
#decide how much items to take out in the list,in here 40%
f=round(0.4*(length(n[,1])))
o<-n[,1]
remove<-sample(o,f)
l<-o[!o%in%remove]
write.table(l,file="remove perturbation.csv",sep=",")