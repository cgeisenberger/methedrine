# Author: Christoph Geisenberger
# URL: https://github.com/cgeisenberger/methedrine



# attach packages -----

library(shiny)
library(shinythemes)
library(shinyjs)
library(uuid)
library(tidyverse)
library(crystalmeth)



# set global parameters -----

# max 30 Mb uploads
options(shiny.maxRequestSize = 30*1024^2)
upload_dir <- "./uploads/"
report_dir <- "./reports/"

# attach report template
report_template <- "/Users/cge/Dropbox/Research/software/methedrine/temp/netid_report.Rmd"

# create folders if necessary
if (!dir.exists(upload_dir)){
  cat("Upload directory doesn't exist and will be created")
  dir.create(upload_dir)
}

if (!dir.exists(report_dir)){
  cat("Report directory doesn't exist and will be created")
  dir.create(report_dir)
}


# attach randomForest object
load("/Users/cge/Dropbox/Research/software/methedrine/temp/NetID_v1.RData")

# rename for convenience
classifier <- net_id_v1
rm(net_id_v1)



# server -----

server <- function(input, output, session) {
  
  observe({
    
    # return if nothing happens
    if (is.null(input$upload)) {
      return()
    } else {
      
      # disable download button (reset if user performs multiple uploads)
      shinyjs::disable("download_reports")
      
      # validate uploaded files -----
      
      # assign UUID and time stamp to upload
      job_id <- uuid::UUIDgenerate()
      time <- Sys.time()
      
      # extract temp directory of uploaded files
      temp_dir <- input$upload$datapath
      
      # create a new directory for uploaded files and output
      job_dir <- file.path(upload_dir, job_id)
      dir.create(job_dir)
      
      # copy files
      files <- input$upload$name
      file.copy(from = temp_dir, 
                to = file.path(job_dir, files))
      
      # scan and validate uploaded files
      queue <- scan_directory(dir = job_dir)
      
      # extract valid classification cases
      basenames <- get_cases(queue)
      n_samples <- length(basenames)
      
      # list invalid files and cases
      files_invalid <- c(get_invalid(queue), get_red_only(queue), get_green_only(queue))
      n_invalid <- length(files_invalid)
      
      # check if valid cases have been uploaded
      if (n_samples == 0) {
        msg <- "Error: No valid paired IDAT files, aborting..."
        showNotification(ui = msg, duration = NULL, type = "error")
        return()
      }
      
      # check if non-IDAT or unpaired IDAT files are present
      if (n_invalid != 0){
        msg <- paste0("Warning: Detected ", n_invalid, " invalid (unpaired or non-IDAT) files.")
        showNotification(ui = msg, duration = NULL, type = "warning")
      }
      
      # sample processing -----
      cases <- lapply(X = as.list(basenames), ClassificationCase$new, path = job_dir)
      lapply(cases, FUN = function(x){x$run_workflow(rf_object = classifier)})
      
      # generate reports -----
      out_files <- lapply(cases, FUN = function(x){render_report(case = x,
                                                                 template = "./temp/netid_report.Rmd",
                                                                 out_dir = file.path(report_dir, job_id),
                                                                 out_type = input$report_format)})
      
      # prepare download -----
      out_zip <- file.path(report_dir, job_id, "results.zip")
      zip(zipfile = out_zip, files = unlist(out_files), flags = "-j")

      # enable downloads after archive has been created
      shinyjs::enable("download_reports")
      
      # create download handler
      output$download_reports <- downloadHandler(
        
        filename = function() {
          return("results.zip")
        },
        
        content = function(file) {
          file.copy(from = out_zip, to = file)
        }
      )
    }
  })
  
  # disable the downdload button on page load
  shinyjs::disable("download_reports")
  
  
  
}



# User interface -----

ui <- fluidPage(theme = shinytheme("spacelab"),
                
  tags$head(
    tags$style(
      HTML(".shiny-notification {
      position:fixed;
      top: calc(25%);
      left: calc(50%);
      }")
      )
    ),             
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
                label = "Upload IDAT Files",
                multiple = TRUE,
                accept = c("application/idat")
                ),
      
      # Input: Report file format ----
      "Select file format for reports:",
      
      selectInput(inputId = "report_format",
                  label = NULL,
                  choices = c("pdf", "html"),
                  selected = "pdf",
                  multiple = FALSE),
      
      # Download button
      downloadButton("download_reports")
    ),
    
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Empty field for now
      textOutput(outputId = "test"),

    )
    
  )
)


#--------------#
### Run App ####
#--------------#

shinyApp(ui = ui, server = server)

