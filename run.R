# File: /generate-reports-cli/run.R

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  stop("Usage: Rscript run.R <abundance_table_path> [<template_path> <infosheet_path> <output_dir>]")
}

abundance_table_path <- args[1]
template_path <- ifelse(length(args) >= 2, args[2], "templates/report_template.qmd")
infosheet_path <- ifelse(length(args) >= 3, args[3], "templates/physician_info_template.qmd")
output_dir <- ifelse(length(args) >= 4, args[4], "reports")

source("src/generate_report.R")

generate_report(abundance_table_path, template_path, infosheet_path, output_dir)