inputs: {
  imports = inputs.self.lib.mkImports [
    ./tritanium-control-center.nix
    ./tritanium-shell.nix
  ];
}
