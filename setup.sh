#!/bin/bash

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_DIR="$ROOT_DIR/rules"
DRAFTS_DIR="$RULES_DIR/drafts"

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

echo "Copying rules from $RULES_DIR to $DEST_DIR..."

# Support directory hierarchy, exclude drafts directory, and copy .md files as .mdc files
find "$RULES_DIR" -type f -name "*.md" ! -path "$DRAFTS_DIR/*" | while read -r file; do
  relative_path="${file#$RULES_DIR/}"
  output_path="$DEST_DIR/${relative_path%.md}.mdc"
  output_dir=$(dirname "$output_path")

  mkdir -p "$output_dir"

  # {rules_dir} プレースホルダを実際のルールディレクトリ名で置換して出力
  sed "s|{rules_dir}|$rules_dir|g" "$file" > "$output_path"

  echo "Copied: ${output_path#$DEST_DIR/}"
done

echo "All applicable rules copied to $DEST_DIR."
