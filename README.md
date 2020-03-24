# Methedrine

Web application for methylation-based diagnostic profiling of tumors


## Introduction

This repository provides a web interface for the automated analysis of DNA methylation data for diagnostic purposes. More specifically, 
users can upload raw IDAT files for Illumina 450K and EPIC arrays. The samples are processed, classified and rendered as PDF or HTML reports (avaiable as an option). Once the processing is finished, the reports are made available for download as a zip file. The following sections provide more information about the underlying software and how to set up the web application. 

> Note: For full functionality, the software needs a template to generate reports and a classification model. Both of these are currently
> **not** part of the package but will be released after publication. Please contact @whackeng or @cgeisenberger for support. 


## Installing dependencies

### R packages

```{r}
install.packages("shiny", "shinythemes", "shinyjs", "tidyverse", "uuid")

# crystalmeth has to be installed from Github:
install.packages("devtools")
devtools::install_github("cgeisenberger/crystalmeth")
```

### Pandoc & pdflatex

`Crystalmeth` and `methedrine` use markdown-based templates to generate diagnostic reports. Therefore, addtional software is necessary to compile PDFs and HTML files. First, make sure `pandoc` is installed. For Mac OS users, this line of code will do the trick `brew install pandoc`. If that doesn't work, refer to the [Pandoc documentation](https://pandoc.org/installing.html) for more information.

Having `pandoc` installed will enable you to compile HTML reports. To be able to generate PDFs, tinytex is needed aswell, install via:

```{r}
install.packages("tinytex")
tinytex::install_tinytex()
```



## Running the application 


All the necessary code to run *methedrine* is contained in `app.R`. There are three ways to run the application: 

1. Direct download
  * Download the raw code from [github](https://raw.githubusercontent.com/cgeisenberger/methedrine/master/app.R)
  * copy into folder `path/to/app`
  * execute `runApp("path/to/app")`
2. Run directly
  * **always runs newest version**
  * execute `runGitHub( "methedrine", "cgeisenberger")`

