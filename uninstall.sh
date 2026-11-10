#!/data/data/com.termux/files/usr/bin/bash
set -e
TARGET="${PREFIX:-/data/data/com.termux/files/usr}/bin/danish"

echo "This removes the installed DANISH command only."
echo "It does not delete /data/local/tmp/danish.sh or other TMP files."
read -r -p "Type REMOVE to continue: " answer

if [ "$answer" = "REMOVE" ]; then
  rm -f "$TARGET"
  echo "DANISH ARMY ROOT SUITE uninstalled."
else
  echo "Uninstall cancelled."
fi
