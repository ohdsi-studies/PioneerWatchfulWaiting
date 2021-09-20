Docker container instructions
=============================

This folder contains a number of files that can help you to run the study package within a Docker container.
Ready-to-go containers are also published on [Docker Hub](https://hub.docker.com/repository/docker/keesvanbochove/pioneer-package).

# Instructions
These instructions assume you would like to use the published container, but of course
you can also choose to build it from source yourself using the provided `Dockerfile`.

## 1. Supply configuration variables and create the cointainer
You can use the file `pioneer-package.env` in this folder to update environment variables
needed to run the study. Please copy it to a file named `.env` and fill in your details.
You can then create and start the container using the following command:
```
docker run -itd --env-file .env --name pioneer keesvanbochove:pioneer-package
```
Note that depending on your Docker configuration you may need to add other arguments, such as the target network.

## 2. Copy your private SFTP upload key to the container
```
docker cp study-data-site-pioneer pioneer:/
```

## 3. Run the study
You can use the following command to attach to the R session started within the container:
```
docker attach pioneer
```
You can now follow the instructions in `extras/CodeToRun.R` from section 2 on as if you were running locally.

A few comments:
* If you want to temporarily return to your command line but keep the container running, the default detach sequence is `CTRL-p CTRL-q`
* Please don't forget to run the `uploadDiagnosticsResults` and `uploadStudyResults` commands to upload to the OHDSI SFTP server! This requires your container to have internet connection.
* If you exit the R session (using `q()`), the container will be stopped, so don't do that until you are finished.

## 4. Copy the results out of the container onto your filesystem
By default, the results are in a folder named identical to your database ID.
So if your database ID is `SP` and you would like to copy the result folder to your current path, you would run:
```
docker cp pioneer:/SP .
```

5. Destroy the container
After you copied and inspected the results, you can safely destroy the container.
However, this will not delete the results in the result tables in your database (see `COHORT_SCHEMA`).
```
docker rm pioneer
```