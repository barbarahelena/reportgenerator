# Report Generator CLI

## Overview
This project provides a command line interface for generating reports from a Kraken-style Bracken abundance table. The reports are generated using templates and can be customized based on participant data. This package was made for a project in the Elinav Lab (Weizmann Institute of Science, DKFZ Heidelberg).

## Installation
To install the CLI, follow these steps:

1. **Download or clone the repository** to your local directory.

2. **Run the setup script** to install the CLI. You can run the script without any arguments to install it to the default directory (`~/bin`), or specify a custom directory.

   ```sh
   sh setup.sh
   ```

   Or, to specify a custom directory:

   ```sh
   sh setup.sh /path/to/custom/dir
   ```

3. **Ensure the target directory is in your PATH**. When prompted by the script, say 'yes' if you want the report generator to be available in your path. Otherwise manually: If you installed the CLI to `~/bin`, add the following line to your shell profile (e.g., `.bashrc`), followed by a command to reload your shell profile:

   ```sh
   export PATH="$HOME/bin:$PATH"
   source ~/.bashrc
   ```
   If you specified a custom directory, replace `~/bin` with your custom directory path.

4. **Verify the installation** by running the `reportgenerator` command:

   ```sh
   reportgenerator --help
   ```

   This should display the help message for the `reportgenerator` script, confirming that the installation was successful.

## Dependencies

### System Requirements
- R (version 4.0 or higher)
- Quarto (version 1.3 or higher)
- Bash shell environment

### R Packages
The following R packages will be automatically installed if missing:

**Core packages:**
- dplyr: For data manipulation
- stringr: For string handling
- ggplot2: For generating visualizations
- optparse: For command line argument parsing
- forcats: For factor level manipulation
- tidyr: For data reshaping

**Test packages (only needed when running tests):**
- testthat: For unit testing
- mockery: For mocking in tests
- R6: For test reporter classes

### Installation
All required R packages are automatically installed when first running the tool. If you prefer to install them manually:

```r
# Install core packages
install.packages(c("dplyr", "stringr", "ggplot2", "optparse", "forcats", "tidyr"))

# Install test packages (optional)
install.packages(c("testthat", "mockery", "R6"))
```

## Usage
To generate a report, use the `reportgenerator` command followed by the necessary arguments. For example:

```sh
reportgenerator -a input_file -o output_dir
```

For more information on the available options and arguments, run:

```sh
reportgenerator --help
```
Running tests:
```bash
reportgenerator --test
```
The test uses an example minimal abudance table from the testfolder of the package.

### Command Line Options
| Option | Description | Required? | Default |
|--------|-------------|-----------|---------|
| `-a, --abundance` | Path to abundance table file | **REQUIRED** | - |
| `-p, --template` | Path to report template | Optional | templates/report_template.qmd |
| `-i, --infosheet` | Path to physician info template | Optional | templates/physician_info_template.qmd | 
| `-o, --output` | Output directory for reports | Optional | reports |
| `-s, --sample` | Sample prefix in column names | Optional | Sample |
| `-t, --test` | Run tests instead of normal operation | Optional | FALSE |

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
Or activate a mamba environment with the dependencies needed for this tool.

## Development
To modify templates, edit files in the `templates/` directory.

## Contributing
Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.