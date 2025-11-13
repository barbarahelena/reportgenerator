# Report Generator CLI

## Overview
This project provides a command line interface for generating reports from a Kraken-style Bracken abundance table. The reports are generated using templates and can be customized based on participant data. This package was made for a project in the Elinav Lab (Weizmann Institute of Science, DKFZ Heidelberg).

## Dependencies

### System Requirements
- R (version 4.0 or higher)
- Quarto (version 1.3 or higher)
- Bash shell environment
- LaTeX distribution (TinyTex)

### Mamba environment
It is recommended to use the env.yml in this folder to make a mamba (or conda) environment, so that you have all R packages you need. After that, you can install tinytex with quarto:

```sh
mamba create -f env.yml
mamba activate reports
quarto install tinytex
```

### R Packages
The following R packages will be automatically installed if missing:

**Core packages:** dplyr, stringr, ggplot2, optparse, forcats, tidyr, vegan and rmarkdown.

**Test packages (only needed when running tests):** testthat, mockery and R6.

These are already part of the mamba environment (see above), so in that case you can skip this step. Alternatively, you can install the R packages manually:

```r
# Install core packages
install.packages(c("dplyr", "stringr", "ggplot2", "optparse", "forcats", "tidyr", "vegan", "rmarkdown"))

# Install test packages (optional)
install.packages(c("testthat", "mockery", "R6"))
```

### Install fonts
The reports need a number of fonts, depending on the language:
- Montserrat
- Roboto
- Noto Sans Hebrew
- Noto Sans Arabic

You can get them via [Google Fonts](https://fonts.google.com/share?selection.family=Montserrat:ital,wght@0,100..900;1,100..900|Noto+Sans+Arabic:wght@100..900|Noto+Sans+Hebrew:wght@100..900|Roboto:ital,wght@0,100..900;1,100..900). To install these fonts, download them, unzip, move them to your fonts folder and update the font cache, for example:

```sh
# Unzip and move to your fonts folder
unzip 'Montserrat,Noto_Sans_Arabic,Noto_Sans_Hebrew,Roboto.zip'
cd 'Montserrat,Noto_Sans_Arabic,Noto_Sans_Hebrew,Roboto'
find . -name "*.ttf" -exec cp {} ~/.local/share/fonts/ \;

# Update font cache
fc-cache -f -v 

# List fonts to check 
fc-list || ls ~/.local/share/fonts/
```

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
The test uses an example minimal abudance table from the testfolder of the package; it creates three English reports and a physician info report in a test_reports folder in your current directory.

### Command Line Options
| Option | Description | Required? | Default |
|--------|-------------|-----------|---------|
| `-a, --abundance` | Path to abundance table file | Required | - |
| `-p, --template` | Path to report template | Optional | templates/report_template.qmd |
| `-i, --infosheet` | Path to physician info template | Optional | templates/physician_info_template.qmd | 
| `-o, --output` | Output directory for reports | Optional | reports |
| `-s, --sample` | Sample prefix in column names that will be stripped off in the report | Optional | - |
| `-l, --language` | Languages, comma-separated | Optional | en,he,ru,ar (all languages) |
| `-t, --test` | Run tests instead of normal operation | Optional | FALSE |

### Input Format
The abundance table should be a tab-delimited file with the following format:
- First column: Taxonomic name 
- Second column: Taxonomic rank (D, P, C, O, F, G, S)
- Remaining columns: Sample abundances with names like `Sample001.kraken2.report_bracken`. If the column names start with a number, an X will be appended for the sample ID in the report IDs.

The following taxonomy should occur in your table for the reports to be generated: Bacteroidota, Bacillota, Pseudomonadota, Parabacteroides, Odoribacter, Blautia, Faecalibacterium, Verrucomicrobiota, Anaerostipes, Lactobacillus, Roseburia, Akkermansia muciniphila, Dorea formicigenerans, Desulfovibrionaceae, Bacteroides, Prevotella, Escherichia, Bifidobacterium. To make sure that the pie chart with all species is correct, you should leave all species in the abundance table.

> [!WARNING]
> Note that taxonomy of Bacteroidota and Bacillota were updated around 2021. If you're using an older database, these might be named differently.

## Output
The tool generates:
- Individual PDF reports for each sample in the abundance table (example: `reports/english/report_ID_en.pdf`)
- A general information sheet (physician_info.pdf)
- All files are saved to the specified output directory

## Development
To modify templates, edit files in the `templates/` directory. Run `setup.sh` again to make sure that you can use the updated `reportgenerator` on the command line.

## Contributing
Contributions are welcome! Please feel free to submit a pull request or open an issue for any enhancements or bug fixes.

## License
This project is licensed under the MIT License. See the LICENSE file for details.