#!/bin/bash
set -e

# Navigate to the lambda directory
cd "$(dirname "$0")"

# Create a temporary directory for dependencies
mkdir -p package

# Install requirements to the package directory
pip install --target ./package -r requirements.txt

# Copy the lambda function to the package directory
cp lambda_function.py package/

# Create the zip file
cd package
zip -r ../lambda_function.zip .
cd ..

# Clean up
rm -rf package