{ stdenvNoCC
, lib
, autoPatchelfHook
, makeWrapper
, glib, gtk3, dbus, libX11, libXScrnSaver, libXcursor, libXrandr, libXrender
, libXi, libXt, pango, cairo, gdk-pixbuf, freetype, fontconfig
, alsa-lib, at-spi2-atk, at-spi2-core, libxkbcommon, wayland
, nss, nspr, libdrm, mesa, zlib
, sources  # kommt aus _sources/generated.nix
}:

stdenvNoCC.mkDerivation {
  pname = "zen-browser-stable-bin";
  version = sources.zen.version;
  src = sources.zen.src; # enthält bereits den korrekten Hash

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  buildInputs = [
    glib gtk3 dbus libX11 libXScrnSaver libXcursor libXrandr libXrender
    libXi libXt pango cairo gdk-pixbuf freetype fontconfig
    alsa-lib at-spi2-atk at-spi2-core libxkbcommon wayland
    nss nspr libdrm mesa zlib
  ];

  unpackCmd = "tar -xJf $src";

  installPhase = ''
  runHook preInstall

  # robustes Kopieren inkl. dotfiles; fall back ohne bash-Optionen:
  mkdir -p $out/lib/zen $out/bin $out/share/applications $out/share/icons/hicolor/128x128/apps

  # Variante A: mit bash nullglob/dotglob
  shopt -s nullglob dotglob
  cp -r ./* $out/lib/zen/

  # Wrapper
  makeWrapper $out/lib/zen/zen $out/bin/zen \
    --set-default MOZ_DISABLE_AUTO_SAFE_MODE 1 \
    --set-default MOZ_LEGACY_PROFILES 1 \
    --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
      glib gtk3 dbus libX11 libXScrnSaver libXcursor libXrandr libXrender
      libXi libXt pango cairo gdk-pixbuf freetype fontconfig
      alsa-lib at-spi2-atk at-spi2-core libxkbcommon wayland
      nss nspr libdrm mesa zlib
    ]}"

  # Desktop-Datei
  cat > $out/share/applications/zen-browser.desktop <<EOF
[Desktop Entry]
Name=Zen Browser (Stable)
GenericName=Web Browser
Exec=$out/bin/zen %U
Terminal=false
Type=Application
Icon=zen-browser
Categories=Network;WebBrowser;
StartupWMClass=Zen
MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;
EOF

  # Icon, Pfad kann je nach Upstream leicht variieren
  if [ -f $out/lib/zen/browser/chrome/icons/default/default128.png ]; then
    install -Dm444 $out/lib/zen/browser/chrome/icons/default/default128.png \
      $out/share/icons/hicolor/128x128/apps/zen-browser.png
  elif [ -f $out/lib/zen/browser/chrome/icons/default/default128.jpg ]; then
    install -Dm444 $out/lib/zen/browser/chrome/icons/default/default128.jpg \
      $out/share/icons/hicolor/128x128/apps/zen-browser.png
  fi

  runHook postInstall
'';


  meta = with lib; {
    description = "Zen Browser stable binary, wrapped for NixOS";
    homepage = "https://github.com/zen-browser/desktop";
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "zen";
  };
}
