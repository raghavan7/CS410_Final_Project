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

print("########################################################################")
print("                        Split Data Generation Steps                     ")
print("########################################################################")

print("Process data into five splits")

data = read.table("data/alldata.tsv", stringsAsFactors = FALSE, header = TRUE)
testIDs = read.csv("data/splits.csv", header = TRUE)

print("Once all split files are created, we are going to use the first split for our vocab creation")

if (!file.exists("data/split_1")){
  for(j in 1:5){
    dir.create(paste("data/split_", j, sep=""))
    train = data[-testIDs[,j], c("id", "sentiment", "review") ]
    test = data[testIDs[,j], c("id", "review")]
    test.y = data[testIDs[,j], c("id", "sentiment", "score")]
    
    tmp_file_name = paste("data/split_", j, "/", "train.tsv", sep="")
    write.table(train, file=tmp_file_name,
                quote=TRUE,
                row.names = FALSE,
                sep='\t')
    tmp_file_name = paste("data/split_", j, "/", "test.tsv", sep="")
    write.table(test, file=tmp_file_name,
                quote=TRUE,
                row.names = FALSE,
                sep='\t')
    tmp_file_name = paste("data/split_", j, "/", "test_y.tsv", sep="")
    write.table(test.y, file=tmp_file_name,
                quote=TRUE,
                row.names = FALSE,
                sep='\t')
  }
}

print("Split creation completed")

#####################################
# Read data for first split
#####################################

print("########################################################################")
print("                        Voabulary Generation Steps                      ")
print("########################################################################")

print("Reading data from the first split")

train = read.table("data/split_1/train.tsv",
                   stringsAsFactors = FALSE,
                   header = TRUE)
train$review = gsub('<.*?>', ' ', train$review)

#####################################
# Initial Document  Matrix  Creation
#####################################

stop_words = c("i", "me", "my", "myself",
               "we", "our", "ours", "ourselves",
               "you", "your", "yours",
               "their", "they", "his", "her",
               "she", "he", "a", "an", "and",
               "is", "was", "are", "were",
               "him", "himself", "has", "have",
               "it", "its", "the", "us")
it_train = itoken(train$review,
                  preprocessor = tolower,
                  tokenizer = word_tokenizer)
tmp_vocab = create_vocabulary(it_train,
                              stopwords = stop_words,
                              ngram = c(1L,4L))
tmp_vocab = prune_vocabulary(tmp_vocab, term_count_min = 10,
                             doc_proportion_max = 0.5,
                             doc_proportion_min = 0.001)
dtm_train  = create_dtm(it_train, vocab_vectorizer(tmp_vocab))

print("Initial Document  Matrix  created")

#####################################
# Implement two  sample T test method
#####################################

print("Running two sample T-test method to reduce the vocab size further")
v_size = dim(dtm_train)[2]
ytrain = train$sentiment

#####################################
#Find mean and variance for each label
#####################################
summ = matrix(0, nrow=v_size, ncol=4)
summ[,1] = colapply_simple_triplet_matrix(
  as.simple_triplet_matrix(dtm_train[ytrain==1, ]), mean)
summ[,2] = colapply_simple_triplet_matrix(
  as.simple_triplet_matrix(dtm_train[ytrain==1, ]), var)
summ[,3] = colapply_simple_triplet_matrix(
  as.simple_triplet_matrix(dtm_train[ytrain==0, ]), mean)
summ[,4] = colapply_simple_triplet_matrix(
  as.simple_triplet_matrix(dtm_train[ytrain==0, ]), var)

n1 = sum(ytrain);
n = length(ytrain)
n0 = n - n1

my_p = (summ[,1] - summ[,3])/sqrt(summ[,2]/n1 + summ[,4]/n0)

#####################################
# Ordering  words by  magnitude of T-statistic value and filtering top 2000 words
#####################################

print("Ordering words by magnitude of T-statistic value and filtering top 2000 words")

words = colnames(dtm_train)
id = order(abs(my_p), decreasing=TRUE)[1:2000]
vocab2000 = words[id]
positive.list = words[id[my_p[id]>0]]
negative.list = words[id[my_p[id]<0]]

#####################################
#Top 50 positive words
#####################################
#print(positive.list[1:50]) #uncomment this line to view positive 50 words

#####################################
#Top 50 negative words
#####################################
#print(negative.list[1:50]) #uncomment this line to view negative 50 words

#####################################
# Model Usage
# Create a document matrix with the above 2K words
#####################################
print("Creating a document matrix with the 2000 words")
vec2 = vocab_vectorizer(create_vocabulary(vocab2000, ngram = c(1L, 2L)))
dtm_train_2 = create_dtm(it_train, vec2)

#####################################
# Fit the model(Lasso)
#####################################
print("Fitting data into lasso model with alpha=1")
tmp_fit_1 = glmnet(x = dtm_train_2, y = train$sentiment, alpha = 1,
                   family='binomial')

#####################################
# Pick largest DF among those less than  1K
#####################################
print("Picking largest DF among those less than 1000")
vocab1000 = colnames(dtm_train_2)[which(tmp_fit_1$beta[, 44] != 0)]

#####################################
# Create final vocab file (998 words)
#####################################

if (file.exists("data/split_1")){
  for(j in 1:5){
    write.table(vocab1000, file = paste("data/split_", j,"/myvocab.txt", sep=""), row.names = FALSE)
  }
}

print("Created final vocab file (998 words) in all split folders")