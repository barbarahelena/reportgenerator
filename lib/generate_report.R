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
                            sample_prefix) {
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
  "% Modern font packages",
  "\\usepackage{fontspec}",
  "\\usepackage{unicode-math}",
  "\\setmainfont{Roboto}",
  "\\setsansfont{Montserrat}",
  "",
  "% Define alternative fallback in case fonts aren't found",
  "\\newfontfamily\\fallbackfont{DejaVu Sans}[Scale=MatchLowercase]",
  "",
  "% Set appropriate margins",
  "\\usepackage[top=1in, bottom=1in, left=1in, right=1in]{geometry}",
  "",
  "\\usepackage{fancyhdr}",
  "\\usepackage{graphicx}",
  "\\usepackage{float}",
  "\\usepackage{xcolor}",
  "\\usepackage{titlesec}",
  "\\usepackage{tcolorbox}",
  "\\usepackage{enumitem}",
  "\\usepackage{booktabs}",
  "\\usepackage{microtype}",
  "\\usepackage{hyperref}",
  "",
  "% Define colors",
  "\\definecolor{maincolor}{RGB}{0, 114, 181}      % Main blue",
  "\\definecolor{accentcolor}{RGB}{225, 135, 39}   % Orange accent",
  "\\definecolor{lightgray}{RGB}{245, 245, 245}    % Light background",
  "\\definecolor{goodcolor}{RGB}{32, 133, 78}      % Green for good metrics",
  "\\definecolor{warncolor}{RGB}{188, 60, 41}      % Red for warning metrics",
  "",
  "% Custom section styling with more modern look",
  "\\titleformat{\\section}",
  "  {\\color{maincolor}\\sffamily\\Large\\bfseries}",
  "  {\\thesection}{1em}{}[\\titlerule]",
  "",
  "\\titleformat{\\subsection}",
  "  {\\color{maincolor}\\sffamily\\large\\bfseries}",
  "  {\\thesubsection}{1em}{}",
  "",
  "% Adjust header and footer to fit with margins",
  "\\pagestyle{fancy}",
  "\\fancyhf{}",
  "\\renewcommand{\\headrulewidth}{0.4pt}",
  "\\renewcommand{\\footrulewidth}{0.4pt}",
  "\\setlength{\\headheight}{15pt}",
  "",
  "\\fancyhead[L]{Elinav Lab}",
  "\\fancyhead[C]{\\sffamily Microbiome Analysis}",
  sprintf("\\fancyhead[R]{\\textit{%s}}", date_string),
  "\\fancyfoot[C]{\\thepage}",
  "\\fancyfoot[L]{\\textcolor{maincolor}{\\sffamily Confidential}}",
  "",
  "% Custom boxes with more modern styling",
  "\\newtcolorbox{infobox}{",
  "  colback=lightgray,",
  "  colframe=maincolor,",
  "  boxrule=1pt,",
  "  arc=2mm,",
  "  boxsep=5pt,",
  "  left=10pt,",
  "  right=10pt,",
  "  title=Key Findings,",
  "  fonttitle=\\sffamily\\bfseries\\color{maincolor}",
  "}",
  "",
  "\\newtcolorbox{warningbox}{",
  "  colback=white,",
  "  colframe=accentcolor,",
  "  boxrule=1pt,",
  "  arc=2mm,",
  "  boxsep=5pt,",
  "  left=10pt,",
  "  right=10pt,",
  "  title=Important Note,",
  "  fonttitle=\\sffamily\\bfseries\\color{accentcolor}",
  "}",
  "% Modern table styling",
  "\\renewcommand{\\arraystretch}{1.2}",
  "\\setlength{\\tabcolsep}{8pt}",  # Adjusted from 12pt to 8pt for better fit
  "",
  "% Ensure figures stay where placed",
  "\\floatplacement{figure}{H}"
)
  report_home <- Sys.getenv("REPORT_GENERATOR_HOME", getwd())
  work_dir <- Sys.getenv("WORKING_DIR", getwd())
  writeLines(preamble_content, file.path(report_home, "/templates/preamble.tex"))

  # Loop through participants and make report
  dir.create(output_dir, showWarnings = FALSE)
  setwd(report_home)
  cat(paste0(ab_path, "\n"))
  for (participant_id in colnames(abdata_filt)) {
    output_file <- paste0("report_", participant_id, ".pdf")
    command <- paste0("quarto render ", template_path, 
                  " --pdf-engine=lualatex",
                  " -P participant_id:'", participant_id, "'",
                  " -P abundance_file_path:'", ab_path, "'",
                  " -P sample_prefix:'", sample_prefix, "'",
                  " --output ", output_file)
    system(command)
    system(paste0("mv ", output_file, " ", output_dir))
  }

  # Generate information sheet for physicians
  command <- paste0("quarto render ", infosheet_path, 
                            " --output physician_info.pdf",
                            " --pdf-engine=lualatex")
  system(command)
  system(paste0("mv physician_info.pdf ", output_dir))

  cat("")
}