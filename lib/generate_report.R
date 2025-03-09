#' Generate Reports from Kraken-Style Bracken Abundance Tables
#'
#' This function reads an abundance table and generates individual reports
#' for each participant using Quarto templates.
#'
#' @param ab_path Path to the abundance table file
#' @param template_path Path to the report template (Quarto document)
#' @param infosheet_path Path to the physician info template
#' @param output_dir Directory where reports will be saved
#' @param sample_prefix Prefix to remove from sample names (e.g., "Sample")
#'
#' @return Invisible NULL. The function's output is the generated report files.
#' @export
#'
#' @examples
#' \dontrun{
#' generate_report(
#'   "path/to/abundance_table.txt",
#'   template_path = "templates/report_template.qmd",
#'   output_dir = "reports",
#'   sample_prefix = "SampleP"
#' )
#' }
# Script to generate reports from a kraken-style bracken abundance table
generate_report <- function(ab_path, 
                            template_path, 
                            infosheet_path,
                            output_dir, 
                            sample_prefix = "Sample") {
# Read the abundance table to obtain the list of participant ids
abdata <- utils::read.delim(ab_path)

# Select columns containing "report_bracken" and rename them
bracken_cols <- grep("report_bracken", colnames(abdata), value = TRUE)
abdata_filt <- abdata[, bracken_cols, drop = FALSE]

if (length(bracken_cols) > 0) {
  # Create simplified names
  new_names <- gsub(paste0(sample_prefix, "(.+)\\.kraken2\\.report_bracken"), "\\1", bracken_cols)
  colnames(abdata_filt) <- new_names
}

  # Make header tex file
  date_string <- format(Sys.Date(), "%B %Y")
  preamble_content <- c(
    "\\usepackage{fancyhdr}",
    "\\usepackage{graphicx}",
    "\\usepackage{float}",
    "",
    "\\pagestyle{fancy}",
    "\\fancyhf{}", # clear all header and footer fields
    "\\renewcommand{\\headrulewidth}{0pt}",
    "\\renewcommand{\\footrulewidth}{0.4pt}",
    "",
    "\\fancyhead[L]{Elinav Lab}",
    "\\fancyhead[C]{Weizmann Institute of Science}",
    sprintf("\\fancyhead[R]{\\textit{%s}}", date_string),
    "\\fancyfoot[C]{\\thepage}"
  )
  report_home <- Sys.getenv("REPORT_GENERATOR_HOME", getwd())
  work_dir <- Sys.getenv("WORKING_DIR", getwd())
  writeLines(preamble_content, file.path(report_home, "preamble.tex"))

  # Loop through participants and make report
  dir.create(output_dir, showWarnings = FALSE)
  setwd(report_home)
  cat(paste0(ab_path, "\n"))
  for (participant_id in colnames(abdata_filt)[1]) {
    output_file <- paste0("report_", participant_id, ".pdf")
    command <- paste0("quarto render ", template_path, " -P participant_id:'", participant_id, "'",
                  " -P abundance_file_path:'", ab_path, "'",
                  " -P sample_prefix:'", sample_prefix, "'",
                  " --output ", output_file)
    system(command)
    system(paste0("mv ", output_file, " ", output_dir))
  }

  # Generate information sheet for physicians
  command <- paste0("quarto render ", infosheet_path, " --output ", "physician_info.pdf")
  system(command)
  system(paste0("mv physician_info.pdf ", output_dir))
}