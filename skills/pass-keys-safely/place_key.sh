#!/usr/bin/env bash
# Usage: place_key.sh NAME SEND_LINK ENV_FILE
# Opens a one-time Bitwarden Send link with the Bitwarden CLI and writes NAME=<key> into ENV_FILE.
# Prints only "placed NAME", never the key.
set +x
set -euo pipefail
name="${1:?NAME}"; link="${2:?SEND_LINK}"; envf="${3:?ENV_FILE}"
[[ "$name" =~ ^[A-Z_][A-Z0-9_]*$ ]] || { echo "bad NAME: use letters, digits, underscore" >&2; exit 2; }
command -v bw >/dev/null || { echo "install the Bitwarden CLI first: https://bitwarden.com/help/cli/" >&2; exit 2; }
[ -L "$envf" ] && { echo "ENV_FILE is a symlink: point at the real file" >&2; exit 2; }
if command -v git >/dev/null && git -C "$(dirname "$envf")" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
   && ! git -C "$(dirname "$envf")" check-ignore -q "$(basename "$envf")"; then
  echo "ENV_FILE is in a git repo and not ignored: add it to .gitignore first" >&2; exit 2
fi
errf="$(mktemp)"; tmp=""
cleanup() { rm -f "$errf"; [ -n "$tmp" ] && rm -f "$tmp"; return 0; }
trap cleanup EXIT
if ! key="$(bw send receive "$link" 2>"$errf")" || [ -z "$key" ]; then
  if grep -qiE 'not found|404|deleted|expired|max access' "$errf"; then
    echo "link already used or not found: treat the key as exposed, cancel it with the vendor, ask for a new one"
  else
    echo "could not open the link: check your connection and try once more"
  fi
  exit 1
fi
key="${key%$'\r'}"
if [[ ! "$key" =~ ^[[:graph:]]+$ || "$key" == *[\'\"\\\`\$]* ]]; then
  echo "key has spaces, quotes or line breaks, and the link is now used: ask for the key placed by hand or a new link" >&2; exit 3
fi
umask 077
touch "$envf"; chmod 600 "$envf"
tmp="$(mktemp "${envf}.XXXX")"
grep -v "^${name}=" "$envf" > "$tmp" || true
printf "%s='%s'\n" "$name" "$key" >> "$tmp"
mv "$tmp" "$envf"; tmp=""
unset key
echo "placed $name"
