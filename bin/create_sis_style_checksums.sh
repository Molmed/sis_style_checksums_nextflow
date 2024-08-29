#!/bin/bash

set -o errexit

export FOLDER="$1"
export INCLUDE_FILE="$2"
export OUTPUT_FILE="checksums.md5"
export IGNORE_CACHE="$3"
export FOLDER_NAME=$(basename $FOLDER)
export OUTPATH="$FOLDER/MD5/$OUTPUT_FILE"
export TMPPATH="${OUTPUT_FILE}.tmp"

mkdir -p "$(dirname "${OUTPATH}")"
if [ "$(echo "$IGNORE_CACHE" |tr '[:upper:]' '[:lower:]')" = true ]
then
  cp $OUTPATH $OUTPUT_FILE
fi
touch $OUTPUT_FILE

rsync \
  -vrktp \
  --list-only \
  --relative \
  --chmod=Dg+sx,ug+w,o-rwx \
  --prune-empty-dirs \
  --exclude="$OUTPUT_FILE" \
  --exclude="$TMPPATH" \
  --include-from="$INCLUDE_FILE" \
  --exclude="*" \
  "$(dirname  "$FOLDER")/./${FOLDER_NAME}/" |\
rev |\
cut -f1 -d" " |\
rev |\
grep "^$FOLDER_NAME\/" |\
xargs -n1 -I{} \
  sh -c "if [ ! -d {} ]; then echo {}; fi" |\
grep -v "^$" |\
sort |\
comm \
  -2 \
  -3 \
  - \
  <(sed -re 's/^\S+\s+//' "$OUTPUT_FILE" |sort) |\
xargs \
  -0 \
  -d '\n' \
  -r \
  md5sum > "$TMPPATH"

cat <(grep -v '^$' "$OUTPUT_FILE") <(grep -v '^$' "$TMPPATH") > "${OUTPUT_FILE}.intermediate"
mv "${OUTPUT_FILE}.intermediate" "${OUTPUT_FILE}"
rm -f "$TMPPATH"
