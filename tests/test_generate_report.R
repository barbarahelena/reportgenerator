# Test cases for the generate_report function

library(testthat)

# Load the function to be tested
source("../src/generate_report.R")

# Define a temporary abundance table for testing
temp_abundance_table <- tempfile(fileext = ".txt")
write.table(data.frame(Sample1 = c(1, 2, 3), Sample2 = c(4, 5, 6)), 
            file = temp_abundance_table, 
            row.names = FALSE, 
            sep = "\t")

# Test that the generate_report function runs without errors
test_that("generate_report runs without errors", {
  expect_error(generate_report(temp_abundance_table), NA)
})

# Test that the output directory is created
test_that("output directory is created", {
  output_dir <- "reports"
  if (dir.exists(output_dir)) {
    unlink(output_dir, recursive = TRUE)
  }
  generate_report(temp_abundance_table)
  expect_true(dir.exists(output_dir))
})

# Clean up temporary files
unlink(temp_abundance_table)