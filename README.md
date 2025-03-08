# generate-reports-cli

## Overview
This project provides a command line interface for generating reports from a Kraken-style Bracken abundance table. The reports are generated using templates and can be customized based on participant data. This package was made for a project in the Elinav Lab (Weizmann Institute of Science, DKFZ Heidelberg).

## Project Structure
- **src/**: Contains the main R scripts for report generation.
  - **generate_report.R**: Main function to read abundance data and generate reports.
  - **utils/**: Contains utility functions for data manipulation and report formatting.
- **templates/**: Holds the templates used for generating reports and physician information sheets.
  - **report_template.qmd**: Template for participant reports.
  - **physician_info_template.qmd**: Template for physician information sheets.
- **config/**: Contains configuration settings for the project.
  - **default_config.R**: Default settings and parameters.
- **tests/**: Contains tests for the report generation functionality.
  - **test_generate_report.R**: Tests to validate the behavior of the `generate_report` function.
- **run.R**: Entry point for the command line interface.
- **.Rprofile**: Customizes the R environment when the project is loaded.
- **README.md**: Documentation for the project.

## Installation
To use this project, ensure you have R and the required packages installed. You can install the necessary packages by running:

```R
install.packages(c("dplyr", "stringr"))
```

## Usage
To generate reports, run the following command in your terminal:

```bash
Rscript run.R --abundance_table <path_to_abundance_table> --output_dir <output_directory>
```

Replace `<path_to_abundance_table>` with the path to your abundance table and `<output_directory>` with the desired output directory for the reports.

## Dependencies
- R (version 4.0 or higher)
- Required R packages: `dplyr`, `stringr`, `quarto`

## Contributing
Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.