#!/bin/bash

set -o errexit

export FOLDER="$1"
export INCLUDE_FILE="$2"
export OUTPUT_FILE="$3"
export IGNORE_CACHE="$4"
export FOLDER_NAME="$(basename "$FOLDER")"
export OUTPATH="$FOLDER/MD5/$OUTPUT_FILE"
export TMPPATH="${OUTPATH}.tmp"

pushd "$FOLDER/.." > /dev/null

mkdir -p "$(dirname "${OUTPATH}")"
if [ "$(echo "$IGNORE_CACHE" |tr '[:upper:]' '[:lower:]')" = true ]
then
  rm -f "${OUTPATH}"
fi
touch "${OUTPATH}"

rsync \
  -vrktp \
  --list-only \
  --relative \
  --chmod=Dg+sx,ug+w,o-rwx \
  --prune-empty-dirs \
  --exclude="${OUTPATH}" \
  --exclude="${TMPPATH}" \
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
  <(sed -re 's/^\S+\s+//' "$OUTPATH" |sort) |\
xargs \
  -0 \
  -d '\n' \
  -r \
  md5sum > "$TMPPATH"

cat <(grep -v '^$' "$OUTPATH") <(grep -v '^$' "$TMPPATH") > "${OUTPATH}.intermediate"
mv "${OUTPATH}.intermediate" "${OUTPATH}"
rm -f "$TMPPATH"

popd > /dev/null
