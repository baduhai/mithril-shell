inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (inputs) self;
  inherit (pkgs.hostPlatform) system;

  cfg = config.programs.tritanium-control-center;

  target = "tritanium-control-center";

  mkService = exec: {
    Unit = {
      Description = "${target} compatibility service";
      PartOf = "${target}.target";
    };

    Service = {
      ExecStart = exec;
      Restart = "on-failure";
    };

    Install.WantedBy = [
      "${target}.target"
    ];
  };
in
{
  options.programs.tritanium-control-center = with lib; {
    enable = mkOption {
      type = types.bool;
      default = config.services.tritanium-shell.enable;
      description = ''
        Enable tritanium-control-center, a patched version of gnome-control-center.

        Patches include improving compatibility outside of GNOME and hiding unsupported and/or
        extraneous settings.
      '';
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = self.packages.${system}.tritanium-control-center;
      defaultText = lib.literalExpression "inputs.tritanium-shell.packages.\${system}.default";
      description = ''
        The tritanium-control-center package to use.
      '';
    };

    compatibility = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable various services to improve compatibility of various aspects of the control center
          app.
        '';
      };

      bluetooth = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to enable gnome-settings-daemon's rfkill service, allowing the bluetooth panel to
            be used.
          '';
        };

        package = mkOption {
          type = types.package;
          default = inputs.nixpkgs.legacyPackages.${system}.gnome-settings-daemon;
          description = ''
            Where to find the `libexec/gsd-rfkill` binary.
          '';
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [
      cfg.package
    ];

    systemd.user = lib.mkIf cfg.compatibility.enable {
      targets.${target} = {
        Unit.description = ''
          A group of services to complement tritanium-control-center.
        '';

        Install.WantedBy = [
          "tritanium-shell.service"
        ];
      };

      services.gsd-rfkill = lib.mkIf cfg.compatibility.bluetooth.enable (
        mkService "${cfg.compatibility.bluetooth.package}/libexec/gsd-rfkill"
      );
    };
  };
}
