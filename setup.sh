#!/bin/bash
set -e

# NVM yüklü mü kontrol et
if [ -z "$NVM_DIR" ] || [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo "🟢 NVM bulunamadı, kuruluyor..."
    export NVM_DIR="$HOME/.nvm"

    # NVM indir ve kur
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

    # Shell içinde aktif et
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Node.js kur
    nvm install 20

    # Export'ları bashrc'ye ekle (tekrar eklenmesin diye kontrol edelim)
    grep -qxF 'export NVM_DIR="$HOME/.nvm"' ~/.bashrc || echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    grep -qxF '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' ~/.bashrc || echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
    grep -qxF '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' ~/.bashrc || echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

    echo "✅ NVM ve Node.js kuruldu ve bashrc'ye eklendi."
else
    echo "ℹ️ NVM zaten kurulmuş."
    # Eğer istersen buraya Node.js güncelleme veya versiyon switch ekleyebilirsin
fi

# Node ve npm versiyonlarını göster
node -v
npm -v

CONFIG_FILE="/boot/firmware/config.txt"

# --- Eski SPI ve UART satırlarını temizle ---
sudo sed -i '/^#*dtparam=spi=/d' "$CONFIG_FILE"
sudo sed -i '/^#*dtparam=uart0=/d' "$CONFIG_FILE"

# --- SPI ve UART'ı aç ---
echo "dtparam=spi=on" | sudo tee -a "$CONFIG_FILE"
echo "dtparam=uart0=on" | sudo tee -a "$CONFIG_FILE"

echo "✅ SPI ve UART0 açıldı. /dev/spi* ve /dev/serial0 ile kontrol edebilirsiniz."
echo "⚠️ Değişikliklerin kalıcı olması için reboot önerilir: sudo reboot"