{
  ags,
  bun,
  gammastep,
  grim,
  libnotify,
  tritanium-control-center,
  sassc,
  swaynotificationcenter,
  writeShellApplication,
  wl-clipboard,
  adwaita-icon-theme,
  libdbusmenu-gtk3,
  agsConfig ? ../../ags,
}:
writeShellApplication rec {
  name = "tritanium-shell";

  runtimeInputs = [
    ags
    bun
    gammastep
    grim
    libnotify
    tritanium-control-center
    sassc
    swaynotificationcenter
    wl-clipboard
    adwaita-icon-theme
    libdbusmenu-gtk3
  ];

  text = ''
    export XDG_DATA_DIRS=$XDG_DATA_DIRS:${adwaita-icon-theme}/share
    export GI_TYPELIB_PATH=${libdbusmenu-gtk3}/lib/girepository-1.0
    exec ags -c ${agsConfig}/config.js -b tritanium-shell "$@"
  '';

  derivationArgs.passthru.packages = runtimeInputs;
}
