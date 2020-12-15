# Methedrine

`Methedrine` is a web application for methylation-based diagnostic profiling of tumors. It can be used to predict tissue origin for [neuroendocrine tumors](https://en.wikipedia.org/wiki/Neuroendocrine_tumor). The code used to produce the random forest classifier and calibration model can be found in the [NEN-ID repository](https://github.com/whackeng/NEN-ID). For more information, please refer to our publication ([Hackeng et al.]()).

> Note: Methedrine comes pre-packed with a html report template and a classifier + calibration models for neuroendocrine tumors. However, the application can easily be extended by replacing the objects declared in app.R. Please contact the package authors if you need help with the setup. 


## Introduction

This repository provides a web interface for the automated analysis of DNA methylation data for diagnostic purposes. More specifically, 
users can upload raw IDAT files for Illumina 450K and EPIC arrays. The samples are processed, classified and a HTML report is generated for every pair of input IDAT files. Once the processing is finished, the reports are made available for download as a `.zip` file. The following sections provide more information about the underlying software and how to set up the web application. 


## Installing dependencies

### R packages

```{r}
install.packages("shiny", "shinythemes", "shinyjs", "tidyverse", "uuid")

# crystalmeth has to be installed from Github:
install.packages("devtools")
devtools::install_github("cgeisenberger/crystalmeth")
```

### Pandoc & pdflatex

Crystalmeth` and `methedrine` use markdown-based templates to generate diagnostic reports. Therefore, addtional software is necessary to compile PDFs and HTML files. First, make sure `pandoc` is installed. For Mac OS users, this line of code will do the trick (assuming [Homebrew](https://brew.sh) is available on your system): `brew install pandoc`. If that doesn't work, refer to the [Pandoc documentation](https://pandoc.org/installing.html) for troubleshooting.

Having `pandoc` installed will enable you to compile HTML reports. To be able to generate PDFs, tinytex is needed aswell, install via:

```{r}
install.packages("tinytex")
tinytex::install_tinytex()
```


## Running the application 


All the necessary code to run *methedrine* is contained in `app.R`. There are three ways to run the application: 


### Local: direct download

* Download the raw code from [github](https://raw.githubusercontent.com/cgeisenberger/methedrine/master/app.R)
* copy into folder `path/to/app`
* execute `runApp("path/to/app")`


### Local: run from GitHub

> **recommended (always runs newest version)**

```{r}
library(shiny)
runGitHub( "methedrine", "cgeisenberger")
```


### Shinyapps.io



