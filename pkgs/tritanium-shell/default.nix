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
  ];

  text = ''
    XDG_DATA_DIRS=$XDG_DATA_DIRS:${adwaita-icon-theme}/share
    exec ags -c ${agsConfig}/config.js -b tritanium-shell "$@"
  '';

  derivationArgs.passthru.packages = runtimeInputs;
}
