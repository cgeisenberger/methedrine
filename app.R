# Author: Christoph Geisenberger
# URL: https://github.com/cgeisenberger/methedrine



# dependencies -----

# load crystalmeth
library(crystalmeth)

# attach packages
library(shiny)
library(shinythemes)
library(shinyjs)
library(uuid)
library(tidyverse)

# add Bioconductor repositories (otherwise, deployment crashes)
library(BiocManager)
options(repos = BiocManager::repositories())

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
report_template <- "./included/netid_report.Rmd"

# load classifier
classifier <- readRDS(file = "./included/net_id_v1.rds")



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
      n_samples <- length(get_cases(queue))
      basenames <- get_cases(queue)
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
        # check if non-IDAT or unpaired IDAT files are present
        if (n_invalid != 0){
          msg <- paste0("Warning: Detected ", n_invalid, " invalid (unpaired or non-IDAT) files.")
          showNotification(ui = msg, duration = NULL, type = "warning")
        } else {
          job$cases <- lapply(X = as.list(basenames), ClassificationCase$new, path = job_dir)
          shinyjs::enable("submit")
        }
      }
    }
  })
  
  # observer: process samples when submit button is clicked -----
  observeEvent(input$submit, {
    shinyjs::disable("submit")

    # process samples
    job$data <- lapply(job$cases, FUN = function(x){x$run_workflow(rf_object = classifier)})
    })
  
  # observer: render reports when data or format is changed -----
  observeEvent({
    # observe both data object and report format object
    job$data
    input$report_format
    },{
      
      # return if data has not been processed (initial setting of format causes triggering otherwise)
      if (is.null(job$data)) return()
      
      # disable downloads:
      # if this is the first iteration, no noticeable change for user
      # in case output file format is changed, previous download is disabled, 
      # and re-enabled with new format after rendering of the reports is done
      shinyjs::disable("download_reports")
      
      # create reports
      out_files <- lapply(job$cases, FUN = function(x){render_report(case = x,
                                                                     template = report_template,
                                                                     out_dir = file.path(report_dir, job$id),
                                                                     out_type = input$report_format)})
      print(out_files)
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
  titlePanel("NET-ID: Methylation classification for neuroendocrine tumors"),
  
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
      radioButtons(inputId = "report_format",
                   label = "Step 2: Choose report file format",
                   choices = c("html", "pdf"),
                   selected = "html"),
      
      br(),
      
      # Input: Action button to start processing -----
      fluidRow(align="center",
        actionButton(inputId = "submit",
                     label = "Step 3: Submit job")
      ),
      
      hr(),
      
      # Download button
      fluidRow(align="center",
               downloadButton(outputId = "download_reports",
                              label = "4: Start Download")
      ),
      
      hr(),
      
      "Note: Refresh page to start new session"
      
    ),
    
    
    # Main panel for displaying outputs ----
    mainPanel(includeMarkdown("./contents/howto.md"))
    
  )
)



# Run App -----

shinyApp(ui = ui, server = server)

