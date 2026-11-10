#!/data/data/com.termux/files/usr/bin/bash
set -e
REPO_RAW="https://raw.githubusercontent.com/freefire6872349325-bit/DANISH-ARMY-ROOT-SUITE/main"
TARGET="${PREFIX:-/data/data/com.termux/files/usr}/bin/danish"
TMP="$HOME/.danish-manager-update.tmp"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl missing. Install it with: pkg install curl"
  exit 1
fi

echo "Checking DANISH ARMY ROOT SUITE update..."
if ! curl -fL --retry 2 "$REPO_RAW/danish-army-manager.sh" -o "$TMP"; then
  rm -f "$TMP"
  echo "Update download failed. Confirm the GitHub repository and main branch."
  exit 1
fi

if [ ! -s "$TMP" ] || ! head -n 1 "$TMP" | grep -q 'bash'; then
  rm -f "$TMP"
  echo "Invalid update file. Existing installation was not changed."
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"
install -m 700 "$TMP" "$TARGET"
rm -f "$TMP"
echo "DANISH ARMY ROOT SUITE updated."
