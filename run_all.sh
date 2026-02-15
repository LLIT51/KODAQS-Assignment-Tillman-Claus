#!/bin/bash
set -e

echo "Restoring renv environment..."
Rscript -e "renv::restore(prompt = FALSE)"

echo "Running cleaning script..."
Rscript analysis/01_cleaning.R

echo "Running analysis script..."
Rscript analysis/02_analysis.R

echo "All scripts executed successfully."
