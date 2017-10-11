######################
#Importing Data
######################
data<-read.csv("wdbc.data",header = FALSE)
names(data)<-c('id',"diagnosis",
               "radiusM","textureM","perimeterM","areaM","smoothnessM","compactnessM","concavityM","concavePointsM","symmetryM","fractalDimensionM",
               "radiusSE","textureSE","perimeterSE","areaSE","smoothnessSE","compactnessSE","concavitySE","concavePointsSE","symmetrySE","fractalDimensionSE",
               "radiusW","textureW","perimeterW","areaW","smoothnessW","compactnessW","concavityW","concavePointsW","symmetryW","fractalDimensionW")

# Encoding categorical data
data$diagnosis = factor(data$diagnosis,
                    levels = c('M', 'B'),
                    labels = c(1, 0))
id<-data[,1]
data<-data[,-1]        #taking the patient ids aways for modelling purpose
header<-names(data)
dim(data)

######################
#Training Data
######################
set.seed(101)

#Assisning training data set size as 75% of total data
training_size<-round(dim(data)[1]*.75)
training_size

#Creating a random index sample 
trainingIndex<-sample(1:dim(data)[1], size = training_size,replace = FALSE)

#Assigning the training set
training<-data[trainingIndex,]
dim(training)

#separating nonfactors before scaling
trainingDiagnosis<-training[,1]
trainingFactors<-data.matrix(training[,2:31], rownames.force = NA)


#preProcess
#install.packages('caret')
library(caret)
prep<-preProcess(trainingFactors,method=c('center','scale'))
summary(prep)
trainingFactors<-predict(prep,trainingFactors)
training<-cbind.data.frame(trainingFactors,trainingDiagnosis)
View(training)
dim(training)

######################
#Test Data
######################
test<-data[-trainingIndex,]
View(test)
dim(test)
sapply(test,class)
testDiagnosis<-test[,1]
testFactors<-data.matrix(test[,2:31], rownames.force = NA)
class(testFactors)

test<-predict(prep,testFactors)

test<-data.frame(test)
dim(test)
View(test)






####################################
# Linear Discriminant Analysis LDA
####################################

#install.packages('MASS')
library(MASS)
classifier.LDA=  lda(trainingDiagnosis ~ ., data=training)
classifier.LDA

#Predicting on training
classifier.LDA.values<-predict(classifier.LDA)

#predicting the Test set results
testPred.LDA=predict(classifierLDA, newdata = test)$class
testPred.LDA

#confusion matrix
cm.LDA = table(testDiagnosis, testPred.LDA)
cm.LDA
accuracy.LDA = (cm.LDA[1,1] + cm.LDA[2,2]) / sum(cm.LDA)
accuracy.LDA #0.9295775


#######################################################
#LOGISTIC REGRESSION
#install.packages('e1071')
#fit Logistic Regression to the Training set
#library('e1071')
classifier.GLM= glm(formula = trainingDiagnosis ~ .,
                     family = binomial(link='logit'),
                     data = training)
summary(classifier.GLM)
classifier.GLM
#predicting the Test set results
testPred.GLM=predict(classifier.GLM, type = 'response', newdata = test)
class(testPred.GLM)
testPred.GLM<-testPred.GLM>=0.5
testPred.GLM

#confusion matrix
cm.GLM = table(testDiagnosis, testPred.GLM)
cm.GLM
accuracy.GLM = (cm.GLM[1,1] + cm.GLM[2,2]) / sum(cm.GLM)
accuracy.GLM #0.9507042


############################################################
#K-NN
#fit K-NN to the Training set and predict Test set results
#install.packages('class')
#create your classifier
library(class)
elbow_method = vector(); #FINDING THE BEST K
k_range = (1:100)
k_range = as.numeric(as.character(k_range))
for( i in k_range){
  y_pred_knn = knn(train = training_set[,2:31],
                   test = test_set[, -1],
                   cl = training_set[, 1],
                   k = i)#vector of prediction
  y_pred_knn=as.numeric(as.character(y_pred_knn))
  sq_error = (y_pred_knn-mean(y_pred_knn))^2
  sse = sum(sq_error)
  #wss = (nrow(mydata)-1)*sum(apply(mydata,2,var))
  #for (i in 2:15) wss[i] <- sum(kmeans(mydata,
  #centers=i)$withinss)
  #plot(1:15, wss, type="b", xlab="Number of Clusters",
  #ylab="Within groups sum of squares")
  #confusion matrix
  #cm_knn = table(test_set[,1], y_pred_knn)
  #accuracy_knn = (cm_knn[1,1] + cm_knn[2,2]) / (cm_knn[1,1] + cm_knn[2,2] + cm_knn[1,2] + cm_knn[2,1])
  elbow_method[i] = sse
}

k_accuracy = cbind(k_range, elbow_method)
plot(k_range, elbow_method)
min_error = min(elbow_method)
print(k_range[elbow_method=min_error])#for k=2



#########################################################################

# Fitting SVM to the Training set
#install.packages('e1071')
#library(e1071)

#SVM kernel= 'linear'
classifier.SVM.linear = svm(formula = trainingDiagnosis ~ .,
                            data = training,
                            type = 'C-classification',
                            kernel = 'linear')

# Predicting the Test set results
testPred.SVM.linear = predict(classifier.SVM.linear, newdata = test)
# Making the Confusion Matrix
cm.SVM.linear = table(testDiagnosis, testPred.SVM.linear)
cm.SVM.linear #accuracy = 135/142 = 0.9507
accuracy.SVM.linear = (cm.SVM.linear[1,1] + cm.SVM.linear[2,2]) / sum(cm.SVM.linear)
accuracy.SVM.linear


#SVM kernel= 'rbf'
classifier.SVM.rbf = svm(formula = trainingDiagnosis ~ .,
                            data = training,
                            type = 'C-classification',
                            kernel = 'radial')

# Predicting the Test set results
testPred.SVM.rbf = predict(classifier.SVM.rbf, newdata = test)
# Making the Confusion Matrix
cm.SVM.rbf = table(testDiagnosis, testPred.SVM.rbf)
cm.SVM.rbf #accuracy = 135/142 = 0.9507
accuracy.SVM.rbf = (cm.SVM.rbf[1,1] + cm.SVM.rbf[2,2]) / sum(cm.SVM.rbf)
accuracy.SVM.rbf


#SVM kernel= 'polynomial'
classifier.SVM.polynomial = svm(formula = trainingDiagnosis ~ .,
                         data = training,
                         type = 'C-classification',
                         kernel = 'polynomial')

# Predicting the Test set results
testPred.SVM.polynomial= predict(classifier.SVM.polynomial, newdata = test)
# Making the Confusion Matrix
cm.SVM.polynomial = table(testDiagnosis, testPred.SVM.polynomial)
cm.SVM.polynomial #accuracy = 135/142 = 0.9507
accuracy.SVM.polynomial = (cm.SVM.polynomial[1,1] + cm.SVM.polynomial[2,2]) / sum(cm.SVM.polynomial)
accuracy.SVM.polynomial#0.8521127



#SVM kernel= 'sigmoid'
classifier.SVM.sigmoid = svm(formula = trainingDiagnosis ~ .,
                                data = training,
                                type = 'C-classification',
                                kernel = 'sigmoid')

# Predicting the Test set results
testPred.SVM.sigmoid= predict(classifier.SVM.sigmoid, newdata = test)
# Making the Confusion Matrix
cm.SVM.sigmoid = table(testDiagnosis, testPred.SVM.sigmoid)
cm.SVM.sigmoid #accuracy = 135/142 = 0.9507
accuracy.SVM.sigmoid = (cm.SVM.sigmoid[1,1] + cm.SVM.sigmoid[2,2]) / sum(cm.SVM.sigmoid)
accuracy.SVM.sigmoid#0.9577465
