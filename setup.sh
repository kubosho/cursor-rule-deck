#!/bin/bash

set -e

VERSION="1.0.0"

RULES_DIR="$(cd "$(dirname "$0")" && pwd)/rules"
DRAFTS_DIR="$RULES_DIR/drafts"
DEST_DIR="$target_dir/.cursor/rules"

usage() {
  echo "Usage: $0 --target <target-directory>"
  echo "Options:"
  echo "  --target   Specify the target directory to set up rules."
  echo "  --help     Show this help message."
  echo "  --version  Show script version."
  exit 0
}

# 引数パース
target_dir=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --target)
      target_dir=$2
      shift 2
      ;;
    --help)
      usage
      ;;
    --version)
      echo "setup.sh version $VERSION"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

if [ -z "$target_dir" ]; then
  echo "Error: --target option is required."
  usage
fi

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

echo "Copying rules from $RULES_DIR to $DEST_DIR..."

# 階層構造にも対応し、drafts配下を除外して.mdファイルを*.mdcファイルとしてコピー
find "$RULES_DIR" -type f -name "*.md" ! -path "$DRAFTS_DIR/*" | while read -r file; do
  relative_path="${file#$RULES_DIR/}"
  output_path="$DEST_DIR/${relative_path%.md}.mdc"
  output_dir=$(dirname "$output_path")

  mkdir -p "$output_dir"
  cp "$file" "$output_path"
  echo "Copied: ${output_path#$DEST_DIR/}"
done

echo "All applicable rules copied to $DEST_DIR."
