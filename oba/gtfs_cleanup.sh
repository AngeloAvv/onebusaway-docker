#!/bin/bash

ZIP_FILE="$1"

if [ -z "$ZIP_FILE" ]; then
    echo "Error: please specify the ZIP file."
    echo "Usage: $0 <file.zip>"
    exit 1
fi

apt update && apt install -qq -y gawk unzip zip

FILES_TO_MODIFY=("routes.txt" "shapes.txt" "trips.txt")
COLUMNS_TO_MODIFY=("route_id" "shape_id")

TMP_DIR="tmp_zip"
mkdir -p $TMP_DIR

unzip -q $ZIP_FILE -d $TMP_DIR

replace_in_column() {
    local input_file="$1"
    local output_file="$2"
    local columns=("$@")
    columns=("${columns[@]:2}")

    awk -v cols="${columns[*]}" '
    BEGIN {
        split(cols, colArr, " ")
    }
    {
        for (i in colArr) {
            $colArr[i] = gensub(/\//, "barrato", "g", $colArr[i])
        }
        print $0
    }' FS=',' OFS=',' "$input_file" > "$output_file"
}

replace_in_column "$TMP_DIR/routes.txt" "$TMP_DIR/routes.txt.tmp" 1
replace_in_column "$TMP_DIR/shapes.txt" "$TMP_DIR/shapes.txt.tmp" 1
replace_in_column "$TMP_DIR/trips.txt" "$TMP_DIR/trips.txt.tmp" 1 8

mv "$TMP_DIR/routes.txt.tmp" "$TMP_DIR/routes.txt"
mv "$TMP_DIR/shapes.txt.tmp" "$TMP_DIR/shapes.txt"
mv "$TMP_DIR/trips.txt.tmp" "$TMP_DIR/trips.txt"

cd $TMP_DIR
zip -r -q ../$ZIP_FILE *

cd ..
rm -rf $TMP_DIR

echo "Replacement completed and ZIP file updated."