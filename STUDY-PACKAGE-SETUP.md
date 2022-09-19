Installing the study package using renv
===========================================================================================
  
The following steps will detail how to set up the package using [renv](https://rstudio.github.io/renv/articles/renv.html).

# Package Installation

This section will detail the process for installing the package along with all of the R package dependencies using [renv](https://rstudio.github.io/renv/articles/renv.html). In short, we are using renv to encapsulate the R dependencies for this project in a way that will not disturb your other R depdencies.

The script below is an example to use for setting up your environment. There are some items to consider before moving ahead with the installation.

## Package setup considerations

- We will use `renv` to install the R package dependencies. You should refer to the [renv cache](https://rstudio.github.io/renv/articles/renv.html#cache) section to review how these files are stored for your operating system. If you need/want to change the default storage for your R packages, you will need to set the R `RENV_PATHS_ROOT` environment variable to different path.
- If you plan to run this package in an environment without Internet access, you should set the `RENV_PATHS_CACHE` to the `projectRootFolder` so that you can copy the contents of the `projectRootFolder` to the machine with access to your CDM to run the study. Additionally, you will want to make sure you download the `renv.lock` file from the computer with Internet access.
                                                                                                 
## Package setup steps

The setup script below is used to install the **SkeletonPredictionStudy** package. You will need to modify this setup script as follows:
                                                                                              
- Set the `projectRootFolder` variable to the directory specific to your environment. In this example we are using `C:/SkeletonPredictionStudy`. This root folder will serve a few purposes:
  - It will hold the R depdencies in subfolders in this directory.
  - It should be used to hold the output of running the study package.
- If you need to change the default location where `renv` will install the R package dependencies, uncomment out the line: `Sys.setenv("RENV_PATHS_ROOT"="C:\renv")` and replace `"C:\renv"` with your directory of choice.
- If you plan to run the package in an environment where there is no Internet access, uncomment out the line: `Sys.setenv("RENV_PATHS_CACHE"=projectFolder)`. This will ensure that all of the R package dependencies are copied to the `projectRootFolder`.
                                                                                              
Then execute the script as shown below:
                                                                                              
````
# If you don't have renv as an R library you need to install it:
install.packages("renv")

# renv will create an environemnt with all the R libraries and versions that
# were used by the original study developer (this is handy if the study needs to be run 
# in the future when new versions are available and may have different code that 
# causes a study to break)

# You need to specify a project folder for the renv (the study specific environment will be 
# save here) and you need to set you R working direcory to this location before running renv
projectFolder <- "C:/SkeletonPredictionStudy"
if(!dir.exists(projectFolder)){
dir.create(projectFolder,   recursive = T)
}
setwd(projectFolder)
                                                                                              
# Download the lock file:
download.file("https://raw.githubusercontent.com/ohdsi-studies/SkeletonPredictionStudy/main/renv.lock", "renv.lock")

# Build the local library into projectFolder (takes a while):
renv::init()

# (When not in RStudio, you'll need to restart R now)

# finally install the SkeletonPredictionStudy package
install.packages('devtools')
devtools::install_github('ohdsi-studies/SkeletonPredictionStudy')

library(SkeletonPredictionStudy)
````                                                                                                 
# -------------------------------------------------------------
# What to expect
# -------------------------------------------------------------
You will see the following message the first time you run `renv::init()`: 
  
  ````
> renv::init()

Welcome to renv!
  
It looks like this is your first time using renv. This is a one-time message,
briefly describing some of renv's functionality.

renv maintains a local cache of data on the filesystem, located at:

- "E:/renv"

This path can be customized: please see the documentation in `?renv::paths`.

renv will also write to files within the active project folder, including:

- A folder 'renv' in the project directory, and
- A lockfile called 'renv.lock' in the project directory.

In particular, projects using renv will normally use a private, per-project
R library, in which new packages will be installed. This project library is
isolated from other R libraries on your system.

In addition, renv will update files within your project directory, including:

- .gitignore
- .Rbuildignore
- .Rprofile

Please read the introduction vignette with `vignette("renv")` for more information.
You can also browse the package documentation online at https://rstudio.github.io/renv.
````

You can safely continue by pressing 'y' after this prompt since the renv.lock file is downloaded from the **SkeletonPredictionStudy** GitHub code repository. Once the installation is complete, you may need to restart R (if you are working outside of RStudio) and you should see this message:

````
Project 'C:/SkeletonPredictionStudy' loaded. [renv 0.x.y]
````

Now the study package is installed and ready to execute! 
