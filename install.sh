#!/usr/bin/env bash
# Installs the `vt` command so you can run it like any normal Linux tool.
# Usage:
#   ./install.sh            # install for current user -> ~/.local/bin/vt
#   sudo ./install.sh -g    # install system-wide     -> /usr/local/bin/vt
#   ./install.sh -u         # uninstall (user)        (add sudo + -g for global)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC=""
GLOBAL=0
UNINSTALL=0
while [ $# -gt 0 ]; do
  case "$1" in
    -g) GLOBAL=1 ;;
    -u) UNINSTALL=1 ;;
    -f) shift; SRC="${1:-}" ;;   # -f /path/to/script  (any filename works)
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# Auto-detect the script if -f wasn't given (vt, vt.py, VT_.py ... case-insensitive)
if [ -z "$SRC" ]; then
  for name in vt vt.py VT_.py VT.py; do
    [ -f "$HERE/$name" ] && SRC="$HERE/$name" && break
  done
fi
if [ -z "$SRC" ]; then
  SRC="$(find "$HERE" -maxdepth 1 -type f -iname 'vt*' ! -name '*.sh' | head -n1)"
fi

if [ "$GLOBAL" -eq 1 ]; then DEST_DIR="/usr/local/bin"; else DEST_DIR="$HOME/.local/bin"; fi
DEST="$DEST_DIR/vt"

if [ "$UNINSTALL" -eq 1 ]; then
  rm -f "$DEST" && echo "[+] Removed $DEST"
  exit 0
fi

command -v python3 >/dev/null || { echo "[!] python3 is required"; exit 1; }
[ -n "$SRC" ] && [ -f "$SRC" ] || {
  echo "[!] Cannot find the script next to install.sh."
  echo "    Run: ./install.sh -f /path/to/your/script.py"
  exit 1
}
echo "[*] Using $SRC"

mkdir -p "$DEST_DIR"
install -m 755 "$SRC" "$DEST"
echo "[+] Installed to $DEST"

case ":$PATH:" in
  *":$DEST_DIR:"*) ;;
  *)
    echo "[!] $DEST_DIR is not in your PATH. Add this line to ~/.bashrc or ~/.zshrc:"
    echo "      export PATH=\"$DEST_DIR:\$PATH\""
    echo "    then run: source ~/.bashrc   (or restart your terminal)"
    ;;
esac

echo
echo "Next: add your API key, then try it:"
echo "      vt config set-key YOUR_API_KEY"
echo "      vt domain example.com"
echo "      vt --help"
