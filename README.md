### CS 410 Final Project (**Work In Progress**)
### Final Project Submission for Suganya Somu (SSOMU2) and Raghavendran Ramasubramanian (RR26)

A video presentation demonstrating usage of the software is available at [Link](https://youtube)

## Project Structure

```plaintext
├── main.R                                            <-- R file containing model execution and AUC check
├── vocab_creation.R                                  <-- R file containing Vocabulary creation from first split
├── run_docker.sh                                     <-- sh file containing docker run command (mention below in step 3)
├── Dockerconfig
|    |
|    └── requirements.R                               <-- library requirement file to install dependencies in docker image
├── data
|    |
|    ├── split* 
|    |    ├── myvocab.txt                             <-- bag of words generated from vocab_creation.R script
|    |    ├── prediction_results.txt                  <-- prediction results on test data from model run
|    |    ├── test_y.tsv                               
|    |    ├── test.tsv                                <-- test data for model
|    |    └── test.tsv                                <-- train data for model
|    ├── alldata.tsv                                  <-- full imdb dataset
|    └── splits.csv                                   <-- file with split information to generate split folders
├── Project Progress Report - Sentients.pdf 
├── Project Proposal - Sentients.pdf 
├── Dockerfile                                        <-- configuration for Docker image
└── README.md                           
```

### 1) Docker Image setup and model execution steps for execution for Graders

**Build Docker**<br/>
Step 1. `docker build --rm --force-rm -t rstudio/sentients .` <br/>
Step 2. `docker image list | grep sentients`<br/>

**Run Docker**<br/>
Step 3. `DATA_DIR=${PWD}/Data docker run -it --rm -m 4g --name sentients -e` 
        `USERID=$UID -v $DATA_DIR:/home/rstudio/data rstudio/sentients`  
        `/bin/bash`<br/>

**Test Model**<br/>
Once the step 3 run is successful and root directory is shown in command line<br/>
Step 4. `cd /home/rstudio`<br/>
Step 5. `Rscript main.R`<br/>

