# libraries

library(shiny)
library(shinythemes)
library(uuid)
library(tidyverse)

source("./functions.R")

# GLOBAL PARAMETERS

options(shiny.maxRequestSize = 30*1024^2)
upload_dir = "./uploads/"



#--------------#
### Server #####
#--------------#

server <- function(input, output, session) {
  
  observe({
    
    # return if nothing happens
    if (is.null(input$upload)) {
      return()
    } else {
      
      # validate uploaded files -----
      
      # assign UUID and time stamp to upload
      uuid <- uuid::UUIDgenerate()
      time <- Sys.time()
      
      # copy uploaded files from TEMP to upload directory
      temp_dir <- input$upload$datapath
      
      job_dir <- file.path(upload_dir, uuid)
      dir.create(job_dir)
      
      files <- input$upload$name
      file.copy(from = temp_dir, 
                to = file.path(job_dir, files))
      
      # scan and validate uploaded files
      upload <- validate_upload(upload_dir = job_dir)
      
      # extract valid classification cases
      basenames <- get_cases(upload)
      n_samples <- length(basenames)
      
      # list invalid files and cases
      non_idat <- c(get_non_idat(upload), get_red_only(upload), get_green_only(upload))
      n_invalid <- length(non_idat)
      
      # check if valid cases have been uploaded
      if (n_samples == 0) {
        msg <- "Error: No valid paired IDAT files, aborting..."
        showNotification(ui = msg, duration = NULL, type = "error")
        return()
      }
      
      # check if non-IDAT or unpaired IDAT files are present
      if (n_invalid != 0){
        msg <- paste0("Warning: Detected ", n_invalid, " unpaired and/or non-IDAT files.")
        showNotification(ui = msg, duration = NULL, type = "warning")
        Sys.sleep(2)
      }
      
      # Display notification with number of classification cases
      msg <- paste0("Detected ", n_samples, " classification case(s). Starting processing.")
      showNotification(ui = msg, duration = NULL, type = "message")
      
      # break here for now
      Sys.sleep(5)
      stop("nananana")
      
      # sample processing -----
      cases <- lapply(X = as.list(bn), ClassificationCase$new, path = input_dir)
      lapply(cases, FUN = function(x){x$run_workflow(rf_object = rf)})
      
      
      # generate reports -----
      
      
    }
  })
}


#---------------------#
## User interface #####
#---------------------#

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
      
      # Input: Select a file ----
      fileInput(inputId = "upload", 
                label = "Upload IDAT Files",
                multiple = TRUE,
                accept = c("application/idat")
                ),
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Empty field for now
      textOutput(outputId = "test")
      
    )
    
  )
)


#--------------#
### Run App ####
#--------------#

shinyApp(ui = ui, server = server)

