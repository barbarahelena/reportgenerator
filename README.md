# Reportgenerator CLI

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
# Generate Reports CLI

## Installation

To install the CLI on an HPC system, follow these steps:

1. **Download or clone the repository** to your local directory on the HPC system.

2. **Run the setup script** to install the CLI. You can run the script without any arguments to install it to the default directory (`~/bin`), or specify a custom directory.

   ```sh
   sh setup.sh
   ```

   Or, to specify a custom directory:

   ```sh
   sh setup.sh /path/to/custom/dir
   ```

3. **Ensure the target directory is in your PATH**. If you installed the CLI to `~/bin`, add the following line to your shell profile (e.g., `.bashrc` or `.bash_profile`):

   ```sh
   export PATH="$HOME/bin:$PATH"
   ```

   If you specified a custom directory, replace `~/bin` with your custom directory path.

4. **Reload your shell profile** to apply the changes:

   ```sh
   source ~/.bashrc
   ```

   Or, if you use `.bash_profile`:

   ```sh
   source ~/.bash_profile
   ```

5. **Verify the installation** by running the `generate-report` command:

   ```sh
   generate-report --help
   ```

   This should display the help message for the `generate-report` script, confirming that the installation was successful.

## Usage
To generate a report, use the `generate-report` command followed by the necessary arguments. For example:

```sh
generate-report input_file output_file
```

For more information on the available options and arguments, run:

```sh
generate-report --help
```

### Command Line Options
| Option | Description | Required? | Default |
|--------|-------------|-----------|---------|
| `-a, --abundance` | Path to abundance table file | **REQUIRED** | - |
| `-p, --template` | Path to report template | Optional | templates/report_template.qmd |
| `-i, --infosheet` | Path to physician info template | Optional | templates/physician_info_template.qmd | 
| `-o, --output` | Output directory for reports | Optional | reports |
| `-s, --sample` | Sample prefix in column names | Optional | Sample |
| `-t, --test` | Run tests instead of normal operation | Optional | FALSE |

### Examples
Basic usage with a mandatory abundance table:
```bash
Rscript run.R /path/to/combined_krakenoutput.txt
```
Custom sample prefix (for samples named like "Participant_L_001"):
```bash
Rscript run.R /path/to/combined_krakenoutput.txt templates/report_template.qmd templates/physician_info_template.qmd reports "Participant_"
```
Running tests:
```bash
generate-report --test
```

### Input Format
The abundance table should be a tab-delimited file with the following format:
- First column: Taxonomic name 
- Second column: Taxonomic rank (D, P, C, O, F, G, S)
- Remaining columns: Sample abundances with names like `Sample001.kraken2.report_bracken`

## Output
The tool generates:
- Individual PDF reports for each sample in the abundance table
- A general information sheet (physician_info.pdf)
- All files are saved to the specified output directory

## HPC Usage
When using on an HPC system, you may need to load the required modules:
```bash
module load R module load quarto
```
## Development
To modify templates, edit files in the `templates/` directory.

## Contributing
Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.