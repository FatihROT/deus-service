#!/bin/bash

# Ayarlar
VERSION_FILE="version"
APPFILE="deus.AppImage"
VERSION_URL="http://192.168.1.20:3000/electron-version"        # sunucudaki version dosyası
APP_URL="http://192.168.1.20:3000/download-electron"  # AppImage URL
WORKDIR=$(pwd)

echo "Çalışma dizini: $WORKDIR"

# -----------------------
# 1️⃣ Version kontrol
# -----------------------
if [ -f "$VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$VERSION_FILE")
    echo "Local version: $LOCAL_VERSION"
else
    echo "Version dosyası yok. İlk indiriliyor..."
    LOCAL_VERSION=""
fi

REMOTE_VERSION=$(curl -s "$VERSION_URL")
echo "Remote version: $REMOTE_VERSION"

if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    echo "Yeni sürüm bulundu! Güncelleniyor..."
    [ -f "$APPFILE" ] && rm -f "$APPFILE"
    
    curl -L --fail -o "$APPFILE" "$APP_URL"
    chmod +x "$APPFILE"
    
    echo "$REMOTE_VERSION" > "$VERSION_FILE"
    echo "Güncelleme tamamlandı: $APPFILE"
else
    echo "Zaten en güncel sürüm. İndirme atlanıyor."
fi

# -----------------------
# 2️⃣ npm install
# -----------------------
if [ -f "package.json" ]; then
    echo "npm install çalıştırılıyor..."
    npm install
else
    echo "package.json bulunamadı, npm install atlanıyor."
fi

# -----------------------
# 3️⃣ npm start
# -----------------------
if [ -f "package.json" ]; then
    echo "npm start çalıştırılıyor..."
    npm start &
else
    echo "package.json bulunamadı, npm start atlanıyor."
fi

# -----------------------
# 4️⃣ AppImage çalıştır
# -----------------------
if [ -f "$APPFILE" ]; then
    echo "AppImage çalıştırılıyor..."
    ./"$APPFILE" &
else
    echo "AppImage bulunamadı, çalıştırma atlanıyor."
fi

echo "Tüm işlemler tamamlandı."
