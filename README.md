### CS 410 Final Project (**Work In Progress**)
### Final Project Submission for Suganya Somu (SSOMU2) and Raghavendran Ramasubramanian (RR26)

A video presentation demonstrating usage of the software is available at [Link](https://youtube)

## Project Structure

```plaintext
├── main.R                                            <-- contains files that might be useful to refer back to
├── vocab_creation.R                                  <-- contains files that might be useful to refer back to
├── run_docker.sh                                       <-- contains files that might be useful to refer back to
├── Dockerconfig
|    |
|    └── requirements.R                               <-- helper function for managing configurations
├── data
|    |
|    ├── split* 
|    |    ├── DDL                     <-- contains DDL scripts
|    |    ├── DML                     <-- contains DML scripts for dags
|    |    ├── initial_load            <-- contains initial load scripts for dags
|    |    ├── KPI                     <-- contains KPI scripts
|    |    └── queries                 <-- contains scripts used for running the model
|    ├── alldata.tsv
|    └── splits.csv
├── Project Progress Report - Sentients.pdf 
├── Project Proposal - Sentients.pdf 
├── Dockerfile                          <-- configuration for Docker image
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

