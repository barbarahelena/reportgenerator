# filepath: /generate-reports-cli/generate-reports-cli/src/generate_report.R
# Script to generate reports from a kraken-style bracken abundance table

generate_report <- function(ab_path, template_path = "../templates/report_template.qmd", 
                            infosheet_path = "../templates/physician_info_template.qmd",
                            output_dir = "reports") {
  library(dplyr)
  library(stringr)

  # Read the abundance table to obtain the list of participant ids
  abdata <- read.delim(ab_path)
  abdata_filt <- abdata %>% select(contains("report_bracken")) %>%
    rename_at(c(colnames(.)[which(str_detect(colnames(.), 'report_bracken'))]), 
                ~str_remove(str_remove(.x, 'Sample'), '.kraken2.report_bracken'))

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
  writeLines(preamble_content, "scripts/preamble.tex")

  # Loop through participants and make report
  dir.create(output_dir, showWarnings = FALSE)
  for (participant_id in colnames(abdata_filt)) {
    output_file <- paste0("report_", participant_id, ".pdf")
    command <- paste0("quarto render ", template_path, " -P participant_id:'", participant_id, "'",
                      " -P abundance_file_path:'", ab_path, "'",
                      " --output ", output_dir, "/", output_file)
    system(command)
  }

  # Generate information sheet for physicians
  command <- paste0("quarto render ", infosheet_path, " --output ", output_dir, "/physician_info.pdf")
  system(command)
}