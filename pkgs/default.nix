inputs:
# An overlay of all the packages exported by the flake.
final: prev: rec {
  tritanium-control-center = final.callPackage ./tritanium-control-center {
    inherit (inputs.self.lib) readPatches;
  };
  tritanium-shell = final.callPackage ./tritanium-shell {
    inherit tritanium-control-center;
  };
}
