library(poweRlaw)
#import the data
g<-read.table("F:/study/university life/BIOINFO/bcb420/dataforRui22.csv")
#Get system size distribution in decreasing order
c<-table(g)
e<-data.frame(c)
f<-sort(e[,2],decreasing=TRUE)
write.table(f,file="size.csv",sep=",")
#If output files are gathered from Permuataion, then omit above part
#edit ouput files in specific format(delete the first column) then import
n<-read.table("C:/Users/Richard/Documents/sizeoutput modified.csv")
#fit power law to size distribution 
m_pl=displ$new(n[,1])
est=estimate_xmin(m_pl)
m_pl$setXmin(est)
m_ln=dislnorm$new(n[,1])
est1=estimate_xmin(m_ln)
m_ln$setXmin(est1)
#plot distribution and fitted powerlaw as well as fitted lognormal
plot(m_pl)
lines(m_pl,col=2)
lines(m_ln,col=3)