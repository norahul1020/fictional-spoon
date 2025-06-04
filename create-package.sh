#!/bin/bash

echo "📦 Creating Tenable WAS POC package..."

# Create a zip file of the entire structure
cd ..
zip -r tenable-was-poc-complete.zip tenable-was-poc/ \
  -x "tenable-was-poc/.git/*" \
  -x "tenable-was-poc/results/*" \
  -x "tenable-was-poc/*.log" \
  -x "tenable-was-poc/*.html"

echo "✅ Package created: tenable-was-poc-complete.zip"
echo ""
echo "📋 Next steps:"
echo "1. Extract the zip file"
echo "2. Create a new GitHub repository"
echo "3. Upload all files to your repository"
echo "4. Set up GitHub secrets (see docs/SECRETS.md)"
echo "5. Run the workflows!"
