library(MASS)
library(class)
library("readr")

vlda = function(v,formula,data,cl){
  require(MASS)
  grps = cut(1:nrow(data),v,labels=FALSE)[sample(1:nrow(data))]
  pred = lapply(1:v,function(i,formula,data){
    omit = which(grps == i)
    z = lda(formula,data=data[-omit,])
    predict(z,data[omit,])
  },formula,data)
  
  wh = unlist(lapply(pred,function(pp)pp$class))
  table(wh,cl[order(grps)])
}

vknn = function(v,data,cl,k){
  grps = cut(1:nrow(data),v,labels=FALSE)[sample(1:nrow(data))]
  pred = lapply(1:v,function(i,data,cl,k){
    omit = which(grps == i)
    pcl = knn(data[-omit,],data[omit,],cl[-omit],k=k)
  },data,cl,k)
  
  wh = unlist(pred)
  table(wh,cl[order(grps)])
} 

data = read_csv("data/HIGGS.csv",col_names = FALSE)

lineardiscrim = lda(X1 ~ ., data)
pred = predict(lineardiscrim, data)
table(data$X1,pred$class)

tt = vlda(5,X1~.,data,data$X1)

error = sum(tt[row(tt) != col(tt)]) / sum(tt) #vlda
print(error)

tt = vknn(5,data,data$X1,5)

error = sum(tt[row(tt) != col(tt)]) / sum(tt) #vlda
print(error)
