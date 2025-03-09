# Test cases for the generate_report function

suppressPackageStartupMessages({
  library(testthat)
  library(mockery)
})

# Find the installation location
report_home <- Sys.getenv("REPORT_GENERATOR_HOME", "")
templ <- file.path(report_home, "templates/report_template.qmd")
info <- file.path(report_home, "templates/physician_info_template.qmd")

if (report_home == "") {
  # If not set, try to determine from current directory
  if (endsWith(getwd(), "tests")) {
    # If we're in the tests directory, go up one level
    report_home <- dirname(getwd())
  } else {
    # Just use current directory
    report_home <- getwd()
  }
  cat("REPORT_GENERATOR_HOME not set, using:", report_home, "\n")
}

lib_path <- file.path(report_home, "lib", "generate_report.R")

if (!file.exists(lib_path)) {
  stop("Cannot find generate_report.R script at: ", lib_path, 
       "\nPlease set REPORT_GENERATOR_HOME environment variable.")
} else {
  source(lib_path)
}

# Use the real example data instead of mock data
test_abundance_path <- file.path(report_home, "tests", "abundancetable.txt")

if (!file.exists(test_abundance_path)) {
  # If the example file doesn't exist, create a temporary one with the correct structure
  cat("Example abundance table not found, creating a temporary one\n")
  test_abundance_path <- tempfile(fileext = ".txt")
  
  # Create test data matching your real data structure
  mock_abundance <- data.frame(
    name = c("Bacteroidetes", "Firmicutes", "Proteobacteria", "Parabacteroides", 
             "Odoribacter", "Blautia", "Faecalibacterium", "Verrucomicrobia",
             "Anaerostipes", "Lactobacillus", "Roseburia", 
             "Akkermansia municiphila", "Dorea formicigenerans"),
    rank = c("P", "P", "P", "G", "G", "G", "G", "P", "G", "G", "G", "S", "S"),
    SampleP001.kraken2.report_bracken = c(45.23, 38.76, 5.42, 3.81, 0.92, 5.18, 
                                        8.35, 1.25, 1.86, 0.42, 4.53, 1.14, 0.63),
    SampleP002.kraken2.report_bracken = c(32.18, 49.35, 7.21, 2.14, 0.38, 7.65, 
                                        11.27, 3.76, 2.45, 1.58, 3.98, 3.65, 0.72)
  )
  
  # Write the test data to a file
  write.table(mock_abundance, file = test_abundance_path, sep = "\t", 
              row.names = FALSE, quote = FALSE)
}

# Test that the generate_report function runs without errors when mocked
test_that("generate_report runs without errors", {
  # Mock both the system call and file writing
  stub(generate_report, "system", function(cmd) 0)
  stub(generate_report, "writeLines", function(...) NULL)
  
  # Should run without error - provide all required arguments
  expect_error(
    generate_report(
      ab_path = test_abundance_path,
      template_path = templ,
      infosheet_path = info,
      output_dir = "test_reports",
      sample_prefix = "Sample"
    ), 
    NA
  )
})

# Test that the output directory is created
test_that("output directory is created", {
  output_dir <- "test_reports"
  if (dir.exists(output_dir)) {
    unlink(output_dir, recursive = TRUE)
  }
  
  # Mock system calls but allow directory creation
  stub(generate_report, "system", function(cmd) 0)
  stub(generate_report, "writeLines", function(...) NULL)
  
  # Pass all required arguments
  generate_report(
    ab_path = test_abundance_path,
    template_path = templ,
    infosheet_path = info,
    output_dir = output_dir,
    sample_prefix = "Sample"
  )
  
  expect_true(dir.exists(output_dir))
  unlink(output_dir, recursive = TRUE)
})

# Test error handling
test_that("generate_report handles invalid file paths", {
  # This test should pass since we expect an error
  nonexistent_file <- tempfile(fileext = ".txt")  # This file doesn't exist
  
  suppressWarnings(
    expect_error(
      generate_report(
        ab_path = nonexistent_file,
        template_path = templ,
        infosheet_path = info
      ),
      regexp = "cannot open|No such file"
    )
  )
})