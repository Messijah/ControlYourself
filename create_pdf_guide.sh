#!/bin/bash

# Script to create beautiful PDF from App Store Submission Guide
# Uses pandoc for conversion

echo "📄 Creating App Store Submission Guide PDF..."

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    echo "❌ Pandoc not found. Installing via Homebrew..."
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install from https://brew.sh"
        exit 1
    fi
    brew install pandoc
    brew install --cask basictex
fi

# Input and output files
INPUT_FILE="APP_STORE_SUBMISSION_GUIDE.md"
OUTPUT_FILE="App_Store_Submission_Guide.pdf"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ $INPUT_FILE not found!"
    exit 1
fi

# Create PDF with pandoc
pandoc "$INPUT_FILE" \
    -o "$OUTPUT_FILE" \
    --pdf-engine=xelatex \
    -V geometry:margin=2.5cm \
    -V fontsize=11pt \
    -V documentclass=article \
    -V colorlinks=true \
    -V linkcolor=blue \
    -V urlcolor=blue \
    -V toccolor=purple \
    --toc \
    --toc-depth=2 \
    -V papersize=a4 \
    -V mainfont="Helvetica" \
    2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ PDF created successfully: $OUTPUT_FILE"
    echo "📍 Location: $(pwd)/$OUTPUT_FILE"
    open "$OUTPUT_FILE"
else
    echo "❌ PDF creation failed. Trying alternative method..."

    # Alternative: Create HTML first, then convert to PDF via wkhtmltopdf
    echo "📝 Creating HTML version..."
    pandoc "$INPUT_FILE" \
        -o "App_Store_Submission_Guide.html" \
        --standalone \
        --css=<(echo "
            body {
                max-width: 800px;
                margin: 40px auto;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                line-height: 1.6;
                color: #333;
            }
            h1 { color: #667eea; border-bottom: 3px solid #667eea; padding-bottom: 10px; }
            h2 { color: #764ba2; margin-top: 30px; }
            h3 { color: #667eea; }
            code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
            pre { background: #f4f4f4; padding: 15px; border-radius: 5px; overflow-x: auto; }
            blockquote { border-left: 4px solid #667eea; padding-left: 20px; margin-left: 0; color: #666; }
            .emoji { font-size: 1.2em; }
        ")

    echo "✅ HTML created: App_Store_Submission_Guide.html"
    echo "💡 Open this in Safari and use File → Export as PDF"
    open "App_Store_Submission_Guide.html"
fi
