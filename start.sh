#!/bin/bash

# Eğer isdown varsa çık
if [ -f "isdown" ]; then
  echo "Dosya zaten indirilmiş. İndirme atlanıyor."
  exit 0
fi

# İndirme URL'si
URL="http://192.168.1.20:3000/download-electron"

# Dosya adı (sunucudan gelen dosya)
FILENAME="deus.AppImage"

# İndir
echo "İndiriliyor: $URL"
curl -L -o "$FILENAME" "$URL"

# İndirme tamamlandı mı kontrol
if [ -f "$FILENAME" ]; then
  echo "İndirme tamamlandı."
  # isdown dosyasını oluştur
  touch isdown
  echo "isdown dosyası oluşturuldu."
else
  echo "İndirme başarısız!"
fi