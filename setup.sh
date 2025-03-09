#!/bin/sh

# Define target directories
BIN_DIR="${1:-$HOME/bin}"
SHARE_DIR="${2:-$HOME/.local/share/reportgenerator}"

mkdir -p "$BIN_DIR"
mkdir -p "$SHARE_DIR"

# Copy the shell wrapper script
if ! cp bin/reportgenerator "$BIN_DIR/"; then
  echo "Error: Failed to copy script to $BIN_DIR"
  exit 1
fi
chmod +x "$BIN_DIR/reportgenerator" 

# Copy supporting files
echo "Copying supporting files to $SHARE_DIR..."
cp -r run.R lib templates tests "$SHARE_DIR/"
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy supporting files to $SHARE_DIR"
  exit 1
fi

# Update the generate-report script to know where the support files are
sed -i "s|PROJECT_ROOT=.*|PROJECT_ROOT=\"$SHARE_DIR\"|" "$BIN_DIR/reportgenerator" 

echo "Installation complete. You can now use the 'reportgenerator' command."

# Check if BIN_DIR is in PATH
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
  echo "$BIN_DIR is not in your PATH."
  
  # Detect the shell configuration file
  if [ -n "$BASH_VERSION" ]; then
    config_file="$HOME/.bashrc"
  elif [ -n "$ZSH_VERSION" ]; then
    config_file="$HOME/.zshrc"
  else
    # Default to .profile which most shells read
    config_file="$HOME/.profile"
  fi
  
  # Offer to add to PATH
  echo "Would you like to add it to your $config_file? (y/n)"
  read -r answer
  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$config_file"
    echo "Added to $config_file. Please run 'source $config_file' or start a new terminal session."
  else
    echo "To add it manually, run:"
    echo "  echo 'export PATH=\"$BIN_DIR:\$PATH\"' >> ~/.bashrc"
  fi
else
  echo "$BIN_DIR is already in your PATH."
fi

# Check for Quarto availability
if command -v quarto >/dev/null 2>&1; then
  echo "✅ Quarto is installed and available in your PATH."
else
  echo "⚠️ Quarto is not found in your PATH. This tool requires Quarto to generate reports."
  echo "Options for installing Quarto:"
  echo "  1. On HPC: Check if a module is available: module avail quarto"
  echo "  2. Install locally: https://quarto.org/docs/get-started/"
  echo "  3. Or download the CLI: https://github.com/quarto-dev/quarto-cli/releases"
fi

# Check for R availability
if command -v Rscript >/dev/null 2>&1; then
  echo "✅ R is installed and available in your PATH."
else
  echo "⚠️ R is not found in your PATH. This tool requires R to run."
  echo "Options for accessing R:"
  echo "  1. On HPC: module load R"
  echo "  2. Install locally: https://www.r-project.org/"
fi

echo "Note: Required R packages will be checked when the tool is run."
echo "Note: On HPC systems, you may need to load required modules:"
echo "  module load R quarto"