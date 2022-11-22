#####################################
#     Load libraries
#####################################
library(text2vec)
library(slam)
library(pROC)
library(glmnet)
library(here)

#####################################
#           Set Seed
#####################################
set.seed(1234)

#####################################
#   Process data into five splits
#####################################
root_path = getwd()
print(root_path)

#####################################
# Load your vocabulary and training data
# Make sure you copy the vocab file in each directory before running the code
#####################################
print("########################################################################")
print("   Generating the Prediction results for each split (test data)        ")
print("########################################################################")

# Create a dataframe to store the AUC results
data = data.frame(Splits=c("Split_1","Split_2","Split_3","Split_4","Split_5"),
                  AUC = c(0,0,0,0,0))

if (file.exists("data/split_1")){
  for(j in 1:5){
    print(paste("Executing prediction calculation for Split_", j, sep=""))
    print("Loading the Vocabulary and train data file")
    myvocab = scan(file = paste("data/split_", j,"/myvocab.txt", sep=""), what = character())
    train = read.table(paste("data/split_", j,"/train.tsv", sep=""), stringsAsFactors = FALSE, header = TRUE)
    
    #####################################
    # Train a binary classification model
    #####################################
    print("Training a binary classification model")
    train$review = gsub('<.*?>', ' ', train$review)
    it_train = itoken(train$review, preprocessor = tolower,
                      tokenizer = word_tokenizer)
    vectorizer = vocab_vectorizer(create_vocabulary(myvocab, ngram = c(1L, 2L)))
    dtm_train = create_dtm(it_train, vectorizer)
    
    #####################################
    # Using Ridge regression with 0.06 lambda found using cross validation
    #####################################
    print("Creating model fit on Train data with Ridge regression (with 0.06 lambda) found using cross validation")
    ridgefit = glmnet(x = dtm_train, y = train$sentiment, alpha = 0,
                      family='binomial', lambda = 0.06)
    
    #####################################
    #        Read test data
    #####################################
    print("Loading the test data")
    test = read.table(paste("data/split_", j,"/test.tsv", sep=""), stringsAsFactors = FALSE, header = TRUE)
    
    #####################################
    # Compute prediction
    # Store your prediction for test data in a data frame
    # "output": col 1 is test$id
    #           col 2 is the predicted probabilities
    #####################################
    print("Computing prediction on the Test Data")
    test$review = gsub('<.*?>', ' ', test$review)
    it_test = itoken(test$review, preprocessor = tolower,
                     tokenizer = word_tokenizer)
    dtm_test  = create_dtm(it_test, vectorizer)
    pred_result = predict(ridgefit, dtm_test, type = "response")
    
    print("Storing test$id and prediction values into dataframe")
    output = data.frame(id = test$id, prob = as.vector(pred_result))
    
    #####################################
    ###### Write output to file #########
    #####################################
    print("Saving the dataframe to prediction_results file")
    write.table(output, file = paste("data/split_", j,"/prediction_results.txt", sep=""), row.names = FALSE, sep='\t')
    
    #####################################
    ###### Generate AUC Report #########
    #####################################
    test.y = read.table(paste("data/split_", j,"/test_y.tsv", sep=""), header = TRUE)
    pred = read.table(paste("data/split_", j,"/prediction_results.txt", sep=""), header = TRUE)
    pred = merge(pred, test.y, by="id")
    roc_obj = roc(pred$sentiment, pred$prob)
    data[j,"AUC"] = pROC::auc(roc_obj)
  }
}

print("########################################################################")
print("                    AUC results for each split                          ")
print("########################################################################")
print(data)
print("########################################################################")