#!/bin/bash
# This is s simple docker run command, broken up so you can read each bit
# -d flag runs in detatched mode
# use -it to start in interactive mode
# --rm removes the container on exit

#sudo docker run -d --rm \
#    -p 28787:8787 \                         # map ports
#    --name hello-world2 \                   # name container
#    -e USERID=$UID \                        # you need to share a UID so you can write to mount file on host
#    -e PASSWORD=SoSecret! \                   # set rstudio password - user is rstudio
#    -v $DATA_DIR:/home/rstudio/Data \       # mount data directory to pick up changes or write to host
#       rstudio/hello-world                  # the name of the image

# simple one-liner for command line copying
#DATA_DIR=${PWD}/Data docker run -d --rm -m 4g  -p 28787:8787 --name sentients -e USERID=$UID -e PASSWORD=SoSecret! -v $DATA_DIR:/home/rstudio/data rstudio/sentients

# this is an example of running the container in interactive mode and logging into a bash shell
DATA_DIR=${PWD}/Data docker run -it --rm -m 4g --name sentients -e USERID=$UID -v $DATA_DIR:/home/rstudio/data rstudio/sentients  /bin/bash 

# Below commands to be manually executed once docker is executed
# cd /home/rstudio
# Rscript main.R
