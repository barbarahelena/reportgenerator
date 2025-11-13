# File: /generate-reports-cli/run.R

# Check required packages and load silently
required_packages <- c("dplyr", "stringr", "ggplot2", "optparse", "forcats", "tidyr", "vegan", "rmarkdown")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(paste("Package", pkg, "is required but not installed.\n"))
    cat(paste("Installing", pkg, "package...\n"))
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

# Load packages without startup messages
suppressPackageStartupMessages({
  library(optparse)
})

# Get the installation and work directory
report_home <- Sys.getenv("REPORT_GENERATOR_HOME", getwd())
# cat(paste0("This is the home folder I'm using: ", report_home, "\n"))
work_dir <- Sys.getenv("WORKING_DIR", "")

# Define command-line options with proper default paths
option_list <- list(
  make_option(c("-a", "--abundance"), 
              type = "character", 
              help = "[REQUIRED] Path to the abundance table"),
              
  make_option(c("-t", "--test"), 
              action = "store_true", 
              default = FALSE, 
              help = "Run tests instead of normal operation"),
              
  make_option(c("-p", "--template"), 
              type = "character", 
              default = file.path(report_home, "templates/report_template.qmd"), 
              help = "Path to the report template [default: installed template]"),
              
  make_option(c("-i", "--infosheet"), 
              type = "character", 
              default = file.path(report_home, "templates/physician_info_template.qmd"), 
              help = "Path to the infosheet template [default: installed template]"),
              
  make_option(c("-o", "--output"), 
              type = "character", 
              default = "reports", 
              help = "Output directory [default: %default]"),
              
  make_option(c("-s", "--sample"), 
              type = "character", 
              default = "none", 
              help = "Sample prefix [default: %default]"),
  
  make_option(c("-l", "--language"), 
            type = "character", 
            default = "en", 
            help = "Report language, comma-separated for multiple [default: %default, options: en, he, ru, ar]")
)

# Parse command-line options
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)
  
# Check if --test flag is present
if (opt$test == TRUE) {
    # Run tests instead of normal operation
    cat("Running tests...\n")
    
    # Check testing packages
    test_packages <- c("testthat", "mockery", "R6")
    for (pkg in test_packages) {
      if (!requireNamespace(pkg, quietly = TRUE)) {
        cat(paste(pkg, "package is required for testing but not installed.\n"))
        cat(paste("Installing", pkg, "package...\n"))
        install.packages(pkg, repos = "https://cloud.r-project.org")
      }
    }
    
    # Load testing packages silently
    suppressPackageStartupMessages({
      library(testthat)
      library(R6)
    })
    
    # Simplified reporter that just tracks if any tests failed
  SimpleFailureReporter <- R6::R6Class("SimpleFailureReporter",
    inherit = testthat::Reporter,
    public = list(
      any_failures = FALSE,
      
      add_result = function(context, test, result) {
        # Check for failure based on class
        if (inherits(result, "expectation_failure") || 
            inherits(result, "expectation_error")) {
          self$any_failures <- TRUE
          
          # Print failure information
          cat("\n❌ FAILURE in test:", test, "\n")
          if (!is.null(result$message)) {
            cat("Message:", result$message, "\n\n")
          }
        }
      },
      
      end_reporter = function() {
        # Nothing to do here
      }
    )
  )

  # Create an instance of our simplified reporter
  reporter <- SimpleFailureReporter$new()

  # Run tests and capture any errors in the process
  test_error_occurred <- FALSE
  testpath <- file.path(report_home, "tests", "test_generate_report.R")
  tryCatch({
    # Run the tests with our reporter
    testthat::test_file(testpath, reporter = reporter)
  }, error = function(e) {
    cat("\n❌ ERROR running tests:", conditionMessage(e), "\n\n")
    test_error_occurred <- TRUE
  })

  # Check if any failures occurred
  if (reporter$any_failures || test_error_occurred) {
    cat("\n❌ Tests failed!\n")
    quit(status = 1)
  } else {
    cat("\n✅ All tests passed!\n")
    quit(status = 0)
  }
} else {
  # Normal operation
  if (!is.null(opt$abundance)) {
    abundance_table_path <- opt$abundance
    if(!is.null(opt$output)) { output_dir <- file.path(work_dir, opt$output) } else{
      output_dir <- file.path(work_dir, "reports")
    }
    template_dir <- ifelse(!is.null(opt$template), opt$template, file.path(report_home, "templates/report_template.qmd"))
    info_dir <- ifelse(!is.null(opt$template), opt$infosheet, file.path(report_home, "templates/physician_info_template.qmd"))
    sample_prefix <- ifelse(is.null(opt$sample), "", opt$sample)
    path_to_script <- file.path(report_home, "lib/generate_report.R")
    source(path_to_script)
    
    # Split language parameter into a vector
    languages <- unlist(strsplit(opt$language, ","))
    languages <- trimws(languages)  # Remove any whitespace
    
    generate_report(opt$abundance, template_dir, info_dir, 
        output_dir, sample_prefix, language = languages)
  } else{
    print_help(opt_parser)
    stop("Abundance table path is required.")
  }
}