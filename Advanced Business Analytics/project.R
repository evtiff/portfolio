cancer <- read.csv("cleanCancerData.csv")
cancer=filter(cancer,status==2)
df<-aggregate(cancer$time, by=list(Category=cancer$ph.ecog), FUN=mean)
library(ggplot2)
p<-ggplot(data=df,aes(x=Category, y=x))+geom_bar(stat="identity",width=0.7)+ xlab("ecog") + ylab("time")
p

library(dplyr)
df_2<-aggregate(time ~ sex+ph.ecog,data=cancer, FUN=mean)                
male=filter(df_2,sex=='1')
p_male<-ggplot(data=male,aes(x=ph.ecog, y=time))+geom_bar(stat="identity",width=0.7)+ xlab("ecog") + ylab("time")
p_male

female=filter(df_2,sex=='2')
female$ph.ecog<-as.factor(female$ph.ecog)
p_female<-ggplot(data=female,aes(x=ph.ecog, y=time))+geom_bar(stat="identity",width=0.7)+ xlab("ecog") + ylab("time")
p_female

df_2$sex<-as.factor(df_2$sex)
ggplot(data=df_2, aes(x=ph.ecog, y=time, fill=sex)) +
  geom_bar(stat="identity", position=position_dodge())
