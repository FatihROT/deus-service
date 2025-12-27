#!/bin/bash

# Ayarlar
VERSION_FILE="version"
APPFILE="deus.AppImage"
VERSION_URL="http://192.168.1.20:3000/electron-version"        # sunucudaki version dosyası
APP_URL="http://192.168.1.20:3000/download-electron"  # AppImage URL

# Local version var mı kontrol et
if [ -f "$VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$VERSION_FILE")
    echo "Local version: $LOCAL_VERSION"
else
    echo "Version dosyası yok. İlk indiriliyor..."
    LOCAL_VERSION=""
fi

# Remote version al
REMOTE_VERSION=$(curl -s "$VERSION_URL")
echo "Remote version: $REMOTE_VERSION"

# Version farklı mı?
if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    echo "Yeni sürüm bulundu! Güncelleniyor..."
    # Eski AppImage varsa sil
    [ -f "$APPFILE" ] && rm -f "$APPFILE"
    
    # Yeni AppImage indir
    curl -L --fail -o "$APPFILE" "$APP_URL"
    chmod +x "$APPFILE"

    # Version dosyasını güncelle
    echo "$REMOTE_VERSION" > "$VERSION_FILE"
    echo "Güncelleme tamamlandı: $APPFILE"
else
    echo "Zaten en güncel sürüm. İndirme atlanıyor."
fi