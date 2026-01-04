#!/bin/bash

# Çalışma dizinine git
cd /home/rot/deus-service || exit
chmod +x deus.AppImage

# X sunucusunu başlat ve içinde komutları çalıştır
# xinit kullanımı: xinit [uygulama] -- [X sunucusu ayarları]
xinit /bin/bash -c "
  xrandr --output DSI-1 --rotate left 2>/dev/null || xrandr --output DSI-0 --rotate left;
  xinput set-prop 6 'Coordinate Transformation Matrix' 0 -1 1 1 0 0 0 0 1;
  ./deus.AppImage --no-sandbox --disable-gpu --disable-software-rasterizer > app1.log 2>&1
" -- :0