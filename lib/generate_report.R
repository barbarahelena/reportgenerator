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
                            template_path = file.path(Sys.getenv("REPORT_GENERATOR_HOME", "."), "templates/report_template.qmd"),
                            infosheet_path = file.path(Sys.getenv("REPORT_GENERATOR_HOME", "."), "templates/physician_info_template.qmd"),
                            output_dir = "reports", 
                            sample_prefix = "Sample",
                            language = c("en")) {

  # Normalize ALL input paths to avoid symlink issues
  ab_path <- normalizePath(ab_path, mustWork = TRUE)
  template_path <- normalizePath(template_path, mustWork = TRUE)
  infosheet_path <- normalizePath(infosheet_path, mustWork = TRUE)
  
  abdata <- utils::read.delim(ab_path)
  bracken_cols <- grep("report_bracken", colnames(abdata), value = TRUE)
  abdata_filt <- abdata[, bracken_cols, drop = FALSE]
  if (length(bracken_cols) > 0) {
    new_names <- gsub(paste0(sample_prefix, "(.+)\\.kraken2\\.report_bracken"), "\\1", bracken_cols)
    colnames(abdata_filt) <- new_names
  }
  
  # Normalize environment paths 
  report_home <- normalizePath(Sys.getenv("REPORT_GENERATOR_HOME", getwd()), mustWork = TRUE)
  work_dir <- normalizePath(Sys.getenv("WORKING_DIR", getwd()), mustWork = TRUE)
  # cat("Using work dir:", work_dir, "\n")
  
  # Create and normalize output directory
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  output_dir <- normalizePath(output_dir, mustWork = TRUE)
  # cat("Using output dir:", output_dir, "\n")
  
  date_string <- format(Sys.Date(), "%B %Y")

  # Language mapping for folders and suffixes
  lang_map <- list(
    "en" = list(folder = "english", suffix = "_en"),
    "he" = list(folder = "hebrew",  suffix = "_he"),
    "ru" = list(folder = "russian", suffix = "_ru"),
    "ar" = list(folder = "arabic",  suffix = "_ar")
  )

  # For each language, create appropriate directories and render reports
  for (lang in language) {
    # Set up template path based on language - normalize all paths
    if (lang == "he") {
      template_path <- normalizePath(file.path(report_home, "templates/report_template_hebrew.qmd"))
      preamble_path <- file.path(report_home, "templates/preamble_hebrew.tex")
      
      # Try to detect available Hebrew fonts
      font_check <- system("fc-list | grep -i hebrew", intern = TRUE, ignore.stderr = TRUE)
      open_sans_check <- system("fc-list | grep -i 'open sans'", intern = TRUE, ignore.stderr = TRUE)
      
      # Set default Hebrew font
      hebrew_font <- "DejaVu Sans"  # Default final fallback
      
      # Check for common Hebrew fonts in preferred order
      if (length(font_check) > 0) {
        if (any(grepl("Noto Sans Hebrew", font_check))) {
          hebrew_font <- "Noto Sans Hebrew"
        } else if (any(grepl("David CLM", font_check))) {
          hebrew_font <- "David CLM"
        } else if (any(grepl("Frank Ruehl", font_check))) {
          hebrew_font <- "Frank Ruehl CLM"
        }
      }
      
      # Set fallback font to Open Sans if available
      fallback_font <- "DejaVu Sans"
      if (length(open_sans_check) > 0) {
        fallback_font <- "Open Sans"
      }
      
      cat("Using Hebrew font:", hebrew_font, "\n")
      cat("Using fallback font:", fallback_font, "\n")
      
      preamble_content <- c(
            "% Core packages",
            "\\usepackage{fontspec}",
            "\\usepackage{xcolor}",
            "\\usepackage{graphicx}",
            "\\usepackage{float}",
            "\\usepackage{tcolorbox}",
            "\\usepackage{fancyhdr}",
            "\\usepackage{titlesec}",
            "\\usepackage{hyperref}",
            "",
            "% RTL language support - proper RTL text direction and alignment",
            "\\usepackage{polyglossia}",
            "\\setmainlanguage[numerals=hebrew]{hebrew}",
            "\\setotherlanguage{english}",
            "",
            "% Define colors",
            "\\definecolor{maincolor}{RGB}{0, 114, 181}",
            "\\definecolor{accentcolor}{RGB}{225, 135, 39}",
            "\\definecolor{lightgray}{RGB}{245, 245, 245}",
            "\\definecolor{goodcolor}{RGB}{32, 133, 78}",
            "\\definecolor{warncolor}{RGB}{188, 60, 41}",
            "",
            "% Configure Hebrew fonts",
            "\\newfontfamily\\hebrewfont{Noto Sans Hebrew}[Script=Hebrew]",
            "\\newfontfamily\\hebrewfontsf{Noto Sans Hebrew}[Script=Hebrew]",
            "\\setmainfont{Noto Sans Hebrew}[Scale=1.1]",
            "\\newfontfamily\\montserratfont{Montserrat}[Scale=MatchLowercase]",
            "",
            "% Simple RTL text commands",
            "\\newcommand{\\texten}[1]{\\foreignlanguage{english}{#1}}",
            "\\newcommand{\\textentitle}[1]{\\foreignlanguage{english}{\\montserratfont\\bfseries #1}}",
            "",
            "% Basic document settings",
            "\\usepackage[top=1in, bottom=1in, left=1in, right=1in]{geometry}",
            "\\parindent=0pt",
            "\\parfillskip=0pt plus 1fil",
            "",
            "% Ensure proper RTL alignment for all document elements",
            "\\everypar{\\rightskip=0pt plus 1fil\\relax}",
            "\\everydisplay{\\rightskip=0pt plus 1fil\\relax}",
            "",
            "% Header and footer setup",
            "\\pagestyle{fancy}",
            "\\fancyhf{}",
            "\\renewcommand{\\headrulewidth}{0.4pt}",
            "\\renewcommand{\\footrulewidth}{0.4pt}",
            sprintf("\\fancyhead[R]{\\texten{\\textit{%s}}}", date_string),  
            "\\fancyhead[L]{\\texten{Elinav Lab}}",
            "\\fancyhead[C]{\\sffamily ניתוח מיקרוביום}",
            "\\fancyfoot[C]{\\thepage}",
            "\\fancyfoot[L]{\\textcolor{maincolor}{\\sffamily חסוי}}",
            "",
            "% Section formatting with RTL alignment",
            "\\titleformat{\\subsection}{\\raggedright\\color{maincolor}\\sffamily\\large\\bfseries}{}{0em}{}",
            "\\titlespacing*{\\subsection}{0pt}{3.25ex plus 1ex minus .2ex}{1.5ex plus .2ex}",
            "",
            "% Box settings - with RTL text direction",
            "\\tcbset{",
            "  halign=justify,",
            "  arc=2mm,",
            "  boxsep=5pt,", 
            "}",
            "% Custom RTL itemize environment",
            "\\let\\olditemize\\itemize",
            "\\renewcommand{\\itemize}{\\begin{RTL}\\olditemize}",
            "\\let\\oldenditemize\\enditemize",
            "\\renewcommand{\\enditemize}{\\oldenditemize\\end{RTL}}",
            "",
            "% Ensure figures stay where placed",
            "\\floatplacement{figure}{H}",
            "\\hyphenpenalty=10000",
            "\\exhyphenpenalty=10000",
            "\\sloppy"
      )
      writeLines(preamble_content, preamble_path)

    } else if (lang == "ru") {
      template_path <- normalizePath(file.path(report_home, "templates/report_template_russian.qmd"))
      preamble_path <- file.path(report_home, "templates/preamble_russian.tex")
      
      # Try to detect available Russian fonts
      roboto_check <- system("fc-list | grep -i 'roboto'", intern = TRUE, ignore.stderr = TRUE)
      if (any(grepl("Roboto", roboto_check))) {
        russian_font <- "Roboto"
      } else{
        font_check <- system("fc-list | grep -i 'cyrillic\\|russian'", intern = TRUE, ignore.stderr = TRUE)
        fallback_font <- "DejaVu Sans"
        if (any(grepl("PT Sans", font_check))) {
          russian_font <- "PT Sans"
        } else if (any(grepl("Arial", font_check))) {
          russian_font <- "Arial"
        } else {
          russian_font <- fallback_font
        }
      }
      cat("Using Russian font:", russian_font, "\n")

      # Create Russian month names mapping
      russian_months <- c(
        "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", 
        "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"
      )

      # Get current month and year
      current_month <- as.integer(format(Sys.Date(), "%m"))
      current_year <- format(Sys.Date(), "%Y")

      # Format date string in Russian
      russian_date <- paste(russian_months[current_month], current_year)

      preamble_content <- c(
      "% Core packages",
      "\\usepackage{fontspec}",
      "\\usepackage{xcolor}",
      "\\usepackage{graphicx}",
      "\\usepackage{float}",
      "\\usepackage{tcolorbox}",
      "\\usepackage{fancyhdr}",
      "\\usepackage{titlesec}",
      "\\usepackage{ragged2e}", 
      "\\usepackage{hyperref}",
      "",
      "% Language support",
      "\\usepackage{polyglossia}",
      "\\setmainlanguage{russian}",
      "\\setotherlanguage{english}",
      "",
      "% Define colors",
      "\\definecolor{maincolor}{RGB}{0, 114, 181}",
      "\\definecolor{accentcolor}{RGB}{225, 135, 39}",
      "\\definecolor{lightgray}{RGB}{245, 245, 245}",
      "\\definecolor{goodcolor}{RGB}{32, 133, 78}",
      "\\definecolor{warncolor}{RGB}{188, 60, 41}",
      "",
      "% Configure Russian fonts",
      paste0("\\setmainfont[Scale=1.1,Script=Cyrillic]{", russian_font, "}"),
      paste0("\\setsansfont[Scale=1.1,Script=Cyrillic]{", russian_font, "}"),
      "\\newfontfamily\\cyrillicfontsf[Script=Cyrillic]{", russian_font, "}",
      "\\newfontfamily\\montserratfont{Montserrat}[Scale=MatchLowercase]",
      "",
      "% Simple text commands for language switching",
      "\\newcommand{\\texten}[1]{\\foreignlanguage{english}{\\textit{#1}}}",
      "\\newcommand{\\textentitle}[1]{\\foreignlanguage{english}{\\montserratfont\\bfseries\\scalebox{1.1}{#1}}}",
      "",
      "% Basic document settings",
      "\\usepackage[top=1in, bottom=1in, left=1in, right=1in]{geometry}",
      "\\parindent=1em",
      "",
      "% Header and footer setup",
      "\\pagestyle{fancy}",
      "\\fancyhf{}",
      "\\renewcommand{\\headrulewidth}{0.4pt}",
      "\\renewcommand{\\footrulewidth}{0.4pt}",
      "\\fancyhead[L]{Elinav Lab}",
      "\\fancyhead[C]{\\sffamily Анализ микробиома}",
      sprintf("\\fancyhead[R]{%s}", russian_date),
      "\\fancyfoot[C]{\\thepage}",
      "\\fancyfoot[L]{\\textcolor{maincolor}{\\sffamily Конфиденциально}}",
      "",
      "% Section formatting",
      "\\titleformat{\\subsection}{\\color{maincolor}\\sffamily\\large\\bfseries}{}{0em}{}",
      "\\titlespacing*{\\subsection}{0pt}{3.25ex plus 1ex minus .2ex}{1.5ex plus .2ex}",
      "",
      "% Box settings",
      "\\tcbset{",
      "  halign=justify,",  # Changed from left to justify
      "  arc=2mm,",
      "  boxsep=5pt,", 
      "  before={\\noindent\\ignorespaces},",
      "}",
      "",
      "% Document structure improvements",
      "\\justifying", 
      "\\setlength{\\headheight}{15pt}",
      "\\hyphenpenalty=50",
      "\\exhyphenpenalty=50",
      "\\emergencystretch=3em",
      "\\sloppy",
      "\\hyphenation{пре-дста-вле-ние ис-сле-до-ва-ние ми-кро-би-о-та ба-кте-рии про-би-о-ти-ки}",
      "",
      "% Ensure figures stay where placed",
      "\\floatplacement{figure}{H}"
    )
      writeLines(preamble_content, preamble_path)

    } else if (lang == "ar") {
      template_path <- normalizePath(file.path(report_home, "templates/report_template_arabic.qmd"))
      preamble_path <- file.path(report_home, "templates/preamble_arabic.tex")
      
      # Try to detect available Arabic fonts
      noto_check <- system("fc-list | grep -i 'noto sans arabic'", intern = TRUE, ignore.stderr = TRUE)
      fallback_font <- "DejaVu Sans"
      if (any(grepl("Noto", noto_check))) {
        arabic_font <- "Noto Sans Arabic"
      } else{
        arabic_font <- fallback_font  # Default final fallback
      }
      cat("Using Arabic font:", arabic_font, "\n")

      # Create Arabic month names mapping
      arabic_months <- c(
        "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", 
        "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
      )
      current_month <- as.integer(format(Sys.Date(), "%m"))
      current_year <- format(Sys.Date(), "%Y")
      arabic_date <- paste(arabic_months[current_month], "\\texten{", current_year, "}")

      preamble_content <- c(
        "% Core packages",
        "\\usepackage{fontspec}",
        "\\usepackage{xcolor}",
        "\\usepackage{graphicx}",
        "\\usepackage{float}",
        "\\usepackage{tcolorbox}",
        "\\usepackage{fancyhdr}",
        "\\usepackage{titlesec}",
        "\\usepackage{hyperref}",
        "",
        "% RTL language support - proper RTL text direction and alignment",
        "\\usepackage{polyglossia}",
        "\\setmainlanguage[numerals=western]{arabic}",
        "\\setotherlanguage{english}",
        "",
        "% Configure Arabic fonts",
        paste0("\\newfontfamily\\arabicfont{", arabic_font, "}[Script=Arabic]"),
        paste0("\\setmainfont{", arabic_font, "}"),
        "\\setsansfont{Changa}",
        "\\newfontfamily\\montserratfont{Montserrat}[Scale=MatchLowercase]",
        "",
        "% Define colors",
        "\\definecolor{maincolor}{RGB}{0, 114, 181}",
        "\\definecolor{accentcolor}{RGB}{225, 135, 39}",
        "\\definecolor{lightgray}{RGB}{245, 245, 245}",
        "\\definecolor{goodcolor}{RGB}{32, 133, 78}",
        "\\definecolor{warncolor}{RGB}{188, 60, 41}",
        "",
        "% Simple RTL text commands",
        "\\newcommand{\\texten}[1]{\\foreignlanguage{english}{#1}}",
        "\\newcommand{\\textentitle}[1]{\\foreignlanguage{english}{\\montserratfont\\bfseries #1}}",
        "% Basic document settings",
        "\\usepackage[top=1in, bottom=1in, left=1in, right=1in]{geometry}",
        "\\parindent=0pt",
        "\\parfillskip=0pt plus 1fil",
        "",
        "% Ensure proper RTL alignment for all document elements",
        "\\everypar{\\rightskip=0pt plus 1fil\\relax}",
        "\\everydisplay{\\rightskip=0pt plus 1fil\\relax}",
        "",
        "% Header and footer setup",
        "\\pagestyle{fancy}",
        "\\fancyhf{}",
        "\\renewcommand{\\headrulewidth}{0.4pt}",
        "\\renewcommand{\\footrulewidth}{0.4pt}",
        "\\fancyhead[L]{\\texten{Elinav Lab}}",
        sprintf("\\fancyhead[C]{\\arabicfont{تقرير تحليل ميكروبيوم}}"),
        sprintf("\\fancyhead[R]{\\arabicfont{%s}}", arabic_date),
        "\\fancyfoot[C]{\\thepage}",
        "\\fancyfoot[L]{\\textcolor{maincolor}{\\sffamily ســــــــــــــري}}",
        "",
        "% Section formatting with RTL alignment",
        "\\titleformat{\\subsection}{\\raggedright\\color{maincolor}\\sffamily\\large\\bfseries}{}{0em}{}",
        "\\titlespacing*{\\subsection}{0pt}{3.25ex plus 1ex minus .2ex}{1.5ex plus .2ex}",
        "",
        "% Box settings - with RTL text direction",
        "\\tcbset{",
        "  halign=justify,",
        "  arc=2mm,",
        "  boxsep=5pt,", 
        "}",
        "% Custom RTL itemize environment",
        "\\let\\olditemize\\itemize",
        "\\renewcommand{\\itemize}{\\begin{RTL}\\olditemize}",
        "\\let\\oldenditemize\\enditemize",
        "\\renewcommand{\\enditemize}{\\oldenditemize\\end{RTL}}",
        "",
        "% Ensure figures stay where placed",
        "\\floatplacement{figure}{H}",
        "\\hyphenpenalty=10000",
        "\\exhyphenpenalty=10000",
        "\\sloppy"
      )
      writeLines(preamble_content, preamble_path)

    } else {
      template_path <- file.path(report_home, "templates/report_template.qmd")
      preamble_path <- file.path(report_home, "templates/preamble.tex")

      preamble_content <- c(
          "% Modern font packages",
          "\\usepackage{fontspec}",
          "\\usepackage{unicode-math}",
          "\\setmainfont{Roboto}",
          "\\setsansfont{Montserrat}",
          "",
          "% Define alternative fallback in case fonts arent found",
          "\\newfontfamily\\fallbackfont{DejaVu Sans}[Scale=MatchLowercase]",
          "\\newfontfamily\\montserratitalic{Montserrat}[ItalicFont=Montserrat-Italic]",
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
          "\\setlength{\\tabcolsep}{8pt}",
          "",
          "% Ensure figures stay where placed",
          "\\floatplacement{figure}{H}",
          "\\hyphenpenalty=1500",
          "\\exhyphenpenalty=1500",
          "\\sloppy"
        )
        writeLines(preamble_content, preamble_path)
    }
    
    # Create output subfolder for this language
    lang_folder <- file.path(output_dir, lang_map[[lang]]$folder)
    dir.create(lang_folder, showWarnings = FALSE, recursive = TRUE)
    # cat("Created language folder:", lang_folder, "\n")
    
    # Add debug information
    # cat("Template path:", template_path, "\n")
    # cat("Number of participants:", length(colnames(abdata_filt)), "\n")
    
    # Loop through participants and make report
    original_wd <- getwd()
    setwd(report_home)
    
    for (participant_id in colnames(abdata_filt)) {
      cat("Processing participant:", participant_id, "\n")
      output_file <- paste0("report_", participant_id, lang_map[[lang]]$suffix, ".pdf")
      
      command <- paste0("quarto render ", shQuote(template_path), " -P participant_id:", shQuote(participant_id),
                    " -P abundance_file_path:", shQuote(ab_path),
                    " -P sample_prefix:", shQuote(sample_prefix),
                    " --output ", shQuote(output_file))
      
      system(command)
      # Quarto creates files as ../filename, so look there directly
      target_path <- file.path(lang_folder, output_file)

      system(paste("mv", shQuote(output_file), shQuote(target_path)))
    }
    
    setwd(original_wd)
  }
  
  # Generate information sheet for physicians
  setwd(report_home)
  system(paste0("quarto render ", shQuote(infosheet_path), " --output physician_info.pdf"))
  if (file.exists("physician_info.pdf")) {
    system(paste("mv", shQuote("physician_info.pdf"), shQuote(file.path(output_dir, "physician_info.pdf"))))
  }
  setwd(original_wd)

  cat("\nReport content generation complete, proceed to rendering.\n")
}