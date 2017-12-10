library("h2o")
library("readr")

data = read_csv("data/HIGGS.csv",col_names = FALSE)

size <- floor(0.75 * nrow(data))
set.seed(142)
train_ind <- sample(seq_len(nrow(data)), size = size)

train <- data[train_ind, ]
test <- data[-train_ind, ]
trainfactored = train
testfactored = test


y <- names(train[,1])
x <- setdiff(names(train), y)
trainfactored$X1 = as.factor(train$X1)
testfactored[,1] <- as.factor(test$X1)

localH2O = h2o.init(ip = "localhost", port = 54321, startH2O = TRUE, min_mem_size = "4g")
train_h2o = as.h2o(trainfactored)


#MODEL TRAINING HERE
model <- h2o.deeplearning(x,
                          y,
                          training_frame = train_h2o,
                          activation = "RectifierWithDropout", 
                          input_dropout_ratio = 0.2,
                          balance_classes = FALSE, 
                          hidden = c(40,50,50,50),
                          epochs = 100)

plot(h2o.performance(model))
h2o.auc(model)

#TESTING HERE
test_h2o = as.h2o(testfactored)

pred = h2o.predict(model,test_h2o)

predictions = unlist(as.list(pred$predict))

mean(test$X1 == predictions)
