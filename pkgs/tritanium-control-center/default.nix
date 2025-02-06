{
  gnome-control-center,
  readPatches,
}:
gnome-control-center.overrideAttrs (old: {
  pname = "tritanium-control-center";

  patches = old.patches ++ (readPatches ./.);

  postFixup = ''
    for i in $out/share/applications/*; do
      substituteInPlace $i --replace "Exec=$out/bin/gnome-control-center" "Exec=$out/bin/tritanium-control-center"
    done
    mv $out/bin/gnome-control-center $out/bin/tritanium-control-center
  '';

  doCheck = false;

  meta.mainProgram = "tritanium-control-center";
})
