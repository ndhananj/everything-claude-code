#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
SOURCE_ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)

usage() {
  echo "Usage: $(basename "$0") /path/to/new-repo"
}

if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

TARGET_DIR=$1

if [[ -e "$TARGET_DIR" ]]; then
  echo "Target directory already exists: $TARGET_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

copy_paths=(
  agents
  assets
  commands
  contexts
  docs
  examples
  hooks
  llms.txt
  mcp-configs
  package.json
  package-lock.json
  plugins
  rules
  schemas
  scripts
  skills
  tests
  the-longform-guide.md
  the-shortform-guide.md
  LICENSE
)

rsync -a --delete-excluded \
  --exclude 'node_modules' \
  --exclude '.git' \
  "${copy_paths[@]/#/${SOURCE_ROOT}/}" \
  "$TARGET_DIR/"

cp "$SCRIPT_DIR/assets/README.template.md" "$TARGET_DIR/README.md"
cp "$SCRIPT_DIR/assets/CONTRIBUTING.template.md" "$TARGET_DIR/CONTRIBUTING.md"

export TARGET_DIR_ABS=$TARGET_DIR
python3 - <<'PY'
import pathlib
import re
import os

root = pathlib.Path(os.environ["TARGET_DIR_ABS"])

replacements = [
    (re.compile(r"Claude Code"), "Codex Agentic Code"),
    (re.compile(r"Claude"), "Codex"),
]

text_exts = {".md", ".txt", ".yml", ".yaml", ".json", ".toml", ".mdx"}

for path in root.rglob("*"):
    if not path.is_file() or path.suffix.lower() not in text_exts:
        continue
    try:
        content = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue

    lines = content.splitlines()
    updated_lines = []
    for line in lines:
        if "http" in line or "www." in line:
            updated_lines.append(line)
            continue
        for pattern, repl in replacements:
            line = pattern.sub(repl, line)
        updated_lines.append(line)

    new_content = "\n".join(updated_lines)
    if new_content != content:
        path.write_text(new_content, encoding="utf-8")
PY

cd "$TARGET_DIR"

git init -b main

git add .
git commit -m "Initial Codex repository scaffold"

echo "Repository created at $TARGET_DIR"
