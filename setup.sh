#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_DIR="$ROOT_DIR/rules"
DRAFTS_DIR="$RULES_DIR/drafts"
PERSONALITIES_DIR="$RULES_DIR/personalities"

VERSION=$(cat "$ROOT_DIR/VERSION")

usage() {
  echo "Usage: $0 [--target <target-directory>] [--rules-dir <rules-directory>] | [target-directory]"
  echo "Options:"
  echo "  --target     Specify the target directory to set up rules. (takes precedence over positional argument)"
  echo "  --rules-dir  Specify the rules directory relative to target (default: .cursor/rules)"
  echo "  --help       Show this help message."
  echo "  --version    Show script version."
  exit 0
}

target_dir=""
rules_dir=".cursor/rules"
# Parse options
declare -a POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --target)
      target_dir=$2
      shift 2
      ;;
    --rules-dir)
      rules_dir=$2
      shift 2
      ;;
    --help)
      usage
      ;;
    --version)
      echo "$VERSION"
      exit 0
      ;;
    --*)
      echo "Unknown option: $1"
      usage
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

# Use the first positional argument if `--target` is not specified
eval set -- "${POSITIONAL_ARGS[@]}"
if [ -z "$target_dir" ] && [ -n "$1" ]; then
  target_dir=$1
fi

if [ -z "$target_dir" ]; then
  echo "Error: target directory is required."
  usage
fi

DEST_DIR="$target_dir/$rules_dir"

if [ -d "$DEST_DIR" ]; then
  echo "$DEST_DIR already exists. Overwrite? (y/n)"
  read -r answer
  case $answer in
    [Yy]*)
      echo "Overwriting existing rules..."
      rm -rf "$DEST_DIR"
      ;;
    [Nn]*)
      echo "Canceled. No changes made."
      exit 0
      ;;
    *)
      echo "Invalid input. Exiting."
      exit 1
      ;;
  esac
fi

mkdir -p "$DEST_DIR"

# Select personality file
personality_files=()
while IFS= read -r -d $'\0' file; do
    personality_files+=("$file")
done < <(find "$PERSONALITIES_DIR" -maxdepth 1 -type f -name "*.md" -print0)

if [ ${#personality_files[@]} -eq 0 ]; then
    echo "Error: No personality files found in $PERSONALITIES_DIR"
    exit 1
fi

echo "Select a personality file to use:"
select selected_personality_file_path in "${personality_files[@]}"; do
    if [ -n "$selected_personality_file_path" ]; then
        echo "Using personality file: $selected_personality_file_path"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Export personality contents to an environment variable for awk
export PERSONALITY_CONTENTS
# Read file and remove Front Matter using awk
PERSONALITY_CONTENTS=$(awk '/^---$/ { if (!in_front_matter) { in_front_matter = 1; next } else { in_front_matter = 0; next } } !in_front_matter { print }' "$selected_personality_file_path")


echo "Copying rules from $RULES_DIR to $DEST_DIR..."

# Support directory hierarchy, exclude drafts directory, and copy .md files as .mdc files
find "$RULES_DIR" -type f -name "*.md" ! -path "$DRAFTS_DIR/*" ! -path "$PERSONALITIES_DIR/*" | while read -r file; do
  relative_path="${file#$RULES_DIR/}"
  output_path="$DEST_DIR/${relative_path%.md}.mdc"
  output_dir=$(dirname "$output_path")

  mkdir -p "$output_dir"

  # if `00_personality.md` file when replace {personality_file_contents} with PERSONALITY_CONTENTS
  if [[ "$relative_path" == "00_personality.md" ]]; then
      # Use awk with environment variable for multi-line replacement
      awk '
      BEGIN { found_placeholder = 0; personality_val = ENVIRON["PERSONALITY_CONTENTS"] }
      /{personality_file_contents}/ {
          print personality_val;
          found_placeholder = 1;
          next;
      }
      { print }
      END { if (!found_placeholder) { print "Warning: {personality_file_contents} placeholder not found in 00_personality.md" > "/dev/stderr" } }
      ' "$file" > "$output_path"
  else
      cp "$file" "$output_path"
  fi


  echo "Copied: ${output_path#$DEST_DIR/}"
done

# Unset the environment variable after use
unset PERSONALITY_CONTENTS

echo "All applicable rules copied to $DEST_DIR."
