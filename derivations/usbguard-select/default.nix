{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "usbguard-select";
  version = "1.0.3";

  dontUnpack = true;

  nativeBuildInputs = with pkgs; [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    mkdir -p $out/bin

    cat > $out/bin/usbguard-select <<'EOF'
    #!${pkgs.runtimeShell}
    set -euo pipefail

    MENU="''${1:-fzf}"

    devices="$(
      ${pkgs.usbguard}/bin/usbguard list-devices | \
        ${pkgs.gawk}/bin/awk '
          $2 == "block" &&
          match($0, /^([0-9]+):/, m) &&
          match($0, /name "([^"]+)"/, n) &&
          n[1] != "" &&
          n[1] !~ /xHCI Host Controller/ {
            printf "%s\t%s\n", m[1], n[1]
          }
        '
    )"

    [ -z "$devices" ] && {
      echo "No matching USB devices found"
      exit 1
    }

    case "$MENU" in
      rofi)
        selected="$(
          printf '%s\n' "$devices" | \
            ${pkgs.rofi}/bin/rofi \
              -dmenu \
              -i \
              -p "USB Device"
        )"
        ;;
      fzf|*)
        selected="$(
          printf '%s\n' "$devices" | \
            ${pkgs.fzf}/bin/fzf \
              --prompt="USB Device > " \
              --with-nth=2 \
              --delimiter=$'\t' \
              --height=40% \
              --border
        )"
        ;;
    esac

    [ -z "$selected" ] && exit 1

    id="$(printf '%s\n' "$selected" | ${pkgs.coreutils}/bin/cut -f1)"

    exec ${pkgs.usbguard}/bin/usbguard allow-device "$id"
    EOF

    chmod +x $out/bin/usbguard-select

    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/scalable/apps

    cp ${./usbguard-select.svg} $out/share/icons/hicolor/scalable/apps/usbguard-select.svg

    cat > $out/share/applications/usbguard-select.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=USBGuard Select
    Comment=Authorize USB devices via USBGuard
    Exec=$out/bin/usbguard-select rofi
    Icon=usbguard-select
    Categories=System;Security;
    Terminal=false
    EOF
  '';
}
