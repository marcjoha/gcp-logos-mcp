#!/bin/bash
set -e

# URLs
CORE_URL="https://services.google.com/fh/files/misc/core-products-icons.zip"
CATEGORY_URL="https://services.google.com/fh/files/misc/category-icons.zip"
LEGACY_URL="https://services.google.com/fh/files/misc/google-cloud-legacy-icons.zip"

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

echo "Cleaning up existing assets/icons directory..."
rm -rf assets/icons
mkdir -p assets/icons

# Function to download, extract and move icons
process_zip() {
  local url=$1
  local prefix=$2
  local zip_file="$TMP_DIR/$prefix.zip"
  local extract_dir="$TMP_DIR/$prefix"
  
  echo "Processing $prefix icons..."
  curl -sL "$url" -o "$zip_file"
  unzip -q "$zip_file" -d "$extract_dir"
  
  # Find all SVGs, lowercase name, replace spaces/underscores with hyphens, prefix, and copy
  find "$extract_dir" -type f -iname "*.svg" | while read -r file; do
    # Skip any MacOS __MACOSX resource fork files that sometimes exist in zips
    if [[ "$file" == *"__MACOSX"* ]]; then
      continue
    fi
    
    filename=$(basename "$file")
    # Clean up filename: lowercase, replace spaces/underscores with hyphen
    clean_name=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/_/-/g')
    icon_id="${prefix}-${clean_name%.svg}"
    cp "$file" "assets/icons/${icon_id}.svg"
  done
}

process_zip "$CORE_URL" "core"
process_zip "$CATEGORY_URL" "category"
process_zip "$LEGACY_URL" "legacy"

echo "Generating assets/icons.json..."
# Use Python to safely generate JSON mapping
python3 -c "
import os, json
manifest = {}
for file in os.listdir('assets/icons'):
    if file.endswith('.svg'):
        icon_id = file[:-4]
        manifest[icon_id] = os.path.join('assets/icons', file)
with open('assets/icons.json', 'w') as f:
    json.dump(manifest, f, indent=2)
"

echo "Done! Icons fetched and manifest created at assets/icons.json."
