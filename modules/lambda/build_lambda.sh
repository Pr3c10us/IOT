#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
LAMBDA_DIR="./lambda"
BUILD_DIR="${LAMBDA_DIR}/build"
ZIP_FILE="${LAMBDA_DIR}/lambda_function.zip"

# Create build directory
mkdir -p "${BUILD_DIR}"

# Navigate to the build directory
cd "${BUILD_DIR}"

# Install dependencies (if any)
# For example, if you have a requirements.txt, uncomment the following lines:
# if [ -f "../requirements.txt" ]; then
#     pip install -r ../requirements.txt -t .
# fi

# Copy the lambda_function.py to the build directory
cp ../lambda_function.py .

# Create the ZIP file
zip -r "${ZIP_FILE}" .

# Navigate back to the original directory
cd -

echo "Lambda function packaged successfully at ${ZIP_FILE}"
