#!/bin/bash
set -e
export NVM_DIR="/home/rot/.nvm"
source "$NVM_DIR/nvm.sh"
WORKDIR="/home/rot/deus-service"
VERSION_FILE="$WORKDIR/version"
ZIPFILE="$WORKDIR/update.zip"
VERSION_URL="https://api.ofsis.app/161c0393-9b45-406a-b3a9-1eae11a5e404"
ZIP_URL="https://api.ofsis.app/0ded29c9-1ddb-44be-ac65-8c0540595ab7"

cd "$WORKDIR" || exit 1

LOCAL_VERSION=""
if [ -f "$VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$VERSION_FILE")
fi

REMOTE_VERSION=$(curl -fs "$VERSION_URL" || true)

if [ -z "$REMOTE_VERSION" ]; then
    echo "⚠️ Remote version alınamadı, update atlanıyor"
    exit 0
fi

if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    echo "⬆️ Yeni sürüm bulundu: $REMOTE_VERSION"

    curl -fL "$ZIP_URL" -o "$ZIPFILE"
    unzip -o "$ZIPFILE" -d "$WORKDIR"
    rm -f "$ZIPFILE"

    echo "$REMOTE_VERSION" > "$VERSION_FILE"

    if [ -f "$WORKDIR/package.json" ]; then
        npm install --production
    fi

    echo "✅ Update tamamlandı"
else
    echo "✅ Zaten güncel"
fi
