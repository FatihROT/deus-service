#!/bin/bash
set -e

WORKDIR="/home/redorigin/deus-service"
USER_NAME="redorigin"

echo "🚀 Deus servis kurulumu başlıyor..."

# -------------------------
# updater.service
# -------------------------
echo "🧱 updater.service yazılıyor..."

sudo tee /etc/systemd/system/updater.service > /dev/null <<EOF
[Unit]
Description=Deus Updater
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash $WORKDIR/updater.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# -------------------------
# backend.service
# -------------------------
echo "🧱 backend.service yazılıyor..."

sudo tee /etc/systemd/system/backend.service > /dev/null <<EOF
[Unit]
Description=Deus Backend
After=updater.service
Requires=updater.service

[Service]
Type=simple
User=root
WorkingDirectory=$WORKDIR
ExecStart=/bin/bash $WORKDIR/backend.sh
Restart=always
RestartSec=3
TimeoutStartSec=90

[Install]
WantedBy=multi-user.target
EOF

# -------------------------
# Kiosk (Electron + X)
# -------------------------
echo "🖥️ Kiosk (Electron) kuruluyor..."

# LightDM kapat
# sudo systemctl disable lightdm 2>/dev/null || true
# sudo systemctl set-default multi-user.target

# TTY1 login'i kapat (çok önemli)
# sudo systemctl disable getty@tty1.service 2>/dev/null || true
# sudo systemctl mask getty@tty1.service

# -------------------------
# deus-kiosk.service
# -------------------------
echo "🧱 deus-kiosk.service yazılıyor..."

sudo tee /etc/systemd/system/deus-kiosk.service > /dev/null <<EOF
[Unit]
Description=Deus Electron Kiosk
After=network.target
Conflicts=getty@tty1.service

[Service]
User=$USER_NAME
TTYPath=/dev/tty1
StandardInput=tty
StandardOutput=journal
StandardError=journal
ExecStart=/usr/bin/startx /home/$USER_NAME/.xinitrc -- :0 vt1
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

# -------------------------
# .xinitrc
# -------------------------
echo "🧾 .xinitrc oluşturuluyor..."

sudo tee /home/$USER_NAME/.xinitrc > /dev/null <<EOF
#!/bin/bash

xset -dpms
xset s off
xset s noblank

# ekran rotasyonu
xrandr --output DSI-1 --rotate left 2>/dev/null || \
xrandr --output DSI-0 --rotate left

# touch
xinput set-prop 6 'Coordinate Transformation Matrix' 1 0 0 0 1 0 0 0 1 || true

cd $WORKDIR || exit 1

exec ./deus.AppImage \\
  --no-sandbox \\
  --disable-gpu \\
  --kiosk
EOF

sudo chown $USER_NAME:$USER_NAME /home/$USER_NAME/.xinitrc
sudo chmod +x /home/$USER_NAME/.xinitrc
echo "🔓 Çalışma klasörü izinleri ayarlanıyor..."
sudo chmod -R 777 $WORKDIR


# -------------------------
# systemd reload
# -------------------------
echo "🔄 systemd reload..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# -------------------------
# enable servisler
# -------------------------
echo "✅ Servisler enable ediliyor..."
sudo systemctl enable updater.service
sudo systemctl enable backend.service
sudo systemctl enable deus-kiosk


# -------------------------
# start servisler
# -------------------------
echo "▶️ Servisler başlatılıyor..."
sudo systemctl start updater.service
sudo systemctl start backend.service

echo "🎉 TÜM SERVİSLER KURULDU VE ÇALIŞIYOR"
echo "🔁 Reboot sonrası otomatik başlayacaklar"
