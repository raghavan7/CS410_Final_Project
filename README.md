### CS 410 Final Project
### Final Project Submission for Suganya Somu (SSOMU2) and Raghavendran Ramasubramanian (RR26)

A video presentation demonstrating usage of the software is available at [Link](https://youtube)

### 1) Docker Image setup steps for execution for Graders

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
