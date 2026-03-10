#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR='deploy'
KEY_ENV='RECREATE_KEY'

if [ -e "$ROOT_DIR" ]; then
  echo "Target directory already exists: $ROOT_DIR"
  exit 1
fi

decode_base64() {
  if base64 -d </dev/null >/dev/null 2>&1; then
    base64 -d
  else
    base64 -D
  fi
}

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required to decrypt this archive."
  exit 1
fi
if [ -z "${!KEY_ENV:-}" ]; then
  read -r -s -p "Enter decryption key: " RECREATE_KEY
  echo ""
else
  RECREATE_KEY="${!KEY_ENV}"
fi

TMP_ENC="$TMP_DIR/payload.enc"
TMP_TAR="$TMP_DIR/payload.tar.gz"
cat <<'PAYLOAD_EOF' | decode_base64 > "$TMP_ENC"
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
PAYLOAD_EOF

RECREATE_KEY="$RECREATE_KEY" openssl enc -d -aes-256-cbc -pbkdf2 -salt \
  -in "$TMP_ENC" -out "$TMP_TAR" -pass env:RECREATE_KEY
tar -xzf "$TMP_TAR"
