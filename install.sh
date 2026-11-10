#!/data/data/com.termux/files/usr/bin/bash
set -e
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SOURCE_DIR/danish-army-manager.sh"
TARGET="$PREFIX/bin/danish"

if [ ! -f "$SOURCE" ]; then
  echo "Manager script missing. Keep install.sh beside danish-army-manager.sh."
  exit 1
fi

mkdir -p "$PREFIX/bin"
install -m 700 "$SOURCE" "$TARGET"

echo
echo "DANISH ARMY ROOT SUITE installed successfully."
echo "Launch it with: danish"
echo "Root access is required for TMP management."
echo "For panel download, install curl if needed: pkg install curl"
