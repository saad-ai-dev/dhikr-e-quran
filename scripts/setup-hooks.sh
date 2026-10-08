#!/bin/bash
# Setup git hooks for the project

HOOK_DIR=".git/hooks"

cat > "$HOOK_DIR/pre-commit" << 'HOOK'
#!/bin/bash
echo "Running dart format check..."
dart format --output=none --set-exit-if-changed lib/ 2>/dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: Code is not formatted. Run 'dart format lib/' to fix."
  exit 1
fi

echo "Running flutter analyze..."
flutter analyze --no-fatal-infos lib/ 2>/dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: Analysis errors found. Fix them before committing."
  exit 1
fi

echo "Pre-commit checks passed."
HOOK

chmod +x "$HOOK_DIR/pre-commit"

cat > "$HOOK_DIR/commit-msg" << 'HOOK'
#!/bin/bash
# Enforce commit message format: lowercase first word, under 72 chars
MSG=$(head -1 "$1")
if [ ${#MSG} -gt 72 ]; then
  echo "ERROR: Commit message first line must be under 72 characters (currently ${#MSG})."
  exit 1
fi
HOOK

chmod +x "$HOOK_DIR/commit-msg"

echo "Git hooks installed successfully."
