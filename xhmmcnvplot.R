#THIS IS A R SCRIPT FOR XHMM CNV 03 STEP
setwd("D:\\myscript\\对肿瘤运行结果进行分析处理的脚本")
rm(list=ls())
tempcnv<-read.table("outcnvfreq.txt",header=T)
library(ggplot2)


tiff("xhmmcnv-12sample-1-7.png",width = 1080, height = 2160)

len<-length(tempcnv$cnvFreq)

  for (i in 1:len)
  {
    
    if(tempcnv$Type[i]==-1){
      tempcnv$cnvFreq[i]<--tempcnv$cnvFreq[i]
      tempcnv$Type[i]<-"DEL"
      }
    if(tempcnv$Type[i]==3){tempcnv$Type[i]<-"AMP"}
  }
  
tempcnv$cnvFreq

ggplot(tempcnv)+geom_bar(aes(x=CNVregion,y=cnvFreq,fill=factor(Type)),stat= 'identity', position = 'stack')+
  theme_bw()+theme_classic()+labs(title="12 SAMPLE XHMM CNV FREQ RESILT")+
  theme(axis.text.x = element_text(size =8,color = "black", face = "bold", vjust = 0.5, hjust = 1, angle = 90))+
  coord_flip()
 

dev.off()


#另一种给amp和del填充不同颜色
tempcnv_amp<-subset(tempcnv,Type==3)
tempcnv_del<-subset(tempcnv,Type==-1)
ggplot(tempcnv)+geom_bar(aes(x=CNVregion,y=cnvFreq),stat= 'identity', position = 'stack')
tempcnv$Type<-tempcnv$Type>0
ggplot(tempcnv)+geom_bar(aes(x=CNVregion,y=cnvFreq,fill=Type),stat= 'identity', position = 'stack')+
  scale_fill_manual(values=c("red","green"),guide=FALSE)+
  theme_bw()+theme_classic()+labs(title="12 SAMPLE XHMM CNV FREQ RESILT")+
  theme(axis.text.x = element_text(size =8,color = "black", face = "bold", vjust = 0.5, hjust = 1, angle = 90))
