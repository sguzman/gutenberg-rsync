#!/usr/bin/env fish
# Sync ONLY plain .epub files (exclude any "*-images*.epub") from a Gutenberg rsync module or path.
# Usage:
#   ./sync-gutenberg-epub.fish [--dry] SRC DEST

function usage
    echo "Usage: "(status filename)" [--dry] SRC DEST"
end

set -l DRY 0
set -l args $argv
if test (count $args) -lt 2
    usage; exit 2
end
if test "$args[1]" = "--dry"
    set DRY 1
    set args $args[2..-1]
end
if test (count $args) -ne 2
    usage; exit 2
end

set -l SRC $args[1]
set -l DST $args[2]

# Big exclude list (kept, but not strictly necessary)
set -l EXCL_EXT_PATTERNS \
    '*.zip' '*.mobi' '*.png' '*.PNG' '*.html' '*.jpg' '*.JPG' '*.jpeg' '*.gzip' '*.txt' '*.tex' '*.svg' \
    '*.log' '*.css' '*.midi' '*.plucker' '*.rdf' '*.mid' '*.bmp' '*.BMP' '*.gz' '*.acl.gutenwebdev' \
    '*.acl.gutenwebprod' '*.gif' '*.pdf' '*.xml' '*.utf8' '*.mp3' '*.wav' '*.mus' '*.aux' '*.htm' '*.rst' \
    '*.mxl' '*.nroff' '*.woff' '*.otf' '*html~' '*utf8~' '*.musicxml' '*.raw' '*.utf8x' '*.bak' '*.ttf' \
    '*.jfif' '*.ogg' '*.mp4' '*.mscz' '*.ly'

# Exclude image-epub variants FIRST
set -l EXCL_IMAGE_EPUBS '*-images.epub' '*-images-3.epub' '*-images*.epub' '*_images*.epub'

# Build filters in correct order
set -l FILTERS "--include=*/"
for p in $EXCL_IMAGE_EPUBS
    set -a FILTERS "--exclude=$p"
end
set -a FILTERS "--include=*.epub"
for p in $EXCL_EXT_PATTERNS
    set -a FILTERS "--exclude=$p"
end
set -a FILTERS "--exclude=*"

set -l BASE -av --progress --prune-empty-dirs --partial
if test $DRY -eq 1
    set -a BASE --dry-run --itemize-changes --debug=FILTER
end

echo "Source: $SRC"
echo "Dest:   $DST"
echo "Filters:"
for f in $FILTERS
    echo "  $f"
end
echo

rsync $BASE $FILTERS -- "$SRC" "$DST"

