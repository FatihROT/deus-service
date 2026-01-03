#!/bin/bash

# -----------------------
# Ayarlar
# -----------------------
WORKDIR="/home/rot/Desktop/deus-service"
VERSION_FILE="$WORKDIR/version"
ZIPFILE="$WORKDIR/deus.zip"
VERSION_URL="http://192.168.1.20:3000/161c0393-9b45-406a-b3a9-1eae11a5e404"
ZIP_URL="http://192.168.1.20:3000/0ded29c9-1ddb-44be-ac65-8c0540595ab7"
APPFILE="$WORKDIR/deus.AppImage"
SERVICE_NAME="deus-updater.service"

# Dizin kontrolü
cd "$WORKDIR" || exit

# -----------------------
# 1️⃣ Version kontrol ve zip indir
# -----------------------
if [ -f "$VERSION_FILE" ]; then
    LOCAL_VERSION=$(cat "$VERSION_FILE")
else
    LOCAL_VERSION=""
fi

REMOTE_VERSION=$(curl -s "$VERSION_URL")

if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    echo "Yeni sürüm var. Güncelleniyor..."
    [ -f "$ZIPFILE" ] && rm -f "$ZIPFILE"
    curl -L --fail -o "$ZIPFILE" "$ZIP_URL"
    unzip -o "$ZIPFILE" -d "$WORKDIR"
    rm -f "$ZIPFILE"
    echo "$REMOTE_VERSION" | tee "$VERSION_FILE" > /dev/null
    echo "Güncelleme tamamlandı."
else
    echo "Zaten güncel."
fi

# -----------------------
# 2️⃣ npm install
# -----------------------
if [ -f "$WORKDIR/package.json" ]; then
    echo "npm install çalıştırılıyor..."
    npm install
fi

# -----------------------
# 3️⃣ npm start (background)
# -----------------------
if [ -f "$WORKDIR/package.json" ]; then
    echo "npm start başlatılıyor..."
    # Önce eski süreci sonlandır (opsiyonel ama sağlıklı)
    pkill -f "npm start" || true
    nohup npm start > "$WORKDIR/npm.log" 2>&1 &
fi



# -----------------------
# 5️⃣ Kendini systemd servisi olarak ekle
# -----------------------
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"

if [ ! -f "$SERVICE_FILE" ]; then
    echo "Servis oluşturuluyor: $SERVICE_NAME"

    # Type=forking seçildi çünkü nohup ile arka plana süreç atıyoruz
    sudo tee "$SERVICE_FILE" > /dev/null <<EOL
[Unit]
Description=Deus Updater Script
After=network.target graphical.target

[Service]
Type=forking
ExecStart=/bin/bash $WORKDIR/start.sh
User=$(whoami)
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/$(whoami)/.Xauthority
WorkingDirectory=$WORKDIR
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

    sudo systemctl daemon-reload
    sudo systemctl enable "$SERVICE_NAME"
    echo "Servis oluşturuldu ve enable edildi."
    sudo reboot
else
    echo "Servis zaten mevcut."
    sudo bash $WORKDIR/start-electron.sh
fi

echo "Tüm işlemler tamamlandı."

