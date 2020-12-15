# Author: Christoph Geisenberger
# URL: https://github.com/cgeisenberger/methedrine



# dependencies -----

# IMPORTANT NOTE
# Loading of some libraries has been moved to a different section (observer: upload)
# to allow for faster loading of the online application


# add Bioconductor repositories (otherwise, deployment crashes)
library(BiocManager)
options(repos = BiocManager::repositories())

# attach packages
library(shiny)
library(shinythemes)
library(shinyjs)
library(uuid)
library(tidyverse)

# import helper functions
source("./global.R")



# set global parameters -----

# shiny parameters
options(shiny.maxRequestSize = 30*1024^2)

# set i/o directories
upload_dir <- "./uploads/"
report_dir <- "./reports/"

# create if directories do not exist yet
dir_create2(upload_dir)
dir_create2(report_dir)

# report template
report_template <- "./included/nen_id_template_html.Rmd"

# load classifier
classifier <- readRDS(file = "./included/rf_model.rds")
calibration_model <- readRDS(file = "./included/calibration_model.rds")

# limit for samples
n_limit <- 10


# server -----

server <- function(input, output, session) {
  
  # disable the download and submit button on page load
  shinyjs::disable("download_reports")
  shinyjs::disable("submit")
  
  # create container for reactive variables
  job <- reactiveValues()
  
  # observer: upload ----
  observe({
    
    # return if nothing happens
    if (is.null(input$upload)) {
      return()
    } else {
      
      # load necessary libraries
      library(crystalmeth)
      library(glmnet)
      library(conumee)
      
      # disable download button if other cases have already been processed
      shinyjs::disable("download_reports")
      
      # assign UUID to job and create dir
      job$id <- uuid::UUIDgenerate()
      job_dir <- file.path(upload_dir, job$id)
      dir.create(job_dir)
      
      # copy files
      temp_dir <- input$upload$datapath
      file.copy(from = temp_dir, 
                to = file.path(job_dir, input$upload$name))
      
      # scan uploaded files
      queue <- scan_directory(dir = job_dir)
      basenames <- get_cases(queue)
      n_samples <- length(basenames)
      files_invalid <- c(get_invalid(queue), get_red_only(queue), get_green_only(queue))
      n_invalid <- length(files_invalid)
      
      # react to upload -----
      # display error and abort if there are no valid samples
      # display warning if there are valid AND invalid samples
      # create ClassificationCase objects for every pair of IDAT files
      if (n_samples == 0) {
        msg <- "Error: Upload does not contain valid pairs of IDAT files"
        showNotification(ui = msg, duration = NULL, type = "error")
        return()
      } else {
        # display warning if invalid files are present
        if (n_invalid != 0){
          # do this if all files are valid
          msg <- paste0("Warning: Detected ", n_invalid, " invalid (unpaired or non-IDAT) files.")
          showNotification(ui = msg, duration = NULL, type = "warning")
        } 
        # check if uploaded samples exceed the limit (n = 10)
        if (n_samples > n_limit) {
            msg <- paste0("Upload is limited to ", n_limit, " samples. Skipping remainder")
            showNotification(ui = msg, duration = NULL, type = "warning")
            job$n <- n_limit
            job$cases <- lapply(X = as.list(basenames[1:n_limit]), ClassificationCase$new, path = job_dir)
          } else {
            job$n <- n_samples
            job$cases <- lapply(X = as.list(basenames), ClassificationCase$new, path = job_dir)
          }
      }
      print(job$cases)
      shinyjs::enable("submit")
    }
  })
  
  # observer: process samples when submit button is clicked -----
  observeEvent(input$submit, {
    shinyjs::disable("submit")
    
    # create and initiate progress indicator
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Processing sample(s)", value = 0)

    # create empty list for results
    processed_data <- vector("list", length = job$n)

    # process samples
    for (i in 1:(job$n)){
      processed_data[[i]] <- job$cases[[i]]$run_full_workflow(
        rf_model = classifier, 
        calibration_model = calibration_model)
      progress$inc(1/(job$n), detail = paste(i + 1, " of ", job$n))
    }
    
    # create reactive value from data
    job$data <- processed_data
    })
  
  # observer: render reports when data or format is changed -----
  observeEvent(job$data, {
      
      # return if data has not been processed (initial setting of format causes triggering otherwise)
      if (is.null(job$data)) return()
      
      # disable downloads:
      # if this is the first iteration, no noticeable change for user
      # in case output file format is changed, previous download is disabled, 
      # and re-enabled with new format after rendering of the reports is done
      shinyjs::disable("download_reports")
      
      # create and initiate progress indicator
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "Rendering report(s)", value = 0)
      
      # create reports
      out_files <- vector("list", length = job$n)
      
      for (i in 1:(job$n)){
        out_files[[i]] <- render_report(case = job$data[[i]],
                                        input = report_template, 
                                        output_dir = file.path(report_dir, job$id),
                                        output_file = paste0(job$data[[i]]$array_basename, ".html"))
        progress$inc(1/(job$n), detail = paste(i+1, " of ", job$n))
      }

      # prepare download
      out_zip <- file.path(report_dir, job$id, "results.zip")
      if(file.exists(out_zip)) file.remove(out_zip)
      
      zip(zipfile = out_zip, files = unlist(out_files), flags = "-j")
      
      # create download file handler
      output$download_reports <- downloadHandler(
      
      filename = function() {
        return("results.zip")
      },
      
      content = function(file) {
        file.copy(from = out_zip, to = file)
      }
    )
    
    # enable downloads after archive has been created
    shinyjs::enable("download_reports")
    
  })
}



# User interface -----

ui <- fluidPage(theme = shinytheme("spacelab"),
                
  # load shinyjs
  shinyjs::useShinyjs(),
  
  # App title ----
  titlePanel("NEN-ID: Methylation classification for neuroendocrine tumors"),
  
  # Header  -----
  # currently empty 
  
  
  # Add some space ----
  br(),
  br(),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: File upload ----
      fileInput(inputId = "upload", 
                label = "Step 1: Upload IDAT Files",
                multiple = TRUE,
                accept = c("application/idat")
                ),
      
      
      # Input: Report file format ----
      # radioButtons(inputId = "report_format",
      #              label = "Step 2: Choose report file format",
      #              choices = c("html", "pdf"),
      #              selected = "html"),
      # 
      # br(),
      
      # Input: Action button to start processing -----
      fluidRow(align="center",
        actionButton(inputId = "submit",
                     label = "Step 2: Submit job")
      ),
      
      br(),
      br(),
      
      # Download button
      fluidRow(align="center",
               downloadButton(outputId = "download_reports",
                              label = "Step 3: Download")
      ),
      
      hr(),
      
      "Note: There is a small delay between uploading and activation of 
      submit button. Also, processing samples of can be slow!"
        
      
    ),
    
    
    # Main panel for displaying outputs ----
    mainPanel(includeMarkdown("./contents/howto.md"))
    
  )
)



# Run App -----

shinyApp(ui = ui, server = server)

